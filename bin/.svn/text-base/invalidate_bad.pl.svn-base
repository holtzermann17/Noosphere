#!/usr/bin/perl

###############################################################################
#
# Invalidate cache for entries that have bad output dir/file on disk.
# bad output includes entries that have \htmladdnormal in the text and
# entries that have newcommand in the tex
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

	my $sth = $dbh->prepare("select objectid, name from cache, objects where method = '$method' and (valid = 1 or valid_html = 1) and tbl = 'objects' and uid = objectid");
	$sth->execute();
	while (my $row = $sth->fetchrow_hashref()) {
		my $objectid = $row->{'objectid'};
		my $fname = $row->{'name'} . ".tex";
#		print "Checking $objectid, $fname\n";
		open (TEX, "$basedir/data/cache/objects/$objectid/$method/$fname");
		open (HTML, "$basedir/data/cache/objects/$objectid/$method/$rfile");
		my $invalidate = 0;
		my $stringToFind = "\\Box";
		while ( my $line = <TEX> ) {
			if ( $line =~ /$stringToFind/ ) {
				$invalidate = 1;
			}
		}
		if ($invalidate == 1 ) {
			print "invalidating $objectid because of $stringToFind\n";
			my $sth2 = $dbh->prepare("update cache set valid = 0, valid_html = 0 where objectid = $objectid and tbl = 'objects' and method = '$method'");
			$sth2->execute();
			$sth2->finish();
		}
		my $invalidate = 0;
		while ( my $line = <HTML> ) {
			if ( $line =~ /htmladdnormal/ ) {
				$invalidate = 1;
			}
		}
		if ($invalidate) {
			print "invalidating $objectid because of htmladdnormal\n";
			my $sth2 = $dbh->prepare("update cache set valid = 0, valid_html = 0 where objectid = $objectid and tbl = 'objects' and method = '$method'");
			$sth2->execute();
			$sth2->finish();
		}
		close(TEX);
		close(HTML);
		if (! -e "$basedir/data/cache/objects/$objectid/$method/$rfile") {
			print "$objectid found missing; invalidating\n";

			my $sth2 = $dbh->prepare("update cache set valid = 0, valid_html = 0 where objectid = $objectid and tbl = 'objects' and method = '$method'");
			$sth2->execute();
			$sth2->finish();
		}
	}
	$sth->finish();

	$dbh->disconnect();
}

main();
