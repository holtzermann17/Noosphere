#!/usr/bin/perl

use lib '/var/www/pm/lib';

use vars qw{$dbh};

use Noosphere;
use Noosphere::DB;
use Noosphere::Config;

$dbh = Noosphere::dbConnect();

my ($rv,$sth) = Noosphere::dbSelect($dbh, {WHAT=>'title, objectid, tbl, userid', FROM=>Noosphere::getConfig('index_tbl'),WHERE=>"userid=2 and type = 1 and tbl != 'users'"});

my @rows = Noosphere::dbGetRows($sth);

Noosphere::dbGather(\@rows, 'tbl', 'objectid', 
	{
	 lec => {'select'=>'created', 'idfield'=>'uid'},
	 books => {'select'=>'created', 'idfield'=>'uid'},
	 papers => {'select'=>'created', 'idfield'=>'uid'},
	 objects => {'select'=>'created', 'idfield'=>'uid'},
	});

foreach my $row (@rows) {

	print "$row->{created} $row->{title} ($row->{tbl})\n";
}

$dbh->disconnect();
