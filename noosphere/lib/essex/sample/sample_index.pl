#!/usr/bin/perl

###############################################################################
#
# Example of how to do indexing (not runnable).
#
###############################################################################

use lib '../';
use SearchClient;

use DBI;

use strict;

sub main {

	# open database connection
	#
	my $dbh = DBI->connect("dbspec","user","pass");

	# open search engine connection
	#
	my $se = SearchClient->new(Sock => './essex.sock');

	# get some data
	# 
	my $sth = $dbh->prepare("select identifier, title, author, abstract, source from ...");
	$sth->execute();

	# add all the records
	#
	while (my $row = $sth->fetchrow_hashref();) {
		
		my @elem_words = split(/\s+/,$row->{'title'});
		$total_words += scalar @elem_words;
    	$se->index($identifier, 'title', \@elem_words) or die "index broke";

		@elem_words = split(/\s+/,$row->{'abstract'});
		$total_words += scalar @elem_words;
    	$se->index($identifier, 'abstract', \@elem_words) or die "index broke";

		@elem_words = split(/\s+/,$row->{'authors'});
		$total_words += scalar @elem_words;
    	$se->index($identifier, 'author', \@elem_words) or die "index broke";

		@elem_words = split(/\s+/,$row->{'source'});
		$total_words += scalar @elem_words;
    	$se->index($identifier, 'source', \@elem_words) or die "index broke";

		print "indexed ${counter}: $identifier\n";
		print " ($total_words words indexed so far)\n";
	}

	# close search engine connection
	#
	$se->finish();

	# close the database connection
	#
	$dbh->disconnect();
}

main();
