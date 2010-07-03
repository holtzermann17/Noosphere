package Noosphere;

use strict;

use Digest::SHA1 qw(sha1_hex);

sub getNewUser {
	my $params = shift;
	my $userinf = shift;	# just in case the user is logged in

	if ($userinf->{'uid'} > 0) {
	
		return errorMessage("Another account? Isn't one enough?");
	}

	my $error = '';
	my $template;
	my $addrs = getConfig('siteaddrs');
	my $boxtitle;

	if (!defined($params->{'verify'})) {
		$boxtitle = "Create New User Account";
		$template = new Template("new_user.html");
	} 
	
	# we just need to verify the information they submitted, then proceed 
	# to send the mail.
	#
	else {
		$error = checkNewUserInfo($params);
		if ($error eq '') {
			my $body = new Template("newuseremail");
			my $hostname = $addrs->{'main'};
			my $hash = makeHash($params->{"user"},$params->{"email"});
#			$hash =~ s/ /%20/;
			$body->setKeys('hash' => $hash, 'hostname' => $hostname);
			sendMail($params->{email},$body->expand());
			# TODO: figure out a way to see if the mail bounces and return error
			$boxtitle = "Mail Sent";
			$template = new Template("sentmail.html");
			$template->setKey('email', $params->{"email"});
		}
		else {
			$boxtitle = "Create New User Account";
			$template = new Template("new_user.html");
			$template->setKeys('error' => $error, 'user' => $params->{'user'}, 'email' => $params->{'email'});
		}
	}
	return paddingTable(makeBox($boxtitle, $template->expand())); 
}

sub getActivate {
	my $params = shift;
	
	my $html = '';
	
	my $error = checkHash($params->{"hash"});
	
	if ($error ne '') {
		return(clearBox("Error",$error));
	}
	if (!defined($params->{"setpass"})) {
		my $tobj = new Template("activate.html");

	$tobj->setKey("hash", $params->{"hash"});
		$html = clearBox("Activate Account",$tobj->expand());
	}
	else {
		$error = activateAccount($dbh,$params->{"hash"},$params->{"p1"},$params->{"p2"}, $params->{'forename'}, $params->{'middlename'}, $params->{'surname'});
		if ($error eq '') {
			$html = clearBox("Success",(new Template("success.html"))->expand());
		}
		else {
			my $tobj = new Template("activate.html");

		$tobj->setKey("hash", $params->{"hash"});
		#BEN - this is commented out in pp, checking if it affects
		# new user login	
	#	$tobj->setError("error", $error);
			$html = clearBox("Activate Account",$tobj->expand());
		}
	}
	return paddingTable($html);
}

# make sure the user's application info is ok (input data is sane, no 
# collisions with other users)
#
sub checkNewUserInfo {
	my $params = shift;

	my $error = '';
	my $user = '';
	my $email	='';
	
	if (!defined($params->{'license'}) || $params->{'license'} ne 'on') {
		$error .= "You must agree to the license for an account.<br/>";
	} 
	if (!defined($params->{'user'}) || $params->{'user'} eq '') {
		$error .= "You must enter a username<br/>"; 
	} else {
		$user = $params->{'user'};
		if ($user =~ /[^\w\[\] ]/) {
			$error .= "Username contains invalid characters.<br/>"; }
		if ($user =~ /^ /) {
			$error .= "Username cannot begin with a space.<br/>"; }
		if ($user =~ / $/) {
			$error .= "Username cannot end with a space.<br/>"; }
		if ($user =~ /[^ ]	+[^ ]/) {
			$error .= "Username contains more than one space in a row.<br/>"; } 
	if (user_registered($params->{'user'},'username')) {
		$error .= "Sorry, that user name is taken.<br/>"; }
	}

	if (!defined($params->{'email'}) || $params->{'email'} eq '') {
		$error .= "You must enter an email address.<br/>"; 
	}
	else {
		$email = $params->{'email'};
		
	# TODO: add some real checks on email address here rfc 882
	#			 note: here is a fake check instead. this may be good enough.
	#
		if (not $email =~ /^[\w\-.]+\@[\w\-.]+$/ ) {
		$error .= "Please enter a <b>valid</b> email address.<br/>";
	}
	if (user_registered($email,'email')) {
			$error .= "Email address already in use.<br/>"; 
	}
	if (email_blacklisted($email)) {
		$error .= "That e-mail address is blacklisted! (shame on you!)<br />";
	}
	}

	return $error;
}

# check to see if an email address matches any of the blacklisted masks
#
sub email_blacklisted {
	my $address = shift;

	my ($rv, $sth) = dbSelect($dbh, {WHAT=>'mask', FROM=>getConfig('blist_tbl'), 'ORDER BY'=>'uid'});
	my @rows = dbGetRows($sth);
	
	foreach my $row (@rows) {
	
		my $mask = $row->{mask};

		return 1 if ($address =~ /$mask/);
	}

	return 0;
}

# make the hash key from the user and email address
#
sub makeHash {
	my $user = shift;
	my $email = shift;
	
	dwarn "user is $user, email is $email";
	my $hash = sha1_hex(join(':',$user,$email),SECRET);
	$hash = "$user:$email:$hash";
	return $hash; 
}

sub checkHash {
	my $hash_str = shift;
	
	my $error = "invalid hash";
	my @hash_data = split(/:/,$hash_str);
	
	return $error unless ($#hash_data eq 2);

	my %ticket = ('user'=>$hash_data[0],'email'=>$hash_data[1],'hash'=>$hash_data[2]);
# dwarn "user is $ticket{'user'} email is $ticket{'email'}";

	my $hash = sha1_hex(join(':',@ticket{qw(user email)}),SECRET);
# dwarn "checking, hash is $hash";

	return $error unless ($ticket{"hash"} eq $hash);
	return ''; 
}

sub activateAccount {
	my $dbh = shift;
	my $hash = shift;
	my $p1 = shift;
	my $p2 = shift;
        my $forename = shift;
	my $middlename = shift;
	my $surname = shift;

	
	my $error = checkHash($hash);
	my $preamble_file = getConfig('default_preamble');
	my $defpreamble = (new Template($preamble_file))->expand();

	# TODO: this function needs to be nicified in many ways, and have the 
	# actual database insert split off into another sub.

	unless ( ($forename ne '') and ($surname ne '') ) {
		return ("please enter a first and last name");
	}

	unless ($error eq '') {
	return($error); }

	unless ($p1 eq $p2) {
	return("passwords are different, please reenter"); }

	unless ($p1 ne '' and $p2 ne '') {
	return("empty password, please reenter"); }

	my ($user,$email) = split(/:/,$hash);
	dwarn "adding $user at $email to database";

	# silently fail if the user exists (probably the client submitted the same
	# command twice in rapid succession)
	#
	if (user_registered($user, 'username')) {
	
		dwarn "not adding $user at $email, already exists!";
	return '';
	}

	# create the record in the user table
	#
	my $newid = nextval('users_uid_seq');
	my ($rv,$dbq) = dbInsert($dbh,{
		INTO=>'users',
		COLS=>'uid,joined,username,password,email,preamble, forename, middlename, surname, displayrealname',
		VALUES=>"$newid,now(),'$user','$p1','$email','".sq($defpreamble)."','$forename', '$middlename', '$surname', 1"});
	$dbq->finish();

	if (not $rv) {
	return("failed to add user"); }

	# make the user's self-named default group and add them to it
	#
	#makeDefaultGroup($newid);
	#my $groupid = lookupfield(getConfig('groups_tbl'),"groupid","userid=$newid");
	#addUserToGroup($groupid,$newid);
	
	# create the default ACL records
	#

	# rule : anyone can read
#	addDefaultUserACL($newid,{default_or_normal=>'d', user_or_group=>'u',
#							 subjectid=>0,
#							 perms=>{'read'=>1,'write'=>0,'acl'=>0}});

	# rule : people in self-named group can write
#	addDefaultUserACL($newid,{default_or_normal=>'n',
#							 user_or_group=>'g',
#							 subjectid=>$groupid,
#							 perms=>{'read'=>1,'write'=>1,'acl'=>0}});

	# add the user to the object title index
	#
	indexTitle(getConfig('user_tbl'), $newid, $newid, $user, $user);

	# index the user name in the search engine
	#
	irIndex(getConfig('user_tbl'), {uid=>$newid, username=>$user});
	
	return ''; 
}

1;
