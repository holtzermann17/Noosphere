package Noosphere;

use strict;

# get a full msc comment for the given id and all categories above
#
sub getHierarchicalMscComment {
	my $id = shift;

	# leaf, but under a main -XX
	#
	if ($id =~ /([0-9]{2})-[0-9]{2}/) {
		return getShortMscCommentById("$1-XX").' :: '.
					 getShortMscCommentById($id);
	}

	# leaf under main/subcategory
	#
	if ($id =~ /([0-9]{2})([A-Z])[0-9]{2}/) {
		my $middle = getShortMscCommentById("$1$2xx");

		return getShortMscCommentById("$1-XX").' :: '.
					 (defined($middle)?$middle.' :: ':'').
					 getShortMscCommentById($id);
	}

	# others
	#
	return getShortMscCommentById($id);
}

# get math subject classification comment with no parens in it
#
sub getShortMscCommentById {
	my $comment = getMscCommentById(shift);

	return undef if (not defined $comment);

	$comment =~ s/\s*\(.*\)\s*/ /g;
	
	return $comment;
}

# get math subject classification comment by id
#
sub getMscCommentById {
	my $id = shift;

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'comment',
		FROM=>'msc',
		WHERE=>"id='$id'"});

	my $row = $sth->fetchrow_hashref();
	$sth->finish();

	return undef if (not defined $row);

	my $comment = $row->{'comment'};

	$comment =~ s/^\s*//;
	$comment =~ s/\s*$//;

	return $comment;
}

# search the MSC for a string
#
sub mscSearch {
	my $params = shift;
	
	my $html = '';

	my $term = $params->{'mscterm'} || '';
	my $leaves = $params->{'leaves'} ? $params->{'leaves'} : ($term ? 'off' : 'on');
	my $leafstatus = $leaves eq 'on' ? 'checked' : '';

	# display search form
	#
	$html .= "<h3>Search the 2000 MSC</h3>
		<center>
		<table border=\"0\"><td>
		<form action=\"/\" method=\"get\">						 
		<input type=\"hidden\" name=\"op\" value=\"mscsearch\">
		<input type=\"text\" name=\"mscterm\" value=\"$term\">
	<input type=\"submit\" value=\"search\">
	<br>
	<font size=\"-2\">(case insensitive substrings, use '-' to exclude)</font>
	<br><br>
		<input type=\"checkbox\" name=\"leaves\" $leafstatus> leaves only
	</form>
		<td></table>
	</center>";

	# do a search, append results
	#
	if ($term) {
		$html .= "<hr>";

		my $results = doMscSearch($term, $leaves);

		if (scalar @$results) {
			foreach my $row (@$results) {
				my $linkto = (defined $row->{'parent'}) ? "id=$row->{parent}" : '';

				$html .= "&nbsp;<b><font face=\"monospace\" size=\"+1\"><a href=\"".getConfig("main_url")."/?op=mscbrowse&$linkto\">$row->{id}</a></font></b> - $row->{comment}<br>";
			}
		}
		else {
			$html .= "Nothing found.";
		}
	}	
	
	$html .= "<br>";

	return paddingTable(clearBox('MSC Search',$html));
}

# do the MSC search with the database
#
sub doMscSearch {
	my $query = shift;
	my $leaves = shift || 'on';

	my @terms = split(/\s+/,latin1ToHtml($query));
	my $searchterm = join (' and ',map(($_=~/^-(.+)$".getConfig("main_url")."/?"not comment like '\%$1\%'":"comment like '\%$_\%' or id='$_'") ,@terms));
	my $leafq = $leaves eq 'on' ? "and not id like '\%X\%'" : "";
	
	my $sth = $dbh->prepare("select id, comment, parent from msc where $searchterm $leafq  order by id asc");
	$sth->execute();

	my @results;

	while (my $row = $sth->fetchrow_hashref()) {
		push @results, $row;
	}

	$sth->finish();
	
	return [@results];
}


# the generic MSC browser; this can be used to either browse the MSC structure
#	itself, or the set of objects within MSC categories in a particular table.
#
sub mscBrowse {
	my $params = shift;

	my $types = $params->{'types'};
	my $id = $params->{'id'};
	my $domain = $params->{'from'} || 'categories';

	my $tags = $params->{'tags'} || '';

	my $tdesc = $domain ne 'categories' ? tabledesc($domain) : '';
	my $scheme = 'msc';
	my $class = getConfig('class_tbl');
	my $clinks = getConfig('clinks_tbl');
	my $showempty = $params->{'showempty'} eq 'on' ? 1 : 0;
	my $template = new XSLTemplate('mscbrowse.xsl');
	
	my $rv;
	my $sth;

	$template->addText('<mscset>');
	$template->addText("<tdesc domain=\"$domain\" showempty=\"$showempty\">$tdesc</tdesc>") if ($tdesc);

	# top level
	#
	if(not(defined($id))) {
		if ($domain ne 'categories') {

	my $q = "select $scheme.id, $scheme.uid, $scheme.comment from $scheme where $scheme.id like '%-XX' order by $scheme.id";

			($rv, $sth) = dbLowLevelSelect($dbh, $q);
		} else {
			($rv, $sth) = dbLowLevelSelect($dbh, "select $scheme.id, $scheme.comment from $scheme where ($scheme.id like '%-XX') order by $scheme.id");
		}

		my @rows = dbGetRows($sth);

		foreach my $row (@rows) {

	my $schemeid = $row->{'uid'};
	#now get all the objects under this class that have the necessary tags
	my $tagq = "select distinct tags.objectid as objectid from $scheme, $class, $clinks, tags where tags.objectid=$class.objectid and tags.tag = 'NS:published' and ($scheme.id = '$row->{id}') and $clinks.a = $scheme.uid and $class.catid = $clinks.b and $class.nsid = $clinks.nsb and $class.tbl = '$domain'";
	warn "executing $tagq";
	my ($rv, $objectsth) = dbLowLevelSelect($dbh, $tagq);
	my @objects = dbGetRows($objectsth);
	my $count = 0;
	my @tagarray = split( /\s*,\s*/, $tags );
	warn "about to check tags stuff";
	foreach my $o ( @objects ) {
		if ( $tags ) {
			warn "checking $o->{objectid}";
			if (hasTags($domain, $o->{'objectid'}, \@tagarray)) {
				$count++;
			}
		} else {
			$count++;
		}
	}
			if ( not $showempty and $count == 0 ) {
				next;
			}
			my $child = lookupfield($scheme, 'id', "parent='$row->{id}'");
			#we have to do the count here
			$template->addText('<mscnode>');
		
			$template->addText("<haschild />") if ($child);
			$template->addText("<tags>$tags</tags>");
			$template->addText("<domain>$domain</domain>");
			$template->addText("<id>$row->{id}</id>");
			$template->addText("<count>$count</count>") if ($domain ne 'categories');
			my $comment = latin1ToUTF8(htmlToLatin1($row->{comment}));
			$template->addText("<comment>$comment</comment>");
			$template->addText('</mscnode>');
		}
	}

	# ##-XX level / ##Cxx level
	#
	elsif ($id =~ /XX$/io) {

		
		if ($domain ne 'categories') {

	#build up the rows
	my $q = "select $scheme.id, $scheme.uid, $scheme.comment from $scheme where $scheme.parent = '$id' order by $scheme.id";


			($rv, $sth) = dbLowLevelSelect($dbh, $q);
		} else {
			($rv, $sth) = dbLowLevelSelect($dbh, "select $scheme.id, $scheme.comment from $scheme where $scheme.parent = '$id' order by $scheme.id");
		}

		my @rows = dbGetRows($sth);
		my $desc = getHierarchicalMscComment($params->{'id'});

		my $upid = lookupfield($scheme, 'parent', "id='$id'");
		my $upstr = (defined $upid ? "$upid/" : '');

		$template->addText("<parent href=\"".getConfig("main_url")."/browse/$domain/$upstr\">");
		$template->addText("<id>$params->{id}</id><desc>$desc</desc>");
		$template->addText('</parent>');
	
		foreach my $row (@rows) {

	my $schemeid = $row->{'uid'};
	#now get all the objects under this class that have the necessary tags
	my $tagq = "select distinct tags.objectid as objectid from $scheme, $class, $clinks, tags where tags.objectid=$class.objectid and tags.tag = 'NS:published' and ($scheme.parent = '$id') and $clinks.a = $scheme.uid and $class.catid = $clinks.b and $class.nsid = $clinks.nsb and $class.tbl = '$domain' and $class.catid = '$schemeid'";
	warn "executing $tagq";
	my ($rv, $objectsth) = dbLowLevelSelect($dbh, $tagq);
	my @objects = dbGetRows($objectsth);
	my $count = 0;
	my @tagarray = split( /\s*,\s*/, $tags );
	warn "about to check tags stuff";
	foreach my $o ( @objects ) {
		warn "checking $o->{objectid}";
		if (hasTags($domain, $o->{'objectid'}, \@tagarray)) {
			$count++;
		}	
	}
	# $domain contains the table name
		#	my $count = 0;
		#	$count = $row->{'cnt'} if ($domain ne 'categories');
			$count = 0 if ($domain eq 'categories');

			if ( not $showempty and $count == 0 ) {
				next;
			}

			my $child = lookupfield($scheme, 'id', "parent='$row->{id}'");
			
			$template->addText('<mscnode>');
			$template->addText("<domain>$domain</domain>");
			$template->addText("<tags>$tags</tags>");
			$template->addText("<haschild />") if ($child);
			$template->addText("<id>$row->{id}</id>");
			$template->addText("<count>$count</count>") if ($domain ne 'categories');
			my $comment = latin1ToUTF8(htmlToLatin1($row->{comment}));
			$template->addText("<comment>$comment</comment>");
			$template->addText('</mscnode>');
		}
	}
	
	# leaf level
	#
	else {
		($rv, $sth) = dbLowLevelSelect($dbh, 
		"select $scheme.id, $scheme.comment, $domain.title, $domain.uid, users.username, users.uid as userid " .
		"from $scheme, $class, $domain, users, tags where tags.objectid=$domain.uid and tags.tag = 'NS:published' and $scheme.id = '$id' and " .	"$class.tbl = '$domain' and $class.catid = $scheme.uid and " .
		"$domain.uid = $class.objectid and users.uid = $domain.userid order by lower($domain.title)");
		my @rows = dbGetRows($sth);
		my $desc = getHierarchicalMscComment($params->{id});

		my $upid = lookupfield($scheme, 'parent', "id='$id'");

		$template->addText("<parent href=\"".getConfig("main_url")."/browse/$domain/$upid/\">");
		$template->addText("<id>$params->{id}</id><desc>$desc</desc>");
		$template->addText('</parent>');
		foreach my $row (@rows) {
			if ( $tags ) {
				my @tagarray = split( /\s*,\s*/, $tags);
				if ( not hasTags($domain, $row->{'uid'}, \@tagarray)) {
					next;
				}	
				
			}
			my @authors = get_authors($row->{'uid'});
			$template->addText('<mscleaf>');
			$template->addText("<domain>$domain</domain>");
			$template->addText("<tags>$tags</tags>");
			$template->addText("<id>$row->{uid}</id>");
			
			my $title = mathTitleXSL($row->{'title'}, 'highlight');
			$template->addText("<title>$title</title>");
			
			foreach my $a (@authors) {
				$template->addText("<owner href=\"".getConfig("main_url")."/?op=getuser;id=$a\">". getUserDisplayName($a) . "</owner>");
			}
			$template->addText('</mscleaf>');
		}
	}

	if ( $tags ne '' ){
		$template->addText("<taglist>$tags</taglist>");
		$template->addText("<message>Displaying all articles with tags = $tags</message>");
	}

	$template->addText('</mscset>');
	return paddingTable($template->expand());
}

1;
