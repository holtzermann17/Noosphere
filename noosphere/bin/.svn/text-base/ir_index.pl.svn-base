#!/usr/bin/perl

# index all objects in Noosphere 
#

use DBI;
use lib '/usr/local/apache/htdocs/noosphere/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::IR;
use Noosphere::Config;
use Noosphere::DB;

$dbh = Noosphere::dbConnect;
Noosphere::initNoosphere();
my $idx = Noosphere::getConfig('index_tbl');

# get a list of different tables in the object index
# 
my $sth = $dbh->prepare("select distinct(tbl) from $idx");
$sth->execute();

my @tables;
while (my $row = $sth->fetchrow_arrayref()) {
	push @tables, $row->[0];	
}
$sth->finish();

# loop over table types, so we can do joins rather than n foreign-key lookups
#
foreach my $table (@tables) {

	my $sth = $dbh->prepare("select $table.* from $idx, $table where $idx.type = 1 and $idx.tbl = '$table' and $table.uid = $idx.objectid order by $table.uid");
	$sth->execute();

	# loop through object records
	#
	while (my $record = $sth->fetchrow_hashref()) {
	
		print "indexing $table:$record->{uid}\n";

		Noosphere::irIndex($table, $record) 
            or die "indexing failed!";
	}
}

$sth->finish();

