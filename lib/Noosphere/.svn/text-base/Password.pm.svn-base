package Noosphere;

use strict;

use Digest::SHA1 qw(sha1_hex);

# change the password
#
sub pwChange {
  my $params = shift; 
  
  my $error = "";
  #Ben retook this line out the PP and PC needed
  my $hash = urlunescape($params->{"hash"});
  #my $hash = "";
  # check for a valid hash
  #
  my $herr = checkHash($hash);
  #my $herr = checkHash($params->{hash});
  if ($herr eq 'invalid hash') { 
    return errorMessage("Invalid password change URL.");
  }
  
  my $template = new Template('pwchange.html');

  # handle submission
  #
  if (defined $params->{submit}) {
    if ($params->{pw1} ne $params->{pw2}) {
	  $error .= "passwords don't match!<br>";
	}

    # make the password change
	if (!$error) {
      return changePassword($hash,$params->{pw1});
	}
  }
  
  # initial form and error handling
  #
  $template->setKey('error',$error);
  $template->setKey('hash',$hash);
  #$template->setKey('hash', $params->{hash});

  return paddingTable(makeBox('Change Your Password',$template->expand()));
}

# actual database change of password, plus return acknowledgement form 
#
sub changePassword {
  my $hash = shift;
  my $password = shift;

  # extract username from the hash
  my ($username) = split(/:/,$hash);

  # do the database operation
  my ($rv, $sth) = dbUpdate($dbh, {WHAT=>getConfig('user_tbl'),SET=>"password='$password'",WHERE=>"username='$username'"});
  $sth->finish();

  # return an acknowledgement
  return paddingTable(makeBox('Password Changed',"The password for <b>$username</b> has been changed.  <p> You may now log in using the new password."));
}

# request a password change.  
#
sub pwChangeRequest {
  my $params = shift;

  my $template = new Template('reqpwchange.html');
  my $error = "";

  if (defined $params->{submit}) {
     # look up the user
	 my $email = lookupfield(getConfig('user_tbl'),'email',"username='$params->{username}'");
	 if (!$email) {
	   $error .= "Cannot find that user!<br>";
	 }
     if (!$error) {
	   # make the hash
	   my $hash=sha1_hex(join(':',$params->{username},$email),SECRET);
       # send out the message
	   return sendPwChangeMail($params->{username},$email, $hash);
	 }
  } 

  # return initial form
  #
  $template->setKey('username',$params->{username});
  $template->setKey('error',$error);
  
  return paddingTable(makeBox('Request a Password Change',$template->expand()));
}

# send out the message with further instructions, return an acknowledgement
#
sub sendPwChangeMail {
  my $username = shift;
  my $email = shift;
  my $hash = shift;

  $hash = urlescape($username.':'.$email.':'.$hash);
  
  # send the mail
  sendMail($email, "
  
Somebody (hopefully you) has requested a password change for the account \"$username.\"  To complete this change, go to the following URL:

 ".getConfig("main_url")."/?op=pwchange&hash=$hash

If you received this message without requesting it, it is possible someone is doing something malicious.  Let us know at ".getAddr('feedback').".
  
  ", getConfig('projname').": password change");

  return paddingTable(makeBox('Mail Sent',"A message was sent to <b>$email</b> with further instructions.  Please follow them to change your password."));
}

1;
