#!/usr/bin/perl

# index papers, books, and expositions
#

use DBI;
use lib '/var/www/noosphere/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::IR;
use Noosphere::Config;
use Noosphere::DB;
use Noosphere::Indexing;

$dbh = Noosphere::dbConnect;
my @tables = (
  Noosphere::getConfig('books_tbl'),
  Noosphere::getConfig('papers_tbl'),
  Noosphere::getConfig('lecs_tbl'),
);

foreach my $table (@tables) {
  my ($rv, $sth) = Noosphere::dbSelect($dbh,{WHAT=>'uid, userid, title, authors, keywords, comments',FROM=>$table,'ORDER BY'=>'lower(title)'});

  while (my $row = $sth->fetchrow_hashref()) {

    print "indexing $table:$row->{uid} ($row->{title})\n";

    # title index it
    Noosphere::indexTitle($table, $row->{uid}, $row->{userid}, $row->{title}, '');
	
	# IR index it
    Noosphere::irIndex($table, $row);
  }
}

