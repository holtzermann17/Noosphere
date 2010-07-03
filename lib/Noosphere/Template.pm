package Noosphere;

use strict;
use Noosphere::FileCache;

# Template::new - retrieve a template object (load from file if necessary)
# Contrast with "getTemplate"
#
sub Template::new
{
	my ($class, $file) = @_;
	my $tpath = getConfig("stemplate_path");
	my $tobj = {};
	my $fcache = new FileCache("$tpath/$file");

	bless $tobj, $class;
	$tobj->{"NAME"} = $file;
	$tobj->{"TEXT"} = $fcache->getText();
	$tobj->resetKeys();
	return $tobj;
}

# templateFromText - this should really be in the constructor, maybe I'll
# fix later
#
sub templateFromText
{
	my $tobj = { "NAME" => "<text>", "TEXT" => shift };

	bless $tobj, "Template";
	$tobj->resetKeys();
	return $tobj;
}

# Template::resetKeys - clears all keys in a template object and resets the
# basic default keys (.*siteaddr, etc.)
#
sub Template::resetKeys
{
	my $tobj = shift;
	my $addrhash = getConfig("siteaddrs");
	my $values = {};

	# site addresses
	#
	foreach my $key (keys %$addrhash) {
		$values->{"${key}siteaddr"} = $addrhash->{$key};
	}

	# other global variables
	#
	$values->{'slogan'} = getConfig('slogan') if getConfig('slogan');
	$values->{'sitename'} = getConfig('projname') if getConfig('projname');
	$values->{'projname'} = getConfig('projname') if getConfig('projname');
	$values->{'main_url'} = getConfig('main_url') if getConfig('main_url');

	$tobj->{"VALUES"} = $values;
}

# Template::setKey - associates a value with a key in the given template
#
sub Template::setKey
{
	my ($tobj, $key, $value) = @_;

	$tobj->{"VALUES"}->{$key} = $value;
}

# Template::setKeys - given a hash, sets keys for each keypair
#
sub Template::setKeys
{
	my ($tobj, %param) = @_;

	foreach my $key (keys %param) {
		$tobj->setKey($key, $param{$key});
	}
}

# Template::setKeyIfUnset - associates a value with a key only if no
# association already exists
#
sub Template::setKeyIfUnset
{
	my ($tobj, $key, $value) = @_;

	$tobj->{"VALUES"}->{$key} ||= $value;
}

# Template::setKeysIfUnset - given a hash, sets keys for each keypair that
# isn't already set
#
sub Template::setKeysIfUnset
{
	my ($tobj, %param) = @_;

	foreach my $key (keys %param) {
		$tobj->setKeyIfUnset($key, $param{$key});
	}
}

# Template::unsetKey - disassociates a key from any value in the given
# template
#
sub Template::unsetKey
{
	my ($tobj, $key) = @_;

	delete($tobj->{"VALUES"}->{$key});
}

# Template::unsetKeys - disassociates keys in the list from any values in
# the given template
#
sub Template::unsetKeys
{
	my $tobj = shift;
	my @ids = @_;

	foreach my $key (@ids) {
		$tobj->unsetKey($key);
	}
}

# Template::expand - expands all template parameters in the template object's
# text and returns the expansion
#
sub Template::expand
{
	my $tobj = shift;
	my $text = $tobj->{"TEXT"};

	foreach my $key (keys %{$tobj->{"VALUES"}}) {
		my $value = $tobj->{"VALUES"}->{$key};
		$text = templateExpandKey($text, $key, $value);
	}
	return templateExpandDefaults($text);
}

# templateExpandKey - expands all instances of a particular template key in
# the given text
#
sub templateExpandKey
{
	my ($text, $key, $value) = @_;

# do all replacements with the appropriate enctype (specified optionally in
# the template key tag).  Default enctype is html, which has htmlenocde
# semantics.  If qhtml.* (quoted-html) is specified, the " character is also
# quoted (for use in tag attributes, for example).  If .*full is specified,
# the replacement is escaped yet again.
    
	my $prefix = getConfig('template_cmd_prefix');
	while($text =~ m!<$prefix:template\s+$key(\s+\w+)?\s*/>!s) {
		my $enctype = $1 || "html";
		my $replacement = htmlescape($value);

		$replacement =~ s/"/\&quot;/go if $enctype =~ /^\s+qhtml/io;
		$replacement = htmlescape($replacement) if $enctype =~ /full$/io;
		$replacement = $value if $enctype =~ /raw/;
		$replacement = urlescape($value) if $enctype =~ /query/;
		$text =~ s!<$prefix:template\s+$key(\s+\w+)?\s*/>!$replacement!s;
	}
	while($text =~ m!<$prefix:template\s+$key(\s+\w+)?\s*>.*?</$prefix:template\s*>!s) {
		my $enctype = $1 || "html";
		my $replacement = htmlescape($value);

		$replacement =~ s/"/\&quot;/go if $enctype =~ /^\s+qhtml/io;
		$replacement = htmlescape($replacement) if $enctype =~ /full$/io;
		$replacement = $value if $enctype =~ /raw/;
		$replacement = urlescape($value) if $enctype =~ /query/;
		$text =~ s!<$prefix:template\s+$key(\s+\w+)?\s*>.*?</$prefix:template\s*>!$replacement!s;
	}
	return $text;
}

# templateExpandDefaults - expands all unexpanded template keys in the given
# text and replaced with default values
#
sub templateExpandDefaults
{
	my $text = shift;

	my $prefix = getConfig('template_cmd_prefix');
	while($text =~ m!<$prefix:template\s+[^>]+(\s+\w+)?\s*/>!s) {
		$text =~ s!<$prefix:template\s+[^>]+(\s+\w+)?\s*/>!!s;
	}
	while($text =~ m!<$prefix:template\s+[^>]+(\s+\w+)?\s*>(.*?)</$prefix:template\s*>!s) {
		my $enctype = $1 || "html";
		my $value = $2;
		my $replacement = htmlescape($value);

		$replacement =~ s/"/\&quot;/go if $enctype =~ /^qhtml/io;
		$replacement = htmlescape($replacement) if $enctype =~ /full$/io;
		$replacement = $value if $enctype =~ /raw/;
		$replacement = urlescape($value) if $enctype =~ /query/;
		$text =~ s!<$prefix:template\s+[^>]+(\s+\w+)?\s*>.*?</$prefix:template\s*>!$value!s;
	}
	return $text;
}

# Template::requestsKey - returns true if the template text has a tag
# corresponding to the given key
#
sub Template::requestsKey
{
	my ($tobj, $key) = @_;

	my $prefix = getConfig('template_cmd_prefix');
	return $tobj->{"TEXT"} =~ /<$prefix:template\s+$key/s;
}

sub templateTest
{
	my ($params, $user_info) = @_;
	my $tobj = new Template("supertest.html");

	foreach my $key (keys %$params) {
		$tobj->setKey($key, $params->{$key});
	}
	return $tobj->expand();
}

1;

