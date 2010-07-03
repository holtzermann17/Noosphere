package Noosphere;
use strict;

use Noosphere::Email;
use URI::Escape;


# get a hash of notice IDs for a user
# 
sub getNoticeIDHash {
	my $userid = shift;

	my %ids;
	
	my $notices = getConfig('notice_tbl');

	my $sth = $dbh->prepare("select uid from $notices where userid = ?");
	$sth->execute($userid);

	while (my $row = $sth->fetchrow_arrayref()) {
		$ids{$row->[0]} = 1;
	}
	$sth->finish();

	return %ids;
}

# delete notices that point to an object (usually one which is being deleted)
#
sub deleteNotices {
	my $table = shift;
	my $objectid = shift;

	my $olinks = getConfig('olinks_tbl');
	my $notices = getConfig('notice_tbl');

	# get a list of notices which have object links pointing to the target object
	#
	my $sth = $dbh->prepare("select srcid from $olinks where desttbl = '$table' and destid = $objectid");
	$sth->execute();
	my @notices;
	while (my $row = $sth->fetchrow_arrayref()) {
		push @notices, $row->[0];
	}
	$sth->finish();

	# now delete the object links
	#
	$dbh->do("delete from $olinks where desttbl = '$table' and destid = $objectid");

	# now delete notices
	#
	if (@notices) {
		$dbh->do("delete from $notices where uid in (".join(', ',@notices).")");
	}
}

# file a "prompt" notice
#
sub filePrompt {
	my $userto = shift;
	my $userfrom = shift;
	my $subject = shift; 
	my $comment = shift;
	my $default = shift;
	my $choices = shift;	# should be an array of [title, url] arrays
	my $context = shift;	# should be an array of {id, table} hashes
	
	insertNotice($userto, $userfrom, $subject, "$comment	Please select an option:", $context, $default, $choices);
}

# file a notice.. also makes context links
#
sub fileNotice {
	my $userto = shift;
	my $userfrom = shift;
	my $subject = shift;
	my $remark = shift || '';
	my $context = shift;	# should be an array of {id,table} hashes.
	
	insertNotice($userto, $userfrom, $subject, $remark, $context);
}

# low-level notice insert routine
#
sub insertNotice {
	my $userto = shift;
	my $userfrom = shift;
	my $subject = shift;	
	my $remark = shift;
	my $context = shift;	# should be an array of {id,table} hashes.
	my $default = shift;
	my $choices = shift;	# should be an array of [title, url] arrays
	
	my $title_line = '';
	my $action_line = '';
	
	# compress title/action line
	#
	if (defined $choices) {
		$title_line = join (';',(map $_->[0], @$choices));
		$action_line = join (';',(map urlescape($_->[1]), @$choices));
		if (not defined $default) {
			$default = "'null'";
		}
	}

	# get the insert id so we can return it
	#
	my $id = nextval('notices_uid_seq');

	# file the notice
	#
	if (defined $choices && scalar @$choices > 0) {
		# prompt notice
		my ($rv,$sth) = dbInsert($dbh,{
			INTO => 'notices',
			COLS => 'created,uid,userid,userfrom,title,data,choice_default,choice_title,choice_action',
			VALUES => "now(),$id,$userto,$userfrom,'".sq($subject)."','".sq($remark)."',".$default.",'".sq($title_line)."','".sq($action_line)."'"});
		$sth->finish();
	} else {
		# informative notice
		my ($rv,$sth) = dbInsert($dbh,{
			INTO => 'notices',
			COLS => 'created,uid,userid,userfrom,title,data',
			VALUES => "now(),$id,$userto,$userfrom,'".sq($subject)."','".sq($remark)."'"});
		$sth->finish();
	}

	my @context_titles; 
	my @context_urls;
	my $root = getConfig('main_url');
	
	# make context links
	#
	foreach my $link (@$context) {
		my $title = lookupfield($link->{'table'},'title',"uid=$link->{id}");
		if (!$title) {	 # maybe the field is named "subject"
			$title = lookupfield($link->{'table'},'subject',"uid=$link->{id}");
		}
		makeObjLink('notices',$id,$link->{'table'},$link->{'id'},$title || "[$link->{id}:$link->{table}]");

		push @context_titles, $title;
		push @context_urls, contextURL($link->{'table'},$link->{'id'});
	}

	# send a parallel email notice if the user pref is on.
	#
	my %touserinf = userInfoById($userto);
	if ($touserinf{'prefs'}->{'noticeemail'} eq 'on') {
	
		my $userfromname = lookupfield(getConfig('user_tbl'), 'username', "uid=$userfrom");

		my $proj = getConfig('projname');
		my $root = getConfig('main_url');

		my $subject = "$proj Notice: $subject";
		my $body = "$subject 
By user: $userfromname

$remark

";

		if (defined $choices) {
			$body .= "IMPORTANT: This is a prompt notice, which means it requires a response from you.
Please go to the URL below to respond.

";
		}

		if (@context_titles) {
			$body .= "Context:\n\n";

			for (my $i = 0; $i <= $#context_titles; $i++) {
				$body .= " $context_titles[$i]\n $context_urls[$i]\n\n";
			}
		}

		$body .= "For more details about this notice, go to $root/?op=notices

NOTE: You can turn these emails off (and still get web notices) by toggling
the corresponding option in your preferences ( $root/?op=editprefs ).
";
		
		sendMail($touserinf{'data'}->{'email'},$body,$subject);
	} 
}

# get the count of notices unviewed by user
#
sub getNoticeCount {
	my $userinf = shift;
	
	return -1 if ($userinf->{uid} < 1);

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'count(uid) as cnt',
	 FROM => 'notices',
	 WHERE => "userid=$userinf->{uid} and viewed=0"});

	return -1 if (!$rv);

	my $row = $sth->fetchrow_hashref();

	return $row->{'cnt'};
}

# exercise the default selection for prompt notices. returned HTML will be
# discarded.
#
sub noticeActivateDefault {
	my $userinf = shift;
	my $uid = shift;

	# grab the fields we need.
	#
	my ($rv, $sth) = dbSelect($dbh, {WHAT=>'choice_title, choice_action, choice_default', FROM=>getConfig('notice_tbl'), WHERE=>"uid=$uid"});

	my $row = $sth->fetchrow_hashref();
	$sth->finish();

	my $default = $row->{choice_default};

	# exercise the default
	#
	if (defined $default && $default != -1) {
		my $title = (split(';', $row->{choice_title}))[$default];
		my $action = (split(';', $row->{choice_action}))[$default];
	
		# "run" the action
		#
		dispatch({%HANDLERS}, paramsToHash($action), $userinf);
	}
}

# exercise all prompt notice defaults for a user before deleting notices
#
sub noticeActivateDefaults {
	my $userinf = shift;

	# select all notices for this user that have defaults we need to exercise
	#
	my ($rv, $sth) = dbSelect($dbh, {WHAT=>'uid', FROM=>getConfig('notice_tbl'), WHERE=>"userid=$userinf->{uid} and choice_default is not null and choice_default > -1"});
	my @rows = dbGetRows($sth);

	foreach my $row (@rows) {
		noticeActivateDefault($userinf, $row->{uid});
	}
}

# view notices
#
sub viewNotices {
	my $params = shift;
	my $userinf = shift;

	my $html = "";
	my ($rv,$sth);

	# handle deletions first
	
	if (defined $params->{'delsel'}) {
		foreach my $key (keys %$params) {
			if ($key =~ /^sel_([0-9]+)$/) {
				noticeActivateDefault($userinf, $1); # activate defaults
				($rv,$sth) = dbDelete($dbh,{FROM=>'notices',WHERE=>"uid=$1 and userid=$userinf->{uid}"});
			}
		}
	} 
	elsif (defined $params->{'delunsel'}) {
		# get list of all notices
		my %unsel = getNoticeIDHash($userinf->{'uid'});

		# delete from this list selected items
		foreach my $key (keys %$params) {
			if ($key =~ /^sel_([0-9]+)$/) {
				delete $unsel{$1};
			}
		}

		# delete remaining notices
		foreach my $uid (keys %unsel) {
			noticeActivateDefault($userinf, $uid); # activate defaults
			($rv,$sth) = dbDelete($dbh,{FROM=>'notices',WHERE=>"uid=$uid and userid=$userinf->{uid}"});
		}
	} 
	
	elsif (defined $params->{'delall'}) {
		noticeActivateDefaults($userinf);	 # activate defaults
		($rv,$sth) = dbDelete($dbh,{FROM=>'notices', WHERE=>"userid=$userinf->{uid}"});
	}

	# handle return message if we just exercised an option
	#
	if (defined $params->{'return_title'}) {
		if (blank($params->{'return_message'})) {
			$html .= "<b>$params->{return_title}</b> : Done.";
		}
		else {
			$html .= "<b>$params->{return_title}</b> : $params->{return_message}";
		}
		$html .= "<br><br>";
	}
	
	# display starts here
	#
	($rv,$sth) = dbSelect($dbh,{WHAT=>'*',FROM=>'notices',WHERE=>"userid=$userinf->{uid} and viewed=0",'ORDER BY'=>'created',DESC=>''});

	my @rows = dbGetRows($sth);

	if (scalar @rows == 0) {
		$html .= "No notices.<br>";
		return paddingTable(clearBox('Your Notices',$html));
	}

	$html .= "<form name=\"notices\" method=\"post\" action=\"/\">";

	$html .= "<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">";
	my $parity = 1;
	foreach my $row (@rows) {
		$html .= formatNotice($row, (($parity++%2)?'#eeeeee':'#ffffff'));
	}
	$html .= "</table>";

	$html .= "<br><center>";
	$html .= " <input type=\"button\" value=\"select all\" onClick=\"var c = 0, _el; for (c = 0; c < document.notices.elements.length; c++) { _el = document.notices.elements[c]; if (_el.type == 'checkbox') { _el.checked = true; } } \">";
	$html .= " <input type=\"reset\" value=\"select none\">";
	$html .= "<br><br>";
	$html .= " <input type=\"submit\" name=\"delsel\" value=\"delete selected\">";
	$html .= " <input type=\"submit\" name=\"delall\" value=\"delete all\">";
	$html .= " <input type=\"submit\" name=\"delunsel\" value=\"delete all except\">";
	$html .= " <br>";
	$html .= "<input type=\"hidden\" name=\"op\" value=\"notices\">";
	$html .= "</form>";
	$html .= "</center>";

	return paddingTable(clearBox('Your Notices',$html));
}

# format a notice for display in list
#
sub formatNotice {
	my $row = shift;
	my $colour = shift;

	my $html = "";
	
	$html .= "<tr>";
	$html .= "<td bgcolor=\"$colour\">";
	$html .= "<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">";

	# selection checkbox
	#
	$html .= "<tr><td>";
	$html .= "<input type=\"checkbox\" name=\"sel_$row->{uid}\">";
 
	# display basic info line
	#
	if (defined $row->{'userfrom'}) {
		my $username = lookupfield('users','username',"uid=$row->{userfrom}");
		$html .= "$row->{title} from <a href=\"".getConfig("main_url")."/?op=getuser&id=$row->{userfrom}\">$username</a> at $row->{created}";
	} else {
		$html .= "$row->{title} at $row->{created}";
	}
	$html .= "</td>";

	# comment/content, if present
	#
	if (nb($row->{'data'})) {
		$html .= "<tr>";
		$html .= "<td><i>".tohtmlascii($row->{'data'})."</i></td>";
		$html .= "</tr>";
	}

	# options, if present
	#
	if (nb($row->{'choice_title'})) {

		$html .= "<tr><td align=\"center\">";
	
		my @titles = split (';', $row->{'choice_title'});
		my @actions = split (';', $row->{'choice_action'});
 		my $default = $row->{'choice_default'};

		$html .= "<br>Your choices: ";

		# make action "buttons"
		#
		my @buttons;
		for (my $i = 0; $i < scalar @titles; $i++) {
			# each action had better already be urlescaped
			push @buttons, "<a href=\"".getConfig("main_url")."/?op=exercise_option&return_title=".urlescape($titles[$i])."&delsel=1&sel_$row->{uid}=on&params=$actions[$i]\">$titles[$i]</a>";
		}

		$html .= "[ ".join(' | ', @buttons)." ]";

		$html .= "</td></tr>";
	
		# default message
		#
		$html .= "<tr><td align=\"center\"><br>";
		if (defined $default && $default != -1) {
			$html .= "<i>The default choice (activated upon deletion) for this prompt is '$titles[$default]'</i>";
		} else {
			$html .= "<i>If you delete this notice, no action will be performed.</i>";
		}
		$html .= "</td></tr>";
	}

	# attached objects
	#
	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'*',FROM=>'objlinks',WHERE=>"srctbl='notices' and srcid=$row->{uid}"});
	my @links = dbGetRows($sth);
	if ($#links >= 0) {
		$html .= "<tr><td>Context: ";
		my @linkhtml = ();
		foreach my $link (@links) {
			my ($op,$from) = getop($link->{'desttbl'});
			push @linkhtml, contextLink($link->{'desttbl'},$link->{'destid'},$link->{'note'});
		}
		$html .= join(', ',@linkhtml);
		$html .= "</td></tr>";
	}
	
	$html .= "</table></td></tr>";
 
	return $html;
}

# exercise a prompt option
#
sub exerciseOption {
	my $params = shift;
	my $userinf = shift;

	# get the new params to pass 
	#
	my $newparams = paramsToHash(urlunescape($params->{params}));
	
	# call the operation (we'd better have a $newparams->{op})
	#
	my $content = dispatch({%HANDLERS}, $newparams, $userinf);

	# add return result message
	#
	$params->{return_message} = $content;
	
	# view notices
	#
	return viewNotices($params, $userinf);
}

# make an object link
#
sub makeObjLink {
	my $srctbl = shift;
	my $srcid = shift;
	my $desttbl = shift;
	my $destid = shift;
	my $note = shift;

	my ($rv,$sth) = dbInsert($dbh,{INTO=>'objlinks',
		COLS=>'srctbl,srcid,desttbl,destid,note',
	VALUES=>"'".sq($srctbl)."',$srcid,'".sq($desttbl)."',$destid,'".sq($note)."'"});

	$sth->finish();
}

# make a generic context link - this is smart enough to make links to getobj
# objects and getmsg objects correctly (and can be generalized further)
#
sub contextLink {
	my $table = shift;
	my $objectid = shift;
	my $anchor = shift;

	my ($op, $from) = getop($table);
	if ($from ne '') {
		return "<a href=\"".getConfig("main_url")."/?op=$op&from=$table&id=$objectid\">$anchor</a>";
	} else {
		return "<a href=\"".getConfig("main_url")."/?op=$op&id=$objectid\">$anchor</a>";
	}
}

# same as above, but only return URL, not entire <A> tag.
#
sub contextURL {
	my $table = shift;
	my $objectid = shift;

	my ($op, $from) = getop($table);
	if ($from ne '') {
		return getConfig("main_url")."/?op=$op&from=$table&id=$objectid";
	} else {
		return getConfig("main_url")."/?op=$op&id=$objectid";
	}
}

# file a "prompt" notice
#
sub filePromptNew {
	my $userto = shift;
	my $userfrom = shift;
	my $subject = shift; 
	my $comment = shift;
	my $htmlemail = shift;
	my $textemail = shift;
	my $default = shift;
	my $choices = shift;	# should be an array of [title, url] arrays
	my $context = shift;	# should be an array of {id, table} hashes
	
	insertNoticeNew($userto, $userfrom, $subject, "$comment	Please select an option:", $htmlemail, $textemail, $context, $default, $choices);
}

# file a notice.. also makes context links
#
sub fileNoticeNew {
	my $userto = shift;
	my $userfrom = shift;
	my $subject = shift;
	my $notice = shift;
	my $htmlemail = shift;
	my $textemail = shift;
	my $context = shift;	# should be an array of {id,table} hashes.
	my $default = shift;
	my $choices = shift;
	
	insertNoticeNew($userto, $userfrom, $subject, $notice, $htmlemail, $textemail, $context, $default, $choices);
}

# low-level notice insert routine
#
sub insertNoticeNew {
	my $userto = shift;
	my $userfrom = shift;
	my $subject = shift;	
	my $remark = shift;
	my $htmlemail = shift;
	my $textemail = shift;
	my $context = shift;	# should be an array of {id,table} hashes.
	my $default = shift;
	my $choices = shift;	# should be an array of [title, url] arrays
	
	my $title_line = '';
	my $action_line = '';
	
	# compress title/action line
	#
	if (defined $choices) {
		$title_line = join (';',(map $_->[0], @$choices));
		$action_line = join (';',(map urlescape($_->[1]), @$choices));
		if (not defined $default) {
			$default = "'null'";
		}
	}

	# get the insert id so we can return it
	#
	my $id = nextval('notices_uid_seq');

	# file the notice
	#
	if (defined $choices && scalar @$choices > 0) {
		# prompt notice
		my ($rv,$sth) = dbInsert($dbh,{
			INTO => 'notices',
			COLS => 'created,uid,userid,userfrom,title,data,choice_default,choice_title,choice_action',
			VALUES => "now(),$id,$userto,$userfrom,'".sq($subject)."','".sq($remark)."',".$default.",'".sq($title_line)."','".sq($action_line)."'"});
		$sth->finish();
	} else {
		# informative notice
		my ($rv,$sth) = dbInsert($dbh,{
			INTO => 'notices',
			COLS => 'created,uid,userid,userfrom,title,data',
			VALUES => "now(),$id,$userto,$userfrom,'".sq($subject)."','".sq($remark)."'"});
		$sth->finish();
	}

	my @context_titles; 
	my @context_urls;
	my $root = getConfig('main_url');
	
	# make context links
	#
	foreach my $link (@$context) {
		my $title = lookupfield($link->{'table'},'title',"uid=$link->{id}");
		if (!$title) {	 # maybe the field is named "subject"
			$title = lookupfield($link->{'table'},'subject',"uid=$link->{id}");
		}
		makeObjLink('notices',$id,$link->{'table'},$link->{'id'},$title || "[$link->{id}:$link->{table}]");

		push @context_titles, $title;
		push @context_urls, contextURL($link->{'table'},$link->{'id'});
	}

	# send a parallel email notice if the user pref is on.
	#
	my %touserinf = userInfoById($userto);
	if ($touserinf{'prefs'}->{'noticeemail'} eq 'on') {
		my $proj = getConfig('projname');
		my $subject = "$proj Notice: $subject";

		sendMultipartMail(
			$touserinf{'data'}->{'email'},
			$subject,
			$textemail,
			$htmlemail	
			); 
	} 
}

1;

