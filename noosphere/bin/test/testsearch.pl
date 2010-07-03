#!/usr/bin/perl

###############################################################################
#
# Test raw search capability in Noosphere.
#
###############################################################################

use lib '/var/www/pm/lib';
use lib '/var/www/essex';

use strict;

use Noosphere;
use Noosphere::Config;
use SearchClient;

# main sub. mmm, sub.
# 
sub main {
	
	# init search client
	#
	my $se = SearchClient->new(Sock => Noosphere::getConfig('searchd_sock'));
	die "couldn't start search client" if (not defined $se);

	# submit search
	#
	my ($nmatches, $results) = $se->limitsearch($ARGV[0], 1000);

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
