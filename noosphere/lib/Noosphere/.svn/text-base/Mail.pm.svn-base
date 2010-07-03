package Noosphere;

use strict;

# getOriginalMailValues - get values from mail we're replying to and put them
#												 into template.
#
sub getOriginalMailValues {
	my $template = shift;
	my $params = shift;
	
	my $id = $params->{id};

	my ($rv,$sth) = dbSelect($dbh,{
		WHAT=>'mail.*,users.username',
		FROM=>'mail,users',
		WHERE=>"users.uid=mail.userfrom and mail.uid=$id"});

	my $rec = $sth->fetchrow_hashref();
	$sth->finish();

	my $body = $rec->{body};
	my $disporig = htmlescape($rec->{body});
	$disporig =~ s/\n/<br \/>/g;
	$template->setKeys('original' => $body, 'disporig' => $disporig, 'sendto' => $rec->{username});
}

# replyMail - reply to a message
# 
sub replyMail	{
	my $params = shift;
	my $userinf = shift;
	
	return needAccount() if $userinf->{'uid'} <= 0;

	my $template = new Template('replymail.html');
	my $error = '';

	if (defined $params->{post}) {
		$error = checkSendMail($params,$userinf);
		if ($error eq '') {
			# actually send
			insertMail($params,$userinf);
			return paddingTable(makeBox("Reply Sent","Your message was sent. Click <a href=\"".getConfig("main_url")."/?op=mailbox\">here</a> to go back to your mailbox."));
		} else {
			getOriginalMailValues($template,$params);
			$template->setKeys(%$params);
		}
	}
	
	elsif (defined $params->{spell}) {
		my $text = $params->{body};
		$text =~ s/>.*?\n//gs;
		$text =~ s/^\s*//s;
		dwarn "submitting to spell : $text";
		my $spell = checkdoc($text);
		$template->setKey('spell', "Spell check (broken words in red, clickable):<br><table width=\"100%\"><tr><td bgcolor=\"#ffffff\">$spell</td></tr></table><hr>");
		getOriginalMailValues($template,$params);
		$template->setKeysIfUnset(%$params);
	}

	elsif (defined $params->{quote}) {
		my $quoted = getquoted($params->{original});
		if (nb($params->{body})) {
			$params->{body} = "$quoted\n\n$params->{body}";
		} else {
			$params->{body} = "$quoted\n\n";
		}
		getOriginalMailValues($template,$params);
		$template->setKeys(%$params);
	}
 
	else {
		$template->setKey('subject', $params->{'rsubject'});
		getOriginalMailValues($template,$params);
		$template->setKeys(%$params);
		$template->unsetKeys('body', 'spell', 'error');
	}

	$template->setKey('error', $error);

	return paddingTable(makeBox('Reply to Mail Message',$template->expand()));
}

# unsendMail - unsend a mail message
#
sub unsendMail {
	my $params = shift;
	my $userinf = shift;
	
	my $id = $params->{id};

	return needAccount() if $userinf->{'uid'} <= 0;

	return errorMessage('Missing id parameter.') if (not defined $params->{id});

	my ($rv,$sth)=dbSelect($dbh,{
			WHAT=>'*',
			FROM=>'mail',
			WHERE=>"uid=$id"});
 
	return errorMessage("Query error, contact admin.") if (!$rv);
	
	return errorMessage("Message could not be found. ".getConfig('projname')." may be inconsitant, notify an admin.") if ($sth->rows() < 1);
	
	my $row = $sth->fetchrow_hashref();

	return errorMessage("You cannot unsend mail you did not send.") if ($row->{userfrom} != $userinf->{uid});

	return errorMessage("You cannot unsend mail that has been read.") if ($row->{'_read'} == 1);
 
	# if we're still here, go ahead and "unsend" (i.e., delete the record)
	#
	($rv,$sth) = dbDelete($dbh,{
						FROM=>'mail',
						WHERE=>"uid=$id"});
	$sth->finish();

	return paddingTable(makeBox('Mail Unsent',"Your message has been unsent. To return to your mailbox, click <a href=\"".getConfig("main_url")."/?op=mailbox\">here</a>. To return to sent mail, click <a href=\"".getConfig("main_url")."/?op=sentmail\">here</a>."));
}

# getNewMailCount - get a count of new (unread) mail messages
#
sub getNewMailCount {
	my $userinf = shift;

	return -1 if ($userinf->{uid} < 1);

	my ($rv,$sth) = dbSelect($dbh,{
			WHAT=>'count(uid) as cnt',
			FROM=>'mail',
			WHERE=>"mail.userto=$userinf->{uid} and _read is null"});

	return -1 if (!$rv);
	my $row = $sth->fetchrow_hashref();

	return $row->{cnt};
}

# getMail - get/display a mail message
#
sub getMail {
	my $params = shift;
	my $userinf = shift;
	
	my $id = $params->{'id'};
	my $template = new XSLTemplate('dispmail.xsl');
	my $sender = 0;
	my $recipient = 0;

	return needAccount() if $userinf->{'uid'} <= 0;
	
	my ($rv,$sth) = dbSelect($dbh,{
			WHAT=>'mail.*,u1.username as fromname, u2.username as toname ',
			FROM=>'mail,users as u1, users as u2',
			WHERE=>"mail.userfrom=u1.uid and mail.userto=u2.uid and mail.uid=$id"});

	return errorMessage("Query error, contact admin.") if (!$rv);

	my $rec = $sth->fetchrow_hashref();

	# security.  egregious ommission previously, thanks bbukh.
	#
	return errorMessage("You can't access that message!") if (!($userinf->{'uid'} == $rec->{'userfrom'} || $userinf->{'uid'} == $rec->{'userto'}));

	# figure out if we're the recipient, if so, mark mail as read if its not.
	#
	if ($rec->{'userto'} == $userinf->{'uid'}) {
		$recipient = 1;
		markMailRead($id) if (not defined $userinf->{'read'});
	}

	# build output data
	#
	$template->addText('<dispmail>');
	$template->setKeys(%$rec);

	# if we're the sender, do not allow replying.
	#
	$template->setKey('reply', !($rec->{'userfrom'} == $userinf->{'uid'}));

	# if we're the sender, and not also the recipient, and the message 
	# has not yet been read, allow unsending
	#
	$template->setKey('unsend', (($rec->{'userfrom'} == $userinf->{'uid'}) and ($recipient == 0) and (not defined $rec->{'_read'})));
 
	my $body = $rec->{'body'};
	$body = htmlescape($body);
	$body =~ s/\n/<br \/>/g;
	$template->setKey('body_formatted', $body);

	if ($rec->{'subject'} !~ /^\s*Re:/i) {
		$template->setKey('rsubject', "Re: $rec->{subject}");
	} else {
		$template->setKey('rsubject', $rec->{'subject'});
	}
	
	$template->addText('</dispmail>');

	return $template->expand();
}

# markMailread - set the "read" flag of a mail message, no questions asked
#
sub markMailRead {
	my $id = shift;

	my ($rv,$sth) = dbUpdate($dbh,{WHAT=>'mail',SET=>'_read=1',WHERE=>"uid=$id"});
	$sth->finish();
}

# mailBox - get mail box screen
#
sub mailBox {
	my $params = shift;
	my $userinf = shift;
	
	my $template = new Template('mailbox.html');
	my $list = '';

	return errorMessage('Must be logged in to use mail') if ($userinf->{uid} < 1);

	my ($rv,$sth) = dbSelect($dbh,{
			WHAT=>'mail.subject,mail.sent,mail.uid,mail.userfrom,users.username',
			FROM=>'mail,users',
			WHERE=>"users.uid=mail.userfrom and mail.userto=$userinf->{uid} and _read is null",
			'ORDER BY'=>'sent',
			DESC=>''});

	return errorMessage("Query error, contact admin.") if (!$rv);
 
	my @rows = dbGetRows($sth);
 
	if ($#rows > -1) {
	$list .= "<table width=\"100%\">";
	$list .= "<tr>
					 <td align=\"center\"><b>date</b></td>
			 <td width=\"80%\" align=\"center\"><b>subject</b></td>
			 <td align=\"center\"><b>from</b></td></tr>";
		my $parity = 1;
		foreach my $row (@rows) {
		my $date = ymd($row->{sent});
		my $bg = $parity?" bgcolor=\"#eeeeee\"":"";
			$list .= "<tr $bg>";
			$list .= "<td>$date</td>";
			$list .= "<td><a href=\"".getConfig("main_url")."/?op=getmail&id=$row->{uid}\">$row->{subject}</a></td>";
			$list .= "<td><a href=\"".getConfig("main_url")."/?op=getuser&id=$row->{userfrom}\">$row->{username}</a></td>";
		$list .= "</tr>";
		$parity = $parity?0:1;
		} 
	$list .= "</table>";
	} else {
		$list = "No new mail.";
	}
 
	$template->setKey('newmail', $list);
	
	return paddingTable(clearBox('Your '.getConfig('projname').' Mail Box',$template->expand()));
}

# sentMail - get mail box screen
#
sub sentMail {
	my $params = shift;
	my $userinf = shift;
	
	my $scale = 2;
	my $template = new Template('pmsentmail.html');
	my $offset = $params->{'offset'} || 0;
	my $limit = int($userinf->{'prefs'}->{'pagelength'} / $scale);

	my $list = '';

	return errorMessage('Must be logged in to use '.getConfig('projname').' mail') if ($userinf->{uid} < 1);

	# get total
	$params->{'total'} = dbRowCount('mail', "mail.userfrom=$userinf->{uid}");

	# get items
	my ($rv,$sth) = dbSelect($dbh,{
			WHAT=>'mail.*,users.username',
			FROM=>'mail,users',
			WHERE=>"users.uid=mail.userto and mail.userfrom=$userinf->{uid}",
			'ORDER BY'=>'sent',
			DESC=>'',
			OFFSET=>$offset, 
			LIMIT=>$limit});

	return errorMessage("Query error, contact admin.") if (!$rv);
 
	my @rows = dbGetRows($sth);
 
	if ($#rows > -1) {

		$list .= getPager($params, $userinf, $scale);
		$list .= "<br />";

		$list .= "<table width=\"100%\">";
		$list .= "<tr>
			 <td align=\"center\"><b>date</b></td>
			 <td width=\"80%\" align=\"center\"><b>subject</b></td>
			 <td align=\"center\"><b>to</b></td>
			 <td align=\"center\"><b>read</b></td>
			</tr>";
		my $parity = 1;
		foreach my $row (@rows) {
			my $date = ymd($row->{'sent'});
			my $bg = $parity ? " bgcolor=\"#eeeeee\"" : "";
		
			$list .= "<tr $bg>";
			$list .= "<td>$date</td>";
			$list .= "<td><a href=\"".getConfig("main_url")."/?op=getmail&id=$row->{uid}\">$row->{subject}</a></td>";
			$list .= "<td align=\"center\"><a href=\"".getConfig("main_url")."/?op=getuser&id=$row->{userto}\">$row->{username}</a></td>";
			my $read = "n";
			$read = "y" if (defined $row->{'_read'} and $row->{'_read'} == 1);
			$list .= "<td align=\"center\">$read</td>";
			$list .= "</tr>";
			$parity = $parity ? 0 : 1;
		} 
		$list .= "</table>";

		$list .= getPager($params, $userinf, $scale);
	} else {
		$list = "No sent mail.";
	}
 
	$template->setKey('sentmail', $list);
	
	return paddingTable(clearBox('Your '.getConfig('projname').' Mail Box',$template->expand()));
}

# oldMail - get Old Mail list
#
sub oldMail {
	my $params = shift;
	my $userinf = shift;
	
	my $template = new Template('oldmail.html');
	my $list = '';
	my $scale = 2;
	my $offset = $params->{'offset'} || 0;
	my $limit = int($userinf->{'prefs'}->{'pagelength'} / $scale);

	return errorMessage('Must be logged in to use '.getConfig('projname').' mail') if ($userinf->{uid} < 1);

	# get total
	$params->{'total'} = dbRowCount('mail', "mail.userto=$userinf->{uid} and _read=1");

	# get messages 
	my ($rv,$sth) = dbSelect($dbh,{
			WHAT=>'mail.subject,mail.sent,mail.uid,mail.userfrom,users.username',
			FROM=>'mail,users',
			WHERE=>"users.uid=mail.userfrom and mail.userto=$userinf->{uid} and _read=1",
			'ORDER BY'=>'sent',
			DESC=>'',
			LIMIT=>$limit,
			OFFSET=>$offset});
	
	return errorMessage("Query error, contact admin.") if (!$rv);
 
	my @rows = dbGetRows($sth);
 
	if ($#rows > -1) {
		$list .= getPager($params, $userinf, $scale);
		$list .= "<br/>";

		$list .= "<table width=\"100%\">";
		$list .= "<tr>
			 <td align=\"center\"><b>date</b></td>
			 <td width=\"80%\" align=\"center\"><b>subject</b></td>
			 <td align=\"center\"><b>from</b></td></tr>";
		my $parity = 1;
		foreach my $row (@rows) {
			my $date = ymd($row->{sent});
			my $bg = $parity?" bgcolor=\"#eeeeee\"":"";
			
			$list .= "<tr $bg>";
			$list .= "<td>$date</td>";
			$list .= "<td><a href=\"".getConfig("main_url")."/?op=getmail&id=$row->{uid}\">$row->{subject}</a></td>";
			$list .= "<td><a href=\"".getConfig("main_url")."/?op=getuser&id=$row->{userfrom}\">$row->{username}</a></td>";
			$list .= "</tr>";
			$parity = $parity ? 0 : 1;
		} 
		$list .= "</table>";

		$list .= getPager($params, $userinf, $scale);
	} else {
		$list = "No old mail.";
	}
 
	$template->setKey('oldmail', $list);
	
	return paddingTable(clearBox('Your '.getConfig('projname').' Mail Box',$template->expand()));
}

sub sendMailForm {
	my $params = shift;
	my $userinf = shift;
	
	my $template = new Template('sendmail.html');
	my $error = '';

	return needAccount() if $userinf->{'uid'} <= 0;
	
	if (defined $params->{'post'}) {
		$error = checkSendMail($params,$userinf);
		if ($error eq "") {
			# actually send
			insertMail($params,$userinf);
			return paddingTable(makeBox("Mail Sent","Your message was sent. Click <a href=\"".getConfig("main_url")."/?op=mailbox\">here</a> to go back to your mailbox."));
		} else {
			$template->setKeys(%$params);
			$template->unsetKey('spell');
		}
	} 
	
	elsif (defined $params->{spell}) {
		my $text = $params->{body};
		$text =~ s/>.*?\n//gs;
		$text =~ s/^\s*//s;
		dwarn "submitting to spell : $text";
		my $spell = checkdoc($text);
		$template->setKey('spell', "Spell check (broken words in red, clickable):<br><table width=\"100%\"><tr><td bgcolor=\"#ffffff\">$spell</td></tr></table><hr>");
		$template->setKeysIfUnset(%$params);
	}

	# get pristine form
	#
	else {
		$template->setKeys(%$params);
		$template->unsetKeys('subject', 'body', 'spell');
	}

	$template->setKey('error', $error);

	return paddingTable(makeBox('Send Mail',$template->expand()));
}

sub checkSendMail {
	my $params = shift;
	my $userinf = shift;
	
	my $error = '';
	
	# check for non-blank fields 
	#
	$error .= "Need a user to send to!<br />" if (blank($params->{sendto}));
	$error .= "Need a subject!<br />" if (blank($params->{subject}));
	$error .= "Need a message!<br />" if (blank($params->{body}));

	# check for valid user
	#
	$error .= "Need a registered ".getConfig('projname')." user for 'To:' field.<br />" if (not user_registered($params->{sendto},'username'));

	$error .= "<br />" if (nb($error));
	return $error;
}

# insertMail - actually "send" it (put it in the database)
#
sub insertMail {
	my $params = shift;
	my $userinf = shift;
	
	return errorMessage('Must be logged in to use '.getConfig('projname').' mail') if ($userinf->{uid} < 1);
	
	my $recipient = getuidbyusername($params->{sendto});
	
	my $nextid = nextval('mail_uid_seq');

	my ($rv,$sth) = dbInsert($dbh,{
			INTO=>'mail',
			COLS=>'sent,uid,userto,userfrom,subject,body',
			VALUES=>"now(),$nextid,$recipient,$userinf->{uid},".quotefields($params->{'subject'},$params->{'body'})});
	$sth->finish();

	# send e-mail notification for system mail if desired
	#
	my %recipientinf = userInfoById($recipient);
	if ($recipientinf{'prefs'}->{'sysemail'} eq 'on') {

		my $userfromname = $userinf->{'data'}->{'username'};

		my $proj = getConfig('projname');
		my $root = getConfig('main_url');

		my $subject = "You have received $proj mail";
		my $body = "Subject: $subject 
From user: $userfromname

Message:

$params->{body}

";

		$body .= "To reply, go to $root/?op=getmail&id=$nextid

NOTE: You can turn these email notifications off  by toggling the corresponding
option in your preferences ( $root/?op=editprefs ).
";
		
		sendMail($recipientinf{'data'}->{'email'},$body,$subject);
	} 
}

1;
