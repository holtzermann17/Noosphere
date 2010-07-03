#!/usr/bin/perl

use IO::Socket;
use lib '/var/www/lib';
use Noosphere;
use Noosphere::Config;

$remote = IO::Socket::INET->new(
                             Proto    => "tcp",
                             PeerAddr => "localhost",
                             PeerPort => Noosphere::getConfig('spell_port'),
							    )
							or die "cannot connect to spellfixer port at localhost";
	
my $check="stablizer libniz brujin";

print $remote $check."\n";

my $result=<$remote>;
$result=~s/\s*$//;

print "$check => $result\n"; 


