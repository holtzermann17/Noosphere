#!/usr/bin/perl

use DBI;
use lib '/var/www/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::IR;
use Noosphere::Config;
use Noosphere::DB;

$dbh = Noosphere::dbConnect;

my @tables = $dbh->tables();

foreach my $table (@tables) {
  print "$table\n";
}
