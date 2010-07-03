#!/usr/bin/perl

$dir="/var/www/noosphere/docs";
$msgfile="logmsg";
$changelogfile="/var/www/noosphere/docs/ChangeLog";
$tempfile="/var/www/noosphere/docs/ChangeLog.temp";
$utccmd="/bin/date --utc";
$vimcmd="/usr/bin/vim";

%people=(apk=>{name=>'Aaron Krowne',email=>'akrowne@vt.edu'},
         lbh=>{name=>'Logan Hanks',email=>'logan@vt.edu'});

if ($#ARGV < 0) {
  print "usage:\n\n";
  print "  logchange initials\n\n";
  exit 1;
}

$person=$ARGV[0];

if ( -e ".$tempfile.swp") {
  print "someone else is in the ChangeLog! wait a few minutes.\n";
  exit 2;
}

$datestring=`$utccmd`;
$datestring=~s/\s*$//;
$personstring="$people{$person}->{name} <$people{$person}->{email}>";

open LOG, $changelogfile;

# find first valid line in the file and grab the last note id
#
while ($line=<LOG>) {
  #if ($line=~/[A-Z][a-z]{2}\s+[A-Z][a-z]{2}\s[0-9]{1,2}\s+[0-9]{2}:[0-9]{2}:[0-9]{2}\s+UTC\s+[0-9]{4}\s+(\w+)\s+(\w+)\s+<.+?>\s+Note\s+([0-9]{4})/) {
  if($line =~ /^[a-z]{3}.*UTC.*Note ([0-9]{4})/i) {
	$lastid=$1;
    last;
  }
}

close LOG;

$newid=$lastid+1;

$newidstr=sprintf("%04d",$newid);

$newheader="$datestring  $personstring Note $newidstr";

open NEWFILE, ">$tempfile";
open OLDFILE, $changelogfile;

# write out new stuff
#
print NEWFILE "$newheader\n";
print NEWFILE "\n  1. \n\n";

# copy over rest of old file
#
while ($line=<OLDFILE>) {
  print NEWFILE $line;
}

close OLDFILE;
close NEWFILE;

# put the user in the editor on the new file
#
system("$vimcmd $tempfile +3");

# when they save, copy over the new file to the old
#
system("cp $changelogfile $changelogfile.bak");
system("mv $tempfile $changelogfile");

# update the log in CVS
#
chdir $dir;
system("cvs commit -F $msgfile");
