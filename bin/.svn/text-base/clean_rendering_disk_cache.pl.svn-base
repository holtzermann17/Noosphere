#!/usr/bin/perl

###############################################################################
#
# This script cleans out the disk rendering cache directory of objects which 
# don't exist in the database anymore (have been deleted).
#
###############################################################################

use lib '/var/www/noosphere/lib';

use strict;

use vars qw{$dbh};

use Noosphere;
use Noosphere::Config;
use Noosphere::DB;

sub main {
	
	$dbh = Noosphere::dbConnect();

	# build a list of IDs in the cached rendering directory
	#
	my $basedir = Noosphere::getConfig('base_dir');
	my $cachedir = "$basedir/data/cache/objects";
	my @filenames = <$cachedir/*>;

	my @cacheids;
	foreach my $file (@filenames) {
		if ( -d $file) {
			if ($file =~ /(\d+)$/) {
				my $id = $1;
				push @cacheids, $id;
			}
		}
	}

	# build a list of ids in the database
	#
	my $sth = $dbh->prepare("select uid from objects");
	$sth->execute();

	my %dbids;
	while (my $row = $sth->fetchrow_arrayref()) {
		$dbids{$row->[0]} = 1;
	}
	$sth->finish();

	# lookup cache directory IDs in DB IDs database.  remove directories for 
	# missing items.
	#
	my $delcount = 0;
	foreach my $cid (@cacheids) {
		if (not exists $dbids{$cid}) {

			print "$cid not found in database, removing.\n";
			system("rm -rf $cachedir/$cid");

			$delcount++;
		}
	}
	
	if ($delcount) {
		print "\n$delcount dangling cache directories removed.\n";
	} else {
		print "\nno dangling cache directories found.\n";
	}
	
	$dbh->disconnect();
}

main();
