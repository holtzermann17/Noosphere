#!/usr/bin/perl

package Noosphere;

#this is a module for sending NNexus formated xml directly to the NNexus
# server on the localhost at port 7070.

use strict;

use Time::HiRes qw ( time alarm sleep );

use Data::Dumper;
use XML::Writer;
use IO::Socket;
use XML::Simple; #we use this to read server responses.
use XML::Writer;
use Noosphere::Util;
use Noosphere::NNexus;
use Encode;

sub linkEntry {
	my $objid = shift;
	my $text = shift;
	my $format = shift;
	my $nolink = shift;

	my $nnexushash = $Noosphere::baseconf::base_config{NNEXUS_CONFIG};
	my $nnexus_address = $nnexushash->{'address'};
	my $nnexus_port = $nnexushash->{'port'};
	my $domain = $nnexushash->{'domain'};

#	$text = latin1ToHtml($text);
#	warn "Sending " .  substr($text, 0, 100) . " to nnexus\n";

	warn "linking with NNexus server at $nnexus_address:$nnexus_port\n";
	my $sock = new IO::Socket::INET (
			PeerAddr => "$nnexus_address",
			PeerPort => "$nnexus_port",
			Proto => 'tcp'
			);

	if ( ! $sock ) {
		warn "Could not create socket to nnexus. $!\n";
		warn "Returning original text.\n";
		return ($text, "");
	}

	my $linkedtext = $text;
	my $links = "";

	my $output = "";
	my $writer = new XML::Writer(OUTPUT => \$output);

	$writer->startTag('linkentry');
	$writer->startTag('domain');
	$writer->characters("$domain");
	$writer->endTag('domain');
	$writer->startTag('objid');
	$writer->characters("$objid");
	$writer->endTag('objid');
	$writer->startTag('format');
	$writer->characters("$format");	
	$writer->endTag('format');
	$writer->startTag('body');
	$text = encode("utf8", $text);
	$writer->characters($text);
	$writer->endTag('body');
	$writer->startTag('mode');
	$writer->characters("0");
	$writer->endTag('mode');
	$writer->startTag('nolink');
	$writer->characters( join (', ', @$nolink) ) if (defined @$nolink);
	$writer->endTag('nolink');
	$writer->endTag('linkentry');
	$writer->end();

	print $sock encode('utf-8', "<request>\n$output\n</request>\n");

	my $response = "";
	while (my $bl = <$sock>){
		$response .= $bl;
	}

	close ($sock);

#	warn "RESPONSE: = " . substr($response, 0, 100);

	if ( $response ne '' ) {
#		$response =~ s/<\s*p\s*>/<p\/>/g;
#		$response =~ s/<\/\s*p\s*>//g;

	#TODO change this to use a real parser
	#pull out body and links
	
	$response =~ /<\s*body\s*>(.*)<\/\s*body\s*>/s;
	$linkedtext = $1;
	$response =~ /(<\s*links\s*>.*<\/\s*links\s*>)/s;
	$links = $1;
	warn "got response from NNexus";
	warn "response = $response";
	warn "linkedtext = $linkedtext";
	warn "links = $links";
	#my $config;
	#eval {
	#	$config = XMLin($response);
	#};
	#if ( $@ ) {
	#	warn "error with XML returned from NNexus";
	#	return( $@, '' );
	#}

	#warn Dumper( $config );

	#my $linkedtext = $config->{'linked'}->{'body'};
	#warn "JJG: " . substr($linkedtext, 0, 100);
	#my $links = $config->{'linked'}->{'links'};
	#warn Dumper( $links );
	#if ( ref( $links ) ) {
	#	$links = "";
	#}
	#warn "JJG: links = $links";


	return (decode('utf-8',$linkedtext), $links );
	} 
	return ($text, '', '');
}


sub NNexus_addobject {
	my $title = shift;
	my $body = shift;
	my $objid = shift;
	my $author = shift;
	my $linkpolicy = shift;
	my $classes = shift;
	my $synonyms = shift;
	my $defines = shift;
	my $batchmode = shift;

	my $nnexushash = $Noosphere::baseconf::base_config{NNEXUS_CONFIG};
	my $nnexus_address = $nnexushash->{'address'};
	my $nnexus_port = $nnexushash->{'port'};
	my $domain = $nnexushash->{'domain'};

	warn "adding object to NNexus server at $nnexus_address:$nnexus_port\n";
	my $sock = new IO::Socket::INET (
			PeerAddr => "$nnexus_address",
			PeerPort => "$nnexus_port",
			Proto => 'tcp'
			);

	if ( ! $sock ) {
		warn "NNexus_addobject: Could not create socket to nnexus. $!\n";
		return ();
	}

	my $output = "";
	my $writer = new XML::Writer(OUTPUT => \$output);


	$writer->startTag('addobject');
	$writer->startTag('entry');
	if ($batchmode) {
		$writer->startTag('batchmode');
		$writer->characters("1");
		$writer->endTag('batchmode');
	}

	$writer->startTag('title');
	$writer->characters($title);
	$writer->endTag('title');

	$writer->startTag('domain');
	$writer->characters($domain);
	$writer->endTag('domain');

	$writer->startTag('body');
	$writer->characters($body);
	$writer->endTag('body');

	$writer->startTag('objid');
	$writer->characters($objid);
	$writer->endTag('objid');

	$writer->startTag('author');
	$writer->characters($author);
	$writer->endTag('author');

	$writer->startTag('linkpolicy');
	$writer->characters($linkpolicy);
	$writer->endTag('linkpolicy');

	my @classstrings = split( /\s*,\s*/, $classes);
	foreach my $cl ( @classstrings ){
		$writer->startTag('class');
		$writer->characters($cl);
		$writer->endTag('class');
	}

	$writer->startTag('defines');
	$writer->startTag('synonym');
	$writer->characters($title);
	$writer->endTag('synonym');
	my @syns = split( /\s*,\s*/, $synonyms);
	foreach my $syn ( @syns ){
		$writer->startTag('synonym');
		$writer->characters($syn);
		$writer->endTag('synonym');
	}
	my @defs = split( /\s*,\s*/, $defines);
	foreach my $def ( @defs ){
		$writer->startTag('synonym');
		$writer->characters($def);
		$writer->endTag('synonym');
	}
	$writer->endTag('defines');

	$writer->endTag('entry');
	$writer->endTag('addobject');
	$writer->end();

	#warn "NNExus_Addobject: sending ->\n$output\n";
	print $sock "<request>\n$output\n</request>\n";

	my $response = "";
	while (my $bl = <$sock>){
		$response .= $bl;
	}

	close($sock);
}

sub NNexus_Update_LinkPolicy { 
	my $objid = shift;
	my $linkpolicy = shift;
	my $nnexushash = $Noosphere::baseconf::base_config{NNEXUS_CONFIG};
	my $nnexus_address = $nnexushash->{'address'};
	my $nnexus_port = $nnexushash->{'port'};
	my $domain = $nnexushash->{'domain'};

	warn "updating linkpolicy on NNexus server at $nnexus_address:$nnexus_port\n";
	my $sock = new IO::Socket::INET (
			PeerAddr => "$nnexus_address",
			PeerPort => "$nnexus_port",
			Proto => 'tcp'
			);

	if ( ! $sock ) {
		warn "NNexus_Update_LinkPolicy: Could not create socket to nnexus. $!\n";
		return ();
	}

	my $output = "";
	my $writer = new XML::Writer(OUTPUT => \$output);


	$writer->startTag('addobject');
	$writer->startTag('entry');
	$writer->startTag('domain');
	$writer->characters($domain);
	$writer->endTag('domain');

	$writer->startTag('objid');
	$writer->characters($objid);
	$writer->endTag('objid');

	$writer->startTag('linkpolicy');
	$writer->characters($linkpolicy);
	$writer->endTag('linkpolicy');
	$writer->endTag('entry');
	$writer->endTag('addobject');
	$writer->end();

	#warn "NNExus_Update_LinkPolicy: sending ->\n$output\n";

	print $sock "<request>\n$output\n</request>\n";
	my $response = "";
	while (my $bl = <$sock>){
		$response .= $bl;
	}
	close $sock;
}

sub NNexus_deleteobject {
	my $objid = shift;
	
	my $nnexushash = $Noosphere::baseconf::base_config{NNEXUS_CONFIG};
	my $nnexus_address = $nnexushash->{'address'};
	my $nnexus_port = $nnexushash->{'port'};
	my $domain = $nnexushash->{'domain'};
	warn "deleting object from NNexus server at $nnexus_address:$nnexus_port\n";
	my $sock = new IO::Socket::INET (
			PeerAddr => "$nnexus_address",
			PeerPort => "$nnexus_port",
			Proto => 'tcp'
			);

	if ( ! $sock ) {
		warn "NNexus_Update_LinkPolicy: Could not create socket to nnexus. $!\n";
		return ();
	}

	my $output = "";
	my $writer = new XML::Writer(OUTPUT => \$output);


	$writer->startTag('deleteentry');
	$writer->startTag('objid');
	$writer->characters($objid);
	$writer->endTag('objid');
	$writer->startTag('domain');
	$writer->characters($domain);
	$writer->endTag('domain');
	$writer->endTag('deleteentry');
	$writer->end();

	#warn "NNExus_deleteobject: sending ->\n$output\n";

	print $sock "<request>\n$output\n</request>\n";
	my $response = "";
	while (my $bl = <$sock>){
		$response .= $bl;
	}
	close $sock;
}

sub NNexus_checkvalid {
	my $objid = shift;
	my $nnexushash = $Noosphere::baseconf::base_config{NNEXUS_CONFIG};
	my $nnexus_address = $nnexushash->{'address'};
	my $nnexus_port = $nnexushash->{'port'};
	my $domain = $nnexushash->{'domain'};
	warn "checking validity of object from NNexus at $nnexus_address:$nnexus_port\n";
	my $sock = new IO::Socket::INET (
			PeerAddr => "$nnexus_address",
			PeerPort => "$nnexus_port",
			Proto => 'tcp'
			);

	if ( ! $sock ) {
		warn "NNexus_checkvalid: Could not create socket to nnexus. $!\n";
		return ();
	}

	my $output = "";
	my $writer = new XML::Writer(OUTPUT => \$output);


	$writer->startTag('checkvalid');
	$writer->startTag('objid');
	$writer->characters($objid);
	$writer->endTag('objid');
	$writer->startTag('domain');
	$writer->characters($domain);
	$writer->endTag('domain');
	$writer->endTag('checkvalid');
	$writer->end();

	#warn "NNexus_checkvalid: sending ->\n$output\n";

	print $sock "<request>\n$output\n</request>\n";

	my $response = "";
	while (my $bl = <$sock>){
		$response .= $bl;
	}

	close ($sock);
	my $config = XMLin($response);
	my $valid = $config->{'valid'};
	return $valid;
}
1;
