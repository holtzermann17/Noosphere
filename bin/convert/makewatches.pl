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

#my ($rv,$sth)=Noosphere::dbLowLevelSelect($dbh,"select userid, uid, 'objects' as table from objects where not type=16 union select userid, uid , 'papers' as table from papers union select userid, uid , 'lec' as table from lec union select userid, uid , 'books' as table from books");
my ($rv,$sth)=Noosphere::dbLowLevelSelect($dbh,"select userid, uid, 'corrections' as table from corrections");

my @rows=Noosphere::dbGetRows($sth);

foreach my $row (@rows) {
  print "$row->{uid} $row->{table}\n";
  Noosphere::addWatch($row->{table},$row->{uid},$row->{userid});
}

