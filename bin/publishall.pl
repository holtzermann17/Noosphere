#!/usr/bin/perl

###############################################################################
#
# The background rendering script.  This exists to make sure the system is 
# productive even during "idle" time (client-wise), and helps minimize the 
# number of rendering waits the user is subject to.
#
###############################################################################

use DBI;
use lib '/var/www/noosphere/lib';

use Noosphere qw($dbh $DEBUG);
use Noosphere::DB;
use Noosphere::Cache;
use Noosphere::Config;
use Noosphere::Cache;
use Noosphere::Util;
use Noosphere::Editor;

# connect to the database
#
$dbh = Noosphere::dbConnect;

Noosphere::initNoosphere();

#my @methods = ('l2h', 'png');
my @methods = ('js');
my $table = Noosphere::getConfig('en_tbl');
my $runfile = "/var/www/noosphere/bin/run/publishall.running";

$|=1;

if ( -e $runfile ) {
	exit 1;
}

# necessary so cached entries can be overwritten by the web application
umask 0002;

$ENV{'PATH'} = "/bin:/usr/bin:/usr/local/bin";

push @INC, ".";

`echo 1 > $runfile`;

$DEBUG = 0;	 # dont need debugging of database access

open STDERR, ">/var/www/logs/error-publishall";


my $sth = $dbh->prepare( "select uid from objects" );
$sth->execute();

while ( my $row = $sth->fetchrow_hashref() ) {
	my $objectid = $row->{'uid'};
	open(OLDOUT, ">&STDOUT");
	open STDOUT, ">>/var/www/logs/stdout-publishall";
	print "checking $objectid\n";
	if ( ! Noosphere::is_published( $objectid ) ) {
		print "publishing $objectid\n";
		Noosphere::do_publish( $objectid, 13792);
#		Noosphere::cacheObject($table, $rec, $method);
		print "\n";
	}
	open(STDOUT, ">&OLDOUT");
}

close STDERR;

`rm $runfile`;
