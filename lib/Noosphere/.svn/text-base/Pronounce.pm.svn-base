# Display and translation of defined pronunciation specification methods
# are implemented here.
#

package Noosphere;

use strict;

# Maps pronunciation guide encoding names to objects which implement that
# encoding.  These objects must define the following methods:
#
#  display($string) - translates encoded pronunciation to html
#

%Pronounce::methods = (
		"jargon" => new Pronounce::Jargon("jargon"),
	);

sub Pronounce::Jargon::new
{
	my $class = shift;
	my $obj = {};

	bless $obj, $class;
	return $obj;
}

sub Pronounce::Jargon::display
{
	my ($self, $text) = @_;

# Strip html characters
	$text =~ s/[&<>]//go;

# Ensure that / delimiters exist
	$text .= '/' if $text =~ m![^/]\$!o;
	$text = '/' . $text if $text =~ m!^[^/]!o;

# Do some useful highlighting.
# Make accented syllable(s) bold
	$text =~ s!([^-`']+[`'])!<b>$1</b>!g;
	return "<tt>$text</tt>";
}

sub Pronounce::Undefined::new
{
	my $class = shift;
	my $enc = shift;
	my $obj = { "ENC" => $enc };

	bless $obj, $class;
	return $obj;
}

sub Pronounce::Undefined::display
{
	my $self = shift;

	return "[encoding $self->{ENC} undefined]";
}

# generatePronunciations - Take an encoded list of pronunciations and
# generate html displaying them in human readable form
#
sub generatePronunciations
{
	my ($mainterm, $text) = @_;
	my @items = split(/\s*,\s*/o, $text);
	my @terms;
	my %th;
	my $html = '<br><table>';

	foreach my $item (@items) {
		my $term;
		my $enc;
		my $spec;
		my $obj;

		$item =~ s/^([^=]*)=//o;
		$term = $1 || $mainterm;
		$item =~ m!(\w+:)?(/[^/]*/)!o;
		$enc = $1 || getConfig('default_pronunciation');
		$spec = $2;
		$enc =~ s/:+$//o;
		$obj = $Pronounce::methods{$enc};
		$obj = new Pronounce::Undefined() unless $obj;
		if($spec && $obj) {
			if(!$th{$term}) {
				$th{$term} = [];
				push @terms, $term;
			}
			push(@{$th{$term}}, $obj->display($spec));
		}
	}
	return "<br>" unless scalar @terms;

	foreach my $term (@terms) {
		$html .= '<tr><td>&nbsp;</td><td valign="top" align="right">' . htmlescape($term) . ': </td><td>' . join(", ", @{$th{$term}}) . '</td></tr>';
	}
	$html .= '</table>';
	return $html;
}

sub normalizePronunciation
{
	my ($mainterm, $text) = @_;
	my @items = split(/\s*,\s*/o, $text);
	my @out;

	foreach my $item (@items) {
		my $term;
		my $enc;
		my $spec;
		my $obj;

		$item =~ s/^([^=]*)=//o;
		$term = $1 || $mainterm;
		$item =~ m!(\w+:)?(/[^/]*/)!o;
		$enc = $1 || getConfig('default_pronunciation');
		$spec = $2;
		push @out, "$term=$enc:$spec" if $spec;
	}
	return join ", ", @out;
}

1;

