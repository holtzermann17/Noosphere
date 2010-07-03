#!/usr/bin/perl

use DBI;
use lib '/var/www/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::IR;
use Noosphere::Config;
use Noosphere::DB;

$dbh = Noosphere::dbConnect;

my ($token, $nmatches) = Noosphere::irSearch($ARGV[0]);

if (not defined $token) {
	die "search error!";
}

if ($nmatches == 0) {
	print "no results.\n";
} else {
	print "got token $token and $nmatches results\n";
}
