#!/usr/bin/perl

# go through watches and remove watches of objects that dont exist
#
# this should not have to be run more than once, since watch cleanup is now a
# part of normal object deletion.

use lib '/var/www/noosphere/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::DB;
use Noosphere::Config;
use Noosphere::Util;
use DBI();

	# start off by connecting to the db
	#
	die "Couldn't open database: ",$DBI::errstr unless ($dbh=Noosphere::dbConnect());
  
	my $bad = 0;

	# get list of all tables there are watches on.
	#
	print "figuring out which tables to analyze\n";

	my $sth = $dbh->prepare("select distinct tbl from watches");
	$sth->execute();

	my @tables;
	while (my $row = $sth->fetchrow_arrayref()) {
		print " got table $row->[0]\n";
		push @tables, $row->[0];
	}
	$sth->finish();

	print "\n";

	print "looking for dangling watches\n";

	print "\n";

	foreach my $table (@tables) {
		print " checking $table\n";

		my $q = "select watches.uid from watches left outer join $table on watches.objectid = $table.uid where watches.tbl = '$table' and $table.uid is null";
		$sth2 = $dbh->prepare($q);
		
		$sth2->execute();

		my @badids = ();

		while (my $row = $sth2->fetchrow_hashref()) {
			print " deleting bad watch $row->{uid}\n";
			push @badids, $row->{'uid'};
			$bad++;
		}

		$sth2->finish();

		# actually do the deletion
		#
		if (@badids) {
			my $idlist = join (', ', @badids);
			$dbh->do("delete from watches where tbl='$table' and uid in ($idlist)");

		}
		print "\n";
	}

	print "found $bad dangling watches\n";

