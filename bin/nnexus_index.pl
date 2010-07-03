#!/usr/bin/perl

#puts all the objects in Noosphere into NNexus
# index all objects in Noosphere 
#

use strict;

use DBI;
use lib '/var/www/noosphere/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::IR;
use Noosphere::Config;
use Noosphere::DB;
use Noosphere::Classification;
use Noosphere::NNexus;

my $dbh = Noosphere::dbConnect;
Noosphere::initNoosphere();

# get a list of different tables in the object index
# 
my $sth = $dbh->prepare("select * from objects");
$sth->execute();

while ( my $row = $sth->fetchrow_hashref() ) {
	my $class = Noosphere::classstring("objects", $row->{'uid'});
	Noosphere::NNexus_addobject ( $row->{'title'},
				'planetmath.org',
				$row->{'data'},
				$row->{'uid'},
				$row->{'userid'},
				$row->{'linkpolicy'},
				$class,
				$row->{'synonyms'},
				$row->{'defines'});
}

$sth->finish();
