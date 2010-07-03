package Noosphere;

use strict;
use Noosphere::Config;
use Noosphere::FileCache;
use Data::Dumper;
use Devel::StackTrace;

sub XSLTemplate::new
{
	my ($class, $file) = @_;
	my $tpath = getConfig("stemplate_path");
	my $tobj = {};
# This document parsing needs to be cached!
	my $template = new Template("template.xsl");
	my $fcache = new FileCache("$tpath/$file");

	$template->setKey('content', $fcache->{"TEXT"});

	my $parser = XML::LibXML->new();
	my $doc = $parser->parse_string($template->expand());

	bless $tobj, $class;

	$tobj->{'KEY_MAP'} = getXSLKeyMap($fcache->{'TEXT'});
	$tobj->{'SET_KEYS'} = {};
	$tobj->{'NAME'} = $file;
	$tobj->{'XSLT'} = XML::LibXSLT->new();
	eval {
	$tobj->{'STYLESHEET'} = $tobj->{'XSLT'}->parse_stylesheet($doc);
	};
	warn $@ if $@;
	$tobj->{'TEXT'} = "";
	$tobj->{'PARAMS'} = {'admin' => 0};
	
	return $tobj;
}

sub XSLTemplate::addText
{
		my ($obj, $text) = @_;

		$obj->{'TEXT'} .= $text;
}

# APK - checks the KEY_MAP for a declared key name from an <xsl:value-of ... > 
#	or <xsl:copy-of ... > statement
#
sub XSLTemplate::requestsKey 
{
	my ($obj, $key) = @_;

	return (defined $obj->{'KEY_MAP'}->{$key});
}

# APK - 
#	does an :
#	$template->addText("<$key>$value</$key>");
#	and updates SET_KEYS
#
sub XSLTemplate::setKey 
{ 
	my ($obj, $key, $value) = @_;

	my $val = $value;
	
	# protect the value from entity translation
	#
	if ($obj->isProtected($key)) {
		$val = htmlescape($val);
	}

	# attempt to fix UTF-16.. this is a bad hack because upper ASCII does not 
	# necessarily imply UTF16.
#	if ($val =~ /[\xa0-\xff]/o) {
#		$val = utf16($val)->utf8;
#	}

	$obj->addText("<$key>$val</$key>");
	$obj->{'SET_KEYS'}->{$key} = 1;
}

# APK - 
# like above, but only sets if the key isn't already set (that we know of)
#
sub XSLTemplate::setKeyIfUnset
{ 
	my ($obj, $key, $value) = @_;

	if (!$obj->{'SET_KEYS'}->{$key}) {
	
	my $val = $value;

		# protect the value from entity translation
	#
	if ($obj->isProtected($key)) {
			$val = htmlescape($val);
	}
	
		$obj->addText("<$key>$val</$key>");
		$obj->{'SET_KEYS'}->{$key} = 1;
	}
}

# APK -
# try to set all key-value pairs from a hash
#
sub XSLTemplate::setKeysIfUnset 
{
	my ($obj, %pairs) = @_;

	foreach my $key (keys %pairs) {
		
	$obj->setKeyIfUnset($key, $pairs{$key});
	}
}

# APK -
# haphazardly set all key/value pairs from a hash. no checking.
#
sub XSLTemplate::setKeys
{
	my ($obj, %pairs) = @_;

	foreach my $key (keys %pairs) {
		
	$obj->setKey($key, $pairs{$key});
	}
}

sub XSLTemplate::setParam
{
		my ($obj, $key, $value) = @_;

		$obj->{'PARAMS'}->{$key} = $value;
}

# APK - basically this function tries to see if a key being set should be 
#	"protected" or not.	"protected" means html/xml escaped.	we need to do 
#	this for all value-of items, but not for copy-of items.
#	
#	NEW: realized that even keys that aren't requested should be protected,
#	so even if they aren't in the key map, TRUE should be returned as default.
#	otherwise we'll still potentially have unescaped stuff in the output XML.
#
sub XSLTemplate::isProtected 
{
	my ($obj, $key) = @_;

	my $ret = ($obj->{'KEY_MAP'}->{$key} eq 'copy-of') ? 0 : 1;

	#dwarn "*** XSLTemplate : key $key has protected status $ret";

	return $ret;
}

sub XSLTemplate::expand
{
	my $obj = shift;
	
	my $parser = XML::LibXML->new();
	my $entitysite = getAddr("entity");

	my $header = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE NSXSLT [
	<!ENTITY nbsp \"&#160;\">
    <!ENTITY \% iso-lat1 PUBLIC \"ISO 8879:1986//ENTITIES Added Latin 1//EN/
/XML\" \"file://".getConfig('entity_dir')."/iso-lat1.ent\">

    \%iso-lat1;
]>";

	# make sure there are no bare ampersands
	$obj->{'TEXT'} =~ s/&(?!(?:\w+|#\d+);)/&amp;/og;

	# add in some globals 
	$obj->{'TEXT'} .= "<globals>".getConfig('xsl_globals')."</globals>";
	
	my $string = $header."\n<NSXSLT>\n".  $obj->{'TEXT'}."\n</NSXSLT>\n";

#	warn "The XML Input string is:----------------\n$string--------------------\n";
	

	my $doc = $parser->parse_string($string);

	my $results = $obj->{"STYLESHEET"}->transform($doc, %{$obj->{"PARAMS"}});
	my $transformed = $obj->{"STYLESHEET"}->output_string($results);
	$transformed =~ s/<!DOCTYPE.+?>//;	# remove doctype so we can embed this

#	warn "The output from the transform is:--------------\n$transformed\n----------------\n";

	# BB: XSL library does not set this flag on
	Encode::_utf8_on($transformed);

	return $transformed;
}

sub XSLTemplate::expandFile
{
	my ($obj, $filename) = @_;
	my $parser = XML::LibXML->new();
	my $doc = $parser->parse_file($filename);

	my $results = $obj->{"STYLESHEET"}->transform($doc, %{$obj->{"PARAMS"}});

	return $obj->{"STYLESHEET"}->output_string($results);
}

# APK -
# get a "map" of "keys" and their types (copy-of or value-of) in a stylesheet
#
sub getXSLKeyMap 
{
	my $text = shift;

	my %map;
	
	while ($text =~ /<\s*xsl:(copy-of|value-of)\s+select="(.+?)"\s*\/\s*>/g) {
		my $type = $1;
		my $key = $2;
	

		# this is done this way so that if a key appears more than once, 
		# if it appears anywhere as a copy-of, it will override all value-of 
		# instances.
		#
		if (not defined $map{$key} || 
			(defined $map{$key} &&	$map{$key} eq 'value-of')) {
		
			#dwarn "*** XSLTemplate: adding $key, $type to keymap";

			$map{$key} = $type;
		}
	}

	# find inline instances of value-of included in attributes
	# NOTE: this is cheesier than En Esch
	#
	while ($text =~ /"[^"]*\{([^}]+)\}[^"]*"/g) {
		
		my $key = $1;

		if (not defined $map{$key} || 
			(defined $map{$key} &&	$map{$key} eq 'value-of')) {
		
			#dwarn "*** XSLTemplate: adding $key, $type to keymap";

			$map{$key} = 'value-of';
		}
	}

	return {%map};
}


1;

