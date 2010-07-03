#!/usr/bin/perl

#
# update concept invalidation index to synch with new entries, if any.
#
use strict;
use lib '/var/www/noosphere/lib';

use Noosphere;
use Noosphere::DB;
use Noosphere::Indexing;
use Noosphere::Crossref;

my $dbh = Noosphere::dbConnect();

# build hash of extant objects
#
my %entries;
my $sth = $dbh->prepare("select uid, data from objects");
$sth->execute();
while (my $row = $sth->fetchrow_arrayref()) {
	$entries{$row->[0]} = $row->[1];
}
$sth->finish();
	
# build hash of indexed objects
#
my %indexed;
$sth = $dbh->prepare("select distinct objectid from inv_idx");
$sth->execute();
while (my $row = $sth->fetchrow_arrayref()) {
	$indexed{$row->[0]} = 1;
}
$sth->finish();

my $invphrases = {};

my $idx = 1;
my $scannedtotal = 0;
foreach my $uid (keys %entries) {

	if (not exists $indexed{$uid}) {

		my @wl = Noosphere::getwordlist(Noosphere::getPlainText($entries{$uid}));

		if (@wl) {
			print "::: indexing $uid :::\n";

			my $scanned = Noosphere::invalIndexEntry($uid, $invphrases);
			$scannedtotal += $scanned;

			$idx++;
		}
	}
}

if ($scannedtotal) {
	print "\ninv phrases are {".join(', ', keys %$invphrases)."}\n";

	print "\nscanned entries $scannedtotal times out of ".($idx-1). " total -> efficiency was ".(($idx-1)/$scannedtotal)."\n";
} else {
	print "nothing indexed.\n";
}

Noosphere::dbDisconnect();
