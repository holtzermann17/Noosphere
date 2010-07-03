#!/usr/bin/perl

# fix synonyms of arbitrary entries

use lib '/var/www/noosphere/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::DB;
use Noosphere::Config;
use Noosphere::Util;
use Noosphere::Encyclopedia;
use Noosphere::Indexing;

use DBI();

my $table = Noosphere::getConfig('en_tbl');
my @ids = (1097, 3506, 3504, 3118, 403, 454, 396, 387, 471);

die "Couldn't open database: ",$DBI::errstr unless ($dbh=Noosphere::dbConnect());

foreach my $id (@ids) {

	my ($rv,$sth) = Noosphere::dbLowLevelSelect($dbh,"select * from $table where uid=$id");
	my $row = $sth->fetchrow_hashref();
	$sth->finish();

	warn "doing $row->{title}";

	Noosphere::indexTitle($table, $row->{uid}, $row->{userid}, $row->{title}, $row->{name});
	Noosphere::deleteSynonyms($table,$row->{uid});
	Noosphere::createSynonyms($row->{synonyms},$row->{userid},$row->{title},$row->{name},$row->{uid},2);
	Noosphere::createSynonyms($row->{defines},$row->{userid},$row->{title},$row->{name},$row->{uid},3);
}
