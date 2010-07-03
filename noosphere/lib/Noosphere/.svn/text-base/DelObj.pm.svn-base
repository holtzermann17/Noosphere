package Noosphere;

###############################################################################
#
# Object deletion module.
#
# contains delObject, common object-deletion routines, and callbacks for 
# the special requirements of different object types.
#
###############################################################################

use strict;

use Noosphere::Util;
use Noosphere::UserData;
use Noosphere::Indexing;
use Noosphere::Pronounce;
use Noosphere::Watches;
use Noosphere::Classification;
use Noosphere::IR;
use Noosphere::Crossref;
use Noosphere::Authors;
use Noosphere::Notices;
use Noosphere::Roles;

sub is_deleted {
	my $objectid = shift;

	my $sth = $dbh->prepare("select objectid from tags where objectid = ? and tag = 'NS:deleted'");
	$sth->execute($objectid);

	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;
	}
}

# main delete entry point
#
sub delObject {
	my $params = shift;
	my $userinf = shift;

	return loginExpired() if ($userinf->{uid} <= 0);
	
	my $userid = objectOwnerByUid($params->{id},$params->{from});

#check to see that this user has permission to delete.

	if ( !can_delete( $userinf->{uid}, $params->{id}) ) {
		return errorMessage("You can't delete other people's objects.	Nice try, though.");
	}
	
	if ($params->{'ask'} eq "yes") {
		return paddingTable(makeBox('Delete Article',"<center><Br><font color=\"#ff0000\" size=\"+1\"><b>Article will be moved to \"Deleted\" section, are you SURE? </b>
	<br><br>
	<a href=\"".getConfig("main_url")."/?op=delobj&from=$params->{from}&id=$params->{id}\">YES!</a><br>
	</center></font>"));
	}

	if (!objectExistsByUid($params->{'id'},$params->{'from'})) {
		return errorMessage("Article doesn't exist! Please report this!");
	}

	# do the deletion
	#
	my $rv = _delObject($params, $userid);

	# format output
	#
	my $template = new XSLTemplate('delobj.xsl');

	$template->addText('<delobj></delobj>');	# no data

	return $template->expand();
}

# non-UI-core of object deletion
#
sub _delObject {
	my $params = shift;
	my $userid = shift;

	my $rv;
	 
	# special delete handlers
	#
	if ($params->{'from'} eq getConfig('en_tbl')) {
		$rv = delEncyclopedia($params,$userid);
	} 

	# generic row delete
	#
	else {
		$rv = delrows($params->{'from'},"uid=$params->{id}");
	} 

	# clean up stuff all objects have
	
	# object index
	#
	delrows(getConfig('index_tbl'), "tbl='$params->{from}' and objectid=$params->{id}");

	# nix file box
	#
	deleteFileBox($params->{'from'},$params->{'id'});

	# declassify
	#
	declassify($params->{'from'},$params->{'id'});

	# delete watches
	#
	delWatchByInfo($params->{'from'}, $params->{'id'}, $userid);

	# delete from title index
	# 
	deleteTitle($params->{'from'}, $params->{'id'});

	# delete from search engine index
	#
#irUnindex($params->{'from'}, $params->{'id'});

	# delete ACL
	#
#	deleteObjectACL($params->{'from'}, $params->{'id'});
	
	# delete messages
	#
	delrows(getConfig('msg_tbl'),"objectid=$params->{id} and tbl='$params->{from}'");

	# update object tickers
	# 
	$stats->invalidate('latestadds');

	# remove dangling notices
	#
	deleteNotices($params->{'from'}, $params->{'id'});

}

# encyclopedia delete.	this must go and remove messages, corrections.
#
sub delEncyclopedia {
	my $params = shift;
	my $userid = shift;
	
	my $table = $params->{from};
	my $id = $params->{id};
	my $name = lookupfield($table,'name',"uid=$id");
	my $owner = lookupfield($table,'userid',"uid=$id");


	# get the row data
	#
	my ($rv, $sth) = dbSelect($dbh,{WHAT=>'*', FROM=>$table, WHERE=>"uid=$id"});
	my $rec = $sth->fetchrow_hashref();
	$sth->finish();
		
	# delete from word index
	#
	dropFromInvalIndex($id);

	# invalidate all objects that point to this one
	#
	xrefUnlink($id,$table);

	# delete corrections
	#
	delrows(getConfig('cor_tbl'),"objectid=$id");
	 
	# now synonyms
	#
	deleteSynonyms($table,$id,$name);

	# now the object (all versions)
	#
#instead of deleting from the database we now just tag the object as deleted.
#we will have a admin_Delete function which will actually remove the object
	my $query = "insert into tags (objectid, tag, userid) values ( ?, 'NS:deleted', ? )";
	my $sth = $dbh->prepare($query);
	$sth->execute( $id, $userid );
#	my $cnt = delrows($table,"name='$name'");
	NNexus_deleteobject( $params->{'id'});

	# decrement user score
	#
	changeUserScore($owner,-getScore('addgloss'));

	# get classification
	#
	my $class = classstring($table, $id);

	# update statistics
	# 
	$stats->invalidate('unproven_theorems') if ($rec->{type} == THEOREM());
	$stats->invalidate('unclassified_objects') if (!$class);

	return 1;	 # return count of rows deleted as result value
}

1;

