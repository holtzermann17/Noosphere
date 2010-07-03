#!/usr/bin/perl

# unindex an object
#

use DBI;
use lib '/var/www/noosphere/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::IR;
use Noosphere::Config;
use Noosphere::DB;

$dbh = Noosphere::dbConnect;
my $table = 'users';
my @objectids = (6811);

foreach my $id (@objectids) {

  print "unindexing $table.$id\n";

  Noosphere::irUnindex($table,$id);
}

