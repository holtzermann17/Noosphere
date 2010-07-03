package Noosphere;
use strict;

use vars qw($reader);

# get and prepare the data for the latest messages RSS feed.
#
# this returns a structure of the form:
# 
# [ 
#	{dateheader1 => [
#		{objtitle1 => url},
#		{objtitle2 => url},
#		{objtitle3 => url},
#				... ]
#	},
#	{dateheader2 => [
#		{objtitle1 => url},
#		{objtitle2 => url},
#		{objtitle3 => url},
#				... ]
#	},
#	...
# ]
# 
sub getLatestMessages_RSS {
	my $prefix = shift;
	
	my ($rv, $sth);

	my $mtbl = getConfig('message_tbl');
	my $utbl = getConfig('user_tbl');
	
	($rv, $sth) = dbSelect($dbh, {WHAT=>"$mtbl.*, users.uid as userid, username, unix_timestamp($mtbl.created) as unixtime, dayofweek(created)-1 as dow, concat(extract(YEAR from created), '-', extract(MONTH from created), '-', extract(DAY from created)) as ymd", FROM=>"$mtbl, $utbl", WHERE=>"$mtbl.userid = $utbl.uid and $mtbl.visible = 1", 'ORDER BY'=>"$mtbl.created", DESC=>1, LIMIT=>getConfig('latest_messages')})
	if getConfig('dbms') eq 'mysql';

	($rv, $sth) = dbSelect($dbh, {WHAT=>"$mtbl.*, users.uid as userid, username, extract(EPOCH FROM created) as unixtime,  date_part('dow',created) as dow, date_part('year',created)||'-'||date_part('month',created)||'-'||date_part('day', created) as ymd", FROM=>"$mtbl, $utbl", WHERE=>"$mtbl.userid = $utbl.uid and $mtbl.visible = 1", 'ORDER BY'=>"$mtbl.created", DESC=>1, LIMIT=>getConfig('latest_messages')})
	if getConfig('dbms') eq 'pg';

	if (! $rv) {
		dwarn "latest message query error\n";
		return "query error";
	}
 
	my @rows = dbGetRows($sth);

	my @daystruct;
	
	my $date = '';
	my $daylist;

	my $pstr = '';
	$pstr = '(msg) ' if $prefix;

	foreach my $row (@rows) {

		# create a day list
		#
		my $day = dowtoa($row->{'dow'},'long');
		if ($row->{'ymd'} ne $date) {
			$date = $row->{'ymd'};
			my $dateheader = "$day, $date";
			$daylist = [];
			push @daystruct, {$dateheader => $daylist};
		}

		# create the new object entry and add to list for this day
		# 
		my $href = getConfig('main_url')."/?op=getmsg;amp;id=$row->{uid}";
		my $title = $pstr.$row->{'subject'};
		my $desc = $row->{'body'};

		# remove comment blocks from messages
		$desc =~ s/^>.*$//gm;

		# squeeze and normalize whitespace
		$desc =~ s/\s+/ /g;

		# try to gracefully truncate long messages
		if (length($desc) > 256) {
			$desc = substr($desc,0,256);
			$desc =~ s/\s+$//;
			$desc .= ' ...';
		}

		$desc =~ s/"/&quot;/g;
		$title =~ s/"/&quot;/g;

		# create the hash for the record
		my $displayname = getUserDisplayName( $row->{'userid'} );
		push @$daylist, {'title' => $title, 
			'link' => $href, 
			'author' => $displayname,
			'description' => htmlescape($desc), 
			'timestamp' => $row->{'unixtime'} };
	}

	# return a ref to the statistics
	return [@daystruct];
}

# ugly switch function to determine if an object has visible messages.  ah, 
# if only we had an OODBMS with a nice class hierarchy and polymorphism...
#
sub hasVisibleMessages {
	my $table = shift;
	my $objectid = shift;

	if ($table eq 'collab') {
	
		my $sth = $dbh->prepare("select published from collab where uid = $objectid");
		$sth->execute();

		my $row = $sth->fetchrow_arrayref();
		if (defined $row) {
			return $row->[0];
		} else {
			dwarn "object ($table, $objectid) missing?";
		}
		$sth->finish();
	}

	return 1;
}

# make non-visible messages for an object visible
#
sub revealMessages {
	my $table = shift;
	my $objectid = shift;

	my $mtbl = getConfig('message_tbl');

	my $sth = $dbh->prepare("update $mtbl set visible = 1 where tbl = '$table' and objectid = $objectid");
	my $rv = $sth->execute();
	$sth->finish();

	return $rv;	
}

# view messages chronologically
#
sub messagesChrono {
	my $params = shift;
	my $userinf = shift;

	my $mtbl = getConfig('message_tbl');
	my $utbl = getConfig('user_tbl');

	my $xml = '';
	my $template = new XSLTemplate('messageschrono.xsl');
	$params->{'offset'} = $params->{'offset'} || 0;
	my $limit = $userinf->{'prefs'}->{'pagelength'};
	
	# get total if needed
	#
	if (not defined $params->{'total'}) {
		$params->{'total'} = dbRowCount($mtbl);
	}

	# query up the messages in order
	#
	my ($rv, $sth) = dbSelect($dbh, {
		WHAT => "$mtbl.*, username, users.uid as userid", 
		FROM => "$mtbl, $utbl", 
		WHERE => "$mtbl.userid=$utbl.uid", 
		'ORDER BY' => "$mtbl.created", 
		DESC => 1,
		LIMIT => $limit,
		OFFSET => $params->{'offset'}
	});

	$template->addText('<messages>');

	while (my $row = $sth->fetchrow_hashref()) {

		my $date = mdhm($row->{'created'});
		my $title = htmlescape($row->{'subject'});
		my $username = getUserDisplayName($row->{'userid'});
		my $href = getConfig('main_url')."/?op=getmsg;amp;id=$row->{uid}";
		my $thref = getConfig('main_url')."/?op=getmsg;amp;id=$row->{threadid}";
		my $ohref = getConfig('main_url')."/?op=getobj;amp;from=$row->{tbl};amp;id=$row->{objectid}";
		my $uhref = getConfig('main_url')."/?op=getuser;amp;id=$row->{userid}";

		$xml .= "		<message>";
		$xml .= "			<date>$date</date>";
		$xml .= "			<title>$title</title>";
		$xml .= "			<username>$username</username>";
		$xml .= "			<href>$href</href>";
		$xml .= "			<thref>$thref</thref>";
		$xml .= "			<uhref>$uhref</uhref>";
		$xml .= "			<ohref>$ohref</ohref>";
		$xml .= "		</message>";
	}
	
	$template->addText($xml);
	$template->addText('</messages>');

	getPageWidgetXSLT($template, $params, $userinf);

	return $template->expand();
}

# callback for cached message XML
#
sub getLatestMessages_data {
	
	return getLatestMessagesXML();
}

# get XML data for most recent messages
#
sub getLatestMessagesXML {
	my $params = shift;
	my $userinf = shift;

	my $xml = '';

	# get latest messages
	#
	my $mtbl = getConfig('message_tbl');
	my $utbl = getConfig('user_tbl');
	my ($rv, $sth) = dbSelect($dbh, {WHAT=>"$mtbl.*, users.uid as userid, username", FROM=>"$mtbl, $utbl", WHERE=>"$mtbl.userid = $utbl.uid and $mtbl.visible = 1", 'ORDER BY'=>"$mtbl.created", DESC=>1, LIMIT=>getConfig('latest_messages')});

	$xml .= "	<messages>";

	while (my $row = $sth->fetchrow_hashref()) {

		my $date = mdhm($row->{'created'});
		my $title = htmlescape($row->{'subject'});
		my $username = getUserDisplayName($row->{'userid'});
		my $href = getConfig('main_url')."/?op=getmsg;amp;id=$row->{uid}";
		my $thref = getConfig('main_url')."/?op=getmsg;amp;id=$row->{threadid}";
		my $ohref = getConfig('main_url')."/?op=getobj;amp;from=$row->{tbl};amp;id=$row->{objectid}";
		my $uhref = getConfig('main_url')."/?op=getuser;amp;id=$row->{userid}";

		$xml .= "		<message>";
		$xml .= "			<date>$date</date>";
		$xml .= "			<title>$title</title>";
		$xml .= "			<username>$username</username>";
		$xml .= "			<href>$href</href>";
		$xml .= "			<thref>$thref</thref>";
		$xml .= "			<uhref>$uhref</uhref>";
		$xml .= "			<ohref>$ohref</ohref>";
		$xml .= "		</message>";
	}
	
	$sth->finish();

	$xml .= "	</messages>";
	
	return $xml;
}

# get some html which shows the count of messages posted to an object, and 
# the number which are new
#
sub msgCountWithNew {
	my $table = shift;
	my $objectid = shift;
	my $userid = shift;
	my $short = shift||1;		 # short format, just shows numbers

	my $total = getmsgcount($table,$objectid);
	my $unseen = count_unseen($table,$objectid,$userid);

	if ($short) {
		return "" if ($total <= 0); # show nothing if short=1 and no messages
		if ($unseen <= 0) {
			return "($total)";
		} else {
			return "($total, <b>$unseen</b>)";
		} 
	} else {
		if ($unseen <= 0) {
			return "($total messages)";
		} else {
			return "($total messages, <b>$unseen unread</b>)";
		} 
	}
}

sub msgCountWithNewXML {
		my ($table, $objectid, $userid) = @_;
		my $total = getmsgcount($table, $objectid);
		my $unseen = count_unseen($table, $objectid, $userid);
		my $txt = "<messages";

		if($unseen > 0) {
				$txt .= " unseen=\"$unseen\"";
		}
		$txt .= " total=\"$total\"/>";
		return $txt;
}

# display a single message
#
sub getMessage {
	my $params = shift;
	my $userinf = shift;
	
	my $uid = $params->{id};
	
	my $prefs = $userinf->{prefs};
	my $msgexpand = (defined $params->{msgexpand}?$params->{msgexpand}:$prefs->{msgexpand});

	my $template = new Template('dispmessage.html');

	my $html = '';
	my $interact = '';
	my $msg = '';		

	# get the data
	#
	my ($rv, $sth) = dbSelect($dbh,{WHAT => '*', 
	FROM => 'messages', 
	WHERE => "uid = $uid", 
	'ORDER BY' => 'created'});

	if (! $rv ) { 
		dwarn "uh oh... query to retrieve message $uid broke!";
		return "Error with message retrieval query!";
	}

	# handle watch toggling
	#
	changeWatch($params, $userinf, 'messages', $params->{'id'});

	my $row = $sth->fetchrow_hashref();
	my $up = getUpArrow("".getConfig("main_url")."/?op=getobj;from=$row->{tbl};id=$row->{objectid}",'parent',"parent object");
 
	my $authorinf = _userfields_by_id($row->{userid},'username','email','homepage', 'uid');
	$msg .= clearBox("$up Viewing Message",
		printmessage($row, $userinf, $authorinf, {single=>1, msgexpand=>$msgexpand}));

	my $itf = 'dispmessage_interact.html';
	if ( is_admin( $userinf->{'uid'} ) ) {
		$itf = 'dispmessage_admin.html';
	}

	my $itemplate = new Template($itf);
	$itemplate->setKeys('id' => $row->{'objectid'}, 'replyto'=>$row->{'uid'});
	$interact .= makeBox('Interact',$itemplate->expand());
	
	$template->setKeys('message' => $msg, 'interact' => $interact, 'replyto' => $row->{'uid'}, 'id' => $row->{'objectid'});
	
	$html .= $template->expand(); 
	
	return $html;
}

sub deleteMessage {
	my $params = shift;
	my $userinf = shift;

	return loginExpired() if ($userinf->{uid} <= 0);
  
	#check to see that this user has permission to delete.
	if ( ! is_admin( $userinf->{'uid'} ) ) {
		return errorMessage("You must be an admin to delete messages.");
	} 
	
	if ($params->{'ask'} eq "yes") {
		return paddingTable(makeBox('Delete Message',"<center><Br><font color=\"#ff0000\" size=\"+1\"><b>Message will be permanently deleted, are you SURE? </b>
	<br/><br/>
	<a href=\"".getConfig("main_url")."/?op=deletemsg;id=$params->{id}\">YES!</a><br/>
	</center></font>"));
	}

	my $delstr = "delete from messages where uid = ?";
	my $sth = $dbh->prepare( $delstr );
	$sth->execute( $params->{'id'} );

	my $template = new XSLTemplate('delmsg.xsl');

	$template->addText('<delmsg></delmsg>');	# no data

	return $template->expand();
}

# main call to display the discussion attached to an object 
#
sub getMessages {
	my $table = shift;
	my $objid = shift;
	my $desc = shift;
	my $params = shift;
	my $userinf = shift;
	my $lastid = shift;	 # id of last seen message, use to highlight new msgs

	my $html = '';				# init

	$params->{offset} = $params->{offset} || 0;

	my $type;
	my $rv;
	my $sth;

	$reader = $userinf;	 # global for identifying reader

	_object_exists($table,$objid) || return "object not found";

	# set display preferences
	#
	my $prefs = $userinf->{prefs};
	my $msgstyle = (defined $params->{msgstyle}?$params->{msgstyle}:$prefs->{msgstyle});
	my $msgexpand = (defined $params->{msgexpand}?$params->{msgexpand}:$prefs->{msgexpand});
	my $msgorder = (defined $params->{msgorder}?$params->{msgorder}:($desc==1?"desc":$prefs->{msgorder}));

	# init page sizes
	#
	my $scale = ($msgstyle eq 'threaded')?4:2;
	my $limit = int($userinf->{prefs}->{pagelength}/$scale);
	
	# handle watch stuff
	# 
	if (defined $params->{watch} && $reader->{uid} > 0) {
		foreach my $key (keys %$params) {
			if ($key =~ /^watch_([0-9]+)$/) {
				toggleWatch('messages',$1,$reader->{uid});
			}
		}
	}
	
	# flat and threaded total queries
	#
	if ($msgstyle eq 'threaded') {
		($rv,$sth) = dbSelect($dbh,{WHAT => '*',
			FROM => 'messages',
			WHERE => "objectid = $objid and tbl='$table' and replyto = -1"});
	} else {
		($rv,$sth) = dbSelect($dbh,{WHAT => '*',
			FROM => 'messages',
			WHERE => "objectid = $objid and tbl='$table'"});
	}

	$params->{'total'} = $sth->rows();
	$sth->finish();
	
	# flat and threaded base queries
	#
	if ($msgstyle eq "threaded") {
		($rv,$sth) = dbSelect($dbh,{WHAT => '*',
			FROM => 'messages',
			WHERE => "objectid = $objid and tbl='$table' and replyto = -1",
			OFFSET => $params->{offset},
			LIMIT => $limit,
			'ORDER BY' => 'created',uc($msgorder)=>''}); 
	} else {
		($rv,$sth) = dbSelect($dbh,{WHAT => '*',
			FROM => 'messages',
			WHERE => "objectid = $objid and tbl='$table'",
			OFFSET => $params->{offset},
			LIMIT => $limit,
			'ORDER BY' => 'created',uc($msgorder)=>''}); 
	}
								
	if (! $rv ) { 
		dwarn "uh oh... error doing message query for $objid";
		return "Query error.";
	}

	# build message display parameter forms
	#
	my $msgstylesel = getSelectBox('msgstyle',getConfig('msgstylesel'),$msgstyle);
	my $msgordersel = getSelectBox('msgorder',getConfig('msgordersel'),$msgorder);
	my $msgexpandsel = getSelectBox('msgexpand',getConfig('msgexpandsel'),$msgexpand);
	my $formvars = hashToFormVars(
		{op => $params->{op},
		 from => $table,
		 id => $objid
		 #total=>$params->{total}, 
		 #offset=>$params->{offset}
	 });
	my $forumpolicy = getConfig('forum_policy');

	my $form = "<form method=\"get\" action=\"/\">
		Style: $msgstylesel Expand: $msgexpandsel Order: $msgordersel
	$formvars
		<input type=\"submit\" value=\"reload\"/>  
	</form>";
		
	$html .= "<div id=\"form\">$form</div>\n";

#		<td align=\"center\">
#			<font size=\"-1\"> <b> <a href=\"$forumpolicy\">forum policy</a> </b>  </font>
#		</td>

	# get and display the messages
	#
	my $count = $sth->rows();
	my @rows = dbGetRows($sth);

	if ($count) {
		$html .= "<form method=\"post\" action=\"/\">\n";
		if ($msgexpand eq '0') {
			$html .= "<hr>";
		}

		my $pager = getPager($params, $userinf, $scale);
		$html .= "<font size=\"-1\">$pager<br /></font>" if (not $pager =~ /displaying\s+all/i);

		foreach my $row ( @rows) {
			$html .= printmessage($row,
				$userinf,
				_userfields_by_id($row->{userid},'username','email','homepage', 'uid'),
				{msgstyle=>$msgstyle,msgexpand=>$msgexpand,lastid=>$lastid}); 
		} 

		$html .= "<font size=\"-1\">$pager<br/></font>" if (not $pager =~ /displaying\s+all/i);

		$formvars = hashToFormVars({op => $params->{'op'},
			from => $table,
			id => $objid,
			offset => $params->{'offset'},
			total => $params->{'total'},
			msgstyle=>$msgstyle,
			msgorder=>$msgorder,
			msgexpand=>$msgexpand});
		
		$html .= " $formvars </form>";

	} else {
		$html .= "<p />No messages.";
	}

	return $html;
}

# abstract message-printing sub
#
sub printmessage {
	my $row = shift;
	my $userinf = shift;
	my $authorinf= shift;
	my $opts = shift;
	
	my $msgstyle = $opts->{msgstyle};
	my $msgexpand = $opts->{msgexpand};
	my $lastid = $opts->{lastid};
	my $single = $opts->{single} || 0;
	
	my $html = '';
	
	$html .= "<table width=\"100%\">\n";
	$html .= "<tr><td>\n";
	if ($single || ($msgexpand != 0)) {
		$html .= printMsgExpanded($row, $userinf, $authorinf, $lastid, $single);
	} else {
		$html .= printMsgHeaderLine($row, $userinf, $authorinf, $lastid);
	}
	$html .= "</td></tr>\n";

	if ($msgstyle ne "flat") {
		$html .= getreplies($userinf, $row->{'uid'}, $row->{'threadid'}, $row->{'tbl'}, $msgexpand, 1, $lastid); 
	}

	$html .= "</table>\n";
	
	return $html;
}

# print collapsed message header
#
sub printMsgHeaderLine {
	my $row = shift;
	my $userinf = shift; #this is currently logged in user info
	my $userinfo = shift; #this is message author's info
	my $lastid = shift;
 
	my $new = '';
	if (defined $lastid and $lastid < $row->{uid}) {
		$new = "<font color=\"#ff0000\">*</font>";
	}



	my $date = nicifyTimestamp($row->{created});
	return getWatchBox($row)." <a href=\"".getConfig("main_url")."/?op=getmsg;id=$row->{uid}\">$row->{subject}</a> $new by " . getUserDisplayName( $row->{'userid'} ) . " <font size=\"-2\">on $date ".getWatchString($row)."</font>\n";

}

# get a string which gives the status of a watch on a message
#
sub getWatchString {
	my $row = shift;

	if ($reader->{uid}>0 &&
			$row->{threadid} == $row->{uid} &&
			hasWatch('messages',$row->{threadid},$reader->{uid})) {
		return "<b>(watching)</b>";
	} 

	return '';
}

# get a checkbox for displaying/setting thread watch
#
sub getWatchBox {
	my $row = shift;

	if ($row->{threadid} == $row->{uid}) {
		return "<input type=\"checkbox\" name=\"watch_$row->{threadid}\"/>";
	}

	return '';
}

# print out a message fully expanded
# 
sub printMsgExpanded {
	my $row = shift;
	my $userinf = shift;
	my $authorinf = shift;
	my $lastid = shift;
	my $single = shift;

	my $html = '';
	
	my $new = '';
	if (defined $lastid and $lastid < $row->{'uid'}) {
		$new = "<font color=\"#ff0000\">*</font>";
	}
	
	$html .= "<table>";

	$html .= "<tr><td><table><tr><td>\n";

	# dont print checkbox-style watch toggle if in single message mode
	#
	if ($single) {
		$html .= "``$row->{subject}'' $new \n";
	} else {
		$html .= getWatchBox($row)." <a href=\"".getConfig("main_url")."/?op=getmsg;id=".$row->{'uid'}."\">".$row->{'subject'}."</a> $new \n";
	}
	
	my $date = nicifyTimestamp($row->{'created'});
	$html .= "by <a href=\"".getConfig("main_url")."/?op=getuser;id=".$row->{'userid'}."\">".getUserDisplayName($row->{'userid'})."</a> on $date ".getWatchString($row);

	$html .= "</td></tr>\n</table></td></tr>\n";

	# print body
	#
	my $body = stdmsg($row->{'body'});
	$html .= "<tr><td><table cellpadding=\"4\"><td>$body</td></table></td></tr>\n";

	# reply control
	#
	my $upurl = '';
	# up URL for a top-level message
	if ($row->{'replyto'} == -1) {
		$upurl = "".getConfig("main_url")."/?op=getobj;from=$row->{tbl};id=$row->{objectid}";
	} 
	# up URL for a message within a thread
	else {
		$upurl = "".getConfig("main_url")."/?op=getmsg;id=$row->{replyto}";
	}

	# top control
	my $top = '';
	if ($row->{replyto} != -1) {
		$top = "| <a href=\"".getConfig("main_url")."/?op=getmsg;id=$row->{threadid}\">top</a>";
	}
	
	$html .= "<tr><td align=\"center\"><font size=\"-1\">[ <a href=\"".getConfig("main_url")."/?op=postmsg;id=$row->{objectid};replyto=$row->{uid}\">reply</a> | <a href=\"$upurl\">up</a> $top ]</font></td></tr>\n";

	# watch widget
	#
	if ($single && $row->{'threadid'} == $row->{'uid'}) {
		$html .= "<p/>";
		$html .= getWatchWidget(
			{'from' => 'messages', 'id' =>$row->{'uid'}, 'op' =>'getmsg'},
			$userinf
		);
	}
	$html .= "</table>";


	return $html;
}

# get a message by uid, for the screen shown when posting a reply
#
sub singlemessage_byid {
	my $id = shift;

	my $row;
	my $userhash;
	my $html = '';
 
	(my $rv, my $sth) = dbSelect($dbh,{WHAT=>'*',FROM=>'messages',WHERE=>"uid=$id"});
	
	$row = $sth->fetchrow_hashref();
	$sth->finish();

	$userhash = _userfields_by_id($row->{userid},'username','uid');
	 
	$html .= "<table width=\"100%\"><tr><td bgcolor=\"#dddddd\">\n";
	$html .= "<b>".$row->{subject}."</b>\n";
	
	my $date = nicifyTimestamp($row->{created});
	$html .= "by <a href=\"".getConfig("main_url")."/?op=getuser;id=".$row->{userid}."\">".getUserDisplayName($row->{'userid'})."</a> on $date";
	$html .= "</td></tr>\n";

	# print body
	#
	my $body = stdmsg($row->{body});
	$html .= "<tr><td><table cellpadding=\"4\" width=\"600\"><tr><td>$body</td></tr></table></td></tr>\n";

	$html .= "</table>\n";
	
	return $html;
}

# main entry point to getting a thread
#
sub getreplies {
	my $userinf = shift;
	my $uid = shift;
	my $threadid = shift;
	my $table = shift;
	my $msgexpand = shift;
	my $level = shift;
	my $lastid = shift;

	my $replies = '';
	my $html;
	
	# cache the entire thread
	#
	my $thread = get_threadhash($threadid, $table);

	# get a formatted display of the thread
	#
	$replies = _r_getmessages($thread, $userinf, $uid, $msgexpand, $level, $lastid);	
	if ($replies ne "") {
		$html = "<tr><td>$replies</td></tr>\n";
	}

	return $html;
}


# get the entire thread as a hash of arrays of database rows.  this 
# removes the need for recursively querying the database.
#
# the arrays are hashed based on the replyto value of their constituent
# messages, making the lookup for replies to a message fast.
# 
sub get_threadhash {
	my $threadid = shift;
	my $table = shift;

	my %threadhash;

	my $sth = $dbh->prepare("select messages.*, users.username from messages, users where users.uid = messages.userid and messages.threadid = ? and messages.tbl = ? order by uid asc");
	$sth->execute($threadid, $table);

	while (my $row = $sth->fetchrow_hashref()) {
		if (not exists $threadhash{$row->{'replyto'}}) {
			$threadhash{$row->{'replyto'}} = [];
		}

		push @{$threadhash{$row->{'replyto'}}}, $row;
	}
	
	$sth->finish();

	return {%threadhash};
}

# recursive portion of message-getting
#
sub _r_getmessages {
	my $thread = shift;
	my $userinf = shift;
	my $uid = shift;
	my $msgexpand = shift;
	my $level = shift;
	my $lastid = shift;

	my $html = '';

	# look up replies to $uid in the thread data structure
	my $rows = $thread->{$uid};

	if (defined $rows && scalar @$rows > 0) { 
		$html .= "<ul>\n";

		foreach my $row (@$rows) {
			my $authorinf = {'username' => $row->{'username'}, 'uid' => $row->{'userid'}};

			if ($msgexpand gt "$level" || $msgexpand eq "-1") {
				$html .= "<table with=\"100%\"><tr><td>\n";
				$html .= printMsgExpanded($row, $userinf, $authorinf, $lastid); 
				$html .= "</td></tr></table>\n";
			} else {
				my $header = printMsgHeaderLine($row, $userinf, $authorinf, $lastid);
				$html .= "<li>$header</li>";
			}
	
			# get all messages posted under this one
			$html .= _r_getmessages($thread, $userinf, $row->{'uid'}, $msgexpand, $level+1, $lastid);
		}

		$html .= "</ul>\n";
	}

	return $html;
}

# grab the subject of an arbitrary message
#
sub _subject_by_id {
	my $uid = shift;

	(my $rv,my $sth) = dbSelect($dbh,{WHAT=>'subject',
																		FROM=>'messages',
									WHERE=>"uid=$uid"});
	my $row=$sth->fetchrow_hashref();
	$sth->finish();
	return $row->{subject};
}

# get top message id from a convo
#
sub get_lastmsg {
	my $from = shift;
	my $objid = shift;

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'uid', FROM=>getConfig('msg_tbl'),WHERE=>"tbl='$from' and objectid=$objid",'ORDER BY'=>'uid',DESC=>'',LIMIT=>'1'});

	return -1 if (!$rv);	# error
	if (!$sth->rows()) {
		$sth->finish();
	return -1;
	}

	my $row = $sth->fetchrow_hashref();
	$sth->finish();

	return $row->{uid};
}

# get the count of unseen messages for a discussion, for this user
#
sub count_unseen {
	my $from = shift;
	my $objid = shift;
	my $userid = shift;

	my $table = getConfig('lseen_tbl');
	my $mtbl = getConfig('msg_tbl');
	my $last = get_lastseen($from,$objid,$userid);

	# anonymous users dont get unread counts.
	#
	return -1 if ($userid<=0);

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'count(uid) as cnt',FROM=>$mtbl,WHERE=>"objectid=$objid and tbl='$from' and uid>$last"});

	return -1 if (!$rv);
	if (!$sth->rows()) {
		$sth->finish();
	return -1;
	}

	my $row = $sth->fetchrow_hashref();
	$sth->finish();

	return $row->{cnt};
}

# get last seen message id for a user id
#
sub get_lastseen {
	my $from = shift;
	my $objid = shift;
	my $userid = shift;

	my $table = getConfig('lseen_tbl');

	return -1 if $userid == -1;

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'lastmsg',FROM=>$table,WHERE=>"tbl='$from' and objid=$objid and userid=$userid"});

	return -1 if (!$rv);	# nothing found 
	if (!$sth->rows()) {
		$sth->finish();
		return -1;
	}

	my $row = $sth->fetchrow_hashref();
	$sth->finish();

	return $row->{lastmsg};
}

# update last message seen for a user
#
sub update_lastseen {
	my $from = shift;
	my $objid = shift;
	my $userid = shift;
	my $lastmsg = shift;

	return if ($userid<0);
	return if ($lastmsg<0);

	my $table = getConfig('lseen_tbl');
	my $oldlast = get_lastseen($from,$objid,$userid);
	
	# add a new entry for this object's discussion for this user
	#
	if ($oldlast == -1) {
		my ($rv,$sth) = dbInsert($dbh,{INTO=>$table,COLS=>'tbl,objid,userid,lastmsg',VALUES=>"'$from',$objid,$userid,$lastmsg"});
	$sth->finish();
	} 
	
	# just update existing entry
	#
	else {
		my ($rv,$sth) = dbUpdate($dbh,{WHAT=>$table,SET=>"lastmsg=$lastmsg",WHERE=>"tbl='$from' and objid=$objid and userid=$userid"});
	$sth->finish();
	}
}

# return 1 if the object exists in the database or 0 if not
#

sub _object_exists {
	my $table = shift;
	my $uid = shift;
 
	# see if the object exists. 
	(my $rv,my $sth) = dbSelect($dbh,{WHAT => 'uid', FROM => $table, WHERE => "uid = $uid"});
				
	$sth->finish();
	# object does not exist
	if (! $rv) {
	 dwarn "object missing, id=$uid. Noosphere is inconsistent!\n";
	 return 0;
	} 

	return 1;
}

# get message posting interface
#
sub postMessage {
	my $params = shift;
	my $userinfo = shift;
	
	my $template;
	my $post;
	my $boxtitle;
	my $html = '';

	if ($userinfo->{'uid'} <= 0) {
		return postError("You can't post as anonymous.");
	}
	
	# preview directive
	#
	if (defined($params->{preview})) {
		($template, $post, $boxtitle) = getPostForm($params);
		my $text = stdmsg($params->{body});
		$post->setKey('preview', "Preview:<br/><table width=\"100%\"><tr><td bgcolor=\"#ffffff\">$text</td></tr></table><hr>");
		$template->setKey('post', makeBox($boxtitle, $post->expand()));
		$html = $template->expand();
	}
	
	# spell directive
	#
	elsif (defined($params->{spell})) {
		($template, $post, $boxtitle) = getPostForm($params);
		my $text = $params->{body};
		$text =~ s/>.*?\n//gs;
		$text =~ s/^\s*//s;
#	dwarn "*** spell: submitting to spellcheck : [$text]";
		my $spell = checkdoc($text);
#	dwarn "*** spell: got back [$spell]";
		$post->setKey('spell', "Spell check (broken words in red, clickable):<br/><table width=\"100%\"><tr><td bgcolor=\"#ffffff\">$spell</td></tr></table><hr>");
		$template->setKey('post', makeBox($boxtitle, $post->expand()));
		$html = $template->expand();
	}
	
	# quote directive
	#
	elsif (defined($params->{quote})) {
		($template, $post, $boxtitle) = getPostForm($params);
		my $quoted = getquotedmessage($params->{'replyto'});
		if (defined($params->{'body'})) {
			my $body = $params->{'body'};
			$post->setKey('body', "$quoted\n\n$body");
		} else {
			$post->setKey('body', $quoted);
		}
		$template->setKey('post', makeBox($boxtitle, $post->expand()));
		$html = $template->expand();
	}
	
	# got body, check if we got subject, if so, go ahead with post
	#
	elsif ($params->{'body'} ne "") {
		if ($params->{'subject'} eq "") {
			return postError("Need a subject.");
		} else {
			my $visible = hasVisibleMessages($params->{'from'}, $params->{'id'});
			$html .= submit_message($params, $userinfo, $visible);
		}
	} 
	
	# got subject so far, give error 
	#
	elsif ($params->{'subject'} ne "" ) {
		$html .= postError("Need a message body."); 
	} 
	# got nothing so far, just get form
	#
	else {
		($template, $post, $boxtitle) = getPostForm($params);
		$template->setKey('post', makeBox($boxtitle, $post->expand()));
		$html = $template->expand();
	}

	return $html;
}

# get error to show user if a post didn't go through
#
sub postError {
	my $error = shift;

	return paddingTable(makeBox('Error',"<font size=\"+1\" color=\"#ff0000\">$error</font>"));
}

# get and populate message posting form
#
sub getPostForm {
	my $params = shift;
	
	my $template;
	my $boxtitle;
	my $post;
	
	if (defined($params->{'replyto'})) {
		$template = new Template('replymessage.html');
		my $original = makeBox('Replying to','<table width="100%" border="0" cellpadding="0" cellspacing="0"><td bgcolor="#ffffff">'.singlemessage_byid($params->{'replyto'}).'</td></table>');
	$boxtitle = 'Compose Post';
	$post = new Template('postmsgform.html');
		my $q = "<input type=\"submit\" name=\"quote\" value=\"quote\">";
	$template->setKeys('original' => $original);
	$post->setKeys('replyto' => $params->{'replyto'}, 'quote' => $q);
	} else {
		$template = new Template('postmessage.html');
	$boxtitle = 'Compose Post';
	$post = new Template('postmsgform.html');
	$template->setKeys('replyto' => $params->{'replyto'});
	}
	if (not defined($params->{quote})) {
		if (defined($params->{body})) {
		my $body = $params->{body};
		$post->setKey('body', $body);
		}
	}
 
	if (defined($params->{'subject'})) {
		my $s = $params->{'subject'};
	$post->setKey('subject', $s);
	} else {
		if (defined($params->{'replyto'})) {
		my $subj =_subject_by_id($params->{'replyto'});
		if ($subj =~ /^Re:/) { 
			$post->setKey('subject', $subj);
		} else {
			$post->setKey('subject', "Re: $subj");
		}
	}
	}
	
	$post->setKeys('id' => $params->{id}, 'from' => $params->{from});
	$post->setKeysIfUnset(%$params);

	return ($template, $post, $boxtitle);
}

# actually insert a message into the database
#
sub submit_message {
	my $params = shift;
	my $userinfo = shift;
	my $visible = shift;	# optional visible parameter

	$visible = 1 if (not defined $visible);
	
	my $userid = $userinfo->{uid};
	my $html = '';
	my $c;
	my $v;
	my $subject = $params->{'subject'};
	my $body = $params->{'body'};
	my $table;

	my $threadid;
	my $msgid = -1;
	my $objectid;
	
	# handle sigs
	#
	if ($userinfo->{prefs}->{usesig} eq "on" and $userinfo->{data}->{sig} ne ""){
		$body="$body
$userinfo->{data}->{sig}";
	}

	my $nextid = nextval('messages_uid_seq');

	# build query columns and values
	#
	my $row;
	if (defined($params->{'replyto'}) && nb($params->{'replyto'})) {
		$row = getmsgfields($params->{replyto},'tbl,threadid,userid');
		$table = $row->{tbl};

		$threadid = $row->{threadid};
		$msgid = $nextid;
		$objectid = $params->{id};
		
		$v = "now(),$nextid,$visible,$row->{threadid},$params->{id},'$row->{tbl}',$params->{replyto},$userid,'".sq($subject)."','".sq($body)."'";
		$c = 'created,uid,visible,threadid,objectid,tbl,replyto,userid,subject,body';
	} else {
		$table = $params->{from};
		$v = "now(),$nextid,$visible,$nextid,$params->{id},'$params->{from}',$userid,'".sq($subject)."','".sq($body)."'";
		$c = 'created,uid,visible,threadid,objectid,tbl,userid,subject,body';
	}
	
	(my $rv,my $sth) = dbInsert($dbh,{INTO=>'messages',COLS=>$c,VALUES=>$v});
	$sth->finish();

	if (! $rv) {
		dwarn "insert of message record failed!";
		return errorMessage("post failed!");
	}

	# give the user points for posting
	#
	changeUserScore($userid,getScore('postmsg'));

	# get a body fragment for use in notification
	#
	my $tbody = $body;  # trimmed body
	$tbody =~ s/^\s*//gos;
	$tbody =~ s/\s*$//gos;
	my @blines = split(/\n/, $tbody);
	my $body_fragment = $tbody;
	if (scalar @blines > 5) {
		$body_fragment = join("\n", @blines[0..4])."\n...";
	}
	
	# update watches
	#
	my $parentobjid = lookupfield('messages','tbl',"uid=$row->{threadid}");
	my %sentnotice;
	updateWatches($params->{id},$params->{from} || $parentobjid,$nextid,'messages',$userid,"\"$subject\" (message post)",$body_fragment,\%sentnotice);

	# if this is a reply...
	#
	if (defined $params->{replyto} && ($userid != $row->{userid})) {
		updateWatches($row->{threadid},'messages',$nextid,'messages',$userid,'message posted', $subject,\%sentnotice);

		# send notice if the user being replied to has reply notification on but
		# has not already receieved notices from above.
		#
		if (userPref($row->{userid},'replynotify') eq 'on' && !$sentnotice{$row->{userid}}) {
			 
			fileNotice($row->{userid},
				$userid,
				"\"$subject\" (reply to you)",	
				$body_fragment,
				[{id=>$nextid,table=>'messages'},
				 {id=>$params->{id},table=>$params->{from}||$parentobjid}]);
		}

	}

	# create a new watch
	#
	if (! defined $params->{replyto}) {
		addWatchIfAllowed('messages',$nextid,$userinfo,'msgwatch');
	}

	# send mail to wathing users
	#
	#if (($table eq 'forums') && $msgid != -1) {
	if ($msgid != -1) {

		#index message
		(my $rv1, my $sth1) = dbSelect($dbh,{WHAT=>'uid,subject,body,created',FROM=>'messages',WHERE=>"uid=".$msgid});
		my $rowMsg = $sth1->fetchrow_hashref();
		$sth1->finish();
		($rv1, $sth1) = dbSelect($dbh,{WHAT=>'username',FROM=>'users',WHERE=>"uid=".$userid});
		my $usern = $sth1->fetchrow_hashref();
		$sth1->finish();
		
		indexTitle("messages",$msgid,$userid,$subject, $subject);
		irIndex("messages", $rowMsg);
		
		#send emails		
		sendEmailBridge($msgid, $usern->{"username"}, $table, $objectid, $threadid, $subject, $body, $userinfo->{prefs}->{self_email}, $userid);
	}
	
	# invalidated message statistics
	#
	$stats->invalidate('latest_messages');

	$html .= "<meta http-equiv=\"refresh\" content=\"0; url=".getConfig("main_url")."/?op=getobj;from=$table;id=".$params->{'id'}."\">";
	$html .= paddingTable(makeBox('Message Posted',"Thank you for posting.	Click <a href=\"".getConfig("main_url")."/?op=getobj;from=$table;id=".$params->{'id'}."\">here</a> to return to the article."));

	return $html;
}

sub sendEmailBridge {
	my $msgid = shift;
	my $username = shift;
	my $table = shift;
	my $objectid = shift;
	my $threadid = shift;
	my $subject = shift;
	my $msg = shift;
	my $selfEmail = shift;
	my $userid = shift;

	warn "Self: $selfEmail";
	(my $rv,my $sth) = dbSelect($dbh,{WHAT=>'userid',FROM=>'watches',WHERE=>"tbl='messages' and objectid=".$threadid});
	while (my $row = $sth->fetchrow_hashref()) {
		if ($userid != $row->{userid} || ($userid == $row->{userid} && $selfEmail eq "on")) {
			warn "Sending email to ".$row->{userid}.". " . $msgid." thread=".$threadid;
			(my $rv1, my $sth1) = dbSelect($dbh,{WHAT=>'email',FROM=>'users',WHERE=>"uid=".$row->{userid}});
			my $user = $sth1->fetchrow_hashref();
			$sth1->finish();
			sendForumMail($row->{userid}, $username, $user->{email}, $msgid, $table, $objectid, $threadid, $subject, $msg);
		}
		if ($userid == $row->{userid} && $selfEmail eq "off") {
			warn "Skipping sending email to post author. Option set to off.";
		}
	}
	$sth->finish();
}

sub sendForumMail {
	my $userid = shift;
	my $username = shift;
	my $to = shift;
	my $msgid = shift;
	my $table = shift;
	my $objectid = shift;
	my $threadid = shift;
	my $subject = shift;
    my $body = shift;

	dwarn "sending forum bridge mail: [$body]";
	warn "Body: " . $body;
	
	$ENV{'PATH'} = '/bin:/usr/bin'; # security measure

	open (MAIL,"| ".getConfig('sendmailcmd')." -f".getConfig('system_email')." $to");
	print MAIL "From: ".$username.'<messages@planetx.cc.vt.edu>'."\n";
	print MAIL "To: $to\n";
	print MAIL "Message-ID: <post.".$table.".".$userid.".".$msgid.".".$objectid.".".$threadid."\@planetmath.org>\n";
	print MAIL "Subject: $subject\n\n";
	print MAIL $body;
	close MAIL;

	warn "Email was sent to ".$to;
	
}

sub verifyMessage {
	my $params = shift;
	my $msgid = $params->{"msg"};
	my $key = $params->{"key"};
	my $html = "";

	
	(my $rv,my $sth) = dbSelect($dbh,{WHAT=>'*',FROM=>'messages_tmp',WHERE=>"uid=$msgid and secret_key=$key"});
	if (my $row = $sth->fetchrow_hashref()) {
		$sth->finish();
		my $c = 'created,uid,visible,threadid,objectid,tbl,replyto,userid,subject,body';
		my $v = "'".$row->{"created"}."',".$row->{"uid"}.",1,".$row->{"threadid"}.",".$row->{"objectid"}.",'".$row->{"tbl"}."',".$row->{"replyto"}.",".$row->{"userid"}.",'".sq($row->{"subject"})."','".sq($row->{"body"})."'";

		($rv, $sth) = dbInsert($dbh,{INTO=>'messages',COLS=>$c,VALUES=>$v});
		$sth->finish();

		$Noosphere::dbh->do("delete from messages_tmp where uid=".$msgid);

		(my $rv1, my $sth1) = dbSelect($dbh,{WHAT=>'username',FROM=>'users',WHERE=>"uid=".$row->{"userid"}});
		my $user = $sth1->fetchrow_hashref();
		$sth1->finish();

		indexTitle("messages",$msgid,$row->{"userid"}, $row->{"subject"}, $row->{"subject"});
		Noosphere::irIndex("messages", $row);
						

		sendEmailBridge($row->{"uid"},$user->{"username"}, $row->{"tbl"}, $row->{"objectid"}, $row->{"threadid"}, $row->{"subject"}, $row->{"body"}, userPref($row->{'userid'}, "self_email"), $row->{"userid"});
		
		$html .= paddingTable(makeBox('Message posted',"Message was verified successfully. Click <a href=\"".getConfig("main_url")."/>here</a>."));
	} else {
		$sth->finish();
		$html .= paddingTable(makeBox('Message not found',"Message was not found. Click <a href=\"".getConfig("main_url")."\">here</a>."));
	}

	
	return $html;
	
}

	
# grab a message from the database and quote it
#
sub getquotedmessage {
	my $uid = shift;
	
	(my $rv,my $sth) = dbSelect($dbh,{WHAT=>'body',FROM=>'messages',WHERE=>"uid=$uid"}); 
	my $row = $sth->fetchrow_hashref();
	
	$sth->finish();

	return getquoted($row->{body});
}

sub getmsgfields {
	my $id = shift;
	my $fields = shift;

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>$fields,FROM=>'messages',WHERE=>"uid=$id",LIMIT=>1});
	my $row = $sth->fetchrow_hashref();
	$sth->finish();
	
	return $row;
}

# split a line of words into two lines at the earliest word boundary before
# some max length 
#
sub wordsplit {
	my $line = shift;
	my $ml = shift;

	my $nextline = '';

	# cut off last word until line is short enough, or contains no more
    # spaces
    # 
	while (length($line) > $ml && $line =~ /\s/) {
		my @words = split(/(\s+)/, $line);
		my ($remove) = splice @words, $#words, 1;

		if ($nextline) {
			$nextline = $remove . $nextline;
		} else {
			$nextline = $remove;
		}

		$line = join ('', @words);
	}

	return ($line, $nextline);
}

# quote some text in message style
#
sub getquoted {
	my $msg = shift;
	
	my @outlines = ();
	my $quote = '';
	my $maxlen = getConfig("message_maxcols");
	my $ml = $maxlen - 3;
	my $qchar = '>';

	my @inlines = split(/\n/, $msg);
 
	my $carry = '';
	my $lastdepth = -1;
 	while ($carry || @inlines) {
		# handle carry over
		if ($carry) {

			my $newquote = ("$qchar " x ($lastdepth+1));

			my $content = $carry;
			$content =~ s/^\s*//;
			$carry = '';

			($content, $carry) = wordsplit($content, $ml - length($newquote));
		
			push @outlines, $newquote . $content;
		} 
		# handle new lines
		else {

			my $line = splice @inlines, 0, 1;	# "pop"
			$line =~ /^(($qchar )*)\s*(.*?)\s*$/;
			my $quote = $1;
			my $content = $3; 

			my $thisdepth = length($quote) / 2;

			my $newquote = "$qchar " . $quote;

			($content, $carry) = wordsplit($content, $ml - length($newquote));

			push @outlines, $newquote . $content;

			$lastdepth = $thisdepth;
		}
	}

	$quote = join("\n",@outlines);
	return $quote;
}

1;
