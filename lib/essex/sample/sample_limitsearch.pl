#!/usr/bin/perl

###############################################################################
#
# Same as sample_search.pl, but uses the second argument as the search result
# limit.
#
###############################################################################

use lib '../';

use strict;

use SearchClient;

# main sub. mmm, sub.
# 
sub main {
	
	# init search client
	#
	my $se = SearchClient->new(Sock => '/citidel/www.citidel.org/bin/run/essex.sock');
	die "couldn't start search client" if (not defined $se);

	# submit search
	#
	my $results = $se->search($ARGV[0], $ARGV[1]);

	if (scalar @$results) {
	
		foreach my $result (@$results) {

			print "$result->[0] : $result->[1]\n";
		}

	} else {
		print "no results\n";
	}
	
	# shut down search client
	#
	$se->finish();
}

main();
