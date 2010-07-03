package Noosphere;

use XML::DOM;

use strict;

# get the XML representation of an object
#
sub getObjectXML {
	my $table = shift;
	my $id = shift;
	my $modifier = shift;	# user id who is responsible for latest modification
	my $comment = shift;	 # modification note.

	return getEncyclopediaXML($id, $modifier, $comment) if ($table eq getConfig('en_tbl'));
	return getCollabXML($id, $modifier, $comment) if ($table eq getConfig('collab_tbl'));
}

# produce XML representation of encyclopedia record
#
sub getEncyclopediaXML {
	my $id = shift;
	my $modifier = shift;
	my $comment = shift;
	
	my $table = getConfig('en_tbl');

	my ($rv, $sth) = dbSelect($dbh, {WHAT=>'*', FROM=>$table, WHERE=>"uid=$id"});

	my $rec = $sth->fetchrow_hashref();
	$sth->finish();

	# gather and convert
	#
	my $typestring = getTypeString($rec->{'type'});
	my $class = classstring($table, $id);
	my $username = lookupfield(getConfig('user_tbl'),'username',"uid=$rec->{userid}");
	my @authors = getAuthorList($table, $id);

	my $xml = "";
	
	# build the XML
	#
	$xml .= "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n";

	$xml .= "<record version=\"$rec->{version}\" id=\"$rec->{uid}\">\n";
	$xml .= " <title>$rec->{title}</title>\n";
	$xml .= " <name>$rec->{name}</name>\n";

	$xml .= " <created>$rec->{created}</created>\n";
	$xml .= " <modified>$rec->{modified}</modified>\n";
	
	$xml .= " <type>$typestring</type>\n";

	if ($rec->{'parentid'}) {
		my $ptitle = lookupfield($table, 'title', "uid=$rec->{parentid}");
		$xml .= "<parent id=\"$rec->{parentid}\">$ptitle</parent>\n";
	}

	if ($rec->{'type'} == PROOF) {
		$xml .= " <selfproof>$rec->{self}</selfproof>\n";
	}

	if (nb($rec->{'pronounce'})) {
		
	$xml .= " <pronunciation>\n";
		
	foreach my $pro (split(/\s*,\s*/,$rec->{'pronounce'})) {
		$pro =~ /^\s*(\S+)\s*=\s*(\S+)\s*:\s*(\/.+?\/)\s*$/;
		my $term = $1;
		my $system = $2;
		my $spec = $3;
		
		$xml .= "	<spec term=\"$term\" system=\"$system\">$spec</spec>\n";
	}
	$xml .= " </pronunciation>\n";
	}
	
	$xml .= " <creator id=\"$rec->{userid}\" name=\"$username\"/>\n";

	# revision metadata
	#
	if ($modifier) {
		my $modifiername = lookupfield(getConfig('user_tbl'),'username',"uid=$modifier");
		$xml .= " <modifier id=\"$modifier\" name=\"$modifiername\"/>\n";
	}

	if ($comment) {
		$xml .= " <comment>".htmlescape($comment)."</comment>\n";
	}
	# end revision metadata

	foreach my $author (@authors) {
		$xml .= " <author id=\"$author->{userid}\" name=\"$author->{username}\"/>\n";
	}

	if (nb($class)) {
		$xml .= " <classification>\n";
		foreach my $catspec (split (/\s*,\s*/, $class)) {
		my ($scheme, $cat) = split (/\s*:\s*/, $catspec);
			$xml .= "	<category scheme=\"$scheme\" code=\"$cat\"/>\n";
		}
		$xml .= " </classification>\n";
	}

	if (nb($rec->{'defines'})) {
		$xml .= " <defines>\n";
		foreach my $def ( split (/\s*,\s*/, $rec->{'defines'})) {
			$xml .= "	<concept>$def</concept>\n";
		}
		$xml .= " </defines>\n";
	}
	
	if (nb($rec->{'synonyms'})) {
		$xml .= " <synonyms>\n";
		foreach my $syn ( split (/\s*,\s*/, $rec->{'synonyms'})) {
			my ($concept, $alias) = split(/\s*=\s*/, $syn);
			if (blank($alias)) {
				$alias = $concept;
				$concept = $rec->{title};	# default concept
			}
			$xml .= "	<synonym concept=\"".qhtmlescape($concept)."\" alias=\"".qhtmlescape($alias)."\"/>\n";
		}
		$xml .= " </synonyms>\n";
	}

	if (nb($rec->{'related'})) {
		$xml .= " <related>\n";
		foreach my $rel (split(/\s*,\s*/, $rec->{'related'})) {
			$xml .= "	<object name=\"$rel\"/>\n";
		}
		$xml .= " </related>\n";
	}

	if (nb($rec->{'keywords'})) {
		$xml .= " <keywords>\n";
		foreach my $keyword (split(/\s*,\s*/, $rec->{'keywords'})) {
			$xml .= "	<term>$keyword</term>\n";
		}
		$xml .= " </keywords>\n";
	}
	
	my $preamble = htmlescape($rec->{'preamble'});
	$xml .= " <preamble>$preamble</preamble>\n";

	my $content = htmlescape($rec->{'data'});
	$xml .= " <content>$content</content>\n";
	
	$xml .= "</record>\n";

	return $xml;
}

# produce XML representation of collaboration record
#
sub getCollabXML {
	my $id = shift;
	my $modifier = shift;
	my $comment = shift;
	
	my $table = getConfig('collab_tbl');

	my ($rv, $sth) = dbSelect($dbh, {WHAT=>'*', FROM=>$table, WHERE=>"uid=$id"});
	my $rec = $sth->fetchrow_hashref();
	$sth->finish();

	# gather and convert
	#
	my $username = lookupfield(getConfig('user_tbl'),'username',"uid=$rec->{userid}");
	my @authors = getAuthorList($table, $id);

	my $xml = "";
	
	# build the XML
	#
	$xml .= "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n";

	$xml .= "<record version=\"$rec->{version}\" id=\"$rec->{uid}\">\n";
	$xml .= " <title>$rec->{title}</title>\n";

	$xml .= " <created>$rec->{created}</created>\n";
	$xml .= " <modified>$rec->{modified}</modified>\n";
	
	$xml .= " <creator id=\"$rec->{userid}\" name=\"$username\"/>\n";

	# revision metadata
	#
	if ($modifier) {
		my $modifiername = lookupfield(getConfig('user_tbl'),'username',"uid=$modifier");
		$xml .= " <modifier id=\"$modifier\" name=\"$modifiername\"/>\n";
	}

	if ($comment) {
		$xml .= " <comment>".htmlescape($comment)."</comment>\n";
	}
	# end revision metadata

	foreach my $author (@authors) {
		$xml .= " <author id=\"$author->{userid}\" name=\"$author->{username}\"/>\n";
	}

	my $content = htmlescape($rec->{'data'});
	$xml .= " <content>$content</content>\n";
	
	$xml .= "</record>\n";

	return $xml;
}

# get a hash of attributes for a DOM element node
#
sub domAttrHash {
	my $elem = shift;

	my $attrs = $elem->getAttributes;

	return undef if (not defined $attrs);

	my $len = $attrs->getLength;

	return undef if ($len eq 0);

	my %hash;
	for my $i (0..$len-1) {
		my $node = $attrs->item($i);
		my $nname = $node->getNodeName;
		$hash{$nname} = $node->getNodeValue;
	}

	return {%hash};			 # make a hashref
}

# parse an XML file into a DOM structure
#
sub getFileDOM {
	my $filename = shift;

	my $parser = new XML::DOM::Parser;
	my $dom = $parser->parsefile ($filename);
	
	return $dom;
}

1;
