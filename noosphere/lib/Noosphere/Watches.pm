package Noosphere;

use strict;

# toggle watch on an object, for a user
#
sub changeWatch {
	my $params = shift;
	my $userinf = shift;
	my $table = shift;
	my $id = shift;
	
	if (defined $params->{watch} && $userinf->{uid} > 0) {
			if ($params->{watch} eq "add") {
			addWatch($table, $id, $userinf->{uid});
		}
		elsif ($params->{watch} eq "remove") {
			delWatchByInfo($table, $id, $userinf->{'uid'});
		} 
	}
}

# show a list of all people watching an object
#
sub showWatchers {
	my $params = shift;
	
	my $table = $params->{from};
	my $id = $params->{id};

	my $template = new XSLTemplate('showwatchers.xsl');

	my @watches = getWatches($table, $id);

	my $objtitle = lookuptitle($table, $id);

	$template->addText("<watchlist objtitle=\"$objtitle\">\n");
	my $ord = 1;
	foreach my $wid (@watches) {
	my $userid = lookupfield(getConfig('watch_tbl'),'userid',"uid=$wid");
	my $username = lookupfield(getConfig('user_tbl'),'username',"uid=$userid");

	$template->addText("	<watcher ord=\"$ord\" name=\"$username\" href=\"".getConfig("main_url")."/?op=getuser;id=$userid\"/>\n");
	$ord++;
	}
	$template->addText("</watchlist>\n");

	return $template->expand();
}

# get a watch toggling widget for a (table,object,user) triplet.
#
sub getWatchWidget {
	my $params = shift;
	my $userinf = shift;

	my $table = $params->{'from'};
	my $objectid = $params->{'id'};
	my $userid = $userinf->{'uid'};

	my $formvars = hashToFormVars($params,['watch']) || '';

	my $watch = '';

	if ($userid > 0) {
		if (hasWatch($table,$objectid,$userid)) {
			$watch = "<form method=\"get\" action=\"/\">
			<a href=\"".getConfig("main_url")."/?op=showwatchers&amp;from=$table&amp;id=$objectid\" title=\"click here to see who is watching this object.\">Watch</a>:	
			$formvars
			<input class=\"small\" type=\"submit\" name=\"watch\" value=\"remove\"/></form>";
		} else {
			$watch = "<form method=\"get\" action=\"/\">
			<a href=\"".getConfig("main_url")."/?op=showwatchers&amp;from=$table&amp;id=$objectid\" title=\"click here to see who is watching this object.\">Watch</a>: 
			$formvars
			<input class=\"small\" type=\"submit\" name=\"watch\" value=\"add\"/></form>";
		}
	} else {
		$watch = '';
	} 

	return $watch;
}


# get user watch list
#
sub listWatches {
	my $params = shift;
	my $userinf = shift;
	
	my $offset = $params->{'offset'}||0;
	my $total = $params->{'total'}||-1;
	#my $page=getConfig('listings_page');
	my $page = $userinf->{'prefs'}->{'pagelength'};

	my $html .= '';
	my $wtbl = getConfig('watch_tbl');
	
	my ($rv,$sth);

	# handle deleting
	#
	if (defined $params->{'delsel'}) {
		foreach my $key (keys %$params) {
			if ($key =~ /^del_([0-9]+)/) {
				($rv,$sth) = dbDelete($dbh,{FROM=>$wtbl,WHERE=>"uid=$1"});
			}
		}
		$total = -1;	 # force recalculating new total.
	} 
	elsif (defined $params->{'delall'}) {
		($rv,$sth) = dbLowLevelSelect($dbh,"select uid from $wtbl where userid=$userinf->{uid} offset $offset limit $page") if getConfig('dbms') eq 'pg';
		($rv,$sth) = dbLowLevelSelect($dbh,"select uid from $wtbl where userid=$userinf->{uid} limit $offset, $page") if getConfig('dbms') eq 'mysql';
		my @rows = dbGetRows($sth);
		foreach my $row (@rows) {
			($rv,$sth) = dbDelete($dbh,{FROM=>$wtbl,WHERE=>"uid=$row->{uid}"});
		}
		$total = -1;	 # force recalculating new total.
	}
	
	# get total 
	#
	if ($total == -1) {
		($rv,$sth) = dbSelect($dbh,{WHAT=>"uid",FROM=>$wtbl,WHERE=>"userid=$userinf->{uid}"});
		$total = $sth->rows();
		$sth->finish();
	}
	return paddingTable(clearBox('Your Watches','No watches.')) if ($total<=0);

	# actually get the watches
	#
	($rv,$sth) = dbLowLevelSelect($dbh,"select * from $wtbl where userid=$userinf->{uid} order by tbl offset $offset limit $page") if getConfig('dbms') eq 'pg';
	($rv,$sth) = dbLowLevelSelect($dbh,"select * from $wtbl where userid=$userinf->{uid} order by tbl limit $offset, $page") if getConfig('dbms') eq 'mysql';

	my @rows = dbGetRows($sth);

	my $i = 1 + $offset;
	my $curtable = '';
	$html .= "<form method=\"post\" action=\"/\">\n";
	foreach my $row (@rows) {
		my $tdesc = tabledesc($row->{'tbl'});
		my $title = lookuptitle($row->{'tbl'}, $row->{'objectid'});

		my $link = '';
		if ($title) {
			$link = contextLink($row->{'tbl'}, $row->{'objectid'}, $title);
		} else {
			$link = "[object $row->{tbl}:$row->{objectid} has been deleted]";
		}

		if ($row->{'tbl'} ne $curtable || $curtable eq '') {
			$html .= "<br><center><b>$tdesc</b></center><br>\n";
			$curtable = $row->{'tbl'};
		}

		$html .= "$i. ";
		$html .= "<input type=\"checkbox\" name=\"del_$row->{uid}\"> ";
		$html .= "$link<br>\n";
		$i++;
	}
	$html .= "<br>\n";
	$html .= "<input type=\"hidden\" name=\"offset\" value=\"$offset\">\n";
	$html .= "<input type=\"hidden\" name=\"total\" value=\"$total\">\n";
	$html .= "<input type=\"hidden\" name=\"op\" value=\"watches\">\n";
	$html .= "<center>\n";
	$html .= "<input type=\"submit\" name=\"delsel\" value=\"delete selected\">\n";
	$html .= "<input type=\"submit\" name=\"delall\" value=\"delete all\">\n";
	$html .= "</form>\n";
	
	$html .= "<br>\n";
	$html .= getPager({op=>'watches',offset=>$offset,total=>$total},$userinf);

	$html .= "</center>\n";

	return paddingTable(clearBox('Your Watches',$html));
}

# update any watches to a specific object, based on an incoming message
# (sends out all the notices)
#
sub updateWatches {
	my $forid = shift;		 # "for" the thing being watched
	my $fortbl = shift;
	my $aboutid = shift;	 # "about" the thing being posted
	my $abouttbl = shift;
	my $aboutuser = shift;
	my $subject = shift;	 # title/subject of notices filed
	my $comment = shift;	 # "body" of the notices filed
	my $senthash = shift;	# in this hash we will set userid=>1 if userid gets a
												 # notice as a result of this sub.	for values already
								 # set, we won't send any notices.

	my @watches = getWatches($fortbl,$forid);
	my $wtbl = getConfig('watch_tbl');

	foreach my $watch (@watches) {
		my $foruser = lookupfield($wtbl,'userid',"uid=$watch");

		next if ($foruser == $aboutuser);			 # no self-watches.
	next if (exists $senthash->{$foruser}); # no duplicate watches
		
	#dwarn "updatewatches *** : forid=$forid, fortbl=$fortbl, aboutid=$aboutid, abouttbl=$abouttbl, aboutuser=$aboutuser, foruser=$foruser, watchid=$watch, subject=$subject";
	
		fileNotice($foruser,$aboutuser,$subject,$comment,[{id=>$aboutid,table=>$abouttbl},{id=>$forid,table=>$fortbl}]);				

	$senthash->{$foruser} = 1;
	}
}

# update any watches to a specific object, based on an event 
#
sub updateEventWatches {
	my $forid = shift;		 # "for" the thing being watched
	my $fortbl = shift;
	my $eventuser = shift; # user performing the event
	my $subject = shift;	 # subject of the notice 
	my $comment = shift;	 # comment (body) of the notice
	my $senthash = shift;	# in this hash we will set userid=>1 if userid gets a
												 # notice as a result of this sub.	for values already
								 # set, we won't send any notices.

	my @watches = getWatches($fortbl,$forid);
	my $wtbl = getConfig('watch_tbl');

	foreach my $watch (@watches) {
		my $foruser = lookupfield($wtbl,'userid',"uid=$watch");

		next if ($foruser == $eventuser);			 # no self-watches
	next if (exists $senthash->{$foruser}); # no duplicate watches
		
		fileNotice($foruser,$eventuser,$comment,$subject,[{id=>$forid,table=>$fortbl}]);				

	$senthash->{$foruser} = 1;
	}
}

# check for a watch on an object, given object/table/userid triplet
#
sub hasWatch {
	my $table=shift;
	my $objectid=shift;
	my $userid=shift;

	my $wtbl=getConfig('watch_tbl');

	my ($rv,$sth)=dbSelect($dbh,{WHAT=>'uid',FROM=>$wtbl,WHERE=>"tbl='$table' and objectid=$objectid and userid=$userid"});
	my $count=$sth->rows();
	$sth->finish();

	return $count;
}

# get a list of watch IDs for a particular object/table (there can be many
# watches due to many users ... )
#
sub getWatches {
	my $table=shift;
	my $objectid=shift;

	my $wtbl=getConfig('watch_tbl');
	my @wlist=();

	my ($rv,$sth)=dbSelect($dbh,{WHAT=>'uid',FROM=>$wtbl,WHERE=>"tbl='$table' and objectid=$objectid"});
	my @rows=dbGetRows($sth);
	
	foreach my $row (@rows) {
		push @wlist,$row->{uid};
	}

	return @wlist;
}

# only add a watch if the user allows it 
#
sub addWatchIfAllowed {
	my $table = shift;
	my $objectid = shift;
	my $userinf = shift;
	my $type = shift;

	addWatch($table,$objectid,$userinf->{uid}) if ($userinf->{prefs}->{$type} eq "on");
}

sub watch {
	my $params = shift;
	my $userinf = shift;
#warn "Watch: $params->{from}, $params->{id}, $userinf->{uid}";
	addWatch( $params->{'from'}, $params->{'id'}, $userinf->{'uid'});
}

sub unWatch {
	my $params = shift;
        my $userinf = shift;
#warn "unWatch: $params->{from}, $params->{id}, $userinf->{uid}";
	delWatchByInfo( $params->{'from'}, $params->{'id'}, $userinf->{'uid'});
}



# change a watch to opposite status
# 
sub toggleWatch {
	my $table=shift;
	my $objectid=shift;
	my $userid=shift;

	if (hasWatch($table,$objectid,$userid)) {
		delWatchByInfo($table,$objectid,$userid);
	} else {
		addWatch($table,$objectid,$userid);
	}
}

# add a watch to an object.
#
sub addWatch {
	my $table=shift;
	my $objectid=shift;
	my $userid=shift;

	my $wtbl=getConfig('watch_tbl');

	my ($rv,$sth)=dbInsert($dbh,{INTO=>$wtbl,COLS=>"objectid,tbl,userid",VALUES=>"$objectid,'$table',$userid"});
}

# delete a watch by user, objectid
#
sub delWatchByInfo {
	my $table = shift;
	my $objectid = shift;
	my $userid = shift;

warn "delWatch called";

warn "Deleting watch for $table, $objectid and user = $userid";

	my $wtbl = getConfig('watch_tbl');

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>"uid",FROM=>$wtbl,WHERE=>"objectid=$objectid and userid=$userid and tbl='$table'"});
	my $row=$sth->fetchrow_hashref();
	$sth->finish();

	delWatch($row->{uid});
}

# get rid of a watch
#
sub delWatch {
	my $wid = shift;

	return if (not defined $wid || $wid < 0);

	my $wtbl = getConfig('watch_tbl');

	my ($rv,$sth) = dbDelete($dbh,{FROM=>$wtbl,WHERE=>"uid=$wid"});
}

# delete all watches for a user
#
sub delUserWatches {
	my $userid = shift;

	my $wtbl = getConfig('watch_tbl');

	my ($rv,$sth) = dbDelete($dbh,{FROM=>$wtbl,WHERE=>"userid=$userid"});
}

1;
