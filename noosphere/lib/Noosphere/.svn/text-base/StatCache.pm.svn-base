package Noosphere;

###############################################################################
#
# StatCache.pm
#
# This package is for efficiently handling of statistics which may take a long
# amount of time to regenerate.  It allows them to only be calculated 
# after certain timeouts, or when some action marks them as invalid.  The 
# statistics are updated when invalid by a callback function given at 
# initialization.  So, this module is strictly for encapsulating the handling
# of the validation functionality.
#
# Statistics are lazily evaluated... meaning they are not literally 
# recalculated when they are invalidated, but instead when a request for the
# statistic happens when it is invalid.
#
# Rather than be stored in memory, the statistics are stored in a database 
# table which is optimized for hash lookup.  This has the benefit of (I think)
# turning into essentially an in-memory store for frequently accessed portions,
# serialization of access, uniformity of data across all Noosphere threads,
# and proper read/write locking.  Essentially I went with the database method
# for a slight slowdown and less control because all of these listed qualities,
# which are necessary, would otherwise have to be recoded in a custom daemon.
#
###############################################################################

use strict;
use Data::Denter;

# make the object. starts off empty.
#
sub StatCache::new {
	my ($class) = @_;

	my $obj = {};  # statistic keys and values will go in here

	bless $obj, $class;

	return $obj;
}

# see if a statistic is cached. mostly for internal use.
#
sub StatCache::isCached {
	my ($self, $key) = @_;

	my $sth = $dbh->prepare('select _key from '.getConfig('storage_tbl').' where _key = ?');
	$sth->execute($key);

	my $count = $sth->rows();
	$sth->finish();

	return $count;
}

# force an invalidation of the statistic addressed by the key $key
#
sub StatCache::invalidate {
	my ($self, $key) = @_;

	my $sth = $dbh->prepare('update '.getConfig('storage_tbl').' set valid = 0 where _key = ?');
	$sth->execute($key);
	$sth->finish();
}


# add a cached statistic if its not cached
#
# statistic specification is of the form
#
# {timeout => seconds,  # interval between forces of refreshing statistic. can
#                       # be left out. 
#  callback => someFunction}  # name of a function (visible from this 
#                               modules's namespace) which should be called
#                               to generate statistics.
#
sub StatCache::add {
	my ($self, $key, $spec) = @_;

	if (!$self->isCached($key)) {
		
		my $sth = $dbh->prepare('insert into '.getConfig('storage_tbl').' (_key, valid, timeout, callback) values (?, ?, ?, ?)');

		dwarn "*** statCache: adding to storage key = $key valid = 0 timeout = $spec->{timeout} callback = $spec->{callback}", 2;

		$sth->execute($key, 0, $spec->{timeout}, $spec->{callback});
		$sth->finish();
	}
}

# check to see if a field is set for a key
#
sub StatCache::fieldSet {
	my ($self, $key, $field) = @_;

	my $sth = $dbh->prepare("select $field from ".getConfig('storage_tbl')." where _key = ?");
	$sth->execute($key);

	my @row = $sth->fetchrow_array;
	$sth->finish();

	return $row[0] ? 1 : 0;
}

# get the value of a field in a storage table, by some key 
#
sub StatCache::getField {
	my ($self, $key, $field) = @_;

	my $sth = $dbh->prepare("select $field from ".getConfig('storage_tbl')." where _key = ?");
	$sth->execute($key);

	my @row = $sth->fetchrow_array;
	$sth->finish();

	return $row[0];
}

# set a field in the storage table, by some key and field
#
sub StatCache::setField {
	my ($self, $key, $field, $value) = @_;

	my $sth = $dbh->prepare("update ".getConfig('storage_tbl')." set $field = ? where _key = ?");
	my $rv = $sth->execute($value, $key);
	$sth->finish();

	return $rv;
}

# update the VALID flag of a statistic based on its timeout, the time of last
# update, and the current time.
#
sub StatCache::timeInvalidate {
	my ($self, $key) = @_;

	# nothing to do if no timeout is set
	#
	return if (!$self->fieldSet($key, 'timeout'));

	# or, set invalid if there is a timeout, and we've never updated the 
	# statistic.
	#
	if (!$self->fieldSet($key, 'lastupdate')) {
		$self->setField($key, 'valid', 0);
		return;
	}
	
	# otherwise, see if difference between last update and now > timeout
	#
	my $diff = time - $self->getField($key, 'lastupdate');

	if ($diff >= $self->getField($key, 'timeout')) { 

		$self->setField($key, 'valid', 0);
	}

	# dont touch anything otherwise
}

# get data for a statistic
#
sub StatCache::get {
	my ($self, $key) = @_;

	# update invalid based on temporal expiration
	#
	$self->timeInvalidate($key) if ($self->getField($key, 'valid'));

	my $statistic;

	# call statistic generating callback if invalid
	#
	if (not $self->getField($key, 'valid')) {
		
		dwarn "*** statCache : generating stats for $key", 2;

		# use the callback to generate the statistic. this eval is kind of 
		# cheesy, but none of the persistant storage modules will store 
		# subroutine references
		#
		my $callbackname = $self->getField($key, 'callback');
		$statistic = &{eval("\\&$callbackname")};

		# update the persistence metadata
		#
		$self->setField($key, '_val', Indent($statistic));
		$self->setField($key, 'valid', 1);
		$self->setField($key, 'lastupdate', time);
	} 
	
	# don't need to update the statistics, just grab the value from 
	# persistent storage
	#
	else {

		dwarn "*** statCache: using cached statistic for $key", 2;

		$statistic = Undent($self->getField($key, '_val'));
	}

	# return the statistic
	#
	return $statistic;
}

1;
