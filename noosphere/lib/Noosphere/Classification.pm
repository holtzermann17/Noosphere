package Noosphere;

use strict;

# get classification info in string *and* hasharray form
#
sub classinfo {
	my $tbl = shift;
	my $id = shift;
	
	# first get the classification..
	#
	my @class = getclass($tbl,$id);
 
	if (not defined $class[0]) {
		return '';
	}

	my @output;
	foreach my $c (@class) {
		push @output, "$c->{ns}:$c->{cat}";
	}

	return (join(', ',@output),[@class]);
}
 
# get a classification string for an object, formatted as an input string
#
sub classstring {
	my $tbl = shift;
	my $id = shift;
	
	# first get the classification..
	#
	my @class = getclass($tbl,$id);

	if (not defined $class[0]) {
		return '';
	}

	my @output;
	foreach my $c (@class) {
		push @output, "$c->{ns}:$c->{cat}";
	}

	return join(', ',@output);
}

# print the classification for an object as
#
#	ns1: cat1
#			 cat2
#			 ...
#	ns2: cat1
#			 cat2
#			 ....
#		...
# 
# if possible, a parenthesized description will follow the cat#'s (like for msc)
#
sub printclass {
	my $tbl = shift;
	my $id = shift;
	my $fs = shift||"+0";	 # font size
	
	my $html = '';
	
	# first get the classification..
	#
	my @class = getclass($tbl,$id);

	if (not defined $class[0]) {
		return "";
	}

	$html.="<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">";

	my $curns = "";
	foreach my $row (@class) {
		$html .= "<tr>";
		my $nsprintable = getnsshortdesc($row->{ns});
		my $nslink = getnslink($row->{ns});
		
		if ($curns ne $row->{ns}) {
#			$nsprintable =~ s/ /&nbsp;/;
			if (nb($nslink)) {
				$html .= "<td valign=\"top\"><font size=\"$fs\"><a target=\"planetmath_popup\" href=\"$nslink\">$nsprintable</a>:</font></td>";
			} else {
				$html .= "<td><font size=\"$fs\">$nsprintable:</font></td>";
			}
			$curns = $row->{ns};
		} else {
			$html .= "<td><font size=\"$fs\"></font></td>";
		}
		my $desc = '';
		if ($row->{ns} eq 'msc') {
			my $fss = $fs-1;
			$desc = "<font size=\"$fss\">(".getHierarchicalMscComment($row->{cat}).")</font>";
		}
		$html .= "<td><font size=\"$fs\"><a href=\"".getConfig("main_url")."/?op=mscbrowse&amp;from=$tbl&amp;id=$row->{cat}\">$row->{cat}</a> $desc</font></td>";
		$html .= "</tr>";
	}

	$html .= "</table>";

	return $html;
}

# get the short description field for a namespace
#
sub getnsshortdesc {
	my $ns=shift;

	return lookupfield(getConfig('ns_tbl'),'shortdesc',"name='$ns'");
}
sub getnsshortdescbyid {
	my $nid=shift;

	return lookupfield(getConfig('ns_tbl'),'shortdesc',"id=$nid");
}

# get the link field for a namespace
#
sub getnslink {
	my $ns=shift;

	return lookupfield(getConfig('ns_tbl'),'link',"name='$ns'");
}
sub getnslinkbyid {
	my $nid=shift;

	return lookupfield(getConfig('ns_tbl'),'link',"id=$nid");
}

# return 1 if an object is classified, 0 otherwise
#
sub isclassified {
	my $tbl=shift;
	my $id=shift;

	my $table=getConfig('class_tbl');

	my ($rv,$sth)=dbSelect($dbh,{WHAT=>'count(objectid) as cnt',FROM=>$table,WHERE=>"tbl='$tbl' and objectid=$id"});

	if (!$rv) {
		$sth->finish();
	return 0;
	}

	my $row=$sth->fetchrow_hashref();
	$sth->finish();
	return ($row->{cnt}>0?1:0);
}

# get the classification for an object as an array of hashrefs {ns, cat}
# order is preserved.
#
sub getclass {
	my $tbl = shift;
	my $id = shift;
 
	my @results = ();

	my $table = getConfig('class_tbl');
	my $nstbl = getConfig('ns_tbl');

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'ns.name as ns,classification.catid',FROM=>"$nstbl,$table",WHERE=>"ns.id=classification.nsid and classification.tbl='$tbl' and classification.objectid=$id",'ORDER BY'=>'ord',ASC=>''});
	
	if (!$rv || $sth->rows() < 1) {
		$sth->finish();
		return ();
	}

	# loop through the rows looking up human-readable category name
	#
	while (my $row = $sth->fetchrow_hashref()) {
		my $catname = getcatname($row->{'ns'},$row->{'catid'}); 
		push @results,{ns => $row->{'ns'}, cat => $catname};
	}

	return @results;
}

# look up human-readable category name from id
#
sub getcatname {
	my $ns = shift;
	my $catid = shift;

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'id', FROM=>$ns, WHERE=>"uid=$catid"});
	if (!$rv || !$sth->rows()) {
		$sth->finish();
		return $catid;
	}

	my $row = $sth->fetchrow_hashref();
	return $row->{'id'};
}

# check to see if a classification string is well-formed.  callbacks for 
# different schemes should go in here.
#
sub checkclass {
	my $classification = shift;

	my @errors;

	my @classparsed = parseclassstring($classification);

	foreach my $catspec (@classparsed) {
		
		if ($catspec->{'ns'} eq 'msc') {
			if ($catspec->{'cat'} =~ /XX$/) {
				push @errors, "In MSC, '-XX' categories are not real categories and cannot be used for classification";
			}
		}
	}

	return @errors;
}

# parse classifcation strings into array of hashes
#
sub parseclassstring {
	my $classification = shift;

	my @categories;

	my @specs = split(/\s*,\s*/, $classification);

	foreach my $class (@specs) {
		$class = normalizecat($class);

		my ($scheme, $cat) = split(/:/,$class);

		push @categories, {ns => $scheme, cat => $cat};
	}

	return @categories;
}

# classify an object (deletes old classifications)
# the classification string should be of the form
#	 ns:category, ns:category, ...
#
sub classify {
	my $tbl = shift;
	my $id = shift;
	my $classification = shift;

	return unless (defined $classification);	

	# declassify the object
	#
	declassify($tbl, $id);

	# put in the new individual classification links
	#
	my @classes = split(/\s*,\s*/,$classification);

	my $ord = 0; 
	my $count = 0;
	foreach my $class (@classes) {
		$class =~ s/^\s*//;
		$class =~ s/\s*$//;
		if (nb($class)) {
			my $result = class_link($tbl, $id, $class, $ord);
			$count++ if $result;
			$ord++;
		}
	}

	# return count of successfully classified
	#
	return $count;
}

# delete classifications for an object
#
sub declassify {
	my $tbl = shift;
	my $id = shift;

	my $table = getConfig('class_tbl');

	my ($rv,$sth) = dbDelete($dbh,{FROM=>$table,WHERE=>"tbl='$tbl' and objectid=$id"});
	$sth->finish();
}

# shorten classifications, turn
#	 msc:11-00, msc:15-00, ...
# to
#	 msc:11-, msc:15-, ...
# or 
#    msc:11, msc:15, ...
#
# depending on the $level parameter
#
# expects normalization first.
#
sub catlevel {
	my $class = shift;
	my $level = shift;

	my @cats = split(/\s*,\s*/,$class);
	foreach my $i (0..$#cats) {
		my ($ns,$longcat) = split(/\s*:\s*/,$cats[$i]);
		my $shortcat = '';
		if ($ns eq "msc") {
			$longcat =~ /^([0-9]{2})/ if ($level == 1);
			$longcat =~ /^([0-9]{2}.)/ if ($level == 2);
			$shortcat = $1;
		}
		$cats[$i] = "$ns:$shortcat";
	}

	return join(', ',@cats);
}

# normalize an entire classification string
#
sub normalizeclass {
	my $class = shift;

	my @carray = split(/\s*,\s*/,$class);

	foreach my $i (0..$#carray) {
		$carray[$i] = normalizecat($carray[$i]);
	}

	return join (', ',@carray);
}

# normalize a category: put it in canonical form
#
sub normalizecat {
	my $cat = shift;

	my ($ns,$catstring);

	# get classification namespace and string. if namespace isn't given,
	# use the default (set to 'msc')
	#
	if ($cat !~ /:/) {
		($ns,$catstring) = (getConfig('default_scheme'),$cat);
	} else {
		($ns,$catstring) = split(/\s*:\s*/,$cat);
	}

	# handle special things, per scheme
	#
	if ($ns eq 'msc') {
		if ($catstring =~ /^([0-9]{2})$/) {
			$catstring = "$1-00";
		}
		$catstring = uc($catstring);
	}

	return "${ns}:$catstring";
}

# put in an individual classification link
# takes a string of the form ns:category and looks up category in table 'ns'
# to find the uid for the category, then it inserts ns,uid for the record.
#
sub class_link {
	my $tbl = shift;
	my $id = shift;
	my $class = shift;
	my $ord = shift;		 # order

	my $table = getConfig('class_tbl');

	$class = normalizecat($class);
	my ($ns,$catstring)=split(/\s*:\s*/,$class);

	# look up id from category string
	#
	my ($rv,$sth) = dbSelect($dbh,{FROM=>$ns,WHAT=>'uid',WHERE=>"id='$catstring'"});
	my $row = $sth->fetchrow_hashref();
	my $catid = $row->{uid};
	$sth->finish();
	
	my $nsid = getnsid($ns);

	# insert the record
	#
	($rv,$sth) = dbInsert($dbh,{INTO=>$table,COLS=>'tbl,objectid,ns,nsid,catid,ord',VALUES=>"'$tbl',$id,'$ns',$nsid,$catid,$ord"});
	$sth->finish();

	return (defined $rv ? 1 : 0);
}

# get namespace id number by namespace name
#
sub getnsid {
	my $ns=shift;
	my $nstbl=getConfig('ns_tbl');
			
	my ($rv,$sth)=Noosphere::dbSelect($dbh,{WHAT=>"id",FROM=>$nstbl,WHERE=>"name='$ns'"});
	my $row=$sth->fetchrow_hashref();
				
	return $row->{id};
}

1;
