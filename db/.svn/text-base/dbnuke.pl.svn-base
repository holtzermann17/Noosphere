#!/usr/bin/perl
use strict;

use lib '/var/www/noosphere/lib';

use Noosphere;
use Noosphere::DB;
use Noosphere::Config;

my $file = $ARGV[0] || "schema.mysql.sql";
my $dbname = Noosphere::getConfig('db_name');
my $dbuser = Noosphere::getConfig('db_user');

print "This will erase and rebuild the '$dbname' database. Continue? [y/n]: ";

my $sure = 'y';

chomp $sure;

if ($sure eq 'y') {

 print "* Shutting down apache\n";
 
 `apachectl stop`;
 
 my $drop = "dropdb -U $dbuser $dbname";
 
 print "Error dropping $dbname\n" if system($drop);
 
 my $create = "createdb -U $dbuser $dbname";
 
 print "Error creating $dbname\n" if system($create);
 
 my $data = "psql -U $dbuser $dbname < $file";
 
 print "Error dumping data into $dbname\n" if system($data); 
 
 print "* Restarting apache\n";
 
 `apachectl start`;
 }
 
else {

 print "No changes made.\n";
 
 exit; 
}

