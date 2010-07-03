#!/usr/bin/perl

use DBI;

$file=$ARGV[0];

@namespaces=();
@subjects=();
%lookup;
%nslookup;

open IN,$file;

# connect to db and clean out tables cat and clinks
#
$dbh=DBI->connect('DBI:mysql:proto','citidel','testing');
$sth=$dbh->prepare('delete from ns');
$sth->execute;
$sth->finish;
$sth=$dbh->prepare('delete from cat');
$sth->execute;
$sth->finish;
$sth=$dbh->prepare('delete from clinks');
$sth->execute;
$sth->finish;

# parse the input file and insert categories and links
#
$counter=0;
$nscount=0;
while ($line=<IN>) {
  next if ($line=~/^\s*$/);
  next if ($line=~/^#/);

  $line=~/^(\w+)\s+(\w.*)$/;
  $operator=$1;
  $operand=$2;
  
  if ($operator eq "namespace") {
    push @namespaces,$operand;
	$nslookup{$operand}=$nscount;
	addns($dbh,$operand,$nscount);
	
	print "added namespace $operand\n";

	$nscount++;
  } 
  elsif ($operator eq "item") {
	next if (check($operand));
	
	push @subjects,$operand;               # bookkeeping
	$lookup{$operand}=$counter;

	doimplicit($dbh,\%lookup,$operand);     # adding to db
	additem($dbh,$operand,$counter,\%nslookup);
	addlink($dbh,$operand,$operand,\%lookup);
	$counter++;

	print "added item $operand\n";
  }
  elsif ($operator eq "contains") {
    ($item1,$item2)=split(/\s*,\s*/,$operand);
    next if (check($item1)||check($item2));
	print "ok, [$item1] contains [$item2]\n";
 
	addlink($dbh,$item1,$item2,\%lookup);
  } 
  elsif ($operator eq "equals") {
    ($item1,$item2)=split(/\s*,\s*/,$operand);
    next if (check($item1)||check($item2));
	print "ok, [$item1] equals [$item2]\n";
	
	addlink($dbh,$item1,$item2,\%lookup);
	addlink($dbh,$item2,$item1,\%lookup);
  }
}

close IN;

$dbh->disconnect;

###############################################################################
# subs 
###############################################################################

sub addns {
  my $dbh=shift;
  my $ns=shift;
  my $id=shift;

  my $sth=$dbh->prepare("insert into ns values ($id,'$ns')");
  $sth->execute;
  $sth->finish;
}

sub additem {
  my $dbh=shift;
  my $item=shift;
  my $id=shift;
  my $nslookup=shift;

  $item=~/^(.+?)[.]/;
  my $ns=$1;

  my $sth=$dbh->prepare("insert into cat values ($id,'$item',$nslookup->{$ns})");
  $sth->execute;
  $sth->finish;
}

sub addlink {
  my $dbh=shift;
  my $a=shift;
  my $b=shift;
  my $lookup=shift;   

  my $query="insert into clinks values ($lookup->{$a},$lookup->{$b})";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
}

sub doimplicit {
  my $dbh=shift;
  my $lookup=shift;
  my $item=shift;

  @subj=split(/[.]/,$item);
  
  if ($#subj >= 2) {
	$parent=join('.',@subj[0..$#subj-1]);
	print "implicit $parent contains $item\n";
	addlink($dbh,$parent,$item,$lookup);
  }
}

sub check {
  my $item=shift;
  
  @subj=split(/[.]/,$item);

  # make sure the namespace exists
  #
  if (invalidns($subj[0])) {
    print "invalid namespace $subj[0] in $item\n";
    return 1;
  }

  # for a nested item, make sure parent branch exists
  #
  if ($#subj >= 2) {
    for ($i=1;$i<$#subj;$i++) { 
	  $parent=join('.',@subj[0..$i]);
      if (notinsubjects($parent)) {
	    print "parent $parent for $item not found!\n";
        return 1;
	  }
	}
  }

  return 0;
}

sub invalidns {
  my $ns=shift;

  foreach my $n (@namespaces) {
    return 0 if ($n eq $ns);
  }

  return 1;
}

sub notinsubjects {
  my $subject=shift;

  foreach my $s (@subjects) {
    return 0 if ($s eq $subject);
  }

  return 1;
}
