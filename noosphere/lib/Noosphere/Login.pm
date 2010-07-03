package Noosphere;

use strict;

# handleLogin - main entry point for getting user information hash and 
#	processing logins.
#
sub handleLogin {
	my ($req, $params, $cookies) = @_;
	

	my %user_info = ('ticket' => undef, 'time' => time(), 'uid' => -1,
									 'ip' => $ENV{'REMOTE_ADDR'});

	# handle proxy-forwarded IP
	#
	my $fip = [split(/\s*,\s*/,$req->headers_in->{'X-Forwarded-For'})]->[0];
	$user_info{'ip'} = $fip if ($fip);

	if (defined $cookies->{'ticket'}) {
		$user_info{'ticket'} = $cookies->{'ticket'}; 
	}
	
	my $user = $params->{'user'};
	my $passwd = $params->{'passwd'};

	# handle logging out: unset ticket
	#
	if ($params->{'op'} eq 'logout') {
		$user_info{'ticket'} = undef;
		$user_info{'uid'} = 0;

		clearCookie($req, 'ticket');

#		my $newparams = paramsToHash(urlunescape($params->{'url'}));
#		%$params = %$newparams;

		dwarn 'got logout'; 
	}
 
	# handle login op
	#
	elsif ($params->{op} eq 'login' && $user && $passwd) {
		$user =~ s/^ +//;
		$user =~ s/ +$//;
		$user =~ s/ +/ /g;
	
		warn "Attempting to log in $user";
	 
		my ($rv,$dbq) = dbSelect($dbh,{
			WHAT => '*',
			FROM => 'users',
			WHERE => "lower(username)=lower('$user') AND password='$passwd' AND active=1",
			LIMIT => 1});
	 
		# error if exactly one row wasn't returned
		#
		if ($rv != 1) {
			$user_info{'ticket'} = undef;
			$user_info{'uid'} = 0;	
		}

		# otherwise we found the user, get their info
		#
		else {
			my $row = $dbq->fetchrow_hashref();
			$dbq->finish();
			$user_info{'uid'} = $row->{'uid'}; 
	 
			$user_info{'ticket'} = makeTicket($user_info{'uid'},
				$user_info{'ip'},
				getConfig('cookie_timeout'),
				$user_info{'time'});

			#my $timeout = $user_info{'time'} + (60 * getConfig('cookie_timeout'));

			my $timeout = 60 * getConfig('cookie_timeout');
			setCookie($req, 'ticket', $user_info{'ticket'}, $timeout); 
		
#			my $newparams = paramsToHash(urlunescape($params->{'url'}));
#			%$params = %$newparams;
		}
	}

	# check for ticket holding login info for any other op
	#
	else {
		$user_info{'uid'} = checkTicket($user_info{'ticket'},
		$user_info{'ip'},
		getConfig('cookie_timeout'),
		$user_info{'time'});
	}

	# get data and prefs (even for anonymous user)
	#
	$user_info{'data'} = getUserData($user_info{'uid'});
	$user_info{'prefs'} = parsePrefs($user_info{'data'}->{'prefs'});

	# handle user last request statistics
	# 
	if ($user_info{'uid'} > 0) {
		markUserAccess($user_info{'uid'}, $user_info{'ip'});
	}

	# handle never logging out
	# 
	if ($user_info{'uid'} > 0 && $user_info{'prefs'}->{'neverlogout'} eq 'on') {
		my $timeout =	(180*24*60*60);	# 6 months
			
		# set a new cookie that pushes expiry time back.
		#
		setCookie($req, 'ticket', $user_info{'ticket'}, $timeout); 
	}

	return %user_info;
}

# get the contents of the login/logged-in box displayed on the left
#
sub getLoginBox {
#	my $params = shift;
	my $user_info = shift;

	my $data = $user_info->{'data'};
	
	my $boxtitle;
	my $login;
	my $template;
	
	if (defined $user_info->{'ticket'} && $user_info->{'uid'} > 0) {
		my $mail = getNewMailCount($user_info);
		my $corrections = countPendingCorrections($user_info);
		my $notices = getNoticeCount($user_info);
		my $xml = '';
		my $username = $data->{'username'};
		my $writer = new XML::Writer(OUTPUT=>\$xml);
		$writer->startTag("logged_in");
		if ( is_editor( $user_info->{'uid'} ) ) {
			$writer->startTag("editor");
			$writer->endTag("editor");	
		}
		$writer->startTag("username");
		$writer->characters($username);
		$writer->endTag("username");
		$writer->startTag('mail');
		$writer->characters($mail);
		$writer->endTag('mail');
		$writer->startTag('notices');
		$writer->characters($notices);
		$writer->endTag('notices');
		$writer->startTag('corrections');
		$writer->characters($corrections);
		$writer->endTag('corrections');
	        $writer->endTag("logged_in");

		my $xslt = getConfig("stemplate_path") . "/loggedin.xsl";
		my $loginbox = buildStringUsingXSLT( $xml, $xslt );

		return $loginbox;
		return "ERROR\n";
		$login = new Template('userbox.html');

#		$login->setKey('bullet', getBullet());
#		$login->setKey('id',$user_info->{uid});
#		$login->setKey('url', hashToParams($params));
	} else {
		my $xml = '';
		my $writer = new XML::Writer(OUTPUT=>\$xml);
		$writer->startTag("login");
		$writer->startTag("main_url");
		$writer->characters(getConfig("main_url"));
		$writer->endTag("main_url");
	        $writer->endTag("login");

		my $xslt = getConfig("stemplate_path") . "/login.xsl";
		my $loginbox = buildStringUsingXSLT( $xml, $xslt );
		return $loginbox;

		$boxtitle = 'Login';
		$login = new Template('login.html');
		my $error = 'login error';

		# handle deactivated account situation
		#
		#if (user_registered($params->{user}, 'username') &&
		#	!isUserActive($params->{user})) {
		
		#	$error = 'account deactivated';
		#}

		#$login->setKey('url', hashToParams($params));
		#$login->setKey('error', $params->{op} eq 'login' ? $error : '');
	}
	
#	return $login->expand();
}

1;
