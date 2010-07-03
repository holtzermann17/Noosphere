#!/usr/bin/perl

###############################################################################
#
# Invalidate cache for entries that have error render output dir/file on disk.
# This is determined by checking planetmath.html for "Rendering failed"
#
###############################################################################

use lib '/var/www/noosphere/lib';

use strict;

use vars qw{$dbh $method $rfile $minsize};

$method = 'js';			# rendering mode to check
$rfile = 'planetmath.html';	# rendered output file to look for
$minsize = 256;			# minimum file size in bytes to be considered "successful"

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
		if (-e "$basedir/data/cache/objects/$objectid/$method/$fname") {
			open (TEX, "$basedir/data/cache/objects/$objectid/$method/$fname");
		}
		if (! -e "$basedir/data/cache/objects/$objectid/$method/$rfile") {
			print "$objectid output totally missing; invalidating\n";

			my $sth2 = $dbh->prepare("update cache set valid = 0, valid_html = 0 where objectid = $objectid and tbl = 'objects' and method = '$method'");
			$sth2->execute();
			$sth2->finish();
			
			next;
		}
		my $filename = "$basedir/data/cache/objects/$objectid/$method/$rfile";
		my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime,$mtime,$ctime,$blksize,$blocks)
           = stat($filename);
		open (HTML, $filename);
		my $html = join ('', <HTML>);
		close(HTML);
=quote
		my $invalidate = 0;
		while ( my $line = <TEX> ) {
			if ( $line =~ /newcommand/ ) {
				$invalidate = 1;
			}
		}
		if ($invalidate == 1 ) {
			print "invalidating $objectid because of newcommand\n";
			my $sth2 = $dbh->prepare("update cache set valid = 0, valid_html = 0 where objectid = $objectid and tbl = 'objects' and method = '$method'");
			$sth2->execute();
			$sth2->finish();
		}
=cut
		if ($html =~ /Rendering failed/igs || $size < $minsize) {
			print "invalidating $objectid because of render error\n";
			my $sth2 = $dbh->prepare("update cache set valid = 0 , valid_html = 0 where objectid = $objectid and tbl = 'objects' and method = '$method'");
			$sth2->execute();
			$sth2->finish();
		}
		close(TEX);
	}
	$sth->finish();

	$dbh->disconnect();
}

main();
