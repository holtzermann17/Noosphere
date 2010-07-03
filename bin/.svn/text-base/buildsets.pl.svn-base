#!/usr/bin/perl

##############################################################################
#
# Build set mappings that can be used in OAI provider, using queries to select
# categories from MSC.
#
##############################################################################

use strict;
use DBI;

use lib '/var/www/noosphere/lib';
use Noosphere;
use Noosphere::DB;
use Noosphere::Config;
use Noosphere::Msc;

use vars qw{$dbh %setspecs};

##############################################################################

%setspecs = (
	CS => 'comput prog algo numerical',
	Physics => 'phys',
);

##############################################################################

sub buildset {
	my $setname = shift;
	my $setquery = shift;

	my @subcats;
	my @categories;

	my $results = Noosphere::doMscSearch($setquery);

	print "	$setname => {";

	foreach my $result (@$results) {
		if ($result->{'id'} =~ /xx$/i) {
			push @subcats, $result->{'id'};
		} else {
			push @categories, $result->{'id'};
		}
	}

	# add in hierarchical closure for internal nodes
	#
	while (scalar @subcats) {
		my $cat = shift @subcats;

		if ($cat =~ /xx$/i) {

			my $sth = $dbh->prepare("select * from msc where parent = ?");
			$sth->execute($cat);

			while (my $row = $sth->fetchrow_hashref()) {
				push @subcats, $row->{'id'};
			}

			$sth->finish();
		}

		push @categories, $cat;
	}	

	foreach my $cat (@categories) {
		print "		$cat => 1,\n";
	}

#	warn "got ".(scalar @categories)." total\n";

	print "	},\n";
}

sub main {
	
	$dbh = Noosphere::dbConnect();
	
	print "\%sets = (\n";

	foreach my $set (keys %setspecs) {
		buildset($set, $setspecs{$set});
	}

	print ");\n";

	$dbh->disconnect();
}

main();
