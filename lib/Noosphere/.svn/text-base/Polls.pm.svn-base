package Noosphere;
use strict;

# add a poll
#
sub addPoll {
	my $params = shift;
	my $userinf = shift;

	my $template = new XSLTemplate('newpoll.xsl');
	
	my $error = '';
	
	$template->addText('<newpoll>');

	if (defined($params->{submit})) {
		$error = checkNewPoll($params);
		$template->addText("<error>$error</error>") if $error;
		$template->setKeys(%$params);
		if ($error eq "") {
			return insertNewPoll($params,$userinf);
		}
	} else {
		# init
		$template->setKey('ttl', '7');
	}
 
	$template->addText('</newpoll>');

	return $template->expand();
}

# insert a new poll to the database
#
sub insertNewPoll {
	my $params = shift;
	my $userinf = shift;
 
	my $tbl = getConfig('polls_tbl');

	my $nextid = nextval($tbl.'_uid_seq');

	my $ttl = "$params->{'ttl'} DAY";
	$ttl =~ s/^\s*//;
	$ttl =~ s/\s*$//;

	my ($rv,$sth);
	
	($rv, $sth) = dbInsert($dbh,{
		INTO=>'polls',
		COLS=>'uid,userid,start,finish,options,title',
		VALUES=>"$nextid,$userinf->{uid},now(),CURRENT_TIMESTAMP + interval '$ttl','".sq($params->{response})."','".sq($params->{question})."'"}
	) if (getConfig('dbms') eq 'pg');

	($rv, $sth) = dbInsert($dbh,{
		INTO=>'polls',
		COLS=>'uid,userid,start,finish,options,title',
		VALUES=>"$nextid,$userinf->{uid},now(),CURRENT_TIMESTAMP + interval $ttl,'".sq($params->{response})."','".sq($params->{question})."'"}
	) if (getConfig('dbms') eq 'mysql');
								 
	if (!$rv) {
		dwarn "error inserting poll";
		return errorMessage("Could not insert poll!");
	}

	$sth->finish();

	return paddingTable(makeBox('Poll created',"Your poll has been successfully created. You should go vote!"));
}

# error checking on new poll data
#
sub checkNewPoll {
	my $params = shift;
	my $error = "";

	if (not defined($params->{question}) or $params->{question} eq "") {
		$error .= "Need a poll question<br />";
	}
	if (not defined($params->{response}) or $params->{response} eq "") {
		$error .= "Need poll responses<br />";
	}
	if (not defined($params->{ttl}) or $params->{ttl} eq "") {
		$error .= "Need a poll time-to-live<br />";
	} else {
		if ($params->{'ttl'} !~ /^\s*\d+\s*$/) {
			$error .= "time-to-live is of the wrong format<br />";
		}
	}

	return $error;
}

# get html for an arbitrary poll (to vote)
#
sub getPoll {
	my $params = shift;
	
	my $html = '';

	(my $rv, my $sth) = dbSelect($dbh,{WHAT=>'title,options,uid',
		 FROM=>'polls',
		 WHERE=>"uid=$params->{id}",
		 LIMIT=>1});

	if (! $rv) {
		dwarn "poll query failed!\n";
		return "poll query failed!";
	}
	
	my $row = $sth->fetchrow_hashref();
	$sth->finish();
	
	$html .= "<table width=\"100%\" cellpadding=\"0\" cellspacing=\"1\">";
	$html .= "<tr><td>$row->{title}</td></tr>";
	$html .= "<tr><td>";
	$html .= "<form method=post action=\"/\">";
	my @options = split(/,/,$row->{options});
	foreach my $option (@options) {
		$html .= "<input type=\"radio\" name=\"option\" value=\"".qhtmlescape($option)."\">".htmlescape($option)."<br>";
	}
	$html .= "</tr></td><tr><td align=\"center\">";
	$html .= "<input type=\"hidden\" name=\"op\" value=\"vote\">";
	$html .= "<input type=\"hidden\" name=\"id\" value=\"$row->{uid}\">";
	$html .= "<input type=\"submit\" value=\"vote\">";
	$html .= "<a href=\"".getConfig("main_url")."/?op=getobj&from=polls&id=$row->{uid}\">(results)</a>";
	$html .= "</tr></td></form>";
 
	$html .= "</table>";

	return paddingTable(clearBox('Vote in Poll',$html));

}

# get html for current poll, that fits on the toolbar
#
sub getCurrentPoll {
	my $html = "";

	(my $rv, my $sth) = dbSelect($dbh,{WHAT=>'title,options,uid',
	 FROM => 'polls',
	 WHERE => 'start<CURRENT_TIMESTAMP and finish>CURRENT_TIMESTAMP',
	 'ORDER BY' => 'start',
	 'DESC' => '',
	 LIMIT => 1});

	if (! $rv) {
		dwarn "poll query failed!\n";
		return "poll query failed!";
	}
	
	my @rows = dbGetRows($sth);
	
	if ($#rows < 0) {
		return clearBox('Current Poll',"No open <a href=\"".getConfig("main_url")."/?op=viewpolls\">polls</a>.");
	}

	my $row = $rows[0];			# we should only have one row (LIMIT 1)
 
	$html.="<table width=\"100%\" cellpadding=\"0\" cellspacing=\"1\">";
	$html.="<tr><td><font size=\"-1\">$row->{title}</font></td></tr>";
	$html.="<tr><td><font size=\"-1\">";
	$html.="<form method=post action=\"/\">";
	my @options=split(/,/,$row->{options});
	foreach my $option (@options) {
		$html.="<input type=\"radio\" name=\"option\" value=\"".qhtmlescape($option)."\">".htmlescape($option)."<br>";
	}
	$html.="</font></tr></td><tr><td align=\"center\">";
	$html.="<input type=\"hidden\" name=\"op\" value=\"vote\">";
	$html.="<input type=\"hidden\" name=\"id\" value=\"$row->{uid}\">";
	$html.="<input type=\"submit\" value=\"vote\">";
	$html.="<font size=\"-1\"><a href=\"".getConfig("main_url")."/?op=getobj&from=polls&id=$row->{uid}\">(results)</a></font>";
	$html.="</tr></td></form>";

	$html.="</table>";
	return clearBox('Current Poll',$html);
}

# actually process a vote
#
sub vote {
	my $params = shift;
	my $userinfo = shift;

	my $tbl = getConfig('action_tbl');

	my $error = checkVote($params,$userinfo);
	if ($error ne "") { return $error; }

	my $nextid = nextval($tbl.'_uid_seq');

	(my $rv, my $sth) = dbInsert($dbh,{INTO=>$tbl,
									 COLS=>'uid,type,objectid,userid,data',
									 VALUES=>"$nextid,".ACT_VOTE.",$params->{id},$userinfo->{uid},'".sq($params->{option})."'"});
	$sth->finish();

	if (! $rv) {
		dwarn "error voting!\n";
		return "error voting";
	}

	# give the user points for voting
	#
	changeUserScore($userinfo->{uid},getScore('vote'));

	$params->{voted}=1;
	$params->{from}='polls';
	return getObj($params,$userinfo);
	#return viewPoll($params,$userinfo,1);
}

# sanity checks for voting ability
#
sub checkVote { 
	my $params=shift;
	my $userinfo=shift;
	my $error="";
	my $template=new Template('error.html');
	
	# some basic checks
	#
	if (not defined($params->{'option'})) {
		$error.="You must select an option.<br>";
	}
	if ($userinfo->{uid} == -1) {
		$error.="You must be logged in to vote.<br>";
	}

	# check actions table to see if we've already voted
	#
	(my $rv,my $sth)=dbSelect($dbh,{WHAT=>'uid',
																	FROM=>'actions',
									WHERE=>"userid=$userinfo->{uid} and objectid=$params->{id} and type=".ACT_VOTE});
	if (! $rv) {
		dwarn "error checking actions table";
	$error.="Could not determine if you have already voted.";
	} else {
		if ($sth->rows() > 0) {
		$error.="You can't vote in this poll twice!";
	}
	}

	# report any errors we found
	#
	if ($error ne "") {
		$template->setKey('error', $error);
		return paddingTable(makeBox('Error',$template->expand()));
	} else {
		return "";
	}
}

# display a list of all polls which allows us to view any particular poll.
#
sub viewPolls {
	my $html = '';
	
	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'uid,title,start,finish,(start<=CURRENT_TIMESTAMP and finish>CURRENT_TIMESTAMP) as opened', 
		FROM=>'polls',
		'ORDER BY'=>'start',DESC=>''});

	if (! $rv) {
		return errorMessage("Poll query failed!");
	}

	my @rows = dbGetRows($sth);

	if (@rows) {
		foreach my $row (@rows) {
			my $start = ymd($row->{start});
			my $finish = ymd($row->{finish});
			if ($row->{opened}) {
				$html .= "[<a href=\"".getConfig("main_url")."/?op=getpoll&id=$row->{uid}\">vote</a>] ";
			}
			$html .= "<a href=\"".getConfig("main_url")."/?op=getobj&from=polls&id=$row->{uid}\">$row->{title}</a> ";
		$html.="<font size=\"-1\">($start to $finish) </font><br>";
		}
	} else {
		$html .= "No polls.";
	}


	return paddingTable(clearBox('Polls',$html));
}

# view results for a poll 
#
sub viewPoll {
	my $params = shift;
	my $userinf = shift;
	
	my $voted = (defined $params->{voted})?$params->{voted}:0;
	my $id = $params->{id};
	
	my $maxpels = getConfig('votingbar_pels');
	my $maxchars = getConfig('votingbar_chars');
	my $table = getConfig('polls_tbl');
	my $maxvotes = 0;
	my $desc = 0;
	my $total = 0;

	my $template = new Template('pollobject.html');

	my $html = '';

	(my $rv,my $sth)=dbSelect($dbh,{WHAT=>'*',
		FROM=>$table,
		WHERE=>"uid=$id",LIMIT=>"1"});

	my $poll=$sth->fetchrow_hashref();
	my @options=split(/,/,$poll->{options});

	$html.="<table width=\"100%\" cellpadding=\"2\" cellspacing=\"0\">";
	$html.="<tr><td colspan=\"3\" align=\"center\">$poll->{title}</td></tr>";
	
	# spacer row for w3m
	#
	$html.="<tr><td colspan=\"3\" align=\"center\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td></tr>";

	my %counts;
	
	# pass one - get a total, get the largest count, build count hash.
	#
	foreach my $option (@options) {
		my $count = getOptionCount($poll->{uid},$option);
		$counts{$option} = $count;
		if ($count > $maxvotes) { $maxvotes=$count; }
		$total += $count;
	}

	# pass two - draw graph
	#
	my $ord = 1;
	foreach my $option (@options) {
		my $color = ($ord % 2 == 1) ? '#eeeeee' : '#ffffff';
		$html .= "<tr bgcolor=\"$color\">";
		my $width = $maxvotes ? ($counts{$option}*$maxpels)/$maxvotes : 0;
		my $chars = $maxvotes ? ($counts{$option}*$maxchars)/$maxvotes : 0;
		my $barchar = getConfig('votingbar_char');
		my $bar = " ";
		for (my $i=0;$i<$chars;$i++) { $bar="$bar$barchar"; }
			$html .=" <td width=\"50\">$option</td><td align=\"left\"><img alt=\"$bar\" src=\"".getConfig('image_url')."/votingbar.png\" width=\"$width\" height=\"22\"></td>";
			$html .= "<td align=\"center\">($counts{$option})</td>";
			$html .= "</tr>";
			$ord++;
		}
	
		# pass 3 - show percentage summary
		#
		my @pcts = ();
		foreach my $option (@options) {
		my $pct = ($counts{$option}*100)/$total;
		my $str = sprintf "%3.1f",$pct;
		push @pcts,"$option=$str%";
	}
	$html .= "<tr><td colspan=\"3\" align=\"center\">".join(', ',@pcts)."</td></tr>";
	
	$html .= "<tr><td colspan=\"3\" align=\"center\">$total people voted total.</td></tr>";
	$html .= "</table>";

	my $content = clearBox("Viewing Poll", $html); 

	my $interact = makeBox('Interact',"<center><a href=\"".getConfig("main_url")."/?op=postmsg&from=$table&id=$id\">post</a></center>");

	$template->setKeys('pollobj' => $content, 'interact' => $interact);

	return $template;
}

# return a count of votes for each option of a poll
#
sub getOptionCount {
	my $id = shift;
	my $option = shift;

	(my $rv,my $sth)=dbSelect($dbh,{WHAT=>'count(uid) as ct',
																	FROM=>'actions',
									WHERE=>"type=".ACT_VOTE." and objectid=$id and data='".sq($option)."'"});
	 
	my $row=$sth->fetchrow_hashref();
	my $count=$row->{ct};

	return $count;
}

1;

