#!/usr/bin/perl

#This is the main module for the Noosphere package

package Noosphere;

use strict;

use Noosphere::Util;
use Noosphere::XSLTemplate;
use Noosphere::Params;
use HTML::Tidy;
use Data::Dumper;
use Apache2::RequestRec();
use Apache2::Const;


use vars qw{%HANDLERS %NONTEMPLATE %CACHEDFILES %REDIRECT};
use vars qw{$dbh $DEBUG $NoosphereTitle $AllowCache $MAINTENANCE $stats $LoadjsMath $CONTENT_TYPE};

# 0 to turn off debug warnings.	1 turns on level 1 display, 2 for level 2 
#	(shows all database and file operations), and so on.
$DEBUG = 0;

# are we in maintenance mode?
#
sub inMaintenance {
	my $ip = shift;	# client IP for whitelist check
	my $root = getConfig('base_dir');

	if (-e "$root/maintenance") {

		# if IP list is present, build and check whitelist
		#
		if (-e "$root/maintenance_ips") {
			open FILE, "$root/maintenance_ips";
			my @list = <FILE>;
			chomp @list;
			my %whitelist = map { $_ => 1 } @list;
			
			# if IP is in whitelist, pretend like we're not in maintenance mode
			#
			if ($whitelist{$ip}) {
				return 0;
			}

			# otherwise, block the request
			#
			else {
				return 1;
			}
		} 
		
		# no IP list-- reject everyone
		# 
		else {
			return 1;
		}
	}

	return 0;
}

sub doRedirectContent {
	my ($params, $user_info, $upload) = @_;
	dispatch(\%REDIRECT, $params, $user_info, $upload);

}

# call functions that have raw output (not embedded in any templates) 
#
sub getNoTemplateContent {
	my ($params, $user_info, $upload) = @_;

	if ($MAINTENANCE == 1) {
		return getMaintenance();
	}

	if ($params->{'op'} eq 'robotstxt') {
		return getConfig('robotstxt');
	}

	my $content = dispatch(\%NONTEMPLATE, $params, $user_info, $upload); 
	
	return $content;
}

# call functions that have output meant to go in the view template
#
sub getViewTemplateContent {
	my ($params, $user_info, $upload) = @_;
	# find function call in handler table and execute it with standard params
	#
	my $content = dispatch(\%HANDLERS,$params, $user_info, $upload); 
	
	return $content;
}

# for main window, with both sidebars
#
sub getMainTemplateContent {
	my $userinf = shift;
	my $content = '';
	# op=news or op=main
	#$content = paddingTable(getTopNews($userinf));
	$content = getFrontPage({}, $userinf);

	return $content;
}

# get the data for front page (latest news, messages) and combine with template
#
sub getFrontPage {
	my $params = shift;
	my $userinf = shift;

#	my $template = new XSLTemplate('frontpage.xsl');

	
	my $xmlstring = '';
	my $w = new XML::Writer( OUTPUT=>\$xmlstring, UNSAFE=>1 );
	$w->startTag('frontpage');
	#latest additions
	my $la = getLatestAdditions();
	$w->startTag("latest_additions");
	$w->raw($la);
	$w->endTag("latest_additions");
	#top authors
	my $ta = getTopUsers();
	$w->startTag("top_users");
	$w->raw($ta);
	$w->endTag("top_users");
	$w->endTag('frontpage');

	
	my $xslt = getConfig("stemplate_path") . "/frontpage.xsl";
	my $page = buildStringUsingXSLT( $xmlstring, $xslt );
	return $page;

	
#	$template->addText("<frontpage>");

	# get the data and add it to be transformed by the stylesheet
	#
#	my $newsxml = $stats->get('top_news');
#	my $messagexml = $stats->get('latest_messages');

	#my $messages = getLatestMessagesXML($params, $userinf);

#	$template->addText($newsxml);
#	$template->addText($messagexml);
#	$template->addText("</frontpage>");

#	return $template->expand();
}

# get main menu box
# 
sub getMainMenu {
	my $template = new XSLTemplate("mainmenu.xsl");
	$template->addText('<mainmenu>');

	my $count = getUnfilledReqCount();
	my $request_count = '';
	$request_count = "($count)" if ($count);

	$count = orphanCount();
	my $orphan_count = '';
	$orphan_count = "($count)" if ($count);
  
	$count = countGlobalPendingCorrections();
	my $cor_count = '';
	$cor_count = "($count)" if ($count);
  
	my $uc_count = '';
	if (getConfig('classification_supported')) {
		$count = $stats->get('unclassified_objects');
		$uc_count = "($count)" if ($count);
	}
  
	$count = $stats->get('unproven_theorems');
	my $up_count = '';
	$up_count = "($count)" if ($count);
	
	my $bullet = getBullet();
	
	$template->setKeys('unproven' => $up_count, 'unclassified' => $uc_count, 'orphans' => $orphan_count, 'corrections' => $cor_count, 'requests' => $request_count, 'bullet' => $bullet);
	
	$template->addText('</mainmenu>');

	return makeBox("Main Menu",$template->expand());
}

# fill sidebars into a template
#
sub fillInSideBars {
	my $html = shift;
	my $params = shift;
	my $userinf = shift;
	my $sidebar = new Template("sidebar.html");
	my $rightbar = new Template("rightbar.html");
	my $login = getLoginBox($userinf);
	$sidebar->setKey('login', $login);
	my $search = getSearchBox($params);
	my $admin = getAdminMenu($userinf->{data}->{access});
	my $editor = getEditorMenu( $userinf->{'uid'} );
	my $topusers = getTopUsers();
	my $features = getMainMenu();
	my $latesta = getLatestAdditions();
	my $latestm = getLatestModifications();
#	my $poll = getCurrentPoll();
	$sidebar->setKeys('search' => $search, 'admin' => $admin, 'features' => $features, 'editor' => $editor, 'login' => $login);
	$rightbar->setKeys('topusers' => $topusers, 'latesta' => $latesta, 'latestm' => $latestm);
	$html->setKeys('sidebar' => $sidebar->expand(), 'rightbar' => $rightbar->expand());
}

# fill left bar (sidebar) into a template
#
sub fillInLeftBar {
	my $html = shift;
	my $params = shift;
	my $userinf = shift;

	warn "fill in left bar called\n";
	
	my $sidebar = new Template("sidebar.html");
	my $login = getLoginBox($userinf);
	my $features = getMainMenu();
	my $admin = getAdminMenu($userinf->{data}->{access});
	my $editor = getEditorMenu( $userinf->{'uid'} );
	$sidebar->setKeys('login' => $login, 'admin' => $admin, 'features' => $features, 'editor' => $editor);
	$html->setKey('sidebar', $sidebar->expand());
	warn "returning $html\n";
	return $html;
}

# get "top" stuff: header and CSS
#
#no more CSS here.
sub headerAndCSS {
	my $template = shift;
	my $params = shift;
	my $search = getSearchBox($params);
	my $header = new Template('header.html');

	$header->setKey('search', $search);
	$template->setKey('header', $header->expand());
	#handle jsMath.
	#
	my $jsmathCode = 
		"<SCRIPT SRC=\"http://" . getConfig('siteaddrs')->{'main'} ."/jsmath/easy/load.js\"></SCRIPT>";
	$template->setKey('jsmathcode', ($LoadjsMath ? $jsmathCode : ''));
}

# final sending of response to web request
#
sub sendOutput {
	my $req = shift;
	my $html = shift;
	my $status = shift || 200;
	my $len = bytes::length($html);

	$req->status($status);
	$req->content_type('text/html;charset=UTF-8');
#    $req->content_language('en');
	$req->headers_out->add('content-length' => $len);
#	$req->send_http_header;
	$req->print($html);
	$req->rflush(); 
}

sub serveImage {
	my ($req, $id) = @_;
	my $image = getImage($id);
	my $len = bytes::length($image);

	$req->content_type('image/png');
	$req->headers_out->add('content-length' => $len);
#	$req->send_http_header;
	$req->print($image);
	$req->rflush();
}

# BB: cached files stored in %CACHEDFILES
#     key exists -- file should be cached
#     key defined -- file has been cached
sub serveFile {
	my ($req, $name) = @_;
	my $html = '';
	unless (defined %CACHEDFILES) {
		my $cachelist = getConfig('cachedfiles');
		%CACHEDFILES = %$cachelist;
		foreach my $key (keys %CACHEDFILES) {
			undef $CACHEDFILES{$key};
		}
	}
	unless (defined $CACHEDFILES{$name}) {
		my $filenames = getConfig('cachedfiles');
		$CACHEDFILES{$name} = [readFile($filenames->{$name}->[0]), $filenames->{$name}->[1] ];
	}
	$html = $CACHEDFILES{$name}->[0];

	warn "reading in $name";
	my $file = readFile($name);
	my $len = bytes::length($file);
#	$req->content_type($CACHEDFILES{$name}->[1]);
	$req->headers_out->add("content-length" => "$len");
#	$req->send_http_header;
	warn "returning size = $len";
	warn "$file";
	$req->print($file);
	$req->rflush(); 

	return;	

	unless (exists $CACHEDFILES{$name}) {
		return 404;	
	}
}

# users who haven't run startup.pl should call this
sub initNoosphere {
	initStats();
}

sub initStats {

	require Noosphere::StatCache;
	$stats = new StatCache;

	# add in the statcache statistics
	#
	$stats->add('unproven_theorems',{callback=>'unprovenCount'});
	$stats->add('unclassified_objects',{callback=>'unclassifiedCount'});
	$stats->add('topusers',{timeout=>30*60, callback=>'getTopUsers_callback'});
	$stats->add('latestadds',{callback=>'getLatestAdditions_data'});
	$stats->add('latestmods',{callback=>'getLatestModifications_data'});
	$stats->add('latest_messages',{timeout=>10*10,callback=>'getLatestMessages_data'});
	$stats->add('top_news',{callback=>'getTopNews_data'});
}

# main noosphere CGI entry point (incomplete)
#
sub cgi_handler {
	my $params = shift;
	my $cookies = shift;
}

# main noosphere mod_perl entry point
#
sub handler {
#	my $req = shift;
	my $req = Apache2::Request->new(shift);
	$LoadjsMath = 0;	
  
	my ($params,$upload) = parseParams($req);
	my %cookies = parseCookies($req);
	my $html = '';

	$AllowCache = 1;	# default to allow client caching

	# uri remapping
	# we use this instead of a mod_rewrite-ish thing
	#
	my $uri = $req->uri();
	
	# deny IIS virii requests
	#
	if ($uri =~ /[aA]dmin\.dll/o || 
		$uri =~ /root\.exe/o ||
		$uri =~ /winnt/o ||
		$uri =~ /cmd\.exe/o ) {
		
		$html .= "No IIS here, sorry.";
		my $len = length($html);
		$req->header_out("Content-Length"=>"$len");
		$req->send_http_header;
		$req->print($html);
		$req->rflush(); 
		exit;	
	}

	# banned hosts or clients
	#
	my $banned = 0;
	my $bannedips = getConfig('bannedips');

	# NOTE: this will not work if you are proxy forwarding!
	if (exists $bannedips->{$ENV{'REMOTE_ADDR'}}) {
		$banned = 1;
	}

	foreach my $str (@{getConfig('screen_scrapers')}) {
		if ($ENV{'HTTP_USER_AGENT'} =~ /$str/i ) {
			$banned = 1;
			last;
		}
	}

	if ($banned) {
		$html .= "You or your client is banned.  This is probably for trying to mirror us impolitely.  Please download snapshots instead, this is what they are for.";
		my $len = bytes::length($html);
		$req->header_out("Content-Length"=>"$len");
		$req->send_http_header;
		$req->print($html);
		$req->rflush(); 

		exit;	
	} 

	# BB: cached files serving
	if ($uri =~ /\/files\/(.+)$/o) { 
		$params->{'img'} = "/data/files/" . $1;
		warn " calling serveImageFile [$1]";
		return serveImageFile($req,$params);
	}

# NEED TO DO A GOOGLE SITEMAP VERIFICATION?  
#
# uncomment this and replace the hash accordingly.
 
	if ($uri =~ /google1f26750bda7f5318\.html/) {
		sendOutput($req, '');

		return;
	}

	# remapping
	#
	if ($uri =~ /\/[Ee]ncyclopedia\/(.+)\.htm[l]{0,1}(#.+)?$/o ||
			$uri =~ /^\/([^\/]+)\.htm[l]{0,1}(#.+)?$/) {
		
		$params->{'op'} = 'getobj';
		$params->{'from'} = getConfig('en_tbl');
		my $basename = $1;
		if ($basename =~ /^\d+$/) {
			$params->{'id'} = $basename;
		} else {
			$params->{'name'} = $basename;
		}
	} elsif ($uri =~ /\/[Ee]ncyclopedia\/([0-9A-Z])[\/]{0,1}$/o) {
	
		my $ord = ord($1);
		$params->{'op'} = 'en';
		$params->{'idx'} = "$ord";
	
	} elsif ($uri =~ /\/[Ee]ncyclopedia[\/]{0,1}$/o) {
	
		$params->{'op'} = 'en';
	}
	elsif ($uri =~ /\/browse\/([^\/]+)\/([^\/]+)\/$/o) {

		my $from = $1;
		my $id = $2;

		$params->{'op'} = 'mscbrowse';
		$params->{'from'} = $from;
		$params->{'id'} = $id;
	}

	elsif ($uri =~ /\/browse\/([^\/]+)\/$/o) {

		my $from = $1;

		$params->{'op'} = 'mscbrowse';
		$params->{'from'} = $from;
	} elsif ( $uri =~ /(\/javascripts\/.*)$/o) {
		my $file = $1;
		$params->{'op'} = 'getimg';
#		$params->{'img'} = 'jquery.js';
		$params->{'img'} = '/data/' . $file;
#	} elsif ( $uri =~ /(\/js\/.*)$/o) {
#		my $file = $1;
#		$params->{'op'} = 'getimg';
#		$params->{'img'} = 'jquery.js';
#		$params->{'img'} = '/data/' . $file;
	} elsif ( $uri =~ /(\/stylesheets\/.*)$/o) {
		my $file = $1;
		$params->{'op'} = 'getimg';
#		$params->{'img'} = 'jquery.js';
		$params->{'img'} = '/data/' . $file;
	} elsif ( $uri =~ /(\/styles\/.*)$/o) {
		my $file = $1;
		$params->{'op'} = 'getimg';
#		$params->{'img'} = 'jquery.js';
		$params->{'img'} = '/data/' . $file;
	}
	elsif ($uri =~ /(\/images\/.*)$/o) {
		my $image = $1;
		$params->{'op'} = 'getimg';
		$params->{'img'} = '/data/' . $image;
	} elsif ( $uri =~ /(\/aux\/.*)$/o){
		warn "opening " . $params->{'img'};
		my $image = $1;
		$params->{'op'} = 'getimg';
		$params->{'img'} = '/data/' . $image;
	} elsif ($uri =~ /(\/jsmath\/.*)$/o ) {
		my $image = $1;
		$params->{'op'} = 'getimg';
		$params->{'img'} = '/data/' . $image;
	}

	elsif ($uri =~ /(\/cache\/.*)$/o) {
		my $image = $1;
		$params->{'op'} = 'getimg';
		$params->{'img'} = '/data/' . $image;
	}
	
	# RSS HANDLER
	#
	elsif ($uri =~ /\/rss\/(\w+)\.xml$/io) {
		$params->{'op'} = 'rssxml';
		$params->{'channel'} = lc($1);
	}

	# remap to display robots.txt directives
	#
	if ($uri =~ /\/robots\.txt$/o) {
		$params->{'op'} = 'robotstxt';
	}

	# generic remapping of /param=val/... style paths
	# NOTE: do we really want to rewrite all of the CGI strings
	# in this site to use this style? hmm...
	#
    if ($uri =~ /\/((?:\w+=[^\/]+\/)+)/o) {
		my $path = $1; 
		
		foreach my $keyval (split(/\//,$path)) { 
			my ($key, $val) = split(/=/,$keyval); 
			$params->{$key} = $val;
		} 
	}
				
#	dwarn "Request URI is $uri";

	# debug print request headers
	# 
	#my %headers_in=$req->headers_in;
	#dwarn "HEADERIN: ----------------------\n";
	#foreach my $key (keys %headers_in) {
	#	dwarn "HEADERIN: $key=>$headers_in{$key}\n";
	#}
	
	# return maintenance mode message.  also checks to see if in whitelisted
	# maintenance mode.
	#
	if (inMaintenance($ENV{'REMOTE_ADDR'})) {
		sendOutput($req, getMaintenance(), 502); # server overloaded status
		return;
	}

	# connect to db
	#
	$dbh = dbConnect() or die "Couldn't open database: ",$DBI::errstr; 

	# handle serving of images
	#
	if ($params->{op} eq 'getimage') {  
		serveImage($req, $params->{id});
		return;	
	}

	if ($params->{op} eq 'getimg' ) {
		serveImageFile($req, $params);
		return;
	}
	
	# initialize stat cache
	#
	if (not defined $stats) {
		initStats();
	}
 
	# user info and cookies
	#
	my %user_info = handleLogin($req, $params, \%cookies);

	# DEBUG: print user info an request
	if ($user_info{uid} > 0) {
		warn "user $user_info{data}->{username} ($user_info{data}->{lastip} @ requested URI $uri)\n";
	}

	if ( doRedirectContent( $params, \%user_info, $upload) ) {
		#redirect back to referrer page
		my $location = getConfig("main_url") . "/?op=getobj;from=$params->{from};id=$params->{id}";
		$req->headers_out->set(Location => $location);
		$req->status(Apache2::Const::REDIRECT);
		return Apache2::Const::REDIRECT;
	}

	# check for any content that isn't meant for any template
	#
	$html = getNoTemplateContent($params, \%user_info, $upload);
 
	# if none, process template stuff
	#
	if ($html eq '') {
		my $content;
		my $template;
		$NoosphereTitle = '';
		$content = getViewTemplateContent($params,\%user_info,$upload);
		if ( $content ne '' ) { 
			my $viewcontent = buildViewPage($content, \%user_info);
			sendOutput( $req, $viewcontent );
			return;
#			$template = new Template('view.html');
#			fillInLeftBar($template,$params,\%user_info);
#			$template->setKeys('content' => $content, 'NoosphereTitle' => $NoosphereTitle);
		} 
		# front page
		elsif ($uri =~ /^\/?$/) {
			$content = buildMainPage(\%user_info);
			warn "content = $content";
			sendOutput($req, $content);
			warn "got past opening main.html template content\n";
			return;
#			$content = getMainTemplateContent(\%user_info); 
#			$template = new Template('main.html');
#			fillInSideBars($template,$params,\%user_info);
#			$template->setKey('content', $content);
		}
		else {
			return 404;
		}
	
		headerAndCSS($template, $params);


	
		# handle caching
		#
		my $nocache = '
		<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache">
		<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
		<META HTTP-EQUIV="Expires" CONTENT="-1">';

		$template->setKey('metacache', ($AllowCache ? '' : $nocache));
		$html = $template->expand();
	} 
 
	# finish and send output
	#
	sendOutput($req, $html);
#	$dbh->disconnect();
#	Apache2::Const::OK;
}

sub buildMainPage {
	my $userinf = shift;
	
	#get login from template
	# if the login succeeds we need to display the menu otherwise a login
	# TODO - prompt with a possible error message.
	my $headt = new Template( 'head.html' );
	my $head = $headt->expand();

	my $headert = new Template( 'header.html' );
	my $header = $headert->expand();

	
	my $loginbox = getLoginBox($userinf);

	my $xslt = getConfig("stemplate_path") . "/logos.xsl";
	my $logosbox = buildStringUsingXSLT( '<temp></temp>', $xslt );


	my $xmlstring = '';
	my $writer = new XML::Writer( OUTPUT=>\$xmlstring, UNSAFE=>1 );
	$writer->startTag("mainpage");
	my $la = getLatestAdditions();
	$writer->startTag("latestadditions");
	$writer->raw($la);
	$writer->endTag("latestadditions");
	#top authors
	my $ta = getTopUsers();
	$writer->startTag("topusers");
	#$writer->raw($ta);
	$writer->endTag("topusers");
	$writer->raw($head);
	$writer->startTag("header");
	$writer->raw($header);
	$writer->endTag("header");
	$writer->startTag("login");
	$writer->raw($loginbox);
	$writer->endTag("login");
	$writer->raw($logosbox);
	$writer->endTag("mainpage");


	my $xslt = getConfig("stemplate_path") . "/mainpage.xsl";

	warn "building with:\n\n\n\n\n\n\n\n$xmlstring\n\n\n\n\n\n\n";
	open( OUT, ">/tmp/mainpage.xml");
	print OUT $xmlstring;
	close(OUT);
	
	my $mainpage = buildStringUsingXSLT( $xmlstring, $xslt );

}

sub buildViewPage {
	my $content = shift;
	my $userinf = shift;

	#tidy up the content so that we know we have valid xhtml
	my $tidy = HTML::Tidy->new( {
                           output_xhtml => 1,
                    });
	my $allclean = $tidy->clean($content);
	#extract out only the body
	$allclean =~ /<body.*?>(.*?)<\/body>/sio;
	my $clean = $1;
	$content = $clean;

#	warn "buildViewPage [$content]\n";
	
	#get login from template
	# if the login succeeds we need to display the menu otherwise a login
	# TODO - prompt with a possible error message.
	my $headt = new Template( 'head.html' );
	my $jsmathCode = "<SCRIPT SRC=\"http://" . getConfig('siteaddrs')->{'main'} ."/jsmath/easy/load.js\"></SCRIPT>";
        $headt->setKey('jsmathcode', ($LoadjsMath ? $jsmathCode : ''));

	#set jsmathcode
	my $head = $headt->expand();

	my $headert = new Template( 'header.html' );
	my $header = $headert->expand();

	
	my $loginbox = getLoginBox($userinf);

	my $xslt = getConfig("stemplate_path") . "/logos.xsl";
	my $logosbox = buildStringUsingXSLT( '<temp></temp>', $xslt );


	my $xmlstring = '';
	my $writer = new XML::Writer( OUTPUT=>\$xmlstring, UNSAFE=>1 );
	$writer->startTag("viewpage");
	$writer->raw($head);
	$writer->startTag("header");
	$writer->raw($header);
	$writer->endTag("header");
	$writer->startTag("login");
	$writer->raw($loginbox);
	$writer->endTag("login");
	$writer->raw($logosbox);
	$writer->startTag("content");
	$writer->raw($content);
	$writer->endTag("content");
	$writer->endTag("viewpage");

	my $xslt = getConfig("stemplate_path") . "/view.xsl";
	my $page = buildStringUsingXSLT( $xmlstring, $xslt );
	return $page;
#	my $template = new XSLTemplate( "view.xsl" );
#	$template->addText($xmlstring);
#	return $template->expand();
}

1;
