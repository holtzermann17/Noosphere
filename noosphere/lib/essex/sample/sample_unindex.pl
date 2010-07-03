#!/usr/bin/perl

###############################################################################
#
# Example of how to do unindexing.
#
###############################################################################

use lib '../';
use SearchClient;

use DBI;

use strict;

sub main {

	# connect to databsae
	# 
	my $dbh = DBI->connect("dbspec","user","pass");

	# connect to search engine
	#
	my $se = SearchClient->new(Sock => './essex.sock');

	# get identifiers to unindex
	#
	my $sth = $dbh->prepare("select identifier from ...");
	$sth->execute();

	# unindex all of the corresponding records
	#
	while (my $row = $sth->fetchrow_hashref();) {
		
		# pretty simple.
		# 
    	$se->unindex($identifier);

		print "unindexed $identifier\n";
	}

	# close search engine connection
	#
	$se->finish();

	# close the database connection
	#
	$dbh->disconnect();
}

main();
