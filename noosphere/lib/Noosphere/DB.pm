package Noosphere;

use DBI;
use strict;

use vars qw{%cached_prepares};

use Noosphere::Util;

# DBConnect - connect to the database
# 
sub dbConnect {
  require Noosphere::Config;

  return $dbh = DBI->connect("DBI:".getConfig("dbms").":dbname=".getConfig('db_name').";host=".getConfig('db_host'), getConfig('db_user'), getConfig('db_pass'));
}

# disconnect (incl. freeing up cached statements)
#
sub dbDisconnect {

	foreach my $sth (values %cached_prepares) {
		$sth->finish();
	}

	$dbh->disconnect();
}

# do a SQL statement prepare and return, maintaining a cache of already
# prepared statements for potential re-use.
#
# NOTE: it is only useful to use these for immutable statements, with bind
# variables or no variables.
#
sub cachedPrepare {
	my $statement = shift;

	if (not exists $cached_prepares{$statement}) {
		$cached_prepares{$statement} = $dbh->prepare($statement);
	}

	return $cached_prepares{$statement};
}

# look up an expression (really just do a select on an arbitrary query and 
# return the first column of the first row)
#
sub dbEval {
	my $expr = shift;

	my $sth = $dbh->prepare("select $expr");
	$sth->execute();

	my $row = $sth->fetchrow_arrayref();
	$sth->finish();

	return $row->[0];
}


# this subroutine will "gather" information which is "scattered" across tables.
# it expects an array(ref) of row hashrefs, with a particular field that 
# determines which table to look in for each row, and a field which holds the 
# unique id for the table
#
# the gather spec should be of the form {table=>select1, table2=>select2}
#
# this procedure should be MUCH faster than doing a lookup for each row, since
# it will only do as many database queries as there are different tables (as
# determined by the $tblfield)
#
sub dbGather {
	my $rows = shift;
	my $tblfield = shift;
	my $idfield = shift;
	my $gather_spec = shift;

	# build the ID list for each table
	#
	my %idlists;
	foreach my $row (@$rows) {

		my $tbl = $row->{$tblfield};
		my $id = $row->{$idfield};
		
		if (not defined $idlists{$tbl}) {
			$idlists{$tbl} = [$id];
		} else {
			push @{$idlists{$tbl}}, $id;
		}
	}

	# do the gather queries
	#
	my %output;
	foreach my $table (keys %idlists) {
		
		# init output
		$output{$table} = {};

		# get the list string for the query
		my $idlist = join (', ', @{$idlists{$table}});

		# process the gather spec
		#
		my $where = $gather_spec->{$table}->{'select'};
		my $idfield = $gather_spec->{$table}->{'idfield'};
		my $aggregate = $gather_spec->{$table}->{'aggregate'};

		my $agg = '';
		if ($aggregate) {
			$agg = "group by $idfield";
		}
		
		# form the query
		my $query = "select $idfield, $where from $table where uid in ($idlist) $agg";
		dwarn "doing gather query = $query", 3;
		my $sth = $dbh->prepare($query);
		my $rv = $sth->execute();

		# gather up the result rows
		#
		while (my $row = $sth->fetchrow_hashref()) {
			$output{$table}->{$row->{uid}} = {%$row};
		}

		$sth->finish();
	}

	# merge in the result rows with passed-in rows
	#
	foreach my $row (@$rows) {

		my $table = $row->{$tblfield};
		my $id = $row->{$idfield};

		merge_hashes_left($row, $output{$table}->{$id});
	}
}

# get the schema of a database
#  (this is VERY postgres-specific, unfortunately)
#
sub dbGetSchema {
  my $dbh = shift;
  my $table = shift;
  
  # get table column schema
  #
  my ($rv, $sth) = dbLowLevelSelect($dbh, 
   "select 
     pg_attribute.attname as colname, 
	 pg_type.typname as typename,
	 pg_attribute.attnotnull as notnull,
	 pg_attrdef.adsrc as default
	from 
	 pg_attribute, pg_type, pg_attrdef
	where 
	 pg_attribute.attrelid = (select oid from pg_class where relname='$table') and
	 pg_type.oid = pg_attribute.atttypid and 
	 pg_attrdef.adrelid = (select oid from pg_class where relname='$table') and
	 pg_attrdef.adnum = pg_attribute.attnum and
	 pg_attribute.attnum > 0 
	union
	select 
     pg_attribute.attname as colname, 
	 pg_type.typname as typename,
	 pg_attribute.attnotnull as notnull,
	 '[none]' as default
	from 
	 pg_attribute, pg_type
	where 
	 pg_attribute.attrelid = (select oid from pg_class where relname='$table') and
	 pg_type.oid = pg_attribute.atttypid and 
	 not pg_attribute.atthasdef and
	 pg_attribute.attnum > 0");

  my @cols = dbGetRows($sth);

  # get indices 
  #
  ($rv, $sth) = dbLowLevelSelect($dbh, 
    "select 
	  pg_class.relname as indname, 
	  pg_attribute.attname as oncol, 
	  pg_index.indisprimary as primary, 
	  pg_index.indisunique as unique
	 from 
	  pg_index, pg_class, pg_attribute 
	 where 
	  pg_class.oid = pg_index.indexrelid and 
	  pg_index.indrelid=(select oid from pg_class where relname='$table') and 
	  pg_attribute.attrelid=(select oid from pg_class where relname='$table') and 
	  pg_attribute.attnum=pg_index.indkey[0]");

  my @inds = dbGetRows($sth);

  return ([@cols], [@inds]);
}

# get a list of tables in the database
#
sub dbGetTables {
  my $dbh = shift;

  return $dbh->tables();
}

# dbRowCount - get the count of rows via WHERE condition.
#
sub dbRowCount {
	my $table = shift;
	my $where = shift;

	my ($rv,$dbq) = dbSelect($dbh,
		($where 
			? {WHAT => 'count(*) as cnt', FROM => $table, WHERE => $where}
			: {WHAT => 'count(*) as cnt', FROM => $table} )
		);
		
	my $row = $dbq->fetchrow_hashref();

	$dbq->finish();
	
	return $row->{'cnt'};
}

sub dbRowCountWithWhat 
{
	my ($what, $table, $where) = @_;

	my $row;
	if (nb($where)) {
		my ($rv, $dbq) = dbSelect($dbh, { WHAT => "count($what) as cnt", FROM => $table, WHERE => $where });
		$row = $dbq->fetchrow_hashref();
		$dbq->finish();
	} else {
		my ($rv, $dbq) = dbSelect($dbh, { WHAT => "count($what) as cnt", FROM => $table});
		$row = $dbq->fetchrow_hashref();
		$dbq->finish();
	}

	return $row->{'cnt'};
}

# getfieldsbyid  - grab fields from any table by id
#
sub getfieldsbyid {
 my $uid = shift;
 my $table = shift;
 my $fields = shift;

 $fields = "*" if (not defined $fields);
 
 my ($rv,$dbq) = dbSelect($dbh,{
  WHAT => $fields,
  FROM => $table,
  WHERE => "uid=$uid"});
  
 return undef if ($dbq->rows() <= 0);
 
 my $row = $dbq->fetchrow_hashref();
 $dbq->finish();
 
 my %rec = %$row;

 return %rec; 
}

sub dbSelect {
  my $dbh = shift;
  my $args = shift;

  my $query = "SELECT";
  if ($args->{DISTINCT}) { $query.=" DISTINCT"; }
  $query .= " $args->{WHAT} FROM $args->{FROM}";
  if ($args->{WHERE}) {
    $query .= " WHERE $args->{WHERE}"; }
  if ($args->{'GROUP BY'}) {
    $query .= " GROUP BY $args->{'GROUP BY'}"; }
  if ($args->{'ORDER BY'}) {
    $query .= " ORDER BY $args->{'ORDER BY'}"; 
  if (defined($args->{DESC})) {
    $query .= " DESC"; }
  elsif (defined($args->{ASC})) {
    $query .= " ASC"; } }

	if (getConfig('dbms') eq 'mysql') {
		if ($args->{LIMIT} && $args->{OFFSET}) {
			$query .= " LIMIT $args->{OFFSET}, $args->{LIMIT}";
		}
		elsif ($args->{LIMIT}) {
			$query .= " LIMIT $args->{LIMIT}";
		}
	} else {
		if ($args->{LIMIT}) {
			$query .= " LIMIT $args->{LIMIT}"; }
		if ($args->{OFFSET}) {
			$query .= " OFFSET $args->{OFFSET}"; }
	}
  
  dwarn "query=$query", 3;
  
  my $dbq = $dbh->prepare($query);
  my $rv = $dbq->execute();
  if (not defined $rv || not defined $dbq) {
	 my ($package, $filename, $line) = caller; 
  	 warn "query failed, called from $filename line $line (in $package)";
	 warn " query was [$query]";
  }

  return ($rv,$dbq); 
}

sub dbLowLevelSelect {
  my $dbh = shift;
  my $query = shift;

  dwarn "lowlevel query=$query", 3;
  
  my $dbq = $dbh->prepare($query);
  my $rv = $dbq->execute();

  if (not defined $rv || not defined $dbq) {
	 my ($package, $filename, $line) = caller; 
  	 warn "query failed, called from $filename line $line (in $package)";
	 warn " query was [$query]";
  }

  return ($rv,$dbq);
}

sub dbGetRows {
  my $dbq = shift;
  
  my @recs;
  my $rec;
  
  while ($rec = $dbq->fetchrow_hashref()) {
    push @recs,$rec; 
  }
  $dbq->finish();
  return(@recs); 
}

sub dbUpdate {
  my $dbh = shift;
  my $args = shift;
 
  my $query = "UPDATE $args->{WHAT} SET $args->{SET}";
  if ($args->{WHERE}) {
    $query .= " WHERE $args->{WHERE}"; 
  }
  if ($args->{LIMIT}) {
    $query .= " LIMIT $args->{LIMIT}"; 
  }
  
  dwarn "query=$query\n", 3;
 
  my $dbq = $dbh->prepare($query);
  my $rv = $dbq->execute();

  if (not defined $rv || not defined $dbq) {
	 my ($package, $filename, $line) = caller; 
  	 warn "query failed, called from $filename line $line (in $package)";
	 warn " query was [$query]";
  }

  return ($rv,$dbq); 
}

sub dbInsert {
  my $dbh = shift;
  my $args = shift;
 
  my $query = "INSERT INTO $args->{INTO}";
 
  if ($args->{COLS}) {
   $query .= " ($args->{COLS})"; 
  }
  
  $query .= " VALUES ($args->{VALUES})";
  
  dwarn "query=$query\n", 3;
  
  my $dbq = $dbh->prepare($query);
  my $rv = $dbq->execute();
  
  if (not defined $rv || not defined $dbq) {
	 my ($package, $filename, $line) = caller; 
  	 warn "query failed, called from $filename line $line (in $package)";
	 warn " query was [$query]";
  }

  return($rv,$dbq); 
}

sub dbDelete {
  my $dbh = shift;
  my $args = shift;
 
  my $query = "DELETE FROM $args->{FROM}";

  if ($args->{WHERE}) {
    $query .= " WHERE $args->{WHERE}"; 
  }
  if ($args->{LIMIT}) {
    $query .= " LIMIT $args->{LIMIT}"; 
  } 
  
  dwarn "query=$query\n", 3;
 
  my $dbq = $dbh->prepare($query);
  my $rv = $dbq->execute();
 
  if (not defined $rv || not defined $dbq) {
	 my ($package, $filename, $line) = caller; 
  	 warn "query failed, called from $filename line $line (in $package)";
	 warn " query was [$query]";
  }

  return($rv,$dbq); 
}

1;
