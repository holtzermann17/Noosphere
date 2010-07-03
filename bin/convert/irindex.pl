#!/usr/bin/perl

# index all entries in the encyclopedia 
#

use DBI;
use lib '/var/www/noosphere/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::IR;
use Noosphere::Config;
use Noosphere::DB;

$dbh=Noosphere::dbConnect;
my $table=Noosphere::getConfig('en_tbl');

my ($rv,$sth)=Noosphere::dbSelect($dbh,{WHAT=>'*',FROM=>$table,'ORDER BY'=>'uid',DESC=>'',WHERE=>"title~*''''"});

while (my $row=$sth->fetchrow_hashref()) {

  print "indexing $row->{uid} ($row->{title})\n";

  Noosphere::irIndex($table,$row);
}

