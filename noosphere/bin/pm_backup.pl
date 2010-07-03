#!/usr/bin/perl

$ENV{'PATH'} = '/bin:/usr/bin:/usr/local/bin:/usr/sbin:/sbin';

# must have ssh key-based login to these hosts
@HOSTS = (
	"198.82.160.76",		# virginia.cc.vt.edu
);

# generate backup archives
#
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

$datestamp = sprintf("%4d%02d%02d%02d", $year+1900,$mon+1,$mday,$hour);

system("cd ~");

print "generating backup archives for $datestamp\n";

print "dumping DB\n";

system("mysqldump -upm -pgroupschemes pm | gzip > pm_db_$datestamp.sql.gz");

system("tar --exclude /var/www/noosphere/data/cache --exclude /var/www/noosphere/data/snapshots --exclude /var/www/noosphere/data/book --exclude /var/www/noosphere/test --exclude /var/www/noosphere/bin/run -zcf pm_files_$datestamp.tar.gz /var/www/noosphere 2>/dev/null");

# copy to hosts
#
foreach $host (@HOSTS) {

	print "copying pm_db to $host\n";
	system("scp -q pm_db_$datestamp.sql.gz pm@".$host.":backups");
	
	print "copying pm_files to $host\n";
	system("scp -q pm_files_$datestamp.tar.gz pm@".$host.":backups");
}

system("rm pm_db_$datestamp.sql.gz");
system("rm pm_files_$datestamp.tar.gz");
