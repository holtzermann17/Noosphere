#!/usr/bin/perl
#
# this file takes a scheme in a table and makes links for it in the 
# category link table, which can then be processed for transitive closure.
# this should be done so that parents (even at the top level) point to all
# of their children directly.
#

use DBI;
use lib '/var/www/noosphere/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::DB;
use Noosphere::Config;

# define the tables
#
my $cattbl='catlinks';
my $schemetbl='msc';
my $nstbl='ns';

# connect to the database
#
$dbh=Noosphere::dbConnect;

my ($rv,$sth)=Noosphere::dbSelect($dbh,{WHAT=>'uid,id',FROM=>$schemetbl,WHERE=>''});

my @rows=Noosphere::dbGetRows($sth);

my $schemeid=getnsid($nstbl,$schemetbl);

foreach my $row (@rows) {
  print "$row->{id} ($row->{uid})\n";

  # insert self-link
  #
  makelink($cattbl,$row->{uid},$row->{uid},$schemeid,$schemeid);
  
  # insert ancestor links
  #
  my @ancestors=getancestors($schemetbl,$row->{uid});
  foreach my $an (@ancestors) {
    print "  $an\n";
	# ancestor points TO descendent
	#
	makelink($cattbl,$an,$row->{uid},$schemeid,$schemeid);
  }
}


###############################################################################

# get namespace id number by namespace name
#
sub getnsid {
  my $nstbl=shift;
  my $ns=shift;

  my ($rv,$sth)=Noosphere::dbSelect($dbh,{WHAT=>"id",FROM=>$nstbl,WHERE=>"name='$ns'"});
  my $row=$sth->fetchrow_hashref();

  return $row->{id};
}


# get all the ancestors for a particular id
#
sub getancestors {
  my $tbl=shift;
  my $id=shift;

  my $curid=$id;
  my @idlist=();

  my $pid=getparent($tbl,$curid);
  while ($pid>-1) {
    push @idlist,$pid;
	$curid=$pid;
    $pid=getparent($tbl,$curid);
  }

  return @idlist;
}

# get parent id, or -1, for an id in a table
#
sub getparent {
  my $tbl=shift;
  my $id=shift;
  
  my ($rv,$sth)=Noosphere::dbSelect($dbh,{WHAT=>'parent',FROM=>$tbl,WHERE=>"uid=$id"});
  return -1 if ($sth->rows()<1);
  my $row=$sth->fetchrow_hashref();
  $sth->finish();

  my $pid=getuidbyid($tbl,$row->{parent});
  return $pid if ($row->{parent});
  return -1;
}

# translate category identifier to numeric uid
#
sub getuidbyid {
  my $tbl=shift;
  my $cid=shift;
  
  my ($rv,$sth)=Noosphere::dbSelect($dbh,{WHAT=>'uid',FROM=>$tbl,WHERE=>"id='$cid'"});
  my $row=$sth->fetchrow_hashref();
  return $row->{uid};
}

# see if a link exists in the link table
#
sub linkexists {
  my ($cattbl,$aid,$bid,$ans,$bns)=@_;

  my ($rv,$sth)=Noosphere::dbSelect($dbh,{WHAT=>'a',FROM=>$cattbl,WHERE=>"a=$aid and b=$bid and nsa=$ans and nsb=$bns",LIMIT=>'1'});
  my $rc=$sth->rows();
  $sth->finish();
  
  return ($rc==0)?0:1;
}

# make a link in the links table
#
sub makelink {
  my ($cattbl,$aid,$bid,$ans,$bns)=@_;

  my ($rv,$sth)=Noosphere::dbInsert($dbh,{INTO=>$cattbl,COLS=>"a,b,nsa,nsb",VALUES=>"$aid,$bid,$ans,$bns"});

}

