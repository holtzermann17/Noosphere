#!/usr/bin/perl

use DBI;
use lib '/var/www/noosphere/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::DB;
use Noosphere::Config;


unless ($dbh||=DBI->connect("DBI:Pg:dbname=testmath","pm","math")) {
	    die "Couldn't open database: ",$DBI::errstr; }

my ($rv,$sth)=Noosphere::dbSelect($dbh,{WHAT=>'id',FROM=>'msc','ORDER BY'=>'id',ASC=>''});

my @rows=Noosphere::dbGetRows($sth);

my $uid=0;
foreach my $row (@rows) {
  print "$row->{id}\n";
  my ($rv2,$sth2)=Noosphere::dbUpdate($dbh,{WHAT=>'msc',SET=>"uid=$uid",WHERE=>"id='$row->{id}'"});
  $sth2->finish();
  $uid++;
}

