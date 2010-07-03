#!/usr/bin/perl

###############################################################################
#
# Invalidate cache for entries lacking a rendering output dir/file on disk.
#
###############################################################################

use lib '/var/www/noosphere/lib';

use strict;

use vars qw{$dbh $method $rfile};

$method = 'js';			# rendering mode to check
$rfile = 'planetmath.html';	# rendered output file to look for

use Noosphere;
use Noosphere::Config;
use Noosphere::DB;

sub main {
	
	$dbh = Noosphere::dbConnect();

	# build a list of IDs in the cached rendering directory
	#
	my $basedir = Noosphere::getConfig('base_dir');
	my $cachedir = "$basedir/data/cache/objects";

	my $sth = $dbh->prepare("select objectid from cache where method = '$method' and (valid = 1 or valid_html = 1) and tbl = 'objects'");
	$sth->execute();
	while (my $row = $sth->fetchrow_arrayref()) {
		my $objectid = $row->[0];
		if (! -e "$basedir/data/cache/objects/$objectid/$method/$rfile") {
			print "$objectid found missing; invalidating\n";

			my $sth2 = $dbh->prepare("update cache set valid = 0, valid_html = 0 where objectid = $objectid and tbl = 'objects'");
			$sth2->execute();
			$sth2->finish();
		}
	}
	$sth->finish();

	$dbh->disconnect();
}

main();
