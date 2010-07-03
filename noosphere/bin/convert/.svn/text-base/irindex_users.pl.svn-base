#!/usr/bin/perl

# index all users
#

use DBI;
use lib '/var/www/noosphere/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::IR;
use Noosphere::Config;
use Noosphere::DB;

$dbh=Noosphere::dbConnect;
my $table=Noosphere::getConfig('user_tbl');

my ($rv,$sth)=Noosphere::dbSelect($dbh,{WHAT=>'uid,username',FROM=>$table,'ORDER BY'=>'lower(username)'});

while (my $row=$sth->fetchrow_hashref()) {

  print "indexing $row->{uid} ($row->{username})\n";

  Noosphere::irIndex($table,$row);
}

