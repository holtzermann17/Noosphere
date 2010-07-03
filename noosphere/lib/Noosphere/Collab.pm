package Noosphere;
use strict;

require Noosphere::Util;

sub getCollabObjList {
	my $userinf = shift;
	my $where = shift; # something like "sitedoc = 1", "sitedoc = 0", etc

	my $xml = "";

	my $collab = getConfig('collab_tbl');

	my $q = "select * from $collab where $where";
	my $sth = $dbh->prepare($q);
	$sth->execute();

	while (my $row = $sth->fetchrow_hashref()) {

		$xml .= '	<docitem>';

		$xml .= "		<uid>$row->{uid}</uid>";
		$xml .= "		<title>".htmlescape($row->{'title'})."</title>";

		if (defined $row->{'abstract'}) {
			my $ab = $row->{'abstract'};
			$ab =~ s/\s+/ /gs;
			$xml .= "		<abstract>".htmlescape($ab)."</abstract>";
		}
		
		# need to get lastedit information 
		#
		my $edits = getConfig('author_tbl');
		my $sth2 = $dbh->prepare("select userid, ts from $edits where tbl='$collab' and objectid=$row->{uid} order by ts desc limit 1");
		$sth2->execute();
		my $lastedit = $sth2->fetchrow_hashref();
		$sth2->finish();

		if (defined $lastedit) {
			my $lastwhen = mdhm($lastedit->{'ts'});
			my $lastuser = lookupfield(getConfig('user_tbl'), 'username', "uid=$lastedit->{userid}");

			$xml .= "		<lastedit>";
			$xml .= "			<who>$lastuser</who>";
			$xml .= "			<when>$lastwhen</when>";
			$xml .= "		</lastedit>";
		}

		my $owner = lookupfield(getConfig('user_tbl'), 'username', "uid=$row->{userid}");
		$xml .= "		<ownername>$owner</ownername>";
		$xml .= "		<owner>1</owner>" if $row->{'userid'} == $userinf->{'uid'};

		$xml .= '	</docitem>';
	}

	return $xml;
}

# collaborative site documentation center.
#
sub siteDoc {
	my $params = shift;
	my $userinf = shift;

	my $template = new XSLTemplate('sitedoc.xsl');

	$template->addText('<sitedoc>');

	$template->addText("	<loggedin>1</loggedin>") if $userinf->{'uid'} > 0;

	# get a list of collaborations that are site docs and are publicly 
	# *writeable*
	#
	my $collab = getConfig('collab_tbl');
	my $acl = getConfig('acl_tbl');
	my $sth = $dbh->prepare("select objectid from $acl where tbl='$collab' and _write = 1 and user_or_group = 'u' and default_or_normal = 'd'");
	$sth->execute();

	my @uids = (-1);	# so the "in ($list)" statement is always valid 

	while (my $row = $sth->fetchrow_arrayref()) {
		push @uids, $row->[0];
	}
	$sth->finish();

	my $uidlist = join(', ', @uids);
	
	# get the intersection of the above list of IDs and the collaborations
	# that are site docs
	#
	my $xml = getCollabObjList($userinf, "sitedoc = 1");
	$template->addText($xml);

	$template->addText('</sitedoc>');

	return $template->expand();
}

# display main collab screen, show's your collaborations, and collaborations
# you have permissions to edit.
#
sub collabMain {
	my $params = shift;
	my $userinf = shift;

	my $template = new XSLTemplate('collabmain.xsl');

	$template->addText('<collabmain>');

	my $collab = getConfig('collab_tbl');
  
	my $glist = join(', ', getMemberGroupIDs($userinf->{'uid'}));

	# get a list of collaborations this user doesn't own but can edit
	#
	my $acl = getConfig('acl_tbl');
	my $sth = $dbh->prepare("select objectid from $acl where tbl='$collab' and _write = 1 and ((user_or_group = 'u' and default_or_normal = 'n' and subjectid = $userinf->{uid}) or (user_or_group = 'g' and default_or_normal = 'n' and subjectid in ($glist)) or (default_or_normal = 'd'))");
	$sth->execute();

	my @uids = (-1);	# so the "in ($list)" statement is always valid 

	while (my $row = $sth->fetchrow_arrayref()) {
		push @uids, $row->[0];
	}
	$sth->finish();

	my $uidlist = join(', ', @uids);

	# get all collaborations this user can see
	#
	my $q = "select * from $collab where userid=$userinf->{uid} or uid in ($uidlist)";
	$sth = $dbh->prepare($q);
	$sth->execute();

	$template->setKey('thisuser',$userinf->{'uid'});

	while (my $row = $sth->fetchrow_hashref()) {

		$template->addText('	<collab>');

		$template->addText("		<uid>$row->{uid}</uid>");
		$template->addText("		<title>".htmlescape($row->{'title'})."</title>");
		$template->addText("		<sitedoc>$row->{sitedoc}</sitedoc>");

		if (defined $row->{'abstract'}) {
			my $ab = $row->{'abstract'};
			$template->addText("		<abstract>".htmlescape($ab)."</abstract>");
		}

		# need to get locked information and output (locked/who, locked/since)
		#
		if ($row->{'_lock'}) {
			my $locktime = mdhm($row->{'locktime'});
			my $lockuser = lookupfield(getConfig('user_tbl'), 'username', "uid=$row->{lockuser}");

			$template->addText('		<lock>');
			$template->addText("			<who>$lockuser</who>");
			$template->addText("			<userid>$row->{lockuser}</userid>");
			$template->addText("			<since>$locktime</since>");
			$template->addText('		</lock>');
		}

		# need to get lastedit information 
		#
		my $edits = getConfig('author_tbl');
		my $sth2 = $dbh->prepare("select userid, ts from $edits where tbl='$collab' and objectid=$row->{uid} order by ts desc limit 1");
		$sth2->execute();
		my $lastedit = $sth2->fetchrow_hashref();
		$sth2->finish();

		if (defined $lastedit) {
			my $lastwhen = mdhm($lastedit->{'ts'});
			my $lastuser = lookupfield(getConfig('user_tbl'), 'username', "uid=$lastedit->{userid}");

			$template->addText("		<lastedit>");
			$template->addText("			<who>$lastuser</who>");
			$template->addText("			<when>$lastwhen</when>");
			$template->addText("		</lastedit>");
		}

		# output information contingent on owner and access rights
		#
		my $owner = $row->{'userid'} == $userinf->{'uid'} ? 1 : 0;
		my $acl = 0;
		if ($owner) {
			$template->addText("		<owner>1</owner>");
			$template->addText("		<acl>1</acl>");
			$acl = 1;
		} else {

			my $owner = lookupfield(getConfig('user_tbl'), 'username', "uid=$row->{userid}");
			$template->addText("		<ownername>$owner</ownername>");
			
			# check for ACL
			my $permissions = getPermissions($collab, $row->{'uid'}, $userinf);	
			if ($permissions->{'acl'}) {
				$template->addText("		<acl>1</acl>");
				$acl = 1;
			}
		}

		# published flag
		#
		$template->addText("		<published>$row->{published}</published>");

		# published URL
		#
		my $puburl = getConfig('main_url')."/?op=getobj&amp;from=$collab&amp;id=$row->{uid}";
		$template->addText("		<url>$puburl</url>") if $row->{'published'};

		# output menu data.  the logic behind this is too messy to put into
		# the XSL and still be able to do even delimeters.
		#
		my @menu;
		push @menu, {url=>getConfig('main_url')."/?op=edit&amp;from=$collab&amp;id=$row->{uid}", anchor=>"edit document", tooltip=>"Edit this document."};
		push @menu, {url=>getConfig('main_url')."/?op=edit&amp;from=$collab&amp;id=$row->{uid}&amp;lock=1", anchor=>"edit (with lock)", tooltip=>"Edit this document, placing a lock on it.  Prevents simultaneous changes."};
		push @menu, {url=>getConfig('main_url')."/?op=collab_edit_comment&amp;id=$row->{uid}", anchor=>"edit comment", tooltip=>"Change the comment that displays for the collaboration on this page."} if $owner;
		push @menu, {url=>getConfig('main_url')."/?op=delobj&amp;from=$collab&amp;id=$row->{uid}&amp;ask=yes", anchor=>"delete", tooltip=>"Delete this collaboration."} if $owner;
		push @menu, {url=>getConfig('main_url')."/?op=vbrowser&amp;from=$collab&amp;id=$row->{uid}", anchor=>"revision history", tooltip=>"View the revision history of this collaboration.  You can roll back changes here, as well."};
		push @menu, {url=>getConfig('main_url')."/?op=acledit&amp;from=$collab&amp;id=$row->{uid}", anchor=>"modify access", tooltip=>"Set and change access rules to this collaboration (add co-authors here)."} if $acl;

		push @menu, {url=>getConfig('main_url')."/?op=collab_publish&amp;id=$row->{uid}&amp;ask=yes", anchor=>"publish", tooltip=>"Make the collaboration viewable to others.  Also gives a 'published' URL."} if (!$row->{'sitedoc'} && !$row->{'published'} && $owner);

		$template->addText("		<menu>");
		foreach my $item (@menu) {
			$template->addText("			<item>");
			$template->addText("				<url>$item->{url}</url>");
			$template->addText("				<tooltip>$item->{tooltip}</tooltip>");
			$template->addText("				<anchor>$item->{anchor}</anchor>");
			$template->addText("			</item>");
			$template->addText();
		}
		$template->addText("		</menu>");
		
		$template->addText('	</collab>');
	}

	$sth->finish();

	$template->addText('</collabmain>');

	return $template->expand();
}

# display a collaboration document
# 
sub renderCollab {
	my $rec = shift;
	my $params = shift;
	my $userinf = shift;
 
	my $method = $params->{'method'} || $userinf->{'prefs'}->{'cmethod'};
	my $template = new XSLTemplate('collab.xsl');

	my $table = getConfig('collab_tbl');

	# get the data for the collab
	#
	my $content = getRenderedContentHtml($params, $table, $rec, $method);

	my $ownername = lookupfield(getConfig('user_tbl'), 'username', "uid=$rec->{userid}");

	my $acount = getAuthorCount($table,$rec->{'uid'});
	my $ocount = getPastOwnerCount($table,$rec->{'uid'});

	#push @links, "<a href=\"".getConfig("main_url")."/?op=authorlist&amp;from=$en&amp;id=$rec->{uid}\">full author list</a> ($acount)" if $acount > 1;
	#push @links, "<a href=\"".getConfig("main_url")."/?op=ownerhistory&amp;from=$en&amp;id=$rec->{uid}\">owner history</a> ($ocount)" if $ocount > 0; 

	# output the data
	#
	$template->addText('<collab>');
	$template->addText("	<content>$content</content>");

	my $viewstyle = getViewStyleWidget($params,$method);
	$template->setKey('viewstyle', $viewstyle);

	my $watchwidget = getWatchWidget($params,$userinf);
	$template->setKey('watchwidget', $watchwidget);
	
	$template->setKey('ownername', $ownername);
	$template->setKey('author_count', $acount);
	$template->setKey('owner_count', $ocount);

	$template->setKeys(%$rec);

	$template->addText('</collab>');

	$template->expand();

	my $outertemplate = new Template('collabobj.html');

	$outertemplate->setKey('collab', $template->expand());

	$outertemplate->setKey('interact', makeBox('Interact',getCollabInteract($rec)));

	return $outertemplate;
}

# "toggle" a collaboration to published; makes it world-readable, toggles 
# published flag in the main record
#
sub publishCollab {
	my $params = shift;
	my $userinf = shift;

	my $table = getConfig('collab_tbl');

	# confirmation stage
	#
	if (defined $params->{'ask'}) {

		my $template = new XSLTemplate('collab_publish_confirm.xsl');
			
		$template->addText("<collab_publish_confirm>");
		$template->setKey('id', $params->{'id'});
		$template->addText("</collab_publish_confirm>");

		return $template->expand();
	}

	# otherwise make the changes to the record's ACL and the published flag
	#
	my $acl = getConfig('acl_tbl');
	$dbh->do("update $acl set _read = 1 where objectid=$params->{id} and tbl='$table' and default_or_normal = 'd'");

	$dbh->do("update $table set published=1 where uid=$params->{id}");

	# make the collab's messages visible
	#
	revealMessages($table, $params->{'id'});

	$params->{'op'} = 'collab';
	return collabMain($params, $userinf);
}

# release a lock on a collaboration
#
sub collabReleaseLock {
	my $params = shift;
	my $userinf = shift;

	my $table = getConfig('collab_tbl');

	my ($lock, $lockuser) = lookupfields($table, '_lock, lockuser', "uid=$params->{id}");

	# handle error conditions
	#
	return errorMessage("There is no lock on that object!") if (!$lock);
	return errorMessage("You don't hold a lock on that object!") if ($lockuser != $userinf->{'uid'});

	# otherwise, release the lock and return the user to collabmain
	#
	$dbh->do("update $table set _lock=0 where uid=$params->{id}");

	$params->{'op'} = 'collab';
	return collabMain($params, $userinf);
}

# edit collaboration comment (this is separate from editing the document)
#
sub editCollabComment {
	my $params = shift;
	my $userinf = shift;

	my $table = getConfig('collab_tbl');
	my $template;

	my ($title, $abstract) = lookupfields($table, 'title, abstract', "uid=$params->{id}");

	if (defined $params->{'save'}) {
		$template = new XSLTemplate('collab_comment_updated.xsl');

		my $sth = $dbh->prepare("update $table set abstract=? where uid=$params->{id}");
		$sth->execute($params->{'abstract'});
		$sth->finish();

		$template->addText('<commentupdated>');
		$template->setKey('id', $params->{'id'});
		$template->setKey('from', $table);
		$template->setKey('title', $title);
		$template->addText('</commentupdated>');

	} else {
		$template = new XSLTemplate('collab_edit_comment.xsl');
	
		$template->addText('<editcomment>');
		$template->setKey('abstract', $abstract);
		$template->setKey('title', $title);
		$template->setKey('id', $params->{'id'});
		$template->addText('</editcomment>');
	}

	return $template->expand();
}

# edit a collaboration document
#
sub editCollab {
	my $params = shift;
	my $userinf = shift;
	my $upload = shift;
	my $rec = shift;

	my @errors;
	my $table = getConfig('collab_tbl');

	return loginExpired() if ($userinf->{'uid'} <= 0);

	my $rec;	# database record, if we're updating

	if (!$params->{'new'}) {
		return errorMessage("You dont have permission to edit that object!") unless (is_admin($userinf->{'uid'}));

		# grab the object
		#
		my ($rv,$sth) = dbSelect($dbh,{WHAT=>'*', FROM=>$params->{'from'}, WHERE=>"uid=$params->{id}"});

		$rec = $sth->fetchrow_hashref();
		$sth->finish();
	}

	my $template = new XSLTemplate('editcollab.xsl');
	$template->addText('<editcollab>');

	my $mode = 'edit';	# default mode

	# handle locking
	#
	if (defined $params->{'lock'}) {
		if ($rec->{'_lock'}) {
			return errorMessage("That object is currently locked.");
		}

		# set a lock
		#
		$dbh->do("update $table set _lock=1, locktime=now(), lockuser=$userinf->{uid} where uid=$params->{id}");
	}
	
	# handle preview
	#
	if (defined $params->{'preview'}) {
		$AllowCache = 0;

		my @errors = checkCollab($params, $userinf);

		if (!@errors) {
			my $pcontent = renderCollabPreview($params, $userinf->{'prefs'}->{'cmethod'} || 'png') || '';
			$template->addText('	<preview>');
			$template->addText("		<content>$pcontent</content>");
			$template->addText('	</preview>');
		
			$mode = 'preview';
		} 

		$template->setKeys(%$params);
	} 

	# handle file manager 
	#
	elsif (defined $params->{'filebox'}) {
		
		handleFileManager($template, $params, $upload);

		$template->setKeys(%$params);
		$mode = 'filebox';
	}
	
	# handle edit
	#
	elsif (defined $params->{'edit'}) {

		$template->setKeys(%$params);
	}

	# submit 
	#
	elsif (defined $params->{'save'}) {
		
		@errors = checkCollab($params, $userinf);

		if (!@errors) {
			
			if ($params->{'new'}) {
				return insertCollab($params, $userinf);
			} else {
				# try to get the user to enter a revision comment
				#
				if (not defined $params->{'revcomment'}) {
					$mode = 'update';
				} else {
					return updateCollab($params, $userinf);
				}
			}
		}

		$template->setKeys(%$params);
	}

	# abort
	#
	elsif (defined $params->{'abort'}) {

		# give up any lock there might be
		#
		$dbh->do("update $table set _lock=0 where uid=$params->{id}");
		
		# return to collab main page
		#
		$params->{'op'} = 'collabmain';
		return collabMain($params, $userinf);
	}

	# init form
	#
	else {

		if (!$params->{'new'}) {
			$template->setKeys(%$rec) if (!$params->{'new'});
			copyBoxFilesToTemp($table, $params); # also makes temp dir
		} else {
    		$params->{'tempdir'} = makeTempCacheDir();
		}

		$template->setKeys(%$params);
	}

	# output errors
	#
	if (@errors) {
		$template->addText('	<feedback>');

		foreach my $item (@errors) {
			$template->addText("		<item>$item</item>");
		}

		$template->addText('	</feedback>');
		
		$mode = 'edit';
	}
	
	$template->setKey('mode', $mode);

	$template->addText('</editcollab>');

	return $template->expand();
}

# check collaboration metadata for problems
#
sub checkCollab {
	my $params = shift;
	my $userinf = shift;

	my @errors;

	# metadata consistency
	#
	if (!$params->{'data'}) {
		push @errors, "Document is empty!"
	}
	
	if (!$params->{'title'}) {
		push @errors, "A title is required.";
	}
	
	# concurrency
	#
	my $dbversion = lookupfield(getConfig('collab_tbl'), 'version', "uid=$params->{id}");
	if ($params->{'version'} < $dbversion) {
		push @errors, "Someone else has checked in a more recent copy of this document! To resolve any possible revision conflicts, you should open up a new edit window for it, integrate the new source with the current source you are working on, and check in the new version.   In the future, if you plan on having long checkouts or expect frequent contention, then you may want to check out the document with a lock.";
	}

	my $lock = lookupfield(getConfig('collab_tbl'), '_lock', "uid=$params->{id}");
	my $lockuser = lookupfield(getConfig('collab_tbl'), 'lockuser', "uid=$params->{id}");

	if ($lock && $lockuser != $userinf->{'uid'}) {
		push @errors, "It appears that someone else has checked out the document and placed a lock on it.  This means you will not be able to commit any changes until after they release the lock.  At this point, to resolve any possible revision conflicts, you should open up a new edit window for the document, integrate the new source with the current source you are working on, and check in the new version.  If you expect frequent contention in the future, you may also want to check out the document with a lock.";
	}

	return @errors;
}

# rendering subroutine-- returns HTML content of the render output
#
sub renderCollabPreview {
	my $params = shift;
	my $method = shift;
	
	my $dir = '';
	my $root = getConfig('cache_root');
	my $name = normalize($params->{'title'});
 
	# figure out cache dir. it really should already exist for us.
	#
	if (defined $params->{'tempdir'}) {
		$dir = $params->{'tempdir'};
	} else {
		$dir = makeTempCacheDir();
		$params->{'tempdir'} = $dir;
	}
 
	# copy files from main dir to method subdir
	#
	if (not -e "$root/$dir/$method") {
		mkdir "$root/$dir/$method";
	}
	chdir "$root/$dir";
	my @files = <*>;
	my @methoddirs = getMethods();
	foreach my $file (@files) {
		if (not inset($file,@methoddirs)) {
			`cp $file $method`;
		}
	}
	chdir "$root";
	
	# remove old rendering file if it exists
	#
	my $outfile = getConfig('rendering_output_file');
	if (-e "$root/$dir/$method/$outfile") {
		`rm $root/$dir/$method/$outfile`;
	}
	
	my $table = getConfig('collab_tbl');
	renderLaTeX('.', $dir, $params->{'data'}, $method, $name);
	
	# if we succeeded, get preview output preview
	#
	my $file = "$root/$dir/$method/$outfile";
	my $size = (stat($file))[7];
	# What is going on here???
	#if ( defined($size) && $size > 0 ) {
		my $preview = readFile($file);
		return $preview;
	#} 
}

# add a new collaboration record to the database
#
sub insertCollab {
	my ($params, $userinf) = @_;

	my $table = getConfig('collab_tbl'); 
	my $nextid = nextval("${table}_uid_seq");
	
	my $sth = $dbh->prepare("insert into $table (uid, userid, title, abstract, data, _lock, created, modified) values (?, ?, ?, ?, ?, 0, now(), now())");

	my $rv = $sth->execute($nextid, $userinf->{'uid'}, $params->{'title'}, $params->{'abstract'}, $params->{'data'});

	if (! $rv) {
		return errorMessage("Couldn't insert your document!");
	}
	
	$params->{'id'} = $nextid;

	# take care of files
	#
	moveTempFilesToBox($params, $params->{'id'}, $table);

	# new watch on the object
	#
	addWatchIfAllowed($table, $params->{'id'}, $userinf,'objwatch');
	
	# add an ACL record
	#
	installDefaultACL($table, $params->{'id'}, $userinf->{'uid'});

	# add the user to the author list
	#
	addAuthorEntry($table, $params->{'id'}, $userinf->{'uid'});

	# add to object index
	#
	my $name = uniquename($params->{'title'});
	indexTitle($table,$params->{'id'},$userinf->{'uid'},$params->{'title'},$name);
	# hack to make the collab invisible
	my $index = getConfig('index_tbl');
	$dbh->do("update $index set type = 3 where tbl='$table' and objectid=$params->{id}");

	# handle scoring
	#
	changeUserScore($userinf->{uid},getScore('addgloss'));

	# new watch on the object
	#
	addWatchIfAllowed($table,$params->{'id'},$userinf,'objwatch');
	

	my $template = new XSLTemplate('editcollab_added.xsl');

	$template->addText('<editcollab_added>');
	$template->setKeys(%$params);
	$template->addText('</editcollab_added>');

	return $template->expand();
}

# update an existing collaboration record.  also makes a disk XML snapshot.
#
sub updateCollab {
	my ($params,$userinf) = @_;

	my $table = getConfig('collab_tbl'); 
	
	# save a snapshot of the current version!
	#
	my $rec = getrow($table, '*', "uid=$params->{id}");
	snapshot($table, $rec->{'uid'}, "Collab$rec->{uid}_$rec->{version}", $userinf->{'uid'}, $params->{'revcomment'});
 
	# update in-table version
	#
	my $sth = $dbh->prepare("update $table set title=?, data=?, _lock=0, modified=now(), version=version+1 where uid=$params->{id}");
	my $rv = $sth->execute($params->{'title'}, $params->{'data'});

	if (! $rv) {
		return errorMessage("Couldn't update your document!");
	}

	# move back temp files
	#
	moveTempFilesToBox($params, $params->{'id'}, $table);
	
	# update author list
	#
	updateAuthorEntry($table,$params->{'id'},$userinf->{'uid'});

	# send out notice that the object was modified
	#
	updateEventWatches($params->{'id'}, $params->{'from'}, $userinf->{'uid'}, 
		$params->{'revcomment'}, "document edited");

	# invalidate cache
	#
	setvalidflag_off($params->{'from'},$params->{'id'});
	setbuildflag_off($params->{'from'},$params->{'id'});

	# TODO: add a watch to the object for this editor if they have the
	# preference set

	# output feedback for this operation
	#
	my $template = new XSLTemplate('editcollab_updated.xsl');

	$template->addText('<editcollab_updated>');
	$template->setKeys(%$params);
	$template->addText('</editcollab_updated>');

	return $template->expand();
}

# apply a snapshot version of collaboration object to the database
#
sub insertCollabSnapshot {
	my $params = shift;
	
	my $table = getConfig('collab_tbl');

	my ($rv,$sth);

	# update the object
	#
	my $update = "update $table set version=?, title=?, data=?, modified=? where uid=$params->{uid}";

	$sth = $dbh->prepare($update);

	$rv = $sth->execute($params->{'version'}, $params->{'title'}, $params->{'data'}, $params->{'modified'});
	
	$sth->finish();
	
	return 1;
}

1;
