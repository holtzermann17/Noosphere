#!/usr/bin/perl

###############################################################################
#
# Example of how to get some internal stats.  These will print to the console
# from which the search engine was run (you may want to launch it redirecting
# this to a .out file or something).
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

	# pretty simple, just call the function
	#
	$se->stats();

	# close search engine connection
	#
	$se->finish();
}

main();
