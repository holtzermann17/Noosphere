#!/usr/bin/perl

###############################################################################
#
# Make an offline browsable snapshot of Noosphere (l2h) entries.
#
###############################################################################

use lib '/var/www/noosphere/lib';

use strict;

use vars qw{$dbh $signature %catlookup %lookup %rlookup};

my %catlookup;
my %rlookup;
my %lookup;

$signature = "Aaron Krowne and the entire team of PlanetMath contributors.";

use Noosphere;
use Noosphere::DB;
use Noosphere::Config;
use Noosphere::Util;
use Noosphere::Latex;
use Noosphere::Classification;

# get primary category code and human-readable name
#
sub getClassification {
	my $objectid = shift;

	my $code = "Unknown";

	my @catcodes = Noosphere::getclass('objects',$objectid);

	if (@catcodes) {
		$code = $catcodes[0]->{'cat'};		
	}

	return $code;
}

sub replaceURL {
	my $name = shift;

	return "HREF=\"../../".getTopCat($rlookup{$1})."/$lookup{$rlookup{$1}}/$lookup{$rlookup{$1}}.html\"";
}

sub getTopCat {
	my $id = shift;
	
	my $catcode = exists $catlookup{$id} ? $catlookup{$id} : 'Unknown';
	my $topcat = substr($catcode, 0 , 2);

	return $topcat;
}

# grab author, owner info for an object
#
sub getAuthorInfo {
	my $objectid = shift;

	my @authors;
	my $owner;

	my $sth = $dbh->prepare("select distinct userid from authors where tbl='objects' and objectid=$objectid order by ts desc");
	$sth->execute();

	while (my $row = $sth->fetchrow_arrayref()) {
		push @authors, $row->[0];
	}
	$sth->finish();

	my $owner = Noosphere::lookupfield('objects', 'userid', "uid=$objectid");

	return ($owner, @authors);
}

# program entry point
#
sub main {

	$dbh = Noosphere::dbConnect();
	Noosphere::initNoosphere();

	# get project name
	#
	my $projname = Noosphere::getConfig('projname');

	# get directories
	#
	my $webroot = Noosphere::getConfig('main_url');
	my $basedir = Noosphere::getConfig('base_dir');
	my $cachedir = "$basedir/data/cache/objects";
	my $snapdir = "$basedir/data/snapshots";

	# get an object id => canonical name lookup table and 
	# canonical name => object id lookup tables.
	#
	my $sth = $dbh->prepare("select objectid, cname, type from objindex where tbl='objects'");
	$sth->execute();

	my $objectcount = $sth->rows();
	while (my $row = $sth->fetchrow_hashref()) {
		
		$lookup{$row->{'objectid'}} = $row->{'cname'} if ($row->{'type'} == 1);
		$rlookup{$row->{'cname'}} = $row->{'objectid'};
	}
	$sth->finish();

	# get an objectid => row lookup
	#
	my %rowlookup;
	my $sth = $dbh->prepare("select * from objects");
	$sth->execute();

	my $objectcount = $sth->rows();
	while (my $row = $sth->fetchrow_hashref()) {
		
		$rowlookup{$row->{'uid'}} = $row;
	}
	$sth->finish();

	# get classification lookup
	#
	$sth = $dbh->prepare("select msc.id as catid, classification.objectid from msc, classification where classification.ord = 0 and classification.catid = msc.uid and classification.tbl='objects'");
	$sth->execute();
	while (my $row = $sth->fetchrow_hashref()) {
		$catlookup{$row->{'objectid'}} = $row->{'catid'};
	}
	$sth->finish();

	# get user id => name lookup
	# 
	my %userlookup;
	my $sth = $dbh->prepare("select uid, username from users");
	$sth->execute();

	while (my $row = $sth->fetchrow_hashref()) {
		$userlookup{$row->{'uid'}} = $row->{'username'};
	}
	$sth->finish();

	# we'll keep index of authors (author => [entry ids]) here
	#
	my %authorindex;

	# build date string
	#
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$year += 1900;
	$mon++;
	my $datestr = sprintf("%04d-%02d-%02d", $year, $mon, $mday);	
	
	# make a working directory for the snapshot
	# 
	my $version = $projname.'-snapshot_'.$datestr;
	my $workingdir = $snapdir.'/'.$version;
	system("mkdir $workingdir") == 0
		or die "couldn't make directory '$workingdir'!";

	system("mkdir $workingdir/entries");

	# write out index: top level (select individual index char dirs)
	#
	
	# get list of index chars, make index directories
	#
	my $sth = $dbh->prepare("select distinct ichar from objindex where tbl='objects' order by ichar asc");
	$sth->execute();

	my @ichars;
	while (my $row = $sth->fetchrow_arrayref()) {
		my $ichar = $row->[0];

		push @ichars, $ichar;
	}
	$sth->finish();

	# iterate over concept labels in each index char, build html index and nav
	# bar.
	# 
	my $conceptcount = 0;

	open NAV, ">$workingdir/navbar.html";
	print NAV "<html>
<head>
	<title>$projname $datestr Snapshot: Nav bar</title>
    <META HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=UTF-8\">
</head>

<body bgcolor=\"#ffffff\">

	<table align=\"center\">
";

	foreach my $ichar (@ichars) {
		
		print "building index for $ichar\n";

		# print nav bar line
		print NAV "<tr><td align=\"center\"><a href=\"$ichar.html\" target=\"main\">$ichar</a></td></tr>\n";

		# build index for this index char
		open INDEX, ">$workingdir/$ichar.html";

		print INDEX "<html>
	<head>
		<title>$projname $datestr Snapshot: $ichar</title>
	    <META HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=UTF-8\">
	</head>
	<body bgcolor=\"#ffffff\">

		<p>

		<center>
			<font size=\"+2\"><b>$ichar</b></font>
		</center>

		<p>

		<hr width=\"90%\">

		<p>

		<table align=\"center\">";

		# iterate over concept labels, indexing them
		#
		my $sth = $dbh->prepare("select * from objindex where ichar = '$ichar' and tbl='objects' order by title asc");
		$sth->execute();

		my @concepts;
		while (my $row = $sth->fetchrow_hashref()) {
			push @concepts, $row;
			$conceptcount++;
		}
		$sth->finish();

		foreach my $concept (sort {Noosphere::cleanCmp(Noosphere::mangleTitle($a->{'title'}),Noosphere::mangleTitle($b->{'title'}))} @concepts) {

			print INDEX "<tr><td>\n";

			my $mtitle = Noosphere::mangleTitle($concept->{'title'});
			
			# get canonical name of object containing this definition/syn.
			#
			my $cname = $concept->{'cname'};
			if ($concept->{'type'} > 1) {
				$cname = $lookup{$rlookup{$cname}};
			}

			my $topcat = getTopCat($concept->{'objectid'});

			# add link in directory for this concept
			#
			print INDEX "<a href=\"entries/$topcat/$cname/$cname.html\">$mtitle</a>";

			# take account of synonyms 
			#
			if ($concept->{'type'} == 2) {
				my $parenttitle = Noosphere::lookupfield('objindex','title',"objectid=$concept->{objectid} and type=1 and tbl='objects'");

				print INDEX " (=<i>$parenttitle</i>)";
			}	

			# take account of defines
			#
			elsif ($concept->{'type'} == 3) {
				my $parenttitle = Noosphere::lookupfield('objindex','title',"objectid=$concept->{objectid} and type=1 and tbl='objects'");

				print INDEX " (defined in <i>$parenttitle</i>)";
			}
			print INDEX "\n</td></tr>\n";
		}
		
		print INDEX "
		</table>
		
	</body>

</html>
	";
		close INDEX;
	}

	print NAV "
	</table>
</body>

</html>";

	close NAV;

	# keep count of edits (person-contributons to any entry)
	#
	my $edits = 0;
	
	# iterate through cache directories, copying over each file and 
	# transforming links
	#
	my @dirs = <$cachedir/*>;

	foreach my $dir (@dirs) {

		if (-d $dir && $dir =~ /\/(\d+)$/) {
			
			print "doing $dir\n";

			my $id = $1;
			my $name = $lookup{$id};			
			my $title = $rowlookup{$id}->{'title'};
			my $version = $rowlookup{$id}->{'version'};
			my $hits = $rowlookup{$id}->{'hits'};
			my $created = Noosphere::ymd($rowlookup{$id}->{'created'});

			my $catcode = exists $catlookup{$id} ? $catlookup{$id} : 'Unknown';
			my $topcat = substr($catcode, 0 , 2);

			# make directory for rendered output
			#
			system("mkdir $workingdir/entries/$topcat 2>/dev/null");			
			system("mkdir $workingdir/entries/$topcat/$name");			

			# copy over what we can verbatim (the TeX source, the images)
			# 
			system("cp $dir/l2h/*.png $workingdir/entries/$topcat/$name");
#			system("cp $dir/l2h/$name.tex $workingdir/entries/$topcat/$name");
			system("cp $dir/l2h/$name.eps $workingdir/entries/$topcat/$name 2>/dev/null");
			system("cp $dir/l2h/$name.css $workingdir/entries/$topcat/$name");
				
			# get author and owner info for entry 
			#
			my ($owner, @authors) = getAuthorInfo($id);

			# make the TeX; add header
			#
			open FILE, "$dir/l2h/$name.tex";
			my $tex = join('', <FILE>);
			close FILE;

			my $authorlist = join(', ', map { $userlookup{$_} } @authors);

			my $header = "%%% This file is part of $projname snapshot of $datestr
%%% Primary Title: $title
%%% Primary Category Code: $catcode
%%% Filename: $name.tex
%%% Version: $version
%%% Owner: $userlookup{$owner}
%%% Author(s): $authorlist
%%% $projname is released under the GNU Free Documentation License.
%%% You should have received a file called fdl.txt along with this file.        
%%% If not, please write to gnu\@gnu.org.
"; 

			open OUTFILE, ">$workingdir/entries/$topcat/$name/$name.tex";
			print OUTFILE $header.$tex;
			close OUTFILE;

			# make the HTML; translate URLs
			#
			open FILE, "$dir/l2h/index.html";
			my $html = join('', <FILE>);
			close FILE;

			$html =~ s/HREF=\s*"$webroot\/encyclopedia\/(\w+).html"/replaceURL($1)/gsie;

			my $authorhtml = "";
			
			$authorhtml .= "Contributors to this entry (in most recent order):
<p>
<ul>
";
			foreach my $authorid (@authors) {

				# add to data for master author index
				#
				if (defined $authorindex{$authorid}) {
					push @{$authorindex{$authorid}}, $id;
				} else {
					$authorindex{$authorid} = [$id];
				}
				$edits++;
				
				# generate in-entry list element for this author
				# 
				my $authorname .= $userlookup{$authorid};

				$authorhtml .= "<li><a href=\"../../people.html#$authorid\">$authorname</a></li>\n";
			}
			$authorhtml .= "</ul>\n";

			$authorhtml .= "<p>\n";

			my $ownername = $userlookup{$owner};

			$authorhtml .= "As of this snapshot date, this entry was owned by <a href=\"../../../people.html#$owner\">$ownername</a>.\n<p>\n";

			# add contributor blurb to transformed entry HTML
			#
			$html =~ s/(<\/body>\s*<\/html>)/$authorhtml\n\n$1/si;

			# add title to top (most entries dont have a title)
			#
			$html =~ s/(<BODY.*?>)/$1\n<p><center><font size="+3">$title<\/font><\/center>/si;
			
			open OUTFILE, ">$workingdir/entries/$topcat/$name/$name.html";
			print OUTFILE $html;
			close OUTFILE;
		}
	}

	# copy logo image over to the directory
	#
	system("cp $basedir/data/images/logo.png $workingdir");

	# copy FDL over to the directory
	#
	system("cp $basedir/data/fdl/fdl.txt $workingdir");

	# write main index
	#
	open MAIN, ">$workingdir/index.html";

	print MAIN "<html>
<head>
	<title>$projname $datestr Snapshot</title>
	<META HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=UTF-8\">
</head>

<frameset rows=\"75,*\">
	<frame src=\"header.html\" scrolling=\"no\">

	<frameset cols=\"100,*\">
		<frame src=\"navbar.html\">
		<frame src=\"frontpage.html\" name=\"main\">
	</frameset>
</frameset>

</html>
	";

	close MAIN;

	# write out author/contributor index
	#
	open PEOPLE, ">$workingdir/people.html";

	print PEOPLE "<html>
<head>
	<title>$projname $datestr Snapshot: Index of Contributors</title>
	<META HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=UTF-8\">
</head>

<body bgcolor=\"#ffffff\">

	<center>
		<font size=\"+3\"><b>Index of $projname Contributors</b></font>
	</center>

	<p>

	<ul>
	
";
	
	# output index entry for each contributor
	#
	foreach my $authorid (sort {lc($userlookup{$a}) <=> lc($userlookup{$b})} keys %authorindex) {
	
		print PEOPLE "<li>";
		
		# anchor
		print PEOPLE "<a name=\"$authorid\">";

		# name and link to user info page on web site
		print PEOPLE "<a href=\"$webroot/?op=getuser&id=$authorid\" target=\"_parent\">$userlookup{$authorid}</a>\n";

		print PEOPLE "<ul>\n";

		# list of objects contributed to, with links
		#
		foreach my $objectid (sort {lc($rowlookup{$a}->{'title'}) <=> lc($rowlookup{$b}->{'title'})} @{$authorindex{$authorid}}) {
			
			print PEOPLE "<li><a href=\"entries/$lookup{$objectid}/$lookup{$objectid}\">$rowlookup{$objectid}->{title}</a></li>\n";
		}

		print PEOPLE "</ul>\n";


		print PEOPLE "</li>\n";
	}

	print PEOPLE "
</body>

</html>";

	close PEOPLE;

	my $contribcount = scalar keys %authorindex;
	my $collabcount = $edits - $contribcount;

	# write out front page
	#
	open FRONT, ">$workingdir/frontpage.html";
	print FRONT "<html>
<head>
	<title>$projname $datestr Snapshot</title>
	<META HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=UTF-8\">
</head>

<body bgcolor=\"#ffffff\">

	<center>
	
		<p>
	
		<font size=\"+3\"><b>The $projname Collection</b></font>

		<p>

		<i>snapshot generated on $datestr</i>

		<p>

		<hr>

	</center>

	<p>

	All entries in this collection copyrighted by their respective authors.

	<p>

	Permission is granted to copy, distribute and/or modify these documents under the terms of the GNU Free Documentation License, Version 1.1 or any later version published by the Free Software Foundation; with no Invariant Sections, with no Front-Cover Texts, and with no Back-Cover Texts. A copy of the license is included in the section entitled <a href=\"fdl.txt\">\"GNU Free Documentation License\"</a>. 
	
	<p>

	<hr>

	<p>
	
	Statistics for this snapshot:

	<p>
	
	<ul>
		<li>$objectcount entries.</li>
		<li>$conceptcount distinct concepts.</li>
		<li>$contribcount contributing writers.</li>
		<li>$collabcount collaborations.</li>
	</ul>

	<p>

	<hr>

	<p>

	To go to an index of contributors, click <a href=\"people.html\">here</a>.

	<p>

	<b>To navigate this snapshot, use the alphabetical index in the left frame</b>.  Within entries, you can follow links to other entries as usual.

	<p>

	Enjoy! 

	<p>

	&mdash; $signature
</body>
</html>
	";

	close FRONT;
	
	# make header
	#
	open HEADER, ">$workingdir/header.html";

	print HEADER "<html>
<head>
	<title>$projname $datestr Snapshot</title>
	<META HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=UTF-8\">
</head>

<body bgcolor=\"#ffffff\">

	<table width=\"100%\">

	<tr>
		<td align=\"left\">
			<img src=\"logo.png\">
		</td>

		<td align=\"right\">

			<a href=\"index.html\" target=\"_parent\">top</a> |
			<a href=\"people.html\" target=\"main\">contributors</a> |
			<a href=\"fdl.txt\" target=\"main\">license</a> |
			<a href=\"$webroot\" target=\"_parent\">web site</a>

		</td>
	</tr>

	</table>
	
</body>

</html>";

	close HEADER;

	# make working directory into tarball
	#
	chdir($snapdir);
	system("tar -czf $version.tar.gz $version/");
	system("rm -rf $version/");
	
	$dbh->disconnect();
}

main();
