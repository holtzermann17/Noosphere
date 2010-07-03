#!/usr/bin/perl

##############################################################################
#
# this script initalizes author lists to include the owner of the object.
# with this set, we can uniformly suppress the separate "author list" when
# viewing objects unless its size is greater than 1.
#
##############################################################################
 
use lib '/var/www/noosphere/lib';
use DBI;
use Noosphere qw($dbh $DEBUG);
use Noosphere::DB;
use Noosphere::Config;
use Noosphere::Authors;

  $DEBUG=1;

  # start off by connecting to the db
  #
  die "Couldn't open database: ",$DBI::errstr unless ($dbh=Noosphere::dbConnect());

  # loop through all applicable tables
  #
  foreach my $table ('objects','lec','papers','books') { 

    my ($rv,$sth)=Noosphere::dbSelect($dbh,{WHAT=>'uid, userid',FROM=>$table});
	my @objects=Noosphere::dbGetRows($sth);

	foreach my $object (@objects) {
      print "adding owner to author list for $table::$object->{uid}, owned by $default->{userid}\n";
      Noosphere::updateAuthorEntry($table,$object->{uid},$object->{userid});
	}
	
  }
