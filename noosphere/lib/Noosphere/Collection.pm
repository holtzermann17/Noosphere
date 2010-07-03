package Noosphere;

###############################################################################
#
# Collection.pm
#
# Routines for handling Noosphere subcollections.
#
###############################################################################

use strict;

# get a printable provenance URL for a source collection nickname
# 
sub getProvenanceURL {
	my $source = shift;

	my $sth = $dbh->prepare("select name, url from source where nickname=?");
	$sth->execute($source);
	if ($sth->rows()) {

		my $row = $sth->fetchrow_hashref();
		$sth->finish();

		return "<a href=\"$row->{url}\">$row->{name}</a>";

	} else {
		$sth->finish();
		return undef;
	}
}

# get the source collection identifier based on a record identifier
#
sub getSourceCollection {
	my $table = shift;
	my $objectid = shift;

	my $idx = getConfig('index_tbl');

	my $sth = $dbh->prepare("select source from $idx where tbl='$table' and objectid=$objectid");
	$sth->execute();

	my $count = $sth->rows();

	if (!$count) {
		$sth->finish();
		return undef;
	}

	my $source = ($sth->fetchrow_arrayref())->[0];
	$sth->finish();

	return $source;
}

1;
