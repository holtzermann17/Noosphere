#!/usr/bin/perl

use DBI;
use lib '/var/www/noosphere/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::DB;
use Noosphere::Encyclopedia;
use Noosphere::Indexing;
use Noosphere::Config;

my $method='l2h';
my $table=Noosphere::getConfig('en_tbl');


# connect to the database
#
$dbh=Noosphere::dbConnect;

my ($rv,$sth)=Noosphere::dbSelect($dbh,{WHAT=>'*',FROM=>$table});
while (my $row=$sth->fetchrow_hashref()) {

#  next if ($row->{uid}<2660);
  print "$row->{title}\n";

  Noosphere::indexTitle($table,$row->{uid},$row->{userid},$row->{title},$row->{name});
  Noosphere::deleteSynonyms($table,$row->{uid});
  Noosphere::createSynonyms($row->{synonyms},$row->{userid},$row->{title},$row->{name},$row->{uid},2);
  Noosphere::createSynonyms($row->{defines},$row->{userid},$row->{title},$row->{name},$row->{uid},3);
}

