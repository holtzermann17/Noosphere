package Noosphere;

###############################################################################
#
# GenericObject.pm
#
# This module is for handling of "generic" objects, the details of the metadata
# handling for each being only a slight variant of the other.  Currently books,
# papers, and expositions are handled here, since there is very little 
# difference in their metadata or the workflow surrounding them.
#
###############################################################################

use strict;

# add a generic object 
#
sub addGeneric {
	my $params = shift;
	my $userinf = shift;
	my $upload = shift;
	
	return errorMessage('Must be logged in to add to the collection!') if ($userinf->{uid} < 1);

	my $template = new XSLTemplate('addgeneric.xsl'); 
	my $table = $params->{to};
	my $error = ''; 

	my $isa = getIsA($table);
	my $section = getIsA($table, 1);

	$template->addText("<addgeneric section=\"$section\">");

	my @filelist = handleFileManager($template, $params, $upload); 

	if (defined $params->{post}) { 
		$error = checkAddGeneric($params, scalar @filelist); 
		
		if ($error eq '') { 
			my $uid = insertGeneric($params,$userinf);
			if ($uid == -1) {
				return errorMessage('Error inserting record. please contact an administrator.'); 
			} else { 
				return paddingTable(makeBox("$isa Added","Thank you for uploading your contribution.  To see it, click <a href=\"".getConfig("main_url")."/?op=getobj&from=$table&id=$uid\">here</a>.")) 
			} 
		} 
	} 
	
	$template->setKeysIfUnset(%$params); 
	$template->setKey('error', $error); 

	$template->addText('</addgeneric>');
	
	return paddingTable(clearBox("Add a $isa",$template->expand()));
}

# check to see if params are good for a potential object
# 
sub checkAddGeneric {
	my $params = shift;
	my $numfiles = shift;

	my $error = '';

	# check for lack of classification
	#
	if (getConfig('classification_supported') == 1) {

		if (blank($params->{'class'})) {
			$error .= "Please classify your entry.	If you need help, try using the <a href=\"".getConfig("main_url")."/?op=mscbrowse\">MSC search</a>.<br />";
		} else {
			my @errors = checkclass($params->{'class'});
			if (@errors) {
				$error .= join("<br />\n", @errors);
			}
		}
	}
	
	if ($params->{'title'} =~ /^\s*$/ ) {
		$error .= 'Need a title.<br />';
	}
	if ($params->{'data'} =~ /^\s*$/ ) { 
		$error .= 'Need an abstract.<br />'; 
	} 
	if ($params->{'authors'} =~ /^\s*$/ ) {
	   	$error .= 'Need at least one author.<br />'; 
	} 

	if ($params->{'to'} eq 'papers') {
		if ($numfiles == 0 && $params->{'urls'} =~ /^\s*$/ ) { 
			$error .= 'Need at least one link for home page of resource or uploaded file.<br />'; 
		} 
	} else {
		if ($params->{'urls'} =~ /^\s*$/ ) { 
			$error .= 'Need at least one link for home page of resource, or if not available, your source.<br />'; 
		} 
	}
	
	if ($params->{'rights'} =~ /^\s*$/ ) { 
		$error .= 'Need a rights statement.<br />'; 
	} 

	return $error;
}

# populate all of the sundry database tables for a new entry
# 
sub insertGeneric {
	my $params = shift;
	my $userinf = shift;

	my $table = $params->{to};

	my @schema = keys %{getConfig('generic_schema')->{$table}};

	# construct insert cols and vals
	# 
	my $cols = join (', ', @schema);
	my $vals = join (', ', (map { sqq($params->{$_}) } @schema));

	# get new id in main table row	
	#
	my $uid = nextval($table.'_uid_seq');

	# do the insert
	#
	my ($rv, $sth) = dbInsert($dbh, {
			INTO => $table,
			COLS => "created, modified, uid, userid, $cols",
			VALUES => "now(), now(), $uid, $userinf->{uid}, $vals"});

	$sth->finish();

	# classify
	#
	classify($table, $uid, $params->{class});

	# add ACL record
	# 
	#installDefaultACL($table, $uid, $userinf->{uid});
	add_author( $userinf->{'uid'} ,$uid, 'LA', $table );


	# take care of files
	#
	moveTempFilesToBox($params, $uid, $table);
	
	# handle scoring
	#
	my $scorekey = 'add'.$table;
	$scorekey =~ s/s$//;
	changeUserScore($userinf->{uid},getScore($scorekey));

	# new watch
	#
	addWatchIfAllowed($table, $uid, $userinf, 'objwatch');

	# title indexing
	#
	indexTitle($table, $uid, $userinf->{uid}, $params->{title}, '');

	# IR indexing
	#
	$params->{uid} = $uid;
	irIndex($table, $params);

	# update statistics
	#
	$stats->invalidate('unclassified_objects');
	$stats->invalidate('latestadds');

	return $uid;
}

# gets the intro screen ("lobby") to the generic object browsing section
# 
sub browseGeneric {
	my $params = shift;
	my $userinf = shift;

	my $template = new XSLTemplate('genericlobby.xsl');

	# get plural section descriptor
	#
	my $section = getIsA($params->{from}, 1);

	$template->addText("<genericlobby name=\"$section\" table=\"$params->{from}\">");
	
	# output data needed for "interact"
	#
	$template->addText("<genericinteract>");
	$template->addText("<name>$section</name><table>$params->{from}</table>");
	$template->addText("</genericinteract>");
	
	$template->addText('</genericlobby>');

	return $template->expand();
}

# listing of any generic object (chronologically)
# 
sub listGeneric {
	my $params = shift;
	my $userinf = shift;

	my $factor = 4;  # scale factor for the list size

	my $offset = $params->{offset} || 0;
	my $limit = int($userinf->{'prefs'}->{'pagelength'} / $factor);
	my $total = 0;

	my $template = new XSLTemplate('genericlist.xsl');

	# get total if we don't have it
	# 
	if (!$params->{total}) {
	    my ($rv,$sth) = dbLowLevelSelect($dbh,"select uid from $params->{from}");
    	$total = $sth->rows();
    	$sth->finish();
	} else {
		$total = $params->{total};
	}

	# query up the objects
	#
	my ($rv, $sth) = dbSelect($dbh, {WHAT=>'*', FROM=>$params->{from},
			'ORDER BY'=>'created', DESC=>'', LIMIT=>$limit, OFFSET=>$offset});
	
	my @rows = dbGetRows($sth);
		
	# format and output metadata
	# 
	my $name = getIsA($params->{from}, 1);
	$template->addText("<genericscreen>");
	$template->addText("<genericlist name=\"$name\" table=\"$params->{from}\">");
	# metadata should be formatted as:
	#
	#  <ord>1</ord>
	#  <title>Foo Bar</title>
	#  <id>1234</id>
	#  <username>LinusT</username>
	#  <userid>234</userid>
	#  <authors>Linus Torvalds</authors>
	#  <date>YYYY-MM-DD</date>
	#  <classification>msc:##A##</classification>

	my $ord = $offset + 1;
	foreach my $row (@rows) {

		my $date = ymd($row->{created});
		my $username = lookupfield(getConfig('user_tbl'), 'username', "uid=$row->{userid}");
		my $class = classstring($params->{from}, $row->{uid});

		$template->addText('<object>');

		$template->setKey('ord', $ord);
		$template->setKey('date', $date);
		$template->setKey('userid', $row->{userid});
		$template->setKey('username', $username);
		$template->setKey('authors', $row->{authors});
		$template->setKey('title',$row->{title});
		$template->setKey('id',$row->{uid});
		$template->setKey('classification',$class);

		$template->addText('</object>');

		$ord++;
	}

	# get the pager
	#
	$params->{offset} = $offset;
	$params->{total} = $total;

	getPageWidgetXSLT($template, $params, $userinf, $factor);

	$template->addText("</genericlist>");

	# output data needed for "interact"
	#
	$template->addText("<genericinteract>");
	$template->addText("<name>$name</name><table>$params->{from}</table>");
	$template->addText("</genericinteract>");

	# close the XML
	# 
	$template->addText("</genericscreen>");

	return $template->expand();
}

# rendering of any generic object
# 
sub renderGeneric {
	my $params = shift;
	my $userinf = shift;
	my $rec = shift;

	my $outertemplate = new Template('genericobj.html');
	my $template = new XSLTemplate('genericobj.xsl');

	my $interact = makeBox('Interact', getGenericInteract($params->{from}, $rec));

	$template->addText("<object>\n");

	# gather "scattered" information about this record
	#	 
	my $coverxml = getCoverImageXML($params->{from}, $params->{id});
	$template->addText($coverxml);
	
	my $filexml = getFileListXML($params->{from}, $params->{id});
	$template->addText($filexml);

	my $classhtml = printclass($params->{from}, $params->{id}, '-1');
	$template->setKey('classification', $classhtml);

	my @urls = split (/\s+/,$rec->{urls});
	if ($#urls >= 0) { 
		$template->addText('<links>');
		foreach my $url (@urls) { 
			$template->addText("<link>$url</link>");
		} 
		$template->addText('</links>');
	}

	# add the "core" information for this record
	# 
	$template->setKey('title', $rec->{title});
	$template->setKey('abstract', $rec->{data});
	$template->setKey('authors', $rec->{authors});
	$template->setKey('userid',$rec->{userid});
	$template->setKey('username',$rec->{username}); # by GetObj()
	$template->setKey('comments',$rec->{comments});
	$template->setKey('rights',activateLinks(htmlescape($rec->{'rights'})));
	$template->setKey('isbn',$rec->{isbn});
	
	$template->addText("</object>\n");
	
	my $isa = getIsA($params->{from});
	my $content = clearBox("$isa: $rec->{title}", $template->expand());

	# we're basically done, return the outer HTML template
	# 
	$outertemplate->setKey('admin', getGenericAdmin($params, $userinf, $rec));
	$outertemplate->setKey('interact', $interact);
	$outertemplate->setKey('content', $content);

	return $outertemplate;
}

# get admin controls for generic object
#
sub getGenericAdmin {
	my $params = shift;
	my $userinf = shift;
	my $rec = shift;

	my $html = '';

	return if ($userinf->{data}->{access} < getConfig('access_admin'));

	$html = "<center>
<a href=\"".getConfig("main_url")."/?op=adminedit&from=$params->{from}&id=$rec->{uid}\">edit metadata</a> |
<a href=\"".getConfig("main_url")."/?op=adminclassify&from=$params->{from}&id=$rec->{uid}\">classify</a> |
<a href=\"".getConfig("main_url")."/?op=delobj&from=$params->{from}&id=$rec->{uid}&ask=yes\">delete object</a>
		</center>";
	
	return adminBox('Admin controls', $html);
}

# get an object type "is-a" descriptor based on table
# 
sub getIsA {
	my $table = shift;
	my $plural = shift || 0;

	# TODO - have this use table descriptors?

	my $s = $plural ? 's' : '';

	return "Exposition$s" if ($table eq getConfig('exp_tbl'));
	return "Book$s" if ($table eq getConfig('books_tbl'));
	return "Paper$s" if ($table eq getConfig('papers_tbl'));
}

sub getCoverImageXML {
	my $table = shift;
	my $id = shift;

	my $xml = '';

	my $fileurl = getConfig('file_url');

	# go to the item's dir
	#
	my $cwd = chdirFileBox($table, $id) or return '';
	
	# output xml for cover image if it was included
	#
	my @cimage = <coverimage.*>; 
	if ($#cimage >= 0) { 
		my @bigimage = <coverimage_big.*>; 
			$xml .= "<imageurl>$fileurl/$table/$id/$cimage[0]</imageurl>";
		if ($#bigimage >= 0) { 
			$xml .= "<imagebigurl>$fileurl/$table/$id/$bigimage[0]</imagebigurl>";
		}
	}

	chdir $cwd;
	return $xml;
}

sub getGenericInteract {
	my $table = shift;
	my $rec = shift;

	return getExpInteract($rec) if ($table eq getConfig('exp_tbl'));
	return getBookInteract($rec) if ($table eq getConfig('books_tbl'));
	return getPaperInteract($rec) if ($table eq getConfig('papers_tbl'));
}

1;
