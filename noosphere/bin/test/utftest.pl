#!/usr/bin/perl

use strict;
use lib '/var/www/pm/lib';
use Noosphere;
use Noosphere::DB;
use Unicode::String qw(utf8 latin1);

my $dbh = Noosphere::dbConnect();

my ($rv,$sth) = Noosphere::dbSelect($dbh, {WHAT=>'*', FROM=>'objects', WHERE=>"uid=2657"});

my $row = $sth->fetchrow_hashref();
$sth->finish();

#my $utitle = utf8($row->{title});   # make unicode string
my $utitle = latin1($row->{title});   # set, with input as latein1

my $latin = $utitle->latin1;
my $hex = $utitle->hex;

print "title is [$row->{title}]\n";

print "in utf8 [$utitle]\n";

print "in latin1 [$latin]\n";

print "in hex [$hex]\n";


$dbh->disconnect();


