package Noosphere;

use strict;

use Noosphere::Tags;

# this is the main object editor entry point now
#
sub genericEditor {
	my $params = shift;
	my $userinf = shift;
	my $upload = shift;
	
	my $template = new Template('genericedit.html');
	my $schemas = getConfig('generic_schema');
	my $schema = $schemas->{$params->{from}};

	my $error = '';

	# pull up the object's record
	#
	my $rec;
	if (!$params->{'new'}) {
		return errorMessage("You can't edit that object!") unless ( 
			$userinf->{'data'}->{'access'} >= getConfig('access_admin') 
			|| is_EA($params->{id}, $userinf->{uid}) 
			|| is_EB( $userinf->{uid}) 
			|| is_LA( $params->{'id'}, $userinf->{'uid'} ) 
			|| is_CA( $params->{'id'}, $userinf->{'uid'} ) 
			);
	
		my ($rv,$sth) = dbSelect($dbh,{WHAT=>'*',FROM=>$params->{'from'},WHERE=>"uid=$params->{id}"});
		$rec = $sth->fetchrow_hashref();
		$sth->finish();
		
		my $tags = getTags( $params->{'from'} , $params->{'id'} );
		$rec->{'tags'} = join(', ', keys( %$tags ));
	}
	
	# encyclopedia has a different editor
	#
	if ($params->{'from'} eq getConfig('en_tbl')) {
		return editEncyclopedia($params, $userinf, $upload, $rec);
	}

	# collaborations has a different editor
	#
	if ($params->{'from'} eq getConfig('collab_tbl')) {
		return editCollab($params, $userinf, $upload, $rec);
	}

	# handle post
	#
	if (defined $params->{post}) {
		return updateObjectMetadata($schema,$params,$userinf,$rec);
	}

	# file box command	
	elsif (defined $params->{filebox}) {
		 # just refresh
	} 

	# set some initial stuff
	#
	else {
		$template->setKey('class', classstring($params->{from},$params->{id}));
	}
	
	$template->setKeysIfUnset(%$params);
	my $editor = getMetadataEditor($params,$schema,$rec);
	handleFileManager($template,$params,$upload);
	$template->setKeys('error' => $error, 'editor' => $editor);
	
	return paddingTable(clearBox('Editing Object',$template->expand()));
}

# editEncylopedia - entry point for editing encyclopedia object
#
sub editEncyclopedia {
	my $params = shift;
	my $userinf = shift;
	my $upload = shift;
	my $rec = shift;
	
	my $template = new XSLTemplate('editencyclopedia.xsl');
	my $error = '';
	my $warn = '';
	my $table = getConfig('en_tbl');
 
	$template->addText('<entry>');
	my $tagstring = getNSTagsControl();
        $template->setKey('optionaltags', $tagstring);


	# handle post
	#
	if (defined $params->{post}) {
		($error,$warn) = checkEncyclopediaEntry($params, 0, $userinf->{'uid'});
		if ($error eq '') {
			reviseEncyclopedia($rec, $params, $userinf);
			return paddingTable(makeBox('Article Revised',"
			Your article has been successfully revised.<p/>
			Quick links:
			<p/>
			<ul>
				<li><a href=\"".getConfig("main_url")."/?op=getobj&from=$params->{from}&id=$params->{id}\">view the article</a></li>
				<li><a href=\"".getConfig("main_url")."/?op=edit&from=$params->{from}&id=$params->{id}\">edit the article again</a></li>
				<li><a href=\"".getConfig("main_url")."/?op=edituserobjs\">edit your other articles</a></li>
				<li><a href=\"".getConfig("main_url")."/?op=editcors\">your corrections</a></li>
			</ul>
			<br/>"
			));
		} else {
			$error = editEnPreview($rec, $params, $userinf, $template, $error);
		}
	}

	# handle preview
	#
	elsif (defined $params->{preview}) {
		$AllowCache = 0;
		($error,$warn) = checkEncyclopediaEntry($params,0, $userinf->{'uid'});
		#$template->setKeyIfUnset('error', $error);
		$error = editEnPreview($rec,$params,$userinf,$template,$error);
		#$template->setKeyIfUnset('error', $error);
	} 
	
	# file box command or getting of preamble
	#	
	elsif (defined $params->{filebox} || $params->{getpre}) {
		if (defined $params->{getpre}) {
			$params->{preamble} = $userinf->{data}->{preamble};
		}
		editEnRefresh($template,$rec,$params);
	}
	
	# no command - give initial form
	#
	else {
		editEnRefresh($template,$rec,$params);
		copyBoxFilesToTemp(getConfig('en_tbl'),$params);	# copy filebox to temporary dir
	}
	handleFileManager($template,$params,$upload);
	
	# insert error messages (with warnings)
	#
	$error .= $warn;	 # toss in warnings now
	if ($error ne '') { $error .= "<hr />"; }
	
	$template->setKey('error', $error) if ($error);

	$template->addText("</entry>");
	
	if ($Noosphere::baseconf::base_config{RATINGS_MODULE}) {
		Noosphere::Ratings::Ratings::decreaseObjectRatings($rec->{'uid'});
	}
	
	return paddingTable(clearBox('Editing Object',$template->expand()));
}

# just carry over values needed to generate form
#
sub editEnRefresh {
	my $template = shift;
	my $rec = shift;
	my $params = shift;
 
	my $corrections = getCorrectionForm($params,"accept");
	$template->setKey('corrections', $corrections);

	# set revision comment to correction-based message
	# 
	if ($params->{correct} && blank($params->{revcomment})) {
		my $ctitle = lookupfield(getConfig('cor_tbl'), 'title', "uid=$params->{correct}");
		$params->{revcomment} ||= "Changes for correction #$params->{correct} ('$ctitle').";
	}
			
	if (defined $params->{keep}) {
		# APK - what the hell is this?
		my $val = ($params->{keep} eq "on") ? "checked":"";
		$template->setKey('keep', $val);
	}
	if (not defined $params->{class}) {
		$template->setKey('class', classstring($params->{from},$rec->{uid}));
	}
	my $typeis = $params->{type} || getConfig('typestrings')->{$rec->{type}};
	$template->setKey('typeis', $typeis);
	
	$template->setKeysIfUnset(%$params);
	$template->setKeysIfUnset(%$rec);
	
	if (isAttachmentType($rec->{type}) && blank($params->{parent})) {
		my $name = getnamebyid($rec->{parentid});
		$template->setKey('parent', $name);
	}
	my $tbox = gettypebox({reverse %{getConfig('typestrings')}},$params->{type}||$rec->{type});
	$template->setKey('tbox', $tbox);

	if (blank($params->{parent}) and defined $rec->{parentid}) {
		my $parent = getnamebyid($rec->{parentid});
		$template->setKey('parent', $parent);
	} 
 
	return $template;
}

# do a preview, return errors
#
sub editEnPreview {
	my $rec = shift;
	my $params = shift;
	my $userinf = shift;
	my $template = shift;
	my $error = shift;

	my $output = '';

	if ($error eq '') {
		# APK - why was this here?
		#$params->{'title'} = $rec->{'title'};

		my $preview = renderEnPreview(0, $params, $userinf->{'prefs'}->{'method'});

		if ($preview ne '') { 
			$template->setKey('showpreview', $preview);
		} else {
			$error .= 'There was an error in your LaTeX.	Please fix it and try your submission again.<br />';
		}
	}
 
	editEnRefresh($template, $rec, $params);

	return $error;
}

# actually carryout the database revision process
#
sub reviseEncyclopedia {
	my $rec = shift;
	my $params = shift;
	my $userinf = shift;
	
	my $parentid;
	my $pq = '';
	my $thash = {reverse %{getConfig("typestrings")}};
	my $ntype = $thash->{$params->{type}}; 
	my $table = getConfig('en_tbl');

	# add parent id to update if this is an attachment type
	#
	if (nb($params->{parent})) {
		$parentid = getidbyname($params->{parent});
		return 0 if ($parentid == -1);
		$pq = ", parentid=$parentid";
	} else {
		$pq = ', parentid=null';
	}
	
	if (not defined($rec->{parentid})) {
		$rec->{parentid} = 'null';
	}

	# save a snapshot of the current version!
	#
	snapshot($table, $rec->{uid}, "$rec->{name}_$rec->{version}", $userinf->{uid}, $params->{revcomment});
 
	my ($rv,$sth);

	my $synonyms = $params->{synonyms} || '';
	my $keywords = $params->{keywords} || '';
	my $related = $params->{related} || '';
	my $defines = $params->{defines} || '';

	my $pronounce = $params->{pronounce} ? sq(normalizePronunciation($params->{title}, $params->{pronounce})) : undef;
	
	#dwarn "*** LBH *** pronounce in reviseEncyclopedia: $pronounce\n";
	
	# update the object
	#
	my $update = "update $table
	set version=version+1,
	 type=?, title=?, preamble=?, data=?, synonyms=?, defines=?, related=?,
	 keywords=?, pronounce=?, self=? $pq
	 where uid=$rec->{uid}";

	$sth = $dbh->prepare($update);

	$rv = $sth->execute($ntype, $params->{title}, $params->{preamble},
		$params->{data}, $synonyms, $defines, $related, $keywords, $pronounce,
		($params->{self} eq 'on' ? 1 : 0));
	
	$sth->finish();

	#handle tags
	my $oldtags = getTags($table, $rec->{'uid'});
	my $newtagstring = $params->{'tags'};
	my @newtags = split( /\s*,\s*/, $newtagstring );
	my $userid = $userinf->{'uid'};
	my %newmap = map { $_ => $userid } @newtags;
	foreach my $k (keys  %$oldtags ) {
		$newmap{$k} = $oldtags->{$k};
	}

	updateTags( $rec->{'uid'}, \%newmap );

	# handle encyclopedia change stuff.
	handleEncyclopediaChange($params,$rec);

	# move back temp files
	moveTempFilesToBox($params,$params->{id},$table);
	
	# close any corrections
	closeCorrection($params,$userinf,'accept');

	# give some points for the edit
	changeUserScore($userinf->{uid},getScore('edit_en_major'));

	# update author list
	updateAuthorEntry($table,$params->{id},$userinf->{uid});

	# send out notice that the object was modified
	updateEventWatches($params->{id}, $params->{from}, $userinf->{uid}, 
	$params->{revcomment}, "object edited");

	NNexus_addobject( $params->{'title'},
					$params->{'data'},
					$params->{'id'},
					$userinf->{'uid'},
					$params->{'policy'},
					$params->{'class'},	
					$synonyms,
					$defines);



	return 1;
}

# apply a snapshot version of encyclopedia to the database
#
sub insertEncyclopediaSnapshot {
	my $params = shift;
	
	my $parentid;

	my $pq = '';

	my $table = getConfig('en_tbl');
	my $thash = {reverse %{getConfig("typestrings")}};
	my $ntype = $thash->{$params->{'type'}}; 

	# add parent id to update if this is an attachment type
	#
	if (nb($params->{parentid})) {
		$pq = ", parentid=$params->{parentid}";
	} else {
		$pq = ', parentid=null';
	}
	
	my ($rv,$sth);

	my $synonyms = $params->{synonyms} || '';
	my $keywords = $params->{keywords} || '';
	my $related = $params->{related} || '';
	my $defines = $params->{defines} || '';

	my $pronounce = $params->{pronounce} ? sq(normalizePronunciation($params->{title}, $params->{pronounce})) : undef;
	
	#dwarn "*** LBH *** pronounce in insertEncyclopediaSnapshot: $pronounce\n";
	
	# update the object
	#
	my $update = "update $table
	set version=?, 
	 type=?, title=?, preamble=?, data=?, synonyms=?, defines=?, related=?,
	 keywords=?, pronounce=?, self=?, modified=? $pq
	 where uid=$params->{uid}";

	$sth = $dbh->prepare($update);

	$rv = $sth->execute($params->{'version'}, 
		$ntype, 
		$params->{'title'}, 
		$params->{'preamble'},
		$params->{'data'}, 
		$synonyms,
		$defines,
		$related,
		$keywords, 
		$pronounce,
		$params->{'selfproof'},
		$params->{'modified'});
	
	$sth->finish();
	
	return 1;
}

# update stuff that needs to be updated after an encyclopedia entry
# changes
#
sub handleEncyclopediaChange {
	my $params = shift;
	my $rec = shift;

	my $table = getConfig('en_tbl');
	my $cname = $params->{'name'} || $rec->{'name'};

	my $thash = {reverse %{getConfig("typestrings")}};
	my $ntype = $thash->{$params->{type}}; 

	# update last modified date
	#
	my ($rv,$sth) = dbUpdate($dbh,{WHAT=>$table,
		 SET=>"modified=CURRENT_TIMESTAMP",
		 WHERE=>"uid=$rec->{uid}"});

	$sth->finish();

	# if title changed, handle re-cross reffing
	if ($params->{'title'} ne $rec->{'title'}) {
		xrefChange($rec->{'uid'},$table);
		xrefTitleInvalidate($params->{'title'},$table);
	}
	
	# re-index and un-xref this entry if data changed
	if ($params->{'data'} ne $rec->{'data'}) {
		invalIndexEntry($params->{'id'});
		xrefDeleteLinksFrom($rec->{'uid'}, $table);	
	}

	# re-index for IR
	irIndex($table, $params); 

	# invalidate the object (for all methods)
	setvalidflag_off($table, $rec->{'uid'});	 
	setvalid_htmlflag_off($table, $rec->{'uid'});	 
	
	# if synonyms changed handle re-cross reffing
	#
	my $calledchange = 0;
	if ($params->{'synonyms'} ne $rec->{'synonyms'}) {
		xrefChange($rec->{'uid'}, $table);
		$calledchange = 1;
		foreach my $syn (splitindexterms($params->{'synonyms'})) {
			xrefTitleInvalidate($syn, $table);
		}
	}

	# if defines changed handle re-cross reffing
	#
	if ($params->{'defines'} ne $rec->{'defines'}) {
		xrefChange($rec->{'uid'}, $table) unless ($calledchange);
		foreach my $def (splitindexterms($params->{'defines'})) {
			xrefTitleInvalidate($def, $table);
		}
	}
	
	# title indexing
	#
	indexTitle($table, $rec->{'uid'}, $rec->{'userid'},$params->{'title'},$cname, $rec->{'source'});
	deleteSynonyms($table, $rec->{'uid'});
	createSynonyms($params->{'synonyms'}, $rec->{'userid'}, $rec->{'title'}, $cname, $rec->{'uid'}, 2, $rec->{'source'});
	createSynonyms($params->{'defines'}, $rec->{'userid'}, $rec->{'title'}, $cname, $rec->{'uid'}, 3, $rec->{'source'});

	# classification (dont wipe it out if its not there)
	my $oldclass = classstring($table, $rec->{'uid'});
	if (exists $params->{'class'}) {
		classify($table, $rec->{'uid'}, $params->{'class'});
	}

	# update statistics
	#
	$stats->invalidate('unproven_theorems') 
		if (($ntype != $rec->{'type'} && $ntype == THEOREM()) ||
			(!$rec->{'self'} && $params->{'self'} eq 'on'));

	$stats->invalidate('unclassified_objects') if ($params->{'class'} ne $oldclass);
	$stats->invalidate('latestmods');

	# make sure relateds are symmetric
	#
	symmetricRelated($cname, $params->{'related'}, {userInfoById($rec->{'userid'})} );
}

# get the form component for editing metadata
# 
sub getMetadataEditor {
	my $params = shift;
	my $schema = shift;
	my $rec = shift;
	
	my $html = "";

	# build metadata editing portion of form
	#
	foreach my $key (keys %$schema) {
		my ($widget,$desc) = getFormWidget($schema,$key,$rec);
		$html .= "<div valign=\"top\">$desc:</div> $widget <br /><br />";
	}

	return $html;
}

# generic update of object metadata
#
sub updateObjectMetadata {
	my $schema = shift;
	my $params = shift;
	my $userinf = shift;
	my $rec = shift;
	my $gohome = shift;

	my @update;
	
	# find fields which have changed
	#
	foreach my $key (keys %$rec) {
	
	my $val = $params->{$key};
	
	# convert checkbox values to boolean 0/1
	if ($schema->{$key}->[1] eq 'check') {
		if (defined $val) {
				$val = ($val eq 'on') ? 1 : 0;
		}
	}
		if (defined $val && ($val ne $rec->{$key})) {
	
			push @update, "$key='".sq($val)."'";
	} elsif ((not defined $val) && ($schema->{$key}->[1] eq 'check')) {
	
		push @update, "$key=0";
	}
	}

	# make the changes
	#
	if ($#update >= 0) {
		my ($rv,$sth) = dbUpdate($dbh, {
			WHAT => $params->{from},
 			SET =>join(',',@update),
			WHERE => "uid=$params->{id}"
		});
	
		$sth->finish();
	}

	# classify
	#
	my $classcount = classify($params->{from},$params->{id},$params->{class});

	# update title index
	#
	indexTitle($params->{from}, $params->{id}, $userinf->{uid}, $params->{title});;

	# update IR index
	#
	irIndex($params->{from}, $params);

	# update statistics
	#
	$stats->invalidate('unclassified_objects');
	$stats->invalidate('latestmods');

	# finish up
	#
	return paddingTable(makeBox('Update Successful',"You will now be redirected back to the object. If this does not work, click <a href=\"".getConfig("main_url")."/?op=getobj&from=$params->{from}&id=$params->{id}\">here</a>.
		<meta http-equiv=\"refresh\" content=\"0; url=".getConfig("main_url")."/?op=getobj&from=$params->{from}&id=$params->{id}\">"));
}

1;
