package Noosphere;

use strict;
use Socket;
use Noosphere::Editor;
use Noosphere::Roles;
use Data::Dumper;

# a settings "main menu" screen.  enables us to unload things from the userbox.
#
sub getSettings {
	my $params = shift;
	my $userinf = shift;

	my $template = new XSLTemplate('settings.xsl');
	
	$template->addText('<settings>');

	$template->setKey('id', $userinf->{'uid'});

	$template->addText('</settings>');

	return $template->expand();

}

# return 1 if the user is active, 0 if account is deactivated (by user name)
#
sub isUserActive {
	my $username = shift;

	my $val = lookupfield(getConfig('user_tbl'), 'active', "username='$username'");

	return $val;
}

# markUserAccess - mark a user as having accessed Noosphere at the current time
#
sub markUserAccess {
	my $uid = shift;
	my $ip = shift;

	my $sth = $dbh->prepare("update users set last = CURRENT_TIMESTAMP, lastip=? where uid=$uid");
	$sth->execute($ip);
	$sth->finish();
}

# changeUserScore - change a user's score. keeps score table updated.
#
sub changeUserScore {
	my $id = shift;
	my $delta = shift;
	my $onlyScore = shift;
 
	# TODO - we need a transaction here for updating both rows at the same time
	#
	my ($rv,$sth) = dbUpdate($dbh,{WHAT=>'users',
								 SET=>"score=score+$delta",
								 WHERE=>"uid=$id"});
	

	if (!(defined $onlyScore)) {
		my ($rv,$sth) = dbUpdate($dbh,{WHAT=>'users',
			                     SET=>"karma=karma+$delta",
								 WHERE=>"uid=$id"});
	}
	
	$sth->finish();
	($rv,$sth) = dbInsert($dbh,{INTO=>'score',
								 COLS=>'userid,delta',
								 VALUES=>"$id,$delta"});
	
	$sth->finish();

	# invalidate top user statistics
	#
	$stats->invalidate('topusers');
}

# user object edit list
# 
sub userEditObjectList {
	my $params = shift;
	my $userinf = shift;
	
	my $template = new XSLTemplate("usereditobjlist.xsl");
	
	my $offset = $params->{'offset'} || 0;
	my $total = $params->{'total'} || -1;
	my $limit = $userinf->{'prefs'}->{'pagelength'};
	my $uid = $userinf->{'uid'};
	my $table = getConfig('index_tbl');
	my $en = getConfig('en_tbl');

	# get total
	# 
	my $filter = '';
	my $query = "select distinct title, uid as objectid, roles.userid as userid from objects, roles where";
	if ($params->{'qtype'} eq 'coauthor') {
		$filter = " roles.objectid = objects.uid and role = 'CA' and roles.userid = $uid";
	} elsif( $params->{'qtype'} eq 'editor' ) {
		$filter = " roles.objectid = objects.uid and (role = 'EA' and roles.userid = $uid)";
	} elsif( $params->{'qtype'} eq 'world' ) {
		$query = "select distinct title, uid as objectid from objects, roles, tags where";
		$filter = " tags.tag = 'NS:worldeditable' and tags.objectid=objects.uid";
	} else {
		$filter = " roles.objectid = objects.uid and role = 'LA' and roles.userid = $uid";
	}

	$query .= $filter;


warn "executing $query";
	my $sth = $dbh->prepare($query);
	$sth->execute();
#	my ($rv,$sth) = dbLowLevelSelect($dbh,"select userid from $table, roles where $filter and tbl != 'users' and tbl != 'messages' and type = 1");
#	my $row = $sth->fetchrow_hashref();
#	print Dumper($row);
	$total = $sth->rows();
warn "$total results for $uid";
	$sth->finish();
	
	# query up the data
	#
	$query .= " order by lower(title) limit $offset, $limit";
warn "executing $query";
	$sth = $dbh->prepare($query);# offset $offset, $limit");
	$sth->execute();
#	($rv,$sth) = dbLowLevelSelect($dbh,"select title, objectid, tbl, userid from $table where $filter tbl != 'users' and tbl != 'messages' and type = 1 order by lower(title) offset $offset limit $limit")
#		if (getConfig('dbms') eq 'pg');
#	($rv,$sth) = dbLowLevelSelect($dbh,"select title, objectid, tbl, userid from $table where $filter and tbl != 'users' and tbl != 'messages' and type = 1 order by lower(title) limit $offset, $limit")
#		if (getConfig('dbms') eq 'mysql');
	
#	if (not defined $rv) {
#		dwarn "error getting objects for user $uid";
#		return errorMessage("Error with object query. contact an admin.");
#	}

	# get the rows
	# 
	my @rows = dbGetRows($sth);

	for (my $i = 0; $i < @rows; $i++ ) {
		if (is_deleted($rows[$i]->{'objectid'})) {
			splice( @rows, $i, 1);
			$i--;
		}
	}

	# gather in additional data from the individual tables
	#
	#dbGather(\@rows, 'tbl', 'objectid', 
	#	{
		# getConfig('exp_tbl') => {'select'=>'created', 'idfield'=>'uid'}, 
		# getConfig('books_tbl') => {'select'=>'created', 'idfield'=>'uid'},
		# getConfig('papers_tbl') => {'select'=>'created', 'idfield'=>'uid'}, 
	#	 getConfig('en_tbl') => {'select'=>'created, type as etype', 'idfield'=>'uid'}, 
	#});
	 
	$template->addText("<usereditobjs qtype=\"$params->{qtype}\">");

	if (scalar @rows > 0) {
		
		my $ord = 1;

		foreach my $row (@rows) {
			#nasty hack for now. The code below should be fixed to not have to do this
			$row->{'tbl'} = 'objects';
			my $date = ymd($row->{'created'});

			$template->addText("<object date=\"$date\"");
			
			$template->addText(" ord=\"$ord\"");
			$template->addText(" id=\"$row->{objectid}\"");
			$template->addText(" table=\"$row->{tbl}\"");

			$template->addText(" edithref=\"".getConfig("main_url")."/?op=edit;from=$row->{tbl};id=$row->{objectid}\""); 
			if ( is_published( $row->{'objectid'} ) ) {
				$template->addText(" published=\"1\"");
			}
			$template->addText(" requestpubhref=\"".getConfig("main_url")."/?op=requestpublication;from=$row->{tbl};id=$row->{objectid}\"");
#		$template->addText(" aclhref=\"".getConfig("main_url")."/?op=acledit;from=$row->{tbl};id=$row->{objectid}\""); 
			$template->addText(" editroleshref=\"".getConfig("main_url")."/?op=editroles;from=$row->{tbl};id=$row->{objectid}\"");

			if ($row->{'tbl'} eq $en) {
				$template->addText(" historyhref=\"".getConfig("main_url")."/?op=vbrowser;from=$row->{tbl};id=$row->{objectid}\""); 
				$template->addText(" linkhref=\"".getConfig("main_url")."/?op=linkpolicy;from=$row->{tbl};id=$row->{objectid}\""); 
			}

			$template->addText(" href=\"".getConfig("main_url")."/?op=getobj&amp;from=$row->{tbl}&amp;id=$row->{objectid}\""); 
			$template->addText(" title=\"".qhtmlescape($row->{'title'})."\""); 
			
			# find flags
			#
			my $flags = '';
			my $unclassified = (isclassified($row->{'tbl'},$row->{'objectid'}) ? '' : 'u');
			my $messages = (count_unseen($row->{'tbl'}, $row->{'objectid'}, $userinf->{'uid'}) > 0 ? 'm' : '');
			my $corrections = 0;
			if ($row->{'tbl'} eq $en) {
				$corrections = (hascorrections($row->{'tbl'},$row->{'objectid'}) ? 'c' : '');
			}

			$template->addText(" unclassified=\"1\"") if ($unclassified);
			$template->addText(" hasmessages=\"1\"") if ($messages);
			$template->addText(" hascorrections=\"1\"") if ($corrections);
			$template->addText(" isowner=\"1\"") if ($row->{'userid'} == $uid);

			$template->addText("/>\n");

			$ord++;
		}
		
		$params->{'offset'} = $offset;
		$params->{'total'} = $total;

		getPageWidgetXSLT($template, $params, $userinf);
	}

	$template->addText("</usereditobjs>");

	return paddingTable(clearBox('Your Articles',$template->expand()));
}

# format a user's message record for list display
#
sub formatUserMessageRec {
	my ($rec, $ord) = @_;

	my $xml = '';
	
	my $title = qhtmlescape(lookupfield($rec->{tbl},'title',"uid=$rec->{objectid}"));
	my $date = ymd($rec->{created});
	
	$xml .= "		<series ord=\"$ord\"/>";
	$xml .= "		<message date=\"$date\" title=\"".qhtmlescape($rec->{subject})."\" href=\"".getConfig("main_url")."/?op=getmsg;id=$rec->{uid}\"/>";
	$xml .= "		<object title=\"$title\" href=\"".getConfig("main_url")."/?op=getobj;from=$rec->{tbl};id=$rec->{objectid}\"/>";

	return $xml;
}

# format a user's object record for a list display
#
sub formatUserObjectRec {
	my ($rec, $ord) = @_;

	my $xml = '';
	
	$xml .= "		<series ord=\"$ord\"/>";
	$xml .= "		<object title=\"".qhtmlescape($rec->{title})."\" href=\"".getConfig("main_url")."/?op=getobj;from=objects;id=$rec->{objectid}\" table=\"$rec->{tbl}\"/>";

	return $xml;
}

sub formatUserCorrectionFiledRec { 
	my ($rec, $ord) = @_;
 
	my $xml = '';
	
	my $date = ymd($rec->{filed});
	my $title = lookupfield(getConfig('en_tbl'),'title',"uid=$rec->{objectid}");
	
	$xml .= "		<series ord=\"$ord\"/>";
	$xml .= "		<object title=\"".qhtmlescape($title)."\" href=\"".getConfig("main_url")."/?op=getobj;from=".getConfig('en_tbl').";id=$rec->{objectid}\"/>";
	$xml .= "		<correction date=\"$date\" title=\"".qhtmlescape($rec->{title})."\" href=\"".getConfig("main_url")."/?op=getobj;from=".getConfig('cor_tbl').";id=$rec->{uid}\"/>";
	
	return $xml;
}

sub formatUserCorrectionReceivedRec { 
	my ($rec, $ord) = @_;
 
	my $xml = '';
	
	my $date = ymd($rec->{filed});
	my $username = lookupfield(getConfig('user_tbl'),'username',"uid=$rec->{userid}");
	my $title = qhtmlescape(lookupfield(getConfig('en_tbl'),'title',"uid=$rec->{objectid}"));
	
	$xml .= "		<series ord=\"$ord\"/>";
	$xml .= "		<object title=\"$title\" href=\"".getConfig("main_url")."/?op=getobj;from=".getConfig('en_tbl').";id=$rec->{objectid}\"/>";
	$xml .= "		<correction date=\"$date\" title=\"".qhtmlescape($rec->{title})."\" href=\"".getConfig("main_url")."/?op=getobj;from=".getConfig('cor_tbl').";id=$rec->{uid}\"/>";
	$xml .= "		<user name=\"$username\" href=\"".getConfig("main_url")."/?op=getuser;id=$rec->{userid}\"/>";
	
	return $xml;
}

sub getCorrectionsReceivedCount {
	my $userid = shift;

	my ($rv,$sth) = dbLowLevelSelect($dbh,"select distinct corrections.uid from objindex, corrections where objindex.userid=$userid and objindex.tbl='".getConfig('en_tbl')."' and corrections.objectid=objindex.objectid");
	my $count = $sth->rows();
	$sth->finish();

	return $count;
}

sub getCorrectionsFiledCount {
	my $userid = shift;

	my ($rv,$sth) = dbLowLevelSelect($dbh, "select uid from corrections where userid=$userid");
	my $count = $sth->rows();
	$sth->finish();

	return $count;
}

# answer whether user has created any objects in the system
#
sub userCreatedObjects {
	my $userid = shift;

	my @statements = (
		# count messages
		"select uid from messages where messages.userid=$userid",
			# count primary objects
		"select userid from objindex where userid=$userid and tbl != 'users' and type = 1",
			# count corrections files
		"select uid from corrections where userid=$userid",
		"select userid from roles where userid=$userid"
	),

	my $count = 0;

	# count all types of objects the user has created
	#
	foreach	my $statement (@statements) {
		my ($rv, $sth) = dbLowLevelSelect($dbh, $statement);
		$count += $sth->rows();
		$sth->finish();
	}
		
	return $count;
}

# a generic list of a user's objects
#
sub userGenericList {
	my $params = shift;
	my $userinf = shift;

	my $op = $params->{op};
	my $offset = $params->{offset}||0;
	my $total = $params->{total}||-1;
	my $limit = $userinf->{'prefs'}->{'pagelength'};	
	my $uid = $params->{id};
	my $template = new XSLTemplate("usergeneric.xsl");

	# database invariance (jesus christ this is ugly)
	#
	my ($q_usermsgs, $q_userobjs, $q_usercorsf, $q_usercorsr);

	$q_usermsgs = "select messages.created, messages.objectid, messages.uid, messages.subject, messages.tbl from messages where messages.userid=$uid order by created desc limit $limit offset $offset" if getConfig('dbms') eq 'pg';
	$q_usermsgs = "select messages.created, messages.objectid, messages.uid, messages.subject, messages.tbl from messages where messages.userid=$uid order by created desc limit $offset, $limit" if getConfig('dbms') eq 'mysql';
	
	$q_userobjs = "select objectid,title,tbl from roles, objects where roles.userid=$uid and objects.uid = roles.objectid order by lower(title) offset $offset limit $limit"  if getConfig('dbms') eq 'pg';
	$q_userobjs = "select objectid,title from roles, objects where roles.userid=$uid and objects.uid=roles.objectid order by lower(title) limit $offset, $limit"  if getConfig('dbms') eq 'mysql';

	$q_usercorsf = "select uid, objectid, filed, title from corrections where userid=$uid order by filed desc limit $limit offset $offset" if getConfig('dbms') eq 'pg';
	$q_usercorsf = "select uid, objectid, filed, title from corrections where userid=$uid order by filed desc limit $offset, $limit" if getConfig('dbms') eq 'mysql';

	$q_usercorsr = "select distinct corrections.objectid, corrections.title, corrections.uid, corrections.userid, corrections.filed from objindex, corrections where objindex.userid=$uid and objindex.tbl='".getConfig('en_tbl')."' and corrections.objectid=objindex.objectid order by corrections.filed desc limit $limit offset $offset" if getConfig('dbms') eq 'pg';
	$q_usercorsr = "select distinct corrections.objectid, corrections.title, corrections.uid, corrections.userid, corrections.filed from objindex, corrections where objindex.userid=$uid and objindex.tbl='".getConfig('en_tbl')."' and corrections.objectid=objindex.objectid order by corrections.filed desc limit $offset, $limit" if getConfig('dbms') eq 'mysql';

	# structure holding the specifics
	#
	my $specifics = {
		'usermsgs'=>[
		"select uid from messages where messages.userid=$uid",
		$q_usermsgs,
		\&formatUserMessageRec
	 ],

	 'userobjs'=>[
		"select userid from objindex where userid=$uid and tbl != 'users' and tbl != 'messages' and type = 1",
		$q_userobjs,
		\&formatUserObjectRec
	 ],

	 'usercorsf'=>[
		"select uid from corrections where userid=$uid",
		$q_usercorsf,
		\&formatUserCorrectionFiledRec
	 ],

	 'usercorsr'=>[
		"select distinct corrections.uid from objindex, corrections where objindex.userid=$uid and objindex.tbl='".getConfig('en_tbl')."' and corrections.objectid=objindex.objectid",
		$q_usercorsr,
		\&formatUserCorrectionReceivedRec
	 ]
	};
	
	# get total if we're lacking it
	#
	if ($total < 0) {
		my ($rv,$sth) = dbLowLevelSelect($dbh,$specifics->{$op}->[0]);
	$total = $sth->rows();
	$sth->finish();
	}
	
	# actual retrieve the info
	#
	my ($rv,$sth) = dbLowLevelSelect($dbh,$specifics->{$op}->[1]);
	
	if (! $rv) {
		dwarn "error with query for user $uid";
	return errorMessage("error with query. contact an admin.");
	}

	my @rows = dbGetRows($sth);
 
	$params->{offset} = $offset;
	$params->{total} = $total;

	# print out the XML
	#
	$template->addText("<$op>");
	if ($#rows >= 0 ) {
	my $num = $offset+1;
	
		foreach my $row (@rows) {
		$template->addText("	<item_$op>");
		my $xml=&{$specifics->{$op}->[2]}($row,$num);
		$template->addText($xml);
#		dwarn "adding [$xml] to template";
		#$template->addText(&{$specifics->{$op}->[2]}($row,$num));
		$template->addText("	</item_$op>");
		
		$num++;
		}
	}
	$template->addText("</$op>");

	getPageWidgetXSLT($template, $params, $userinf);

	return paddingTable($template->expand());
}


# edit prefs interface
#
sub editUserPrefs {
	my ($params, $user_info) = @_;
 
	my $content = new Template('editprefs.html');
	my $prefs = $user_info->{'prefs'};
	my $groupings = getConfig('prefs_groupings');
	my $inputs = '';
	my $html = '';

	if ($user_info->{uid} < 1 ) { return loginExpired(); }

	my $error = changePrefs($user_info->{uid},$params,$prefs);
	$content->setKeys('error' => $error, 'id' => $user_info->{"uid"});
	$user_info->{prefs} = getUserPrefs($user_info->{'uid'});
	$prefs = $user_info->{prefs};
 
	foreach my $group (@$groupings) {
		my $groupname = $group->[0];

		$inputs .= "<tr><td bgcolor=\"#eeeeee\">";
		$inputs .= "<font size=\"+1\">$groupname</font>";
		$inputs .= "</td></tr>";

		$inputs .= "<tr><td><br />";
		$inputs .= "<table align=\"center\">";
		foreach my $key (@{$group->[1]}) {
			my ($widget,$desc) = getPrefsWidget($user_info,$key);
			if ($widget ne '') {
				$inputs .= "<tr><td>$desc:</td><td align=\"center\">$widget</td></tr>";
			}
		}
		$inputs .= "</table>";
		$inputs .= "<br/></td></tr>";
	}
	$content->setKey('inputs', $inputs);
 
	$html = makeBox("Edit Preferences for <b>".$user_info->{'data'}->{'username'}."</b>",$content->expand()); 

	return paddingTable($html); 
}

# the user data editor (data other than prefs)
# 
sub editUserData {
 my ($params, $user_info) = @_;
 
 my $content = new Template('edituser.html');
 my $data = $user_info->{'data'};
 my $html = '';

 if ($user_info->{uid} == -1 ) { return loginExpired(); }

 my $error = changeUserData($params,$data);
 $content->setKeys('error' => $error, 'id' => $user_info->{"uid"});
 $data = $user_info->{"data"} = getUserData($user_info->{"uid"});
 $content->setKeys(%$data);
 if ( $data->{'displayrealname'} eq "1" ) {
	$content->setKey('displayrealnamechecked', "checked");
 }
 
 $html = makeBox("Edit User Info for <b>".$data->{'username'}."</b>",$content->expand()); 
 return paddingTable($html); 
}

# the user prefs editor
# 
sub changePrefs {
	my $uid = shift;
	my $params = shift;
	my $prefs = shift;
	my $changed = '';
	my $message = '';		# error message to return, "" is no error
	
	# see if we submitted any changes at all
	#
	if (not defined($params->{submit})) { return ""; };
	
	# go through and look for changed fields
	#
	foreach my $key (keys %$prefs) {
		if (not defined($params->{$key})) {
		if ($prefs->{$key} eq "on") {
			$changed="$changed $key";
		$prefs->{$key}="off";
		}
	} else {
		if ($params->{$key} ne $prefs->{$key}) {
				$changed="$changed $key";
			$prefs->{$key}=$params->{$key};
 		}
		}
	}

	# handle changes
	#
	if ($changed eq "") {
		$message .= "No changes";
	} else {
		# message here is for debug purposes, we might want to take it out
		$message .= "changed $changed";
	
		# do the database update
		setUserPrefs($uid,$prefs);
	}
	
	return $message;			
}

# make sure user data is vaild
#
sub checkUserData {
	my $params = shift;

	my $error = "";

	if (not ($params->{email} =~ /^\s*[\w.\-]+@[\w.\-]+\s*$/)) {
		$error .= "Need a valid e-mail address!<br>";
	}

	return $error;
}

sub changeUserData {
	my $params = shift;
	my $data = shift;
	my $changed = 0;
	my $message = "";		# error message to return, "" is no error
	my $error = "";

	if (defined $params->{'displayrealname'}) {
		$params->{'displayrealname'} = 1;
	} else {
		$params->{'displayrealname'} = 0;
	}

	my @keys = (keys %$params);
	my @fields = ();
	
	# see if we are submitting any fields for changing, if not, just exit
	#
	if ($#keys == 1) {
		return $message;
	} else {

	#check to see if the user is trying to change the password.
	warn Dumper($data);
	my $oldpassword = $data->{'password'};
	my $enteredpass = $params->{'oldpassword'};
	if ( $enteredpass ne '' ) {
		$changed = 1;
	}
	my $newpass1 = $params->{'password'};
	my $newpass2 = $params->{'newpassword2'};

	if ( $oldpassword eq $enteredpass ) {
		if ( $newpass1 eq $newpass2 && $newpass1 ne "" ) {
		#	push @fields, "password";
		} else {
			$error = "The new passwords don't match or you are trying to assign a blank password. Try again.";
		}
	} elsif ( $enteredpass ne "" ) {
		$error = "You entered the wrong password.";
	}

	# go through and look for changed fields
	#

	for my $key (@keys) {
		$params->{$key}='' if (not defined $params->{$key}); # no NULL fields

		if (exists $data->{$key} && ($params->{$key} ne $data->{$key})) {
			if ( ($key eq 'password' && $params->{$key} ne "") || $key ne 'password' ) {
				$changed=1;
				push @fields,$key;
			}
		}
	}
	}

	# handle changes
	#
	if ($changed == 0) {
		$message.="No changes";
	} else {

		$error .= checkUserData($params);

		if ($error eq '') {
			$message .= 'changed';
			my $set = '';
			foreach my $field (@fields) {
				$message .= " $field";
				$set .= "$field=\'".sq($params->{$field})."\',";
			}
			$set =~ s/,$//;	 # kill trailing ,
	
			#dwarn $set;
		
			# do the database update
			(my $rv,my $sth) = dbUpdate($dbh,{WHAT => 'users',
			SET => $set,
			WHERE => 'uid='.$data->{'uid'}});
			$sth->finish();
		}

		# there was an error, can't accept changes
		#
		else {
			$message = $error;
		}
	}
	
	return $message;			
}

# a wrapper to expand the template returned by the getUser sub.
#
sub getUser_wrapper {
	my $params = shift;
	my $userinf = shift;

	my $template = getUser($params, $userinf);

	return $template->expand();
}

# getUser - get/display a user's info
#
sub getUser {
	my $params = shift;
	my $userinf = shift;
	
	my $id = $params->{id};
	my $html = '';

	my $isadmin = ($userinf->{data}->{access} >= getConfig('access_admin'));
	my $loggedin = ($userinf->{uid} > 0);
	my $iseditor = is_EB($userinf->{'uid'});
	
	my $template = new XSLTemplate('dispuser.xsl');

	(my $rv, my $sth) = dbSelect($dbh,{WHAT => '*', 
									FROM => 'users',
									WHERE => "users.uid=$id"});


	if (! $rv) {
		$template->addText("<nouser>1</nouser>");
		return $template;
	}

	my $rec = $sth->fetchrow_hashref();	
	my $prefs = parsePrefs($rec->{prefs});
	
	my %basicinfo;
	foreach my $key (keys %$rec) {
		my $val = $rec->{$key};
		if ($key eq "homepage" && nb($val)) { $val=~/^http:\/\// or $val="http://$val"; }
		if ($key eq "email" && 
			$prefs->{hideemail} eq 'on' && 
			$userinf->{uid} != $id &&
			$userinf->{data}->{access} < getConfig('access_seehiddenemail')) { $val="[hidden]"; } 

		$basicinfo{$key} = $val;
	}

	my $iaddr = inet_aton($basicinfo{'lastip'});
	$basicinfo{'hostname'} = gethostbyaddr($iaddr,Socket::AF_INET());

	# extract info
	#
	my $mc = getrowcount('messages',"userid=$rec->{uid}");
	my $oc = getObjectCount($rec->{'uid'});
	my $crc = getCorrectionsReceivedCount($rec->{uid});
	my $cfc = getCorrectionsFiledCount($rec->{uid});
	my $uname = urlescape($rec->{'username'});
	my $pmail = getConfig("main_url")."/?op=sendmail&amp;sendto=$uname";

	# get group-add info
	#
#	my $groups = {};
#	if ($userinf->{uid} > 0) {
#		$groups = getAdminGroupHash($userinf->{uid});
#		subtractUserFromGroupHash($id, $groups);
#	}

	# output XML for user record
	#
	$template->addText("<user adminview=\"$isadmin\" editorview=\"$iseditor\" loggedin=\"$loggedin\" active=\"$rec->{active}\">");
	$template->addText("	<username>".htmlescape($rec->{username})."</username>");
	$template->addText("	<counts>");
	$template->addText("		 <item label=\"messages\" count=\"$mc\" href=\"".getConfig("main_url")."/?op=usermsgs;id=$rec->{uid}\"/>");
	$template->addText("		 <item label=\"articles\" count=\"$oc\" href=\"".getConfig("main_url")."/?op=userobjs;id=$rec->{uid}\"/>");
	$template->addText("		 <item label=\"corrections filed\" count=\"$cfc\" href=\"".getConfig("main_url")."/?op=usercorsf;id=$rec->{uid}\"/>");
	$template->addText("		 <item label=\"corrections received\" count=\"$crc\" href=\"".getConfig("main_url")."/?op=usercorsr;id=$rec->{uid}\"/>");
	$template->addText("	</counts>");
	$template->addText("	<bio>".htmlcheck($rec->{'bio'})."</bio>");
	$template->addText("	<mailurl>$pmail</mailurl>");
	foreach my $key (keys %basicinfo) {
		if ($key ne 'bio') {
			$template->addText("	<$key>".htmlescape($basicinfo{$key})."</$key>");
		}
	}


#	foreach my $gid (keys %$groups) {
#		$template->addText("	<addablegroup name=\"$groups->{$gid}\" id=\"$gid\"/>");
#	}
	$template->addText("</user>");
 
	return $template;
}

# getUserData - grab user data from database to hash
#
sub getUserData {
	my $uid = shift;
 
	#dwarn "uid is $uid!!!";
	
	my ($rv,$dbq) = dbSelect($dbh,{
	 WHAT => '*',
	 FROM => 'users',
	 WHERE => qq|uid='$uid'|});
	
	my $data = $dbq->fetchrow_hashref();
	$dbq->finish();
 
	return $data; 
}

# get a partial user info line from an ID
# 
sub userInfoById {
	my $userid = shift;

	my %user_info;
 
	$user_info{'uid'} = $userid;
	$user_info{'data'} = getUserData($user_info{'uid'});
	$user_info{'prefs'} = parsePrefs($user_info{'data'}->{'prefs'});

	return %user_info;
}

# get the value of a user's preference for some key
#
sub userPref {
	my $userid = shift;
	my $key = shift;

	my %userinf = userInfoById($userid);

	return $userinf{'prefs'}->{$key};
} 

# look up user fields by id. (pass in uid,field1,field2,...)
#	 
sub _userfields_by_id {
	my $uid = shift;
	my @fields = shift;
	
	(my $rv, my $sth) = dbSelect($dbh,
		{WHAT => join(',',@fields), 
		 FROM => 'users', 
		 WHERE => "uid = $uid"}
		); 

	my $row = $sth->fetchrow_hashref(); 
	
	$sth->finish(); 
	
	return $row; 
}

# parse user prefs data -- includes filling in defaults.
#
sub parsePrefs {
	my $raw = shift;
 
	my %prefs;
	my $defaults = getConfig('prefs_schema');

	# split the string into a hash
	#
	foreach my $keyval (split(/;/,$raw)) {
		my ($key,$val) = split(/=/,$keyval);
		$prefs{$key} = $val;
	}

	# fill in missing fields from defaults.
	#
	foreach my $key (keys %$defaults) {
		if (not defined($prefs{$key})) {
			my $prefarray = $defaults->{$key};
			$prefs{$key} = $prefarray->[2];
		}		
	}
 
	# return a hashref
	#
	return {%prefs};
}


1;
