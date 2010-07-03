#!/usr/bin/perl

# re-index an object (or objects)
#

use DBI;
use lib '/var/www/noosphere/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::IR;
use Noosphere::Config;
use Noosphere::DB;

$dbh = Noosphere::dbConnect;
my $table = 'objects';
my @objectids = (6811);

foreach my $id (@objectids) {

  print "unindexing $table.$id\n";

  Noosphere::irUnindex($table,$id);

  print "reindexing $table.$id\n";

  my $sth = $dbh->prepare("select * from $table where uid=?");
  $sth->execute($id);

  my $row = $sth->fetchrow_hashref();
  $sth->finish();

  Noosphere::irIndex($table, $row);
}


