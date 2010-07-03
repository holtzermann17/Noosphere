package Noosphere;

use Noosphere::DB;
use Noosphere::Config;
use Noosphere::Util;
use Noosphere::UserData;
use Noosphere::Notices;
use Noosphere::Watches;

use strict;

# correction viewing "interact" box
#
sub getCorrectionInteract {
	my $rec = shift;

	my $table = getConfig('cor_tbl');
	my $en = getConfig('en_tbl');		# TODO: generalize

	return makeBox('Interact',"<center><a href=\"".getConfig("main_url")."/?op=correct&amp;from=$en&amp;id=$rec->{objectid}\">new correction</a> | <a href=\"".getConfig("main_url")."/?op=postmsg&amp;from=$table&amp;id=$rec->{uid}\">post message</a></center>");
}

# get a list of correction ids to nag as a hash, {id, elapsed, filed}
#	("filed" is grace interval adjusted)
#
sub getNagList {

	my $times = getConfig('cor_times');
	my $cor = getConfig('cor_tbl');

	my @list;
	
	my ($rv,$sth);
	
	($rv, $sth) = dbSelect($dbh,{WHAT=>"uid, title, filed, objectid, filed+graceint, now()-graceint-filed as elapsed",FROM=>$cor,WHERE=>"closed is null and now()-graceint-filed >= interval '$times->{nagstart}'"})
		if (getConfig('dbms') eq 'pg');

	($rv, $sth) = dbSelect($dbh,{WHAT=>"uid, title, filed, objectid, filed + interval graceint SECOND, unix_timestamp(now()) - graceint - unix_timestamp(filed) as elapsed",FROM=>$cor,WHERE=>"closed is null and now() - interval graceint SECOND - filed + now() >= interval $times->{nagstart} + now()"})
		if (getConfig('dbms') eq 'mysql');

	my @rows = dbGetRows($sth);

	foreach my $row (@rows) {
		push @list, {id=>$row->{uid},
					 objectid=>$row->{objectid},
					 elapsed=>$row->{elapsed},
					 filed=>$row->{filed},
					 title=>$row->{title}};
	}

	return @list;
}

# send out a nag for a correction id
#
sub sendNag {
	my $corhash = shift;
	
	my $cid = $corhash->{'id'};
	my $elapsed = $corhash->{'elapsed'};
	my $filed = $corhash->{'filed'};
	my $objectid = $corhash->{'objectid'};

	my $times = getConfig('cor_times');
	my $cor = getConfig('cor_tbl');

	my $userid = lookupfield(getConfig('en_tbl'),'userid',"uid=$objectid");
	return if ($userid <= 0);	# object is not owned

	# use the dbms to do our date arithmetic. get booleans for whether things
	# "should" be happening (nagging, orphaning, adopting)
	#
	my ($rv, $sth);

	# this is pretty ugly... using +now() to make the equations work. oh well.
	($rv,$sth) = dbLowLevelSelect($dbh,"select interval '$elapsed' >= interval '$times->{nagstart}' as nag, interval $elapsed + now() >= interval $times->{adopt} + now() as adopt, interval $elapsed + now() >= interval $times->{orphan} + now() as orphan")
		if (getConfig('dbms') eq 'pg');

	($rv,$sth) = dbLowLevelSelect($dbh,"select interval $elapsed SECOND + now() >= interval $times->{nagstart} + now() as nag, interval $elapsed SECOND + now() >= interval $times->{adopt} + now() as adopt, interval $elapsed SECOND + now() >= interval $times->{orphan} + now() as orphan")
		if (getConfig('dbms') eq 'mysql');

	my $should = $sth->fetchrow_hashref();
	$sth->finish();

	return if ($should->{nag} eq '0');	# exit if nag period hasn't started

	# exit if we've already nagged within the naginterval
	#
	return if (alreadyNagged($cid));	

	# get the dates when things should happen
	#
	($rv,$sth) = dbLowLevelSelect($dbh,"select now() + interval '$times->{naginterval}' as nextnag, timestamp '$filed' + interval '$times->{adopt}' as adopt, timestamp '$filed' + interval '$times->{orphan}' as orphan")
		if (getConfig('dbms') eq 'pg');

	($rv,$sth) = dbLowLevelSelect($dbh,"select now() + interval $times->{naginterval} as nextnag, timestamp '$filed' + interval $times->{adopt} as adopt, timestamp '$filed' + interval $times->{orphan} as orphan")
		if (getConfig('dbms') eq 'mysql');

	my $dates = $sth->fetchrow_hashref();

	$sth->finish();
	
	# build the message texts
	#
	my $eventmessage = "";
	if ($should->{orphan}) {
$eventmessage = "This object has been orphaned.	You may be able to reclaim it if you are quick enough.	";
	} elsif ($should->{adopt}) {
$eventmessage = "This object is now up for adoption!	This means anyone can claim ownership of
it, but you will otherwise remain the owner until the orphan date.";
	}
	
	my $datemessage = "Dates to note (some may have already passed):

Next nag: $dates->{nextnag}
Object goes up for adoption: $dates->{adopt}
Object gets orphaned: $dates->{orphan}";

	my $objtitle = lookupfield(getConfig('en_tbl'),'title',"uid=$corhash->{objectid}");
	my $message = " 
This is an automated nag regarding an outstanding correction.

Object: $objtitle
Correction title: $corhash->{title}

You may view this correction at ".getConfig("main_url")."/?op=getobj&amp;from=$cor&amp;id=$corhash->{id}

$eventmessage

$datemessage
";

	my $useremail = lookupfield(getConfig('user_tbl'),'email',"uid=$userid");

	# send the message
	#
	sendMail($useremail,$message,"outstanding correction notice");

	# mark a timestamp for the nag we just sent
	#
	markNag($cid);
}

# see if we've already nagged within the nag interval
#
sub alreadyNagged {
	my $cid = shift;

	my $times = getConfig('cor_times');
	my $table = getConfig('nag_tbl');

	# this should all work even if a row isn't present
	#
	my ($rv,$sth);
	
	($rv,$sth) = dbSelect($dbh,{WHAT => "now() - lastnag < interval '$times->{naginterval}' as nag",FROM => $table,WHERE => "cid=$cid"})
		if (getConfig('dbms') eq 'pg');

	($rv,$sth) = dbSelect($dbh,{WHAT => "now() - lastnag + now() < interval $times->{naginterval} + now() as nag",FROM => $table,WHERE => "cid=$cid"})
		if (getConfig('dbms') eq 'mysql');

	my $should = $sth->fetchrow_hashref();
	$sth->finish();

	return 1 if ($should->{nag} eq '1');

	return 0;
}

# update the time of last nag for a correction id
#
sub markNag {
	my $cid=shift;
	
	my $table=getConfig('nag_tbl');

	# try update first, if that doesn't work, we'll add a new row
	#
	my ($rv,$sth)=dbUpdate($dbh,{WHAT=>$table,SET=>"lastnag=now()",WHERE=>"cid=$cid"});

	if ($rv == 0) {
		($rv,$sth)=dbInsert($dbh,{INTO=>$table,COLS=>"cid,lastnag",VALUES=>"$cid,now()"});

	$sth->finish();
	}

	$sth->finish();
}

# update grace period for all corrections to some object 
#
sub updateGracePeriodAll {
	my $objectid=shift;

	my $table=getConfig('cor_tbl');

	my ($rv,$sth)=dbSelect($dbh,{WHAT=>"uid",FROM=>$table,WHERE=>"closed is null and objectid=$objectid"}); 
	my @rows=dbGetRows($sth);

	foreach my $row (@rows) {
		updateGracePeriod($row->{uid});
	}
}

# this should be called when an object changes hands. all of its corrections
# should have a grace period added for the new owner.
#
sub updateGracePeriod {
	my $cid = shift;

	my $table = getConfig('cor_tbl');

	my ($rv,$sth);
	($rv,$sth) = dbUpdate(WHAT=>$table,SET=>"graceint = now() - filed",WHERE=>"uid=$cid")
		if (getConfig('dbms') eq 'pg');
	($rv,$sth) = dbUpdate(WHAT=>$table,SET=>"graceint = unix_timestamp(now()) - unix_timestamp(filed)",WHERE=>"uid=$cid")
		if (getConfig('dbms') eq 'mysql');
		
	$sth->finish();
}

# correction rejection form
#
sub rejectCorrection {
	my $params = shift;
	my $userinf = shift;
	my $template = new Template('rejectcor.html');

	# process rejection
	#
	if (defined $params->{post}) {
		closeCorrection($params,$userinf,'reject');
		return editCorrections($params,$userinf);
	}
 
	# get form
	#
	else {
		my $corform = getCorrectionForm($params,"reject");
		$template->setKey('corrections', $corform);
	}

	return paddingTable(makeBox('Reject a Correction',$template->expand()));
}

# correction retraction form
#
sub retractCorrectionUI {
	my $params = shift;
	my $userinf = shift;

	my $template = new Template('retractcor.html');

	# process retraction 
	#
	if (defined $params->{retract}) {
		retractCorrection($params,$userinf);
		if ($params->{'continue'} eq 'editfiledcors') {
			return editFiledCorrections($params,$userinf);
		} 
		elsif ($params->{'continue'} eq 'viewcor') {
			return getObj({op=>'getobj', from=>'corrections', id=>$params->{'correct'}}, $userinf);
			
		}
	}
 
	# get form
	#
	else {
		my $corform = getRetractCorrectionForm($params, $userinf);
		$template->setKey('corrections', $corform);
	}

	return paddingTable(makeBox('Retract a Correction',$template->expand()));
}

# view a list of system-wide corrections
#
sub globalViewCorrections {
	my $params = shift;
	my $userinf = shift;
	
	my $limit = $userinf->{'prefs'}->{'pagelength'};
	my $offset = $params->{'offset'}||0;
	my $total = $params->{'total'}||-1;
	my $html = '';
	my $table = getConfig('en_tbl');
	my $cor = getConfig('cor_tbl');
	
	my $rv;
	my $sth;

	$limit = int($limit /2);

	my $order = "ASC";

	$order = "DESC" if $params->{desc};

	if($total == -1) {
		($rv,$sth)=dbSelect($dbh,{
			WHAT=>"count(*) as cnt",
			FROM=>"corrections,$table,users as u1, users as u2",
			WHERE=>"corrections.closed is null and $table.uid=corrections.objectid and corrections.userid=u1.uid and abs($table.userid)=u2.uid",
		});
		my $row = $sth->fetchrow_hashref();
		$total = $row->{cnt};
		$sth->finish();
	}

	($rv,$sth) = dbSelect($dbh,{WHAT=>"corrections.*,$table.title as objtitle,u1.username as userfrom, u2.username as userto, u2.uid as usertoid, corrections.userid as userfromid",
		 FROM=>"corrections,$table,users as u1, users as u2",
		 WHERE=>"corrections.closed is null and $table.uid=corrections.objectid and corrections.userid=u1.uid and abs($table.userid)=u2.uid",
		 'ORDER BY'=>'filed',
		 $order=>'',
		 OFFSET=>$offset,
		 LIMIT=>$limit,
		});
	
	if (! $rv) {
		return errorMessage("Error with query. Contact admin (unless you are an admin-- then panic.)");
	}

	my @rows = dbGetRows($sth);

	if ($sth->rows() > 0 ) {
		my $i = 1;
		$html .= "<table width=\"100%\">";
		$html .= "<tr><td align=\"center\">date</td><td align=\"center\">correction and object title</td><td align=\"center\">to</td><td align=\"center\">from</td></tr>";
		foreach my $row (@rows) {
			my $ar = "x";
			my $bg = ($i % 2 == 1) ? "bgcolor=\"#eeeeee\"" : "";
			$html .= "<tr $bg>";
			my $date = ymd($row->{filed});
			$html .= "<td valign=\"top\">$date</td>";
			$html .= "<td valign=\"top\"><a href=\"".getConfig("main_url")."/?op=getobj&amp;from=$cor&amp;id=$row->{uid}\">$row->{title}</a><br>to: <a href=\"".getConfig("main_url")."/?op=getobj&amp;from=$table&amp;id=$row->{objectid}\">$row->{objtitle}</a></td>";
 			$html .= "<td valign=\"top\"><a href=\"".getConfig("main_url")."/?op=getuser&amp;id=$row->{usertoid}\">$row->{userto}</a></td>";
			$html .= "<td valign=\"top\"><a href=\"".getConfig("main_url")."/?op=getuser&amp;id=$row->{userfromid}\">$row->{userfrom}</a></td>";
			$html .= "</tr>\n";
			$i++;
		}
		$html .= "</table>";
		$html .= "<br>";
		$html .= getPager({op=>$params->{'op'}, total=>$total, offset=>$offset},$userinf,2);
	}
	else {
		$html .= "No corrections";
	}

	return paddingTable(clearBox("Viewing all pending corrections",$html));

}

# edit your corrections. leads off to either object editor or special
# correction reject form
#
sub editCorrections {
	my $params = shift;
	my $userinf = shift;
	
	my $limit = $userinf->{'prefs'}->{'pagelength'};
	my $offset = $params->{'offset'}||0;
	my $total = $params->{'total'}||-1;
	my $html = '';
	my $table = getConfig('en_tbl');
	my $cor = getConfig('cor_tbl');
	my $order = "DESC";
	my ($rv,$sth);

	$limit = int($limit /2);

	if($total == -1) {
		($rv,$sth) = dbSelect($dbh,{
			WHAT=>"count(*) as cnt",
			FROM=>"corrections,$table,users",
			WHERE=>"$table.uid=corrections.objectid and corrections.userid=users.uid and $table.userid=$userinf->{uid}"});

		my $row = $sth->fetchrow_hashref();
		$total = $row->{cnt};
		$sth->finish();
	}

	$order = "ASC" if $params->{asc};

	($rv,$sth)=dbSelect($dbh,{WHAT=>"corrections.*,$table.title as objtitle,users.username",
		 FROM=>"corrections,$table,users",
		 WHERE=>"$table.uid=corrections.objectid and corrections.userid=users.uid and $table.userid=$userinf->{uid}",
	 	'ORDER BY'=>'filed',
		'OFFSET'=>$offset,
		'LIMIT'=>$limit,
		$order=>''});

	if (! $rv) {
		return errorMessage("Error with query. Contact admin (unless you are an admin-- then panic.)");
	}

	my @rows = dbGetRows($sth);

	$html .= "<center>(edit <a href=\"".getConfig("main_url")."/?op=editfiledcors\">your filed corrections</a>)</center>";
	$html .= "<p>";

	if ($sth->rows() > 0 ) {
		my $i = 1;
		$html .= "<table>";
		$html .= "<tr><td colspan=\"2\" align=\"center\">status, date</td><td width=\"90%\" align=\"center\">correction and object title</td><td align=\"center\">by user</td></tr>";
		foreach my $row (@rows) {
			my $ar = "<div title=\"rejected\">x</a>";
			my $bg = ($i % 2 == 1) ? "bgcolor=\"#eeeeee\"" : '';
			$html .= "<tr $bg>";
			if (not defined $row->{closed}) {
				$ar = "[<a href=\"".getConfig("main_url")."/?op=rejectcor&amp;id=$row->{objectid}&amp;correct=$row->{uid}\" title=\"reject this correction\">x</a>|<a href=\"".getConfig("main_url")."/?op=edit&amp;from=$table&amp;id=$row->{objectid}&amp;correct=$row->{uid}\" title=\"accept this correction\">+</a>]";
			} else {
				$ar = "<div title=\"accepted\">+</div>" if ($row->{accepted} == 1);
				$ar = "<div title=\"retracted\">-</div>" if ($row->{accepted} == 2);
			}
			my $date = ymd($row->{filed});
			$html .= "<td align=\"center\">$ar</td>";
			$html .= "<td valign=\"top\">$date</td>";
			$html .= "<td valign=\"top\"><a href=\"".getConfig("main_url")."/?op=getobj&amp;from=$cor&amp;id=$row->{uid}\">$row->{title}</a><br>to: <a href=\"".getConfig("main_url")."/?op=getobj&amp;from=$table&amp;id=$row->{objectid}\">$row->{objtitle}</a></td>";
			$html .= "<td valign=\"top\"><a href=\"".getConfig("main_url")."/?op=getuser&amp;id=$row->{userid}\">$row->{username}</a></td>";
			$html .= "</tr>";
			$i++;
		}
		$html .= "</table>";
		$html .= "<br>";
		$html .= "<center><font size=\"-1\">(For entries where '[x|+]' appears, click on 'x' to reject the correction and '+' to accept it.)</font></center>";
		$html .= getPager({op=>'editcors', total=>$total, offset=>$offset},$userinf,2);
	}
	else {
		$html .= "No corrections";
	}

	return paddingTable(clearBox("Corrections to Your Objects",$html));
}

# edit your filed corrections. leads off to either object viewer or special
# correction retract form
#
sub editFiledCorrections {
	my $params = shift;
	my $userinf = shift;
	
	my $limit = $userinf->{'prefs'}->{'pagelength'};
	my $offset = $params->{'offset'}||0;
	my $total = $params->{'total'}||-1;
	my $html = '';
	my $table = getConfig('en_tbl');
	my $cor = getConfig('cor_tbl');
	my $order = "DESC";
	my ($rv,$sth);

	$limit = int($limit /2);

	if($total == -1) {
		($rv,$sth) = dbSelect($dbh,{
			WHAT=>"count(*) as cnt",
			FROM=>"corrections,$table,users",
			WHERE=>"corrections.userid=$userinf->{uid} and $table.uid=corrections.objectid and users.uid=$table.userid"});

		my $row = $sth->fetchrow_hashref();
		$total = $row->{cnt};
		$sth->finish();
	}

	$order = "ASC" if $params->{asc};

	($rv,$sth) = dbSelect($dbh,{WHAT=>"corrections.*,$table.title as objtitle,users.username, users.uid as fromid",
		 FROM=>"corrections,$table,users",
		 WHERE=>"corrections.userid=$userinf->{uid} and $table.uid=corrections.objectid and users.uid=$table.userid",
	 	'ORDER BY'=>'filed',
		'OFFSET'=>$offset,
		'LIMIT'=>$limit,
		$order=>''});

	if (! $rv) {
		return errorMessage("Error with query. Contact admin (unless you are an admin-- then panic.)");
	}

	$html .= "<center>(edit <a href=\"".getConfig("main_url")."/?op=editcors\">corrections filed to you</a>)</center>";
	$html .= "<p>";

	my @rows = dbGetRows($sth);

	if ($sth->rows() > 0 ) {
		my $i = 1;
		$html .= "<table>";
		$html .= "<tr><td align=\"center\" colspan=\"2\">status, date</td><td width=\"90%\" align=\"center\">correction and object title</td><td align=\"center\">to user</td></tr>";
		foreach my $row (@rows) {
			my $ar = "<div title=\"rejected\">x</div>";
			my $bg = ($i % 2 == 1) ? "bgcolor=\"#eeeeee\"" : '';
			$html .= "<tr $bg>";
			if (not defined $row->{closed}) {
				$ar = "[&nbsp;<a href=\"".getConfig("main_url")."/?op=retractcor&amp;id=$row->{objectid}&amp;correct=$row->{uid}&amp;continue=editfiledcors\" title=\"retract correction\">-</a>&nbsp;]";
			} else {
				$ar = "<div title=\"accepted\">+</div>" if ($row->{accepted} == 1);
				$ar = "<div title=\"retracted\">-</div>" if ($row->{accepted} == 2);
			}
			my $date = ymd($row->{filed});
			$html .= "<td align=\"center\">$ar</td>";
			$html .= "<td valign=\"top\">$date</td>";
			$html .= "<td valign=\"top\"><a href=\"".getConfig("main_url")."/?op=getobj&amp;from=$cor&amp;id=$row->{uid}\">$row->{title}</a><br>to: <a href=\"".getConfig("main_url")."/?op=getobj&amp;from=$table&amp;id=$row->{objectid}\">$row->{objtitle}</a></td>";
			$html .= "<td valign=\"top\"><a href=\"".getConfig("main_url")."/?op=getuser&amp;id=$row->{fromid}\">$row->{username}</a></td>";
			$html .= "</tr>";
			$i++;
		}
		$html .= "</table>";
		$html .= "<br>";
		$html .= "<center><font size=\"-1\">(For entries where '[ - ]' appears, click on '-' if you'd like to retract the correction.)</font></center>";

		$html .= getPager({op=>'editfiledcors', total=>$total, offset=>$offset},$userinf,2);
	}
	else {
		$html .= "No filed corrections";
	}

	return paddingTable(clearBox("Corrections You've Filed",$html));
}

# closeCorrection
#
sub closeCorrection {
	my $params = shift;
	my $userinf = shift;
	my $directive = shift;

	my $tbl = getConfig('cor_tbl');

	return if (blank($params->{'correct'}));

	my $comment = $params->{'comment'} || "";

	my $data = lookupfield($tbl,'data',"uid=$params->{correct}");
	
	# if they left the original data as comment, take it out
	#
	if ($data =~ /^\s*\Q$comment\E\s*$/ || $comment =~ /^\s*\Q$data\E\s*$/) {
		$comment = "";
	}

	my ($rv,$sth) = dbUpdate($dbh,{WHAT => $tbl,
		SET => "closedbyid=$userinf->{uid},closed=CURRENT_TIMESTAMP,comment='".sq($comment)."',accepted=".(($directive eq 'accept')?'1':'0'),
		WHERE => "uid=$params->{correct}"});

	$sth->finish();

	# bestow points upon the user who submitted the correction, if its accepted
	#
	# APK - we no longer do this if the corrector has edit permission to the 
	# object.
	#
	my %cor = getfieldsbyid($params->{correct},$tbl,'userid,type');
	if ($directive eq 'accept' && ! can_edit($params->{id},$cor{userid})) {
		# need correction record to figure out filer
		changeUserScore($cor{userid},getScore("$cor{type}_accept"));
	}
	
	# email the user who submitted the correction
	#
	mailCloseCorrectionNotice($params,$userinf,$directive);

	# notify users who have a watch on this correction
	#
	my $noticesubj = 'correction '.$directive.'ed';	# correct.ed or reject.ed
	my $senthash = {$cor{userid} => 1};		# omit filer id
	updateEventWatches($params->{correct},	# object pointer
		$tbl, 
		$userinf->{uid},		# event initiating user
		$comment,				# accept/reject comment as body
		$noticesubj,			# subject of notice
		$senthash				# people to omit
	);
	
	$sth->finish();
}

# retract a correction (this is done by the filer)
#
sub retractCorrection {
	my $params = shift;
	my $userinf = shift;

	my $tbl = getConfig('cor_tbl');

	return if (blank($params->{correct}));

	my $comment = $params->{comment} || '';
	
	my ($rv,$sth) = dbUpdate($dbh,{WHAT => $tbl,
		SET => "closedbyid=$userinf->{uid},closed=CURRENT_TIMESTAMP,comment='".sq($comment)."',accepted=2",
		WHERE => "uid=$params->{correct}"});

	$sth->finish();

	# email the user who owns the object
	#
	mailRetractCorrectionNotice($params,$userinf);

	# notify users who have a watch on this correction
	#
	my $noticesubj = 'correction retracted';
	my $senthash = {$userinf->{uid} => 1};	# omit filer id
	updateEventWatches($params->{correct},	# object pointer
		$tbl, 
		$userinf->{uid},		# event initiating user
		$comment,				# retract comment as body
		$noticesubj,			# subject of notice
		$senthash				# people to omit
	);
	
	$sth->finish();
}

# getCorrectionForm - this is the correction form that gets embedded into
#	an object editor.
#
sub getCorrectionForm {
	my $params = shift;
	my $closetype = shift;
	
	my $id = $params->{id};
	my $html = '';

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'*',
	 FROM=>'corrections',
	 WHERE=>"objectid=$id and closed is null"});

	my @rows = dbGetRows($sth);
	
	return '' if ($sth->rows() < 1);

	my $ctext = '';

	$html = "Correction to $closetype: <select name=\"correct\">";
	$html .= "<option value=\"\">[none]</option>";
	foreach my $row (@rows) {
		my $title = htmlescape($row->{title});
		if ($params->{correct} == $row->{uid}) {
			$html .= "<option value=\"$row->{uid}\" selected=\"selected\">#$row->{uid}: $title</option>";
			$ctext = $row->{data};
		} else {
			$html .= "<option value=\"$row->{uid}\">#$row->{uid}: $title</option>";
		}
	}
	$html .= "</select>";
	
	my $comment = $params->{comment}||$ctext;
	$html .= "<br />Comment (edit me):<br /> <textarea name=\"comment\" rows=\"8\" cols=\"75\">" . htmlescape($comment) . "</textarea>";

	my $ct = ucfirst($closetype);
	my $bg = ($closetype eq "accept")?"bgcolor=\"#eeeeee\"":"";
	return "
	 <table width=\"100%\">
	 <tr>
	 <td $bg align=\"center\">
	<table><tr><td> 
		<center><font size=\"+1\">$ct A Correction</font></center>
		<br />
		 $html
		<br />
	</td></tr></table>
	 </td>
	 </tr>
	 </table>
	 <br />";
}

# getRetractCorrectionForm - get the details of the form for retracting a 
#   correction, including selector to pick other corrections
#
sub getRetractCorrectionForm {
	my $params = shift;
	my $userinf = shift;
	
	my $html = '';

	my $userid = lookupfield(getConfig('cor_tbl'), 'userid', "uid=$params->{correct}");

	return errorMessage("You cannot retract a correction you didn't file!") if ($userinf->{uid} != $userid);

	my $title = lookupfield(getConfig('cor_tbl'), 'title', "uid=$params->{correct}");

	my $comment = $params->{comment} || '';
	$html .= "<br />Comment:<br /> <textarea name=\"comment\" rows=\"5\" cols=\"75\">" . htmlescape($comment) . "</textarea>";
	my $continue = $params->{'continue'} || 'viewcor';
	$html .= "<input type=\"hidden\" name=\"continue\" value=\"$continue\"/>";
	$html .= "<input type=\"hidden\" name=\"correct\" value=\"$params->{correct}\"/>";

	return "
	 <table width=\"100%\">
	 <tr>
	 <td align=\"center\">
	 <table><tr><td> 
		<center><font size=\"+1\">Retracting correction '$title'</font></center>
		 $html
		<br />
	</td></tr></table>
	 </td>
	 </tr>
	 </table>
	 <br />";
}

# getCorrections : get all corrections for an object
#
sub getCorrections {
	my $params = shift;
	my $userinf = shift;
	
	my $id = $params->{id};
	my $html = '';
	my $table = getConfig('en_tbl');
	my $cor = getConfig('cor_tbl');
 
	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'corrections.*,users.username', FROM=>'corrections,users', WHERE=>"corrections.userid=users.uid and objectid=$id", 'ORDER BY'=>'filed', DESC=>''});

	if (! $rv) {
		return errorMessage("Error with query. Contact admin");
	}

	my @rows = dbGetRows($sth);

	if ($sth->rows() > 0 ) {
		my $i = 1;
		foreach my $row (@rows) {
			$html .= "$i. <a href=\"".getConfig("main_url")."/?op=getobj&amp;from=$cor&amp;id=$row->{uid}\">$row->{title}</a> by <a href=\"".getConfig("main_url")."/?op=getuser&amp;id=$row->{userid}\">$row->{username}</a> on $row->{filed} ";
		my $messages = msgCountWithNew($cor,$row->{uid},$userinf->{uid});

		if (defined $row->{closed}) {
		$html .= "(retracted)" if ($row->{accepted} == 2);
		$html .= "(accepted)" if ($row->{accepted} == 1);
		$html .= "(rejected)" if ($row->{accepted} == 0);
		} else {
			$html .= "(pending)";
		}
		$html .= " $messages<br>";
		$i++;
		}
	}
	else {
		$html .= "None.";
	}

	$html .= "<br><center>[ <a href=\"".getConfig("main_url")."/?op=getobj&amp;from=$table&amp;id=$id\">back</a> ]</center>";
	
	my %object = getfieldsbyid($id,getConfig('en_tbl'),'title'); 
	my $title = $object{title};
	return paddingTable(clearBox("Corrections for $title",$html));
}

# renderCorrection - format and output a correction record. meant to be called
#	from main GetObj function.
#
sub renderCorrection {
	my $params = shift;
	my $userinf = shift;
	
	my $id = $params->{'id'};
	my $html = '';
	my $pending = 0;
	my $table = getConfig('en_tbl');

	my $template = new Template('corobj.html');
	 
	my $sth = $dbh->prepare("select corrections.*, $table.userid as ownerid, u1.username as ownername, u2.username as filername, u2.uid as filerid, u3.username as closername from corrections, users u1, users u2, users u3, $table  where corrections.closedbyid = u3.uid and corrections.objectid = $table.uid and corrections.userid = u2.uid and $table.userid = u1.uid and corrections.uid = $id");
	my $rv = $sth->execute();

	if (! $rv) {
		return "Error with query. Contact admin";
	}

	if ($sth->rows() <= 0) {
		return errorMessage("Couldn't find that record!");
	}
 
	my $rec = $sth->fetchrow_hashref();

	# format and output record
	#
	$html .= "<center>$rec->{title} by <a href=\"".getConfig("main_url")."/?op=getuser&amp;id=$rec->{userid}\">$rec->{filername}</a></center><br>";
	$html .= "Correction id: $rec->{uid}<br>";
	$html .= "Filed on: $rec->{filed}<br>";
	$html .= "Status: ";
	if (defined $rec->{closed}) {
		$html .= "<b>";
		$html .= "Accepted" if ($rec->{'accepted'} == 1);
		$html .= "Rejected" if ($rec->{'accepted'} == 0);
		$html .= "Retracted" if ($rec->{'accepted'} == 2);
		$html .= "</b> on $rec->{closed}";
	} else {
		$html .= "<b>Pending</b>";
		$pending = 1;
	}
	$html .= "<br>";
	my %thash = %{getConfig('correction_types')};
	%thash = reverse %thash;
	$html .= "Type: $thash{$rec->{type}}";
	$html .= "<br><br>";
	$html .= "Correction text:";
	$html .= "<br>";
	my $text = stdmsg($rec->{data});
	
	$html .= "<table width=\"100%\" cellpadding=\"5\"> <td bgcolor=\"#ffffff\"> $text </td> </table>";
	if ($pending) {
		if ($rec->{'ownerid'} == $userinf->{'uid'} ||
			can_edit( $userinf->{'uid'}, $rec->{'objectid'}, 
				$table )) {
#			hasPermissionTo($table,$rec->{'objectid'},$userinf,'write')) {

			$html .= "<center>[ ";
			$html .= "<a href=\"".getConfig("main_url")."/?op=rejectcor&amp;id=$rec->{objectid}&amp;correct=$rec->{uid}\">x</a> ";
			$html .= "| <a href=\"?op=edit&amp;from=$table&amp;id=$rec->{objectid}&amp;correct=$rec->{uid}\">+</a> ";
			
			# only owners can xfer
			if ($rec->{'ownerid'} == $userinf->{'uid'}) {
				$html .= "| <a href=\"?op=sendobj&amp;from=$table&amp;id=$rec->{objectid}&amp;user=$userinf->{uid}&amp;touser=$rec->{userid}\">transfer</a>"
			}

			$html .= " ]</center>";
		}

		# viewing user is also filer -- add "retract" control
		#
		if ($rec->{'userid'} == $userinf->{'uid'}) {
			$html .= "<center>[ <a href=\"".getConfig("main_url")."/?op=retractcor&amp;id=$rec->{objectid}&amp;correct=$rec->{uid}&amp;continue=viewcor\">retract this correction</a> ]</center>";
		}
	} else {
		if (defined $rec->{'comment'}) {

			my $who = '';

			# accepted or rejected by object owner
			if ($rec->{'accepted'} <= 1) {
				$who = ((($rec->{'closedbyid'} != 0) && ($rec->{'closedbyid'} != $rec->{'ownerid'})) ? 'correction handler' : 'object owner');
			} 
			# retracted by correction filer
			else {
				$who = "correction filer";
			}

			if (nb($rec->{'comment'})) {
				my $comment = stdmsg($rec->{'comment'});
				$html .= "<br>Comment from $who <a href=\"".getConfig("main_url")."/?op=getuser&amp;id=$rec->{closedbyid}\">$rec->{closername}</a>:";
				$html .= "<br>";
				$html .= "<table width=\"100%\" cellpadding=\"5\"> <td bgcolor=\"#ffffff\"> $comment </td> </table>";
			} else {
				$html .= "<br>No comment from $who <a href=\"".getConfig("main_url")."/?op=getuser&amp;id=$rec->{closedbyid}\">$rec->{closername}</a>.";
			}
		} 
	}
	
	my %object = getfieldsbyid($rec->{objectid},$table,'title'); 
	my $title = $object{title};
	
	my $up = getUpArrow("".getConfig("main_url")."/?op=getobj&amp;from=$table&amp;id=$rec->{objectid}",'parent');
	my $correction = makeBox("$up Viewing Correction to '$title'",$html);

	my $interact = getCorrectionInteract($rec);

	$template->setKey('correction',$correction);
	$template->setKey('interact',$interact);

	return $template;
}

# return 1 if an object has *pending* corrections, 0 otherwise
# 
sub hascorrections {
	my $tbl = shift;
	my $id = shift;

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'count(uid) as cnt',FROM=>'corrections',WHERE=>"objectid=$id and closed is null"});

	if (!$rv) {
		$sth->finish();
	return 0;
	}

	my $row = $sth->fetchrow_hashref();
	$sth->finish();
	
	return ($row->{cnt} > 0 ? 1 : 0);
}

# countPendingCorrections
# 
sub countPendingCorrections {
	my $userinf=shift;
	my $table=getConfig('en_tbl');
	
	# if we ever expand correction domains, this will have to be a union 
	#
	my ($rv,$sth)=dbSelect($dbh,{WHAT=>'count(corrections.uid) as cnt',
															 FROM=>"corrections,$table",
								 WHERE=>"corrections.objectid=$table.uid and $table.userid=$userinf->{uid} and corrections.closed is null"
								 });

	my $row=$sth->fetchrow_hashref();
	$sth->finish();
	return $row->{cnt};
}

# countGlobalPendingCorrections
#
sub countGlobalPendingCorrections {
	my $table=getConfig('en_tbl');
	
	# TODO: if we ever expand correction domains, this will have to be a union 
	#
	my ($rv,$sth)=dbSelect($dbh,{WHAT=>'count(corrections.uid) as cnt',
								 FROM=>"corrections,$table",
								 WHERE=>"corrections.objectid=$table.uid and corrections.closed is null"
								 });

	my $row=$sth->fetchrow_hashref();
	$sth->finish();
	return $row->{cnt};
}

# getPendingCorrections
#
sub getPendingCorrections {
	my $id = shift;
	
	my $html = '';

	my $cor = getConfig('cor_tbl');
	
	my ($rv,$sth)=dbSelect($dbh,{WHAT=>'corrections.*,users.username',
															 FROM=>'corrections,users',
								 WHERE=>"corrections.userid=users.uid and objectid=$id and corrections.closed is null",
								 'ORDER BY'=>'filed',
								 DESC=>''});

	if (! $rv) {
		return "Error with query. Contact admin";
	}

	my @rows=dbGetRows($sth);

	if ($sth->rows() > 0 ) {
		my $i=1;
		foreach my $row (@rows) {
			$html.="$i. <a href=\"".getConfig("main_url")."/?op=getobj&amp;from=$cor&amp;id=$row->{uid}\">$row->{title}</a> by <a href=\"".getConfig("main_url")."/?op=getuser&amp;id=$row->{userid}\">$row->{username}</a> on $row->{filed}<br>";
		$i++;
		}
	}
	else {
		$html.="None.";
	}
	
	my $total=totalCorrections($id); 
	if ($total>0) {
		$html.="<center>[ <a href=\"".getConfig("main_url")."/?op=getcors&amp;id=$id\">View all $total</a> ]</center>";
	}
	
	return $html;
}

# get total corrections for a particular object id
#
sub totalCorrections {
	my $id = shift;

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'count(*) as cnt',FROM=>'corrections',WHERE=>"objectid=$id"});

	my $row = $sth->fetchrow_hashref();
	$sth->finish();

	return $row->{'cnt'};
}

# postCorrection - make a correction
#
sub postCorrection {
	my $params = shift;
	my $userinf = shift;
	
	my $template = new Template('correct.html');
	my $error = '';
	my $table = getConfig('en_tbl');
	my %obj;
	
	return errorMessage('You must be logged in to file a correction.') if ($userinf->{uid} <= 0);
	
	%obj = getfieldsbyid($params->{id},getConfig('en_tbl'),'userid');
	return errorMessage("You can't file corrections to articles you can edit.	You must <a href=\"".getConfig("main_url")."/?op=edit&amp;from=$table&amp;id=$params->{id}\">edit</a> them directly.") if ($userinf->{uid} == $obj{userid});

	if (defined $params->{post}) {
		$error = checkCorrection($params);
		if (blank($error)) {
			insertCorrection($params,$userinf);
			return paddingTable(clearBox("Correction filed","Thanks for submitting a correction. You can go back to the parent article by clicking <a href=\"".getConfig("main_url")."/?op=getobj&amp;from=$table&amp;id=$params->{id}\">here</a>."));
		}
		else {
			$template->setKey('error', $error);
			refreshCorrection($template,$params);
		}
	} 
	
	# return pristine form
	#
	else {
		$template->unsetKeys('data','title','error');
		refreshCorrection($template, $params);
	}

	return paddingTable(makeBox('File a Correction',$template->expand()));
}

# refreshCorrection - redraw the form data for a correction form
#
sub refreshCorrection {
	my $template = shift;
	my $params = shift;
	
	my $tbl = getConfig('en_tbl');

	my $tbox = getcortypebox(getConfig('correction_types'),$params->{type} || '');
	$template->setKey('from', $tbl);
	$template->setKey('type', $tbox);
	$template->setKeysIfUnset(%$params);
}

# getcortypebox - get correction type box
#
sub getcortypebox {
    my $corhash = shift;
    my $selected = shift;
	
    my $sel = '';

    $sel .= "<select name=\"type\">";
	$sel .= "<option value=\"\" ".($selected ? "selected" : '').">[select one]</option>";
    foreach my $type (keys %$corhash) {
        if (defined $selected and $selected eq $corhash->{$type}) {
            $sel .= "<option value=\"$corhash->{$type}\" selected>$type</option>";
	    } else {
            $sel .= "<option value=\"$corhash->{$type}\">$type</option>";
	    }
    }
    $sel.="</select>";

    return $sel;
}

# checkCorrection - make sure there are no error fields
#
sub checkCorrection { 
	my $params = shift;

	my $error = '';

	$error .= "Need a title!<br/>" if (blank($params->{title}));
	$error .= "Need a correction message!<br/>" if (blank($params->{data}));
	if (blank($params->{type})) {
		$error .= "You need to select a type!<br/>";
	}

	$error .= "<br/>" if (nb($error));

	return $error;
}

# insertCorrection - actually do the database inserting of the correction
#
sub insertCorrection {
	my $params = shift;
	my $userinf = shift;
	
	my $table = getConfig('cor_tbl');
	my $en = getConfig('en_tbl');

	my $newid = nextval($table."_uid_seq");

	my $gracedef;
	$gracedef = "interval '0 days'" if (getConfig('dbms') eq 'pg');
	$gracedef = "0" if (getConfig('dbms') eq 'mysql');

	my ($rv,$sth) = dbInsert($dbh,{INTO=>$table,
	 COLS=>'filed,uid,objectid,userid,graceint,type,title,data',
	 VALUES=>"now(),$newid,$params->{id},$userinf->{uid},$gracedef,".quotefields($params->{'type'},$params->{'title'},$params->{'data'})});
 
	# take care of notifying the object owner of a correction
	#
	mailCorrectionNotice($params,$userinf,$newid);

	# add a watch on the correction for filer (if permitted)
	#
	addWatchIfAllowed(getConfig('cor_tbl'),$newid,$userinf,'objwatch');

	my $ownerid = lookupfield($en,'userid',"uid=$params->{id}");

	# add a watch for the object owner 
	#
	my $ownerinf = { userInfoById($ownerid) };
	addWatchIfAllowed(getConfig('cor_tbl'), $newid, $ownerinf, 'corwatch');

	# notify all people watching this object (exclude object owner and poster)
	#
	my %sentnotice = ($ownerid=>1);
	updateWatches($params->{id},$en,$newid,$table,$userinf->{uid},'Correction filed', $params->{title},\%sentnotice);

	$sth->finish();
	
}

# mailRetractCorrectionNotice - mail the object owner that a correction to 
#  their object has been retracted
#
sub mailRetractCorrectionNotice {
	my $params = shift;
	my $userinf = shift;
	
	# need correction record to figure out object owner and other stuff
	#
	my %cor = getfieldsbyid($params->{correct},'corrections','uid,userid,objectid,title,type,data,comment');
	
	# get data for object
	#
	my %object = getfieldsbyid($cor{objectid},getConfig('en_tbl'),'uid,userid,title');

	# get data for object owner
	#
	my %owner = getfieldsbyid($object{userid},'users','email,prefs');
	my $prefs = parsePrefs($owner{prefs});
	
	# send notice only if user doesn't want email 
	#
	if (not $prefs->{corecloseemail} eq "on") {
		fileNotice($cor{userid}, 
		 $userinf->{uid}, 
			 "Correction retracted for $object{title}",
			 "User $userinf->{data}->{username} has retracted the correction entitled '$cor{title}.'",
			 [{id=>$object{uid},table=>getConfig('en_tbl')},
				{id=>$cor{uid},table=>getConfig('cor_tbl')}]);
		return;
	}

	my $url = getConfig('main_url')."/?op=getobj&amp;from=corrections&amp;id=$cor{uid}";

	my %thash = %{getConfig('correction_types')};
	%thash = reverse %thash;

	my $subject = "Correction retracted for '$object{title}'";
	my $body = "
Title: $cor{title}
URL: $url
Closed by: $userinf->{data}->{username}
Type: $thash{$cor{type}}
-------------------------------------
Original message:
$cor{data}
-------------------------------------
Closing comment:
$cor{comment}
-------------------------------------
If you do not want to receive these messages any more, unset 'receive email when your corrections are closed' in your preferences.
		";
	
	# send the message
	#
	sendMail($owner{email},$body,$subject);
}

# mailCloseCorrectionNotice - mail the submitter of correction that their 
#							 correction has been closed (if they allow this.)
#
sub mailCloseCorrectionNotice {
	my $params = shift;
	my $userinf = shift;
	my $directive = shift;
	
	# need correction record to figure out filer
	#
	my %cor = getfieldsbyid($params->{correct},'corrections','uid,userid,objectid,title,type,data,comment');
	
	# get data for object
	#
	my %object = getfieldsbyid($cor{objectid},getConfig('en_tbl'),'uid,userid,title');

	# get data for correction owner
	#
	my %owner = getfieldsbyid($cor{userid},'users','email,prefs');
	my $prefs = parsePrefs($owner{prefs});
	
	# send notice only if user doesn't want email 
	#
	if (not $prefs->{corecloseemail} eq "on") {
		fileNotice($cor{userid}, 
						 $userinf->{uid}, 
				 "Correction ${directive}ed for $object{title}",
				 "User $userinf->{data}->{username} has ${directive}ed the correction entitled '$cor{title}.'",
				 [{id=>$object{uid},table=>getConfig('en_tbl')},
					{id=>$cor{uid},table=>getConfig('cor_tbl')}]);
	return;
	}

	my $url = getConfig('main_url')."/?op=getobj&amp;from=corrections&amp;id=$cor{uid}";

	my %thash = %{getConfig('correction_types')};
	%thash = reverse %thash;
	
	my $subject = "Correction ${directive}ed for '$object{title}'";
	my $body = "
Title: $cor{title}
URL: $url
Closed by: $userinf->{data}->{username}
Type: $thash{$cor{type}}
-------------------------------------
Original message:
$cor{data}
-------------------------------------
Closing comment:
$cor{comment}
-------------------------------------
If you do not want to receive these messages any more, unset 'receive email when your corrections are closed' in your preferences.
		";
	
	# send the message
	#
	sendMail($owner{email},$body,$subject);
}

# mailCorrectionNotice - mail the owner of the object a correction notice
#												if they allow this.
#
sub mailCorrectionNotice {
	my $params = shift;
	my $userinf = shift;
	my $corid = shift;
	
	# get data for object
	#
	my %object = getfieldsbyid($params->{id},getConfig('en_tbl'),'uid,userid,title');

	# get data for object owner
	#
	my %owner = getfieldsbyid($object{userid},'users','email,prefs');
	my $prefs = parsePrefs($owner{prefs});
	
	# send notice if owner doesn't want email 
	#
	if (not $prefs->{coremail} eq "on") {
		fileNotice($object{userid},
						 $userinf->{uid},
				 "Correction filed for '$object{title}'",
				 "Correction entitled '$params->{title}' filed by $userinf->{data}->{username}",
				 [{id=>$object{uid},table=>getConfig('en_tbl')},
					{id=>$corid, table=>getConfig('cor_tbl')}]);
		return;
	}
	my $url = getConfig('main_url')."/?op=getobj&amp;from=corrections&amp;id=$corid";

	my $subject = "Correction filed for '$object{title}'";
	my $body = "
Title: $params->{title}
URL: $url
Filed by: $userinf->{data}->{username}
Type: $params->{type}
-------------------------------------
Correction message:
$params->{data}
-------------------------------------
To accept or reject this correction, log in to ".getConfig('projname')." and select 'corrections' from the user box.  From this screen you get a list of corrections to your objects, and you can click on 'reject' or 'accept' for any pending correction.

You can also transfer ownership of objects to the user that filed the 
correction.  To do this, follow the procedure above and then click on the 
correction title to view it.  From here, you can click on 'transfer'. 
Keep in mind that transfers can be declined by the other user.

If you do not want to receive these messages any more, unset 'receive email for corrections' in your preferences.
	";
	
	# send the message
	#
	sendMail($owner{email},$body,$subject);
}

1;
