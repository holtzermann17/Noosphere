#!/usr/bin/perl

#
# import batch corrections that come through emails
#
# corrections look like:
#
# Correction-To: SurrealNumber
# Correction-Filed-By: jac
# Correction-Class: meta
# Correction-Title: quote marks should look like ``this''
#
# It can be shown that $N$ is "sandwiched" between the elements of $N_L$ and 
# $N_R$: it is larger than any element of $N_L$ and smaller than any element of $N_R$.
#
# -*- message separator -*-
#
use strict;
use lib '/var/www/noosphere/lib';

use vars qw{$logfile};

use Noosphere;
use Noosphere::DB;
use Noosphere::Corrections;

$logfile = '/var/www/pm/data/correction_batch/import.log';

my $dbh = Noosphere::dbConnect() or die "couldn't connect to DB";

open LOG, ">> $logfile";

my $timestr = localtime;

print LOG "\n$timestr : Starting batch import\n\n";

# get temp file name
my $fname = $ARGV[0];

# open the file and read in contents
#
open INFILE, $fname;

my $content = "";

while (my $line = <INFILE>) {

	if ($line !~ /^#/) {
		$content .= $line;
	}
}

close INFILE;

# parse each correction
#
my $i = 1;
foreach my $cortext (split(/-\*- message separator -\*-/oi, $content)) {
	
	my ($objname, $fromusername, $cortype, $cortitle, $body);

	if ($cortext =~ /^\s*Correction-Filed-By:\s*(\S.+?\S+)\s*$/om) {
		$fromusername = $1;
	}
	if ($cortext =~ /^\s*Correction-Class:\s*(\S+)\s*$/om) {
		$cortype = $1;
	}
	if ($cortext =~ /^\s*Correction-Title:\s*(\S.+?)\s*$/om) {
		$cortitle = $1;
	}
	if ($cortext =~ /^\s*Correction-To:\s*(\S+)\s*$/om) {
		$objname = $1;
	}
	if ($cortext =~ /Correction-Title:.+?\n\n(.+?)\s*$/os) {
		$body = $1;
	}

=quote
	print "fromusername = [$fromusername]\n";
	print "objname = [$objname]\n";
	print "cortype = [$cortype]\n";
	print "cortitle = [$cortitle]\n";
	print "body = [$body]\n";
=cut

	# add
	#
	if (defined $fromusername &&  defined $cortype && defined $cortitle && defined $objname && defined $body) {
		
		my $userid = Noosphere::lookupfield("users", "uid", "username = '$fromusername'");	
		my $objectid = Noosphere::lookupfield("objects", "uid", "name = '$objname'");

		# check for extant cor with same title from same person and still opened
		#
		my $sth = $dbh->prepare("select * from corrections where userid = $userid and objectid = $objectid and title = '".Noosphere::sq($cortitle)."' and closed IS NULL");
		$sth->execute();
		my $count = $sth->rows();
		$sth->finish();

		# don't add dupe
		#
		if ($count) {
			print LOG "$i. correction '$cortitle' is a duplicate!\n";
		} 
		
		# go ahead and add
		# 
		else {
			Noosphere::insertCorrection({id=>$objectid, type=>$cortype, title=>$cortitle, data=>$body},{uid=>$userid});
			print LOG "$i added ('$cortitle')\n";
		}
		
	} else {
		print LOG "$i. broken or missing metadata!\n";
	}

	$i++;
}

print LOG "\n$timestr : finished with import.\n";
		
close LOG;

Noosphere::dbDisconnect();
