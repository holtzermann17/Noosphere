package Noosphere;

##############################################################################
#
# this module is an interface to handling lists of authors for planetmath 
# objects.
#
##############################################################################

use strict;

# get author count for an object
#
sub getAuthorCount {
	my $table=shift;
	my $objectid=shift;

	my $authortbl=getConfig('author_tbl');

	my ($rv,$sth)=dbSelect($dbh,{WHAT=>'userid',FROM=>$authortbl, WHERE=>"tbl='$table' and objectid=$objectid"});

	my $count=$sth->rows();
	$sth->finish();

	return $count;
}

# set the author list to a list of IDs
#
sub setAuthorList {
	my $table = shift;
	my $objectid = shift;
	my $list = shift;
	
	my $authortbl = getConfig('author_tbl');

	# clear out author list for object
	#
	my $sth = $dbh->prepare("delete from $authortbl where objectid=$objectid and tbl='$table'");
	$sth->execute();
	$sth->finish();

	foreach my $authorid (@$list) {
		
		$sth = $dbh->prepare("insert into authors (tbl, objectid, userid, ts) values ('$table', $objectid, $authorid, now())");
		$sth->execute();
		$sth->finish();
	}
}

# get author list for an object.	
#
# returns an array of hashes, {userid, username, ts}
#
sub getAuthorList { 
	my $table = shift;
	my $objectid = shift;

	my $authortbl = getConfig('author_tbl');
	my $usertbl = getConfig('user_tbl');
	
	my ($rv,$sth) = dbLowLevelSelect($dbh,"select $authortbl.userid, $authortbl.ts, $usertbl.username from $authortbl, $usertbl where $authortbl.tbl='$table' and $authortbl.objectid=$objectid and $usertbl.uid=$authortbl.userid order by $authortbl.ts desc");

	my @rows = dbGetRows($sth);

	return @rows;
}

# get author list for an object, minus the owner.
#
# returns an array of hashes, {userid, username, ts}
#
sub getAuthorListNoOwner { 
	my $table = shift;
	my $objectid = shift;

	my $authortbl = getConfig('author_tbl');
	my $usertbl = getConfig('user_tbl');

	# look up owner
	#
	my $ownerid = lookupfield($table, 'userid', "uid=$objectid");
	
	# grab the list
	#
	my ($rv,$sth) = dbLowLevelSelect($dbh,"select $authortbl.userid, $authortbl.ts, $usertbl.username from $authortbl, $usertbl where $authortbl.tbl='$table' and $authortbl.objectid=$objectid and $usertbl.uid=$authortbl.userid and $authortbl.userid != $ownerid order by $authortbl.ts desc");

	my @rows = dbGetRows($sth);

	return @rows;
}

# show author list for an object, with last edit timestamp
#
sub showAuthorList {
	my $params = shift;

	my $template = new XSLTemplate('authorlist.xsl');

	my @list = getAuthorList($params->{'from'},$params->{'id'});

	my $title = qhtmlescape(lookupfield($params->{'from'}, 'title', "uid=$params->{id}"));
	
	$template->addText("<authorlist title=\"$title\" objectid=\"$params->{id}\" table=\"$params->{from}\">");

	foreach my $author (@list) {

		$template->addText("<author>");
		$template->setKey('userid', $author->{'userid'});
		$template->setKey('username', $author->{'username'});
		$template->setKey('date', $author->{'ts'});
		$template->addText("</author>");
	}

	$template->addText('</authorlist>');

	return $template->expand();
}

# add (or update) an author entry for an object and user
#
sub addAuthorEntry {
	my $table = shift;
	my $objectid = shift;
	my $userid = shift;

	my $authortbl = getConfig('author_tbl');
	
	my ($rv,$sth) = dbUpdate($dbh,{WHAT=>$authortbl,SET=>"ts=now()",WHERE=>"objectid=$objectid and tbl='$table' and userid=$userid"});

	# add upon failure
	#
	if ($rv == 0) {
		$sth->finish();

		my ($rv,$sth) = dbInsert($dbh,{INTO=>$authortbl,COLS=>"tbl,objectid,userid,ts",VALUES=>"'$table', $objectid, $userid, now()"});	
		$sth->finish();

	} else {

		$sth->finish();
	}

}

# alias function for the above
#
sub updateAuthorEntry {
	my $table = shift;
	my $objectid = shift;
	my $userid = shift;

	addAuthorEntry($table,$objectid,$userid);
}

1;

