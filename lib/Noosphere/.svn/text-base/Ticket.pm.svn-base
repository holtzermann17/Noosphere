package Noosphere;

use strict;

use Digest::SHA1 qw(sha1_base64);

# create a ticket from userid, ip, and expiration date triplet
#
sub makeTicket {
	my $uid = shift;	 # user id 
	my $ip = shift;		# ip addr
	my $exp = shift;	 # expiry time
	
	my $now = time;		# get current time

	# build the hash
	#
	my $hash = sha1_base64(join ':',$uid,$exp,$now,SECRET);

	# make the ticket based on the hash and other info
	#
	my $ticket = "$uid:$exp:$now:$hash"; 
	
	return($ticket); 
}

# see if a ticket string is valid
#
sub checkTicket {
	my $ticket_str = shift;
	my $ip = shift;
 
	# split into fields
	#
	my @ticket_data = split(/:/,$ticket_str);
	my %ticket;

	return -1 unless ($#ticket_data == 3);

	$ticket{'uid'}=$ticket_data[0];
	#$ticket{'ip'}=$ticket_data[1];
	$ticket{'expires'}=$ticket_data[1];
	$ticket{'time'}=$ticket_data[2];
	$ticket{'hash'}=$ticket_data[3];

	# first of all, the IP address must match
	#
# APK- there really is no reason for this. very convenient for roaming, for
# sure.
#	return -1 unless ($ticket{'ip'} eq $ip);
 
	# build a hash based on the first 4 fields
	#
	my $hash = sha1_base64(join ':',@ticket{qw(uid expires time)},SECRET);
 
	# compare the built hash to the hash the user provided
	#
	return -1 unless ($ticket{'hash'} eq $hash);
	return -1 unless ((time-$ticket{'time'})<60*$ticket{'expires'});

	# return uid on success
	#
	return($ticket{'uid'}); 
}

1;
