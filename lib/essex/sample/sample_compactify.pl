#!/usr/bin/perl

###############################################################################
#
# Example of how to call compactify.
#
# This currently is not very useful.  But in the future it will do useful 
# memory-optimization and consistency updates.  If you want to plan for the 
# future, have your system call this either periodically and/or after large
# batches of updates.
#
###############################################################################

use lib '../';
use SearchClient;

use DBI;

use strict;

sub main {

	# open search engine connection
	#
	my $se = SearchClient->new(Sock => './essex.sock');

	# easy
	#
	$se->compactify();

	# close search engine connection
	#
	$se->finish();
}

main();
