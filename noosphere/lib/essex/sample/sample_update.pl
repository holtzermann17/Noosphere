#!/usr/bin/perl

###############################################################################
#
# Example of how to update a record.  This is basically just unindexing and 
# then indexing the new content (you HAVE to do it this way to preserve the 
# integrity of the internal search engine data structures.  However, it is 
# designed to be fast).
#
###############################################################################

use lib '../';
use SearchClient;

use DBI;

use strict;

sub main {

	# connect to database
	# 
	my $dbh = DBI->connect("dbspec","user","pass");

	# connect to search engine
	#
	my $se = SearchClient->new(Sock => './essex.sock');

	# get data (which we assume is updated since old indexed version)
	#
	my $sth = $dbh->prepare("select identifier, title, author, abstract, source from ...");
	$sth->execute();

	# update all of the records
	#
	while (my $row = $sth->fetchrow_hashref();) {
		
		# remove old metadata for the record
		#
		$se->unindex($identifier);

		# re-add new version of the record
		# 
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
