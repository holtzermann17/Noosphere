#!/usr/bin/perl
#
# make watches anew
#

use DBI;
use lib '/var/www/noosphere/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::DB;
use Noosphere::Config;
use Noosphere::Watches;

# define the tables
#
my $wtbl=Noosphere::getConfig('watch_tbl');

# connect to the database
#
$dbh=Noosphere::dbConnect;

my ($rv,$sth)=Noosphere::dbLowLevelSelect($dbh,"select userid, uid, 'objects' as table from objects where not type=16 and revid is not null");

my @rows=Noosphere::dbGetRows($sth);

$DEBUG=1;

foreach my $row (@rows) {
  print "$row->{uid} $row->{userid} $row->{table}\n";
  Noosphere::delWatchByInfo($row->{table},$row->{uid},$row->{userid});
}

