#!/usr/bin/perl

use DBI;
use lib '/var/www/noosphere/lib';
use Noosphere qw($dbh $DEBUG);
use Noosphere::DB;
use Noosphere::Cache;
use Noosphere::Config;

# connect to the database
#
$dbh=Noosphere::dbConnect;

my $cattbl='catlinks';

# connect to db
# 
#my $dbh=DBI->connect('DBI:mysql:proto','citidel','testing');

#printlinks(\@links);

$dim=getdim($dbh);
$precount=getcount($dbh);

@matrix=buildmatrix($dbh,$dim);
#printmatrix(@matrix);
trans(\@matrix,$#matrix+1);
#printmatrix(@matrix);

makelinks($dbh,\@matrix,$dim);

$postcount=getcount($dbh);

if ($precount != $postcount) {
  $diff=$postcount-$precount;
  print "added $diff links.\n";
} else {
  print "no changes.\n";
}

###############################################################################

# get # of links
# 
sub getcount {
  my $dbh=shift;

  my $sth=$dbh->prepare("select count(a) as cnt from $cattbl");
  $sth->execute;
  my $row=$sth->fetchrow_hashref;
  $sth->finish;
  return $row->{cnt};
}

# get dimension of the adjacency matrix
#
sub getdim {
  my $dbh=shift;

  my $a;
  my $b;

  my $sth=$dbh->prepare("select max(a) as ma from $cattbl");
  $sth->execute;
  my $row=$sth->fetchrow_hashref;
  $a=$row->{ma};
  $sth->finish;

  $sth=$dbh->prepare("select max(b) as mb from $cattbl");
  $sth->execute;
  $row=$sth->fetchrow_hashref;
  $b=$row->{mb};
  $sth->finish;

  return ($a>$b?($a+1):($b+1));
}

# get the transitive closure of a matrix
#
sub trans {
  my $matrix=shift;
  my $n=shift;

  if ($n == 1) {   # trans closure of a 1x1 matrix is itself
    return;
  }

  for (my $k=0;$k<$n;$k++) {
    for (my $i=0;$i<$n;$i++) {
	
	  if ($matrix->[$i]->[$k]) {
        for (my $j=0;$j<$n;$j++) {

		  if ($matrix->[$k]->[$j]) {
		    $matrix->[$i]->[$j]=1;
		  }
	    }
	  }
	}
  }
}

# print the adjacency matrix
#
sub printmatrix  {
  my @matrix=@_;

  foreach my $row (@matrix) {
    foreach my $val (@$row) {
	  print "$val ";  
	}
	print "\n";
  }
  print "\n";
}

# generate links (in database) from matrix
#
sub makelinks {
  my $dbh=shift;
  my $matrix=shift;
  my $n=shift;

  # insert new links
  #
  for (my $i=0;$i<$n;$i++) {
    for (my $j=0;$j<$n;$j++) {
	  if ($matrix->[$i]->[$j]) {
	    # check to see if this link exists
		#
		$sth=$dbh->prepare("select * from $cattbl where a=$i and b=$j");
		$sth->execute;
		my $rowc=$sth->rows;
		$sth->finish;
		if ($rowc == 0) {
		  $sth=$dbh->prepare("insert into $cattbl values ($i,$j)");
		  $sth->execute;
		  $sth->finish;
		  print "adding: ";
		  printlink($dbh,$i,$j);
		  print "\n";
		}
	  }
    }
  }
}

# print the human-readable version of a link
# 
sub printlink {
  my $dbh=shift;
  my $i=shift;
  my $j=shift;

  my $sth=$dbh->prepare("select cat from cat where id=$i");
  $sth->execute;
  my $row=$sth->fetchrow_hashref;
  my $itext=$row->{cat};
  $sth->finish;
  $sth=$dbh->prepare("select cat from cat where id=$j");
  $sth->execute;
  $row=$sth->fetchrow_hashref;
  my $jtext=$row->{cat};
  $sth->finish;

  print "$itext -> $jtext";
}

# generate adjacency matrix from links
#
sub buildmatrix {
  my $dbh=shift;
  my $n=shift;

  my @matrix=();
  my @row;

  # build empty matrix
  #
  for (my $i=0;$i<$n;$i++) {
    @row=();
    for (my $j=0;$j<$n;$j++) {
	  push @row,($i == $j)?1:0;
	}
	push @matrix,[@row];
  }

  # put links in matrix
  #
  my $sth=$dbh->prepare("select * from $cattbl");
  $sth->execute;
  while ($link=$sth->fetchrow_hashref) {
	$matrix[$link->{a}]->[$link->{b}]=1;
  }
  $sth->finish;

  return @matrix;
}

