package Noosphere;

use Noosphere::Util;


use strict;

sub serveImageFile {
	my ($req, $params) = @_;

	my $filename = getConfig('base_dir') . $params->{'img'};
	my $image = readFile($filename);
	my $len = bytes::length($image);

#	warn "serving $filename of size $len";
	
	my $type = "image/png";

	if ( $filename =~ /.js$/ ) {
		$type = "text/javascript";
	} elsif ( $filename =~ /.jpg$/ ) {
		$type = "image/jpeg";
	} elsif ( $filename =~ /.css$/ ) {
		$type = "text/css";
	} elsif ( $filename =~ /.xml$/ ) {
		$type = "text/xml";
	}

	$req->content_type($type);
	$req->headers_out->add('content-length' => $len);
#       $req->send_http_header; 
	$req->print($image); 
	$req->rflush(); 
}                
# BB: cached files stored in %CACHEDFILES

1;
