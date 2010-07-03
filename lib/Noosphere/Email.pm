package Noosphere;
use strict;

use Noosphere::Config;
use Noosphere::Util;

use MIME::Lite;
use MIME::QuotedPrint;
use XML::LibXSLT;
use XML::LibXML;


#this is the Email module

# the Email module uses templates from stemplates(-local)/mail
# to generate multipart html and txt emails and send them

sub sendMultipartMail {
	my $dest = shift;
	my $subject = shift;
	my $textmsg = shift;
	my $htmlmsg = shift;

	my $DEBUG = 0;
	my $msg = MIME::Lite->new ( 
		From => getConfig('projname')."<".getConfig('reply_email').">", 
		To => $dest, 
		Subject => $subject, 
		Type =>'multipart/alternative') or die "Error creating multipart container: $!\n";

	$msg->attach ( 
		Type => 'text/plain', 
		Data => $textmsg) or die "Error adding the text message part: $!\n";

	$msg->attach ( 
		Type => 'text/html', 
		Data => $htmlmsg) or die "Error adding the html message part: $!\n";

	$msg->send();
	my $str = $msg->as_string;
	warn "Outgoing message is [$str]" if ($DEBUG);
}

1;
