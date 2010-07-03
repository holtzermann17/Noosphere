#!/usr/bin/perl

# copy df values from dedicated df table (ir_word_df) to the new augmented
# dictionary (ir_word, though it should be renamed manually after running this)
#

use DBI;
use lib '/var/www/noosphere/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::IR;
use Noosphere::Config;
use Noosphere::DB;

$dbh = Noosphere::dbConnect;
my $table = Noosphere::getConfig('en_tbl');

my ($rv,$sth) = Noosphere::dbSelect($dbh,{WHAT=>'df, wordid',FROM=>'ir_word_df'});

while (my $row = $sth->fetchrow_hashref()) {

	print "updating df for word $row->{wordid}\n";
	my ($rv2, $sth2) = Noosphere::dbUpdate($dbh, {WHAT=>'ir_word_new', SET=>"df=$row->{df}", WHERE=>"uid=$row->{wordid}"});
}

$sth->finish();

