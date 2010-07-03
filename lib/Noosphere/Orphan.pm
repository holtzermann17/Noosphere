package Noosphere;

use strict;
use Noosphere::Config;
use Noosphere::UserData;
use Noosphere::Owners;

# accept an offer of ownership for an object
#
sub acceptObject {
	my $params = shift;
	my $userinf = shift;

	my $index = getConfig('index_tbl');

	my $targetid = $params->{'touser'};
	my $ownerid = $params->{'user'};

	# some basic authority and sanity checks
	#
	return errorMessage('You must be logged in to receive an object.') if ($userinf->{'uid'} <= 0);

	return errorMessage('You haven\'t been offered that object!') if ($userinf->{'uid'} != $targetid);

	# make a hash, so we can compare it with the hash offered to use
	#
	my $hash = sha1_hex(join(':',$targetid,$ownerid,$params->{'id'}),SECRET);

	if ($params->{'hash'} ne $hash) {
		return paddingTable(errorMessage("Verification failed for ownership transfer!"));
	}

	# change the ownership
	#
	_changeObjectOwner($params->{'from'}, $params->{'id'}, $targetid, 't');

	# change score
	#
	changeUserScore($targetid , getScore("adden")/2);
	changeUserScore($ownerid , -getScore("adden")/2);

	my $title = lookupfield($index, 'title', "objectid=$params->{id} and tbl='$params->{from}'");
	my $targetname = lookupfield(getConfig('user_tbl'), 'username', "uid=$targetid");

	# send mail or notice to offerer
	#
	if (userPref($ownerid, 'xferfinishmail') eq 'on') {
		my $subject = "Object transfer accepted for '$title'";
		my $body = "
Title: $title
Accepted by: $targetname
-------------------------------------

To view the object, go to:

 ".getConfig('main_url')."?op=getobj&id=$params->{'id'}&from=$params->{'from'}

NOTE: You can turn these emails off in your preferences and receive notices
 instead, if you'd like.

	";
	
		# send the message
		#
		sendMail(lookupfield(getConfig('user_tbl'),'email', "uid=$ownerid"),$body,$subject);
	} else {

		fileNotice($ownerid, $targetid, 
			"object transferred",
			"$targetname has accepted ownership of '$title'.",
			[{id=>$params->{'id'},table=>$params->{'from'}}]);
	}

	my $root = getConfig("main_url");

	# send some feedback to acceptor
	# 
	return paddingTable(makeBox("Object Transferred",
	"Congrats! You are now the proud owner of '$title'. 
 	 <p>
	 Quick links:
	 <p>
	 <ul>
	 	<li><a href=\"$root/?op=getobj&id=$params->{id}&from=$params->{from}\">$title</a></li>
	 	<li><a href=\"$root/?op=edituserobjs\">Your objects</a></li>
	 </ul>
	 <br>"
	));
}

# refuse an offer of ownership for an object
#
sub rejectObject {
	my $params = shift;
	my $userinf = shift;

	my $index = getConfig('index_tbl');

	my $targetid = $params->{'touser'};
	my $ownerid = $params->{'user'};

	# some basic authority and sanity checks
	#
	return errorMessage('You must be logged in to reject an object.') if ($userinf->{'uid'} <= 0);

	return errorMessage('You haven\'t been offered that object!') if ($userinf->{'uid'} != $targetid);

	# make a hash, so we can compare it with the hash offered to use
	#
	my $hash = sha1_hex(join(':',$targetid,$ownerid,$params->{'id'}),SECRET);

	if ($params->{'hash'} ne $hash) {
		return paddingTable(errorMessage("Verification failed for ownership transfer!"));
	}

	# send notice of the rejection
	#

	my $title = lookupfield($index, 'title', "objectid=$params->{id} and tbl='$params->{from}'");
	my $targetname = lookupfield(getConfig('user_tbl'), 'username', "uid=$targetid");

	# send mail or notice to offerer
	#
	if (userPref($ownerid, 'xferfinishmail') eq 'on') {
		my $subject = "Object transfer declined for '$title'";
		my $body = "
Title: $title
Declined by: $targetname
-------------------------------------

To view the object, go to:

 ".getConfig('main_url')."?op=getobj&id=$params->{'id'}&from=$params->{'from'}

NOTE: You can turn these emails off in your preferences and receive notices
 instead, if you'd like.

	";
	
		# send the message
		#
		sendMail(lookupfield(getConfig('user_tbl'),'email', "uid=$ownerid"),$body,$subject);
	} else {

		fileNotice($ownerid, $targetid, 
			"object transfer declined",
			"$targetname has declined ownership of '$title'.",
			[{id=>$params->{'id'},table=>$params->{'from'}}]);
	}

	my $root = getConfig("main_url");

	# send some feedback to rejector
	# 
	return paddingTable(makeBox("Object Transfer Declined",
	"You have declined ownership of '$title'. 
 	 <p>
	 Quick links:
	 <p>
	 <ul>
	 	<li><a href=\"$root/?op=getobj&id=$params->{id}&from=$params->{from}\">$title</a></li>
	 	<li><a href=\"$root/?op=edituserobjs\">Your objects</a></li>
	 </ul>
	 <br>"
	));
}

# interface to selecting a user to transfer to.
#
sub transferObject {
	my $params = shift;
	my $userinf = shift;

	my $title = lookupfield($params->{'from'}, 'title', "uid=$params->{id}");

	my $template = new XSLTemplate('transfer.xsl');

	$template->addText('<transfer>');

	$template->setKey('title', $title);
	$template->setKeys(%$params);

	# retrieve author list and output it for convenient selector
	#
	my @authors = getAuthorListNoOwner($params->{'from'}, $params->{'id'});
	if (@authors) {
		$template->addText('<authorlist>');

		foreach my $author (@authors) {
			$template->addText('<author>');
			$template->setKey('name', $author->{'username'});
			$template->setKey('id', $author->{'userid'});
			$template->addText('</author>');
		}
		
		$template->addText('</authorlist>');
	}

	$template->addText('</transfer>');

	return $template->expand();
}

# sendobject: initiate the relinquishing of ownership of an object and 
# offering it up to a specific person.  
# object will only be given up if the target user accepts it.
#
sub sendObject {
	my $params = shift;
	my $userinf = shift;

	my $index = getConfig('index_tbl');

	# some sanity and security checks
	#
	return errorMessage('You must be logged in to send an object.') if ($userinf->{'uid'} <= 0);

	my $ownerid = lookupfield($index, 'userid', "objectid=$params->{id} and tbl='$params->{from}'");

	return errorMessage('You can\'t send an object you don\'t own.') if ($userinf->{'uid'} != $ownerid);

	my $ownername = lookupfield(getConfig('user_tbl'), 'username', "uid=$ownerid");

	# resolve target user id (a user name is a valid 'touser')
	#
	my $targetid = $params->{'touser'};
	if ($params->{'touser'} !~ /^\d+$/) {
		$targetid = lookupfield(getConfig('user_tbl'), 'uid', "username='$params->{touser}'");
	}

	# this should also be useful if the above resolution from name failed
	return errorMessage('Target user does not exist!') if (!getrowcount(getConfig('user_tbl'), "uid=$targetid"));

	my $targetname = lookupfield(getConfig('user_tbl'), 'username', "uid=$targetid");

	my $title = lookupfield($index, 'title', "objectid=$params->{id} and tbl='$params->{from}'");

	if ($params->{'yes'}) {	

		# make a hash so we can authenticate this offer.  we will hash the 
		# user id and object id (the title could change)
		#
		my $hash = sha1_hex(join(':',$targetid,$ownerid,$params->{'id'}),SECRET);

		# send a prompt to the target user offering the object.
		#
		filePrompt($targetid,
			$ownerid, 
			'object transfer',
			"$ownername has offered ownership of '$title' to you.  Do you accept it?",
			1, # default = reject offer
			 [
			  ['accept object', urlescape("op=acceptobj&from=$params->{from}&id=$params->{id}&user=$ownerid&touser=$targetid&hash=$hash")],
			  ['no thanks', urlescape("op=rejectobj&from=$params->{from}&id=$params->{id}&user=$ownerid&touser=$targetid&hash=$hash")],
			 ],
			[{id=>$params->{'id'},table=>$params->{'from'}}]
		 );

		if (userPref($targetid, 'xferoffermail') eq 'on') {
			my $subject = "Object transfer for '$title'";
			my $body = "
Title: $title
Offered by: $ownername
-------------------------------------

To accept ownership of this object, log in and check your notices:

 ".getConfig('main_url')."?op=notices

NOTE: You can turn these emails off in your preferences if you'd like.

	";
	
			# send the message
			#
			sendMail(lookupfield(getConfig('user_tbl'),'email', "uid=$targetid"),$body,$subject);
		}

		my $root = getConfig("main_url");

		my $template = new XSLTemplate('transfer_initiated.xsl');

		$template->addText('<transfer_initiated>');
		$template->addText("	<title>$title</title>");
		$template->addText("	<targetname>$targetname</targetname>");
		$template->addText('</transfer_initiated>');

		return $template->expand();
	} else {
		my $username = urlescape($params->{'touser'});

		return paddingTable(makeBox('Transfer Object',"<center><br><font color=\"#ff0000\" size=\"+1\"><b>Are you sure you want to transfer this object to $targetname? After this is done, $targetname will have complete discretion over your access to the object.</b>
	    <br><br>
		<a href=\"".getConfig("main_url")."/?op=sendobj&amp;from=$params->{from}&amp;id=$params->{id}&amp;touser=$username&amp;user=$ownerid&amp;yes=1\">Transfer</a><br>
		</center></font>
		<br>"));
	}
}

# get a count of objects in the orphange, plus objects which are adoptable
#
sub orphanCount {
	
	my $count = 0;
	
	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'objectid',FROM=>getConfig('index_tbl'),WHERE=>'type=1 and userid<=0'});
	$count += $sth->rows();
	$sth->finish();

	my $cor = getConfig('cor_tbl');
	my $times = getConfig('cor_times');

	($rv,$sth) = dbLowLevelSelect($dbh,"select objectid from (select objectid,max(now()-graceint-filed) as maxelapsed from corrections where closed is null group by objectid) as foo, objects where objects.uid=objectid and objects.userid>0 and maxelapsed>=interval '$times->{adopt}' and maxelapsed<interval '$times->{orphan}'")
		if (getConfig('dbms') eq 'pg');

	# to support pre-subselect Mysql, we have to get a little extravagant..
	#
	if (getConfig('dbms') eq 'mysql') {
		# get the max elapsed time over all corrections per objecti
		#
		$dbh->do("create temporary table foo select objectid, max(unix_timestamp(now()) - graceint - unix_timestamp(filed)) as maxelapsed from corrections where closed is null group by objectid");

		# see if the table exists
		#
		my $ss = $dbh->prepare("select 1 from foo limit 1");
		$ss->execute();
		my $fooexists = $ss->rows();
		$ss->finish();
		return 0 if !$fooexists;

		# now do a query over this data
		($rv,$sth) = dbLowLevelSelect($dbh,"select objectid from foo, objects where objects.uid=foo.objectid and objects.userid>0 and interval foo.maxelapsed SECOND + now() >= interval $times->{adopt} + now() and interval foo.maxelapsed SECOND + now() < interval $times->{orphan} + now()");

		# drop the temporary table
		$dbh->do("drop table foo");
	}
	$count += $sth->rows();
	$sth->finish();

	return $count;
}

# interface for an "object orphanage" (just a list of unowned objects with
# "adopt" controls)
#
sub orphanage {

	my $html = "";

	# get abandoned objects
	#
	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'title,objectid,tbl',FROM=>getConfig('index_tbl'),WHERE=>'type=1 and userid<=0'});
	my @abandoned = dbGetRows($sth);

	# get owned, but adoptable objects
	#
	my $times = getConfig('cor_times');
	my $cor = getConfig('cor_tbl');
	my $en = getConfig('en_tbl');

	($rv,$sth) = dbLowLevelSelect($dbh,"select objectid from (select objectid,max(now()-graceint-filed) as maxelapsed from corrections where closed is null group by objectid) as foo, objects where objects.uid=objectid and objects.userid>0 and maxelapsed>=interval '$times->{adopt}' and maxelapsed<interval '$times->{orphan}'")
		if (getConfig('dbms') eq 'pg');

	# a little more extravagant for Mysql < 4.0 
	if (getConfig('dbms') eq 'mysql') {

		# TODO: make this a heap temporary table?
		$dbh->do("create temporary table foo select objectid,max(unix_timestamp(now()) - graceint - unix_timestamp(filed)) as maxelapsed from corrections where closed is null group by objectid");

		($rv,$sth) = dbLowLevelSelect($dbh,"select objectid from foo, objects where objects.uid=foo.objectid and objects.userid>0 and interval maxelapsed SECOND + now() >= interval $times->{adopt} + now() and interval maxelapsed SECOND + now() < interval $times->{orphan} + now()");

		$dbh->do("drop table foo");
	}

	my @adoptable = dbGetRows($sth);

	if ($#abandoned >= 0) {
		$html .= "<center><b>Orphaned objects:</b></center><br>";

		foreach my $row (@abandoned) {
			my ($lastid, $lastname) = getLastData($en, $row->{'objectid'});

			$html .= "[ <a href=\"".getConfig("main_url")."/?op=adopt&from=$row->{tbl}&id=$row->{objectid}&ask=yes\">adopt</a> ] <a href=\"".getConfig("main_url")."/?op=getobj&from=$row->{tbl}&id=$row->{objectid}\">$row->{title}</a>";
			if ( $lastname ne "" ) {
				$html .= "(was owned by <a href=\"".getConfig("main_url")."/?op=getuser&id=$lastid\">$lastname</a>)";
			}
			$html .= "<br>";
		}

		$html .= "<br>";
	}

	if ($#adoptable >= 0) {
		$html .= "<center><b>Adoptable (but still owned) objects:</b></center><br>";
	
		foreach my $row (@adoptable) {
			my $userid = lookupfield(getConfig('index_tbl'),'userid',"tbl='$en' and objectid=$row->{objectid}");
			my $username = lookupfield(getConfig('user_tbl'),'username',"uid=$userid");
			my $title = lookupfield($en,'title',"uid=$row->{objectid}");

			$html .= "[ <a href=\"".getConfig("main_url")."/?op=adopt&from=objects&id=$row->{objectid}&ask=yes\">adopt</a> ] <a href=\"".getConfig("main_url")."/?op=getobj&from=$en&id=$row->{objectid}\">$title</a> (owned by <a href=\"".getConfig("main_url")."/?op=getuser&id=$userid\">$username</a>)<br>";
		}
	}

	if ($#adoptable < 0 && $#abandoned< 0) {
		$html .= "All objects currently have homes!";
	}

	return paddingTable(clearBox('Object Orphanage',$html));
}

sub isAdoptable
{
	my $uid = shift;
	my $rv;
	my $sth;
	my $times = getConfig('cor_times');

# if object is not owned, it is adoptable
	($rv, $sth) = dbSelect($dbh, { WHAT => '*', FROM => getConfig('index_tbl'), WHERE => "objectid = $uid and type = 1 and userid <= 0" } );
	if($sth->rows() > 0) {
		$sth->finish();
		return 1;
	}
	$sth->finish();

# if object has old enough pending corrections, it is adoptable
	($rv, $sth) = dbSelect($dbh, { WHAT => '*', FROM => getConfig('cor_tbl'), WHERE => "objectid = $uid and closed is null and now() - graceint - filed >= interval '$times->{adopt}'" }) 
	 	if (getConfig('dbms') eq 'pg');

	($rv, $sth) = dbSelect($dbh, { WHAT => '*', FROM => getConfig('cor_tbl'), WHERE => "objectid = $uid and closed is null and from_unixtime(unix_timestamp(filed + interval $times->{adopt}) - graceint) < now()" }) 
	 	if (getConfig('dbms') eq 'mysql');

	if($sth->rows() > 0) {
		$sth->finish();
		return 1;
	}
	$sth->finish();
	return 0;
}

sub adoptObject {
	my $params = shift;
	my $userinf = shift;
	
	my $uid = $params->{'id'};

	return needAccount() if ($userinf->{'uid'} <= 0);

	return errorMessage("Can't find object! Contact an admin.") if (not objectExistsByUid($params->{'id'},$params->{'from'}));

	my $userid = lookupfield($params->{'from'},'userid',"uid=$params->{id}");

	return errorMessage("Adopting your own object doesn't make much sense.") if $userinf->{'uid'} == $userid;

	return errorMessage("That object is not adoptable.") unless isAdoptable($params->{'id'});

	# don't let the user adopt the object if it was orphaned from them.
	#
	my ($lastid, $lastname, $lastaction) = getLastData($params->{'from'}, $params->{'id'});
	if ($userid == 0 && $lastid == $userinf->{'uid'} && $lastaction eq 'o' ) {
		return errorMessage("You can't adopt your own orphan!");
	}

	# return verification prompt
	#
	if ($params->{'ask'} eq "yes") {
		return paddingTable(makeBox('Adopt Object',"<center><Br><font color=\"#ff0000\" size=\"+1\"><b>Are you sure you want to do this? Maintaining an object is work!</b>
	<br><br>
	<a href=\"".getConfig("main_url")."/?op=adopt&from=$params->{from}&id=$params->{id}\">YES!</a><br>
	</center></font>"));
	}
	
	# change the ownership
	#
	_changeObjectOwner($params->{'from'}, $params->{'id'}, $userinf->{'uid'}, 'o');
	
	# change score of adopter
	#
	changeUserScore($userinf->{'uid'},getScore("adden")/2);
	
	# debit original owner
	#
	changeUserScore($userid,-getScore("adden")/2);

	return messageWithRedirect("Object Adopted","".getConfig("main_url")."/?op=getobj&from=$params->{from}&id=$params->{id}","Congratulations! You are the proud owner of a ".getConfig('projname')." object.	You will be directed to see it now.",1);	
}

# helper function to do the miscellaneous things required when object ownership
# changes
#
sub _changeObjectOwner {
	my $tbl = shift;
	my $objectid = shift;
	my $newuser = shift;
	my $event = shift;		# t = transfer, a = abandon, o = orphan

	# get previous owner
	#
	my $prevuser = objectOwnerByUid($objectid, $tbl);

	# change the owner to the current user
	#
	setfields($tbl,"userid=$newuser","uid=$objectid");
	setfields(getConfig('index_tbl'),"userid=$newuser","objectid=$objectid and tbl='$tbl'");

	# update graceint on any pending corrections
	#
	if ($tbl eq getConfig('en_tbl')) {
		# APK - does this statement really work properly in pg?
		setfields(getConfig('cor_tbl'),"graceint = now() - filed","objectid = $objectid and closed is null") if (getConfig('dbms') eq 'pg');
		setfields(getConfig('cor_tbl'),"graceint = unix_timestamp(now()) - unix_timestamp(filed)","objectid = $objectid and closed is null") if (getConfig('dbms') eq 'mysql');
	}

	# update owner log
	#
	addLastOwner($tbl, $objectid, $prevuser, $event) if ($prevuser != 0);
}

# user subroutine to voluntarily give up ownership of an object
#
sub abandonObject {
	my $params = shift;
	my $userinf = shift;

	return errorMessage("Can't find object! Contact an admin.") if (not objectExistsByUid($params->{'id'},$params->{'from'}));
	
	my $userid = lookupfield($params->{'from'},'userid',"uid=$params->{id}");

	return errorMessage("You can't abandon someone else's object") if ($userinf->{uid} != $userid );

	if ($params->{'ask'} eq "yes") {
		return paddingTable(makeBox('Abandon Object',"<center><Br><font color=\"#ff0000\" size=\"+1\"><b>Are you sure you want to do this?</b>
	<br><br>
	<a href=\"".getConfig("main_url")."/?op=abandon&from=$params->{from}&id=$params->{id}\">YES!</a><br>
	</center></font>"));
	}
	
	# perform abandoning
	#
	_abandonObject($params, $userinf->{'uid'});

	return messageWithRedirect("Object abandoned","".getConfig("main_url")."/?op=getobj&from=$params->{from}&id=$params->{id}","Your object has been abandoned.	You will be redirected back to it now.",1);	
}

# low-level performing of abandoning 
#
sub _abandonObject {
	my $params = shift;
	my $userid = shift;

	# change the owner to nobody
	#
	setfields($params->{'from'},"userid=0","uid=$params->{id}");
	setfields(getConfig('index_tbl'),"userid=0","objectid=$params->{id} and tbl='$params->{from}'");

	# update owner log with abandon event
	#
	addLastOwner($params->{'from'}, $params->{'id'}, $userid, 'a');

	# change score
	#
	changeUserScore($userid,-getScore("adden")/2);
}

# orphan objects that need to be orphaned. takes a correction info hash.
#
sub autoOrphan	{
	my $corhash = shift;

	my $elapsed = $corhash->{elapsed};	
	
	my $times = getConfig('cor_times');
	
	my $userid = lookupfield(getConfig('en_tbl'),'userid',"uid=$corhash->{objectid}");
	return if ($userid <= 0);	# object is not owned
	
	# use the dbms to do our date arithmetic. get boolean for whether things
	# should be orphaned.
	#
	my ($rv, $sth);
	($rv,$sth) = dbLowLevelSelect($dbh,"select interval '$elapsed'>=interval '$times->{orphan}' as orphan")
		if (getConfig('dbms') eq 'pg');

	($rv,$sth) = dbLowLevelSelect($dbh,"select interval $elapsed SECOND + now() >= interval $times->{orphan} + now() as orphan")
		if (getConfig('dbms') eq 'mysql');

	my $should = $sth->fetchrow_hashref();
	$sth->finish();

	return unless ($should->{'orphan'});

	dwarn "orphaning object $corhash->{objectid}, elapsed=$corhash->{elapsed}, correction id=$corhash->{id}";

	# change the owner to nobody
	#
	my $table = getConfig('en_tbl');	# TODO: generalize
	setfields($table,"userid=0","uid=$corhash->{objectid}");
	setfields(getConfig('index_tbl'),"userid=0","objectid=$corhash->{objectid} and tbl='$table'");

	# update owner log with orphan event
	#
	addLastOwner(getConfig('en_tbl'), $corhash->{'objectid'}, $userid, 'o');

	# change score
	#
	changeUserScore($userid,-getScore("adden")/2);
}

1;
