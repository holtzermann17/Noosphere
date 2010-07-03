#!/usr/bin/perl

# turn synonyms / defines into concept declarations
#

use DBI;
use vars qw{$dbh $DEBUG};
use lib '/var/www/noosphere/lib';
use Noosphere;
use Noosphere::Config;
use Noosphere::DB;
use Noosphere::Util;

sub addconcept {
	my $concept = shift;
	my $objectid = shift;
	my $istitle = shift || 0;

	return if conceptExistsByName($concept);

	my $nextid = Noosphere::nextval('concepts_id_seq');

	my ($rv, $sth) = Noosphere::dbInsert($dbh, 
		{INTO=>'concepts', 
		VALUES=>"$nextid, $objectid, 1, $istitle, ".Noosphere::sqq($concept)});

	$sth->finish();
}

sub addlabel {
	my $label = shift;
	my $concept = shift;

	return if conceptExistsByName($label);

	my $rec = getConceptByName($concept);

	my $id = $rec->{id};
	my $objectid = $rec->{objectid};

	my ($rv, $sth) = Noosphere::dbInsert($dbh, 
		{INTO=>'concepts', 
		VALUES=>"$id, $objectid, 0, 0, ".Noosphere::sqq($label)});

	$sth->finish();
}

sub getConceptByName {
	my $concept = shift;

	my ($rv, $sth) = Noosphere::dbSelect($dbh, 
		{WHAT=>'*', FROM=>'concepts', WHERE=>'name='.Noosphere::sqq($concept)});
 	my $row = $sth->fetchrow_hashref();

	$sth->finish();

	return $row;
}

sub conceptExistsByName {
	my $concept = shift;

	my ($rv, $sth) = Noosphere::dbSelect($dbh, 
		{WHAT=>'id', FROM=>'concepts', WHERE=>'name='.Noosphere::sqq($concept)});
 	my $count = $sth->rows();
	$sth->finish();

	return $count > 0 ? 1 : 0;
}

sub main {
	
	$DEBUG = 2;
	$dbh = Noosphere::dbConnect;
	my $table = Noosphere::getConfig('en_tbl');

	my ($rv,$sth) = Noosphere::dbSelect($dbh,{WHAT=>'*',FROM=>$table});

	while (my $row = $sth->fetchrow_hashref()) {

		print "adding title concept '$row->{title}'\n";
		addconcept($row->{title}, $row->{uid}, 1);

		foreach my $def (split(/\s*,\s*/, $row->{defines})) {
			print "adding defines concept '$def'\n";
			addconcept($def, $row->{uid});
		}

		foreach my $syn (split(/\s*,\s*/, $row->{synonyms})) {
			print "adding synonym label '$syn'\n";
			addlabel($syn, $row->{title});
		}
	}
}

main();

