#!/usr/bin/perl

use DBI;
use lib '/var/www/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::IR;
use Noosphere::Config;
use Noosphere::DB;

$dbh=Noosphere::dbConnect;
my $table=Noosphere::getConfig('en_tbl');
my $objectid='1051';

my ($rv,$sth)=Noosphere::dbSelect($dbh,{WHAT=>'*',FROM=>$table,WHERE=>"uid=$objectid and revid is null"});

my $row=$sth->fetchrow_hashref();
$sth->finish();

Noosphere::irIndex($table,$row);

