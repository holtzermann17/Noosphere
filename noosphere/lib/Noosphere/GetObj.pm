package Noosphere;
use strict;

use Noosphere::Editor;
use XML::Writer;
use Noosphere::Roles;

use vars qw{$LoadjsMath};

# getObjHtml - the new main object retrieval point. This function uses the
# article.xsl stylesheet to create the correct html of the object.
# Note that html doesn't mean l2h mode but all of the rendering modes for 
# objects in noosphere.
sub getObjHtml {
	my $params = shift;
	my $userinf = shift;

	if (not defined $params->{'from'}){
		$params->{'from'} = 'objects';
	}

	my $id = $params->{'id'};
	my $name = $params->{'name'};

	if ( defined( $name ) ) {
		$id = getidbyname($name);
		$params->{'id'} = $id;
	}

	$params->{'method'} = $params->{'method'} || $userinf->{'prefs'}->{'method'};
	my $method = $params->{'method'};

	if ( $method eq 'js' ) {
		$LoadjsMath = 1;
	} else {
		$LoadjsMath = 0;
	}

	return errorMessage('Could not find object! Contact an admin!') if ($id == -1);

	my $table = $params->{'from'};

	if ( $table eq getConfig('cor_tbl') ) {
		my $template = renderCorrection($params,$userinf);
		return $template->expand();
		my %extraops = ();
		my $objxml = getobjxml( $params, \%extraops, $userinf );
		my $xslfile = getConfig('stemplate_path') . "/correction.xsl";
		my $output = buildStringUsingXSLT( $objxml, $xslfile );
#warn "****** output from article.xsl template------------\n$output\n------\n";
		return $output;
#	} elsif ($table eq getConfig('collab_tbl')) {
#		return getObj($params, $userinf);
} 
if ($table eq 'objects') {

	if (!can_read($userinf->{'uid'},$id, $table)) {

		my $msg = "You don't have permission to view that object.";
		warn " ****** $id cannot be accessed by " . $userinf->{'uid'};
		return errorMessage($msg);
	}

# handle watch changing
#
#changeWatch($params, $userinf, $params->{'from'}, $id);


# hit the object
#
	hitObject($id,$params->{'from'},'hits');


#instead of querying up the object like in the old noosphere code
# we simply get the xml of the object

	my %extraops = ();
	$extraops{'History'} = "/?op=vbrowser;from=objects;id=$id";

	if (hasWatch( 'objects', $id, $userinf->{'uid'} )) {
		$extraops{'Unwatch'} = "/?op=unwatch;from=objects;id=$id";
	} else {
		$extraops{'Watch'} = "/?op=watch;from=objects;id=$id";
	}

#editor special operations
	if ( is_editor( $userinf->{'uid'} ) ) {
		$extraops{'Rerender'} = "/?op=rerender;from=objects;id=$id;method=$method";
		if ( is_published( $id ) ) {
			$extraops{'Unpublish'} = "/?op=unpublish;from=objects;id=$id";
		} else {
			$extraops{'Publish'} = "/?op=publish;from=objects;id=$id";
		}
		$extraops{'Edit Roles'} = "/?op=editroles;from=objects;id=$id";
	}

	if ( can_edit( $userinf->{'uid'}, $id ) ) {
		$extraops{'Edit Page'} = "/?op=edit;from=objects;id=$id";
	}

#author special operations
	if (is_LA( $id, $userinf->{'uid'} )) {
		if ( not is_published( $id ) ) {
			if ( not publication_requested( $id ) ) {
				$extraops{'Request Publication'} = "/?op=requestpublication;from=objects;id=$id";
			} 
		} 
	}

	if ( not is_CA($id, $userinf->{'uid'}) and not is_LA($id, $userinf->{'uid'})) {
		$extraops{'Request Co-authorship'} = "/?op=requestcastatus;from=objects;id=$id";
	}

	if ( is_admin($userinf->{'uid'}) or is_EB( $userinf->{'uid'} ) ) {
		$extraops{'Delete Article'} = "/?op=delobj;from=objects;id=$id;ask=yes";
	}

#	warn Dumper(\%extraops);


	my $objxml = getobjxml( $params, \%extraops, $userinf );
	my $xslfile = getConfig('stemplate_path') . "/article.xsl";
	my $output = buildStringUsingXSLT( $objxml, $xslfile );
#warn "output article = $output";
#warn "****** output from article.xsl template------------\n$output\n------\n";
	return $output;
} else {
#handle all of the other object types
	my $table = $params->{'from'};
	my %extraops = ();
	my $xslfile = '';
	my $objxml = '';
	$extraops{'Edit Page'} = "/?op=edit;from=$table;id=$id";
	$objxml = getobjxml( $params, \%extraops, $userinf );
	$xslfile = getConfig('stemplate_path') . "/$table.xsl";
	my $output = buildStringUsingXSLT( $objxml, $xslfile );
	return $output;
}
}

sub getobjxml {
	my $params = shift;
	my $extraops = shift;
	my $userinf = shift;


	my $output = '';
	my $w = new XML::Writer(OUTPUT=>\$output, NEWLINES=>1, UNSAFE=>1);

# query up the object
	my $table = $params->{'from'};
	my $objid = $params->{'id'};
	$table = 'objects' if ( $table eq '' );
	my $sth = $dbh->prepare_cached("select * from $table where uid = ?");
	$sth->execute( $objid);


	if ($sth->rows()<1) {
		dwarn "object id = $objid not found!";
		$w->startTag("object");
		$w->startTag("error");
		$w->raw("Object $table/$objid not found! Please <a href=\"".
				getConfig('bug_url').
				"\">report this</a> to us!" );
		$w->endTag("error");
		$w->endTag("object");
		$w->end();
		return $output;
	}

	my $method = $params->{'method'};



	if ( my $rec = $sth->fetchrow_hashref() ) {
#the object is in the database.
# build the xml
		if ( $table eq 'objects' ) {
			my $content = getRenderedContentHtml($params, $table, $rec, $method );
			warn "content =  [$content]";

			if ( $table eq 'collab' and $content eq '' ) {
				$content = "Collab object text coming soon.";
			}
#if ( $table eq 'corrections' ) {
#	$content = "Correction text";
#}
			$w->startTag("object");
			$w->startTag("table");
			$w->characters($table);
			$w->endTag("table");
			$w->startTag("id");
			$w->characters($objid);
			$w->endTag("id");
			$w->startTag("title");
			my $title = mathTitle( $rec->{'title'} );
			$w->raw($title);	
			$w->endTag("title");
			$w->startTag("owners");
			$w->raw(getOwnersInfo($rec, $params->{'from'}));
			$w->endTag("owners");
			$w->startTag('citation');
			$w->raw(getCitationInfo( $rec ));	
			$w->endTag('citation');
			my $jslink = "<script type=\"text/javascript\" src=\"" .getConfig('cache_url') . "/objects/$objid/$method/links.js\"/>";
			$jslink .= "<script src=\"http://planet.math.uwaterloo.ca:8080/javascripts/jquery.js\" type=\"text/javascript\"></script><script src=\"http://planet.math.uwaterloo.ca:8080/javascripts/pm.js\" type=\"text/javascript\"></script>";
			$w->startTag('jslinks');
			$w->raw($jslink);
			$w->endTag('jslinks');
			$w->startTag("content");
			$w->raw($content);
			$w->endTag("content");
			$w->startTag("classification");
			my $class = printclass( $table, $objid );
			$w->raw($class);	
			$w->endTag("classification");
			$w->startTag("extraops");
			foreach my $k (sort keys %$extraops) {
				$w->raw("<li><a href=\"" . $extraops->{$k} ."\">$k</a></li>|");
			}
			$w->endTag("extraops");
			$w->startTag("messages");
			my $lastmsg = get_lastseen($params->{'from'},$objid,$userinf->{'uid'});
			my $desc = 0;
			my $messages = getMessages($params->{'from'},$objid,$desc,$params,$userinf,($userinf->{'uid'} < 0 ) ? undef : $lastmsg);
			my $curlast = get_lastmsg($params->{'from'},$objid);
			update_lastseen($params->{'from'},$objid,$userinf->{'uid'},$curlast);
			$w->raw($messages);
			$w->endTag("messages");
			$w->startTag("viewstyle");
			my $viewstyle = getViewStyleWidget($params,$method);
			$w->raw($viewstyle);
			$w->endTag("viewstyle");
#metamessages
			if ( not is_deleted( $objid ) ) {

				if ( not is_published( $objid ) ) {
					if ( publication_requested( $objid ) ) {
						$w->startTag("metamessages");
						$w->characters("This article is currently under review for publication");
						$w->endTag("metamessages");
					} 
				} 
			} else {
				$w->startTag("metamessages");
				$w->characters("This article was deleted from the encyclopedia.");
				$w->endTag("metamessages");

			}
			$w->endTag("object");
			$w->end();
		} else {
			$w->startTag( "object" );
			foreach my $k (keys %$rec) {
				$w->startTag($k);
				$w->characters( $rec->{$k} );
				$w->endTag($k);	
			}
			$w->startTag("id");
			$w->characters($rec->{'uid'});
			$w->endTag("id");
			$w->startTag("table");
			$w->characters($params->{'from'});
			$w->endTag("table");
			$w->startTag("messages");
			my $lastmsg = get_lastseen($params->{'from'},$objid,$userinf->{'uid'});
			my $desc = 0;
			my $messages = getMessages($params->{'from'},$objid,$desc,$params,$userinf,($userinf->{'uid'} < 0 ) ? undef : $lastmsg);
			my $curlast = get_lastmsg($params->{'from'},$objid);
			update_lastseen($params->{'from'},$objid,$userinf->{'uid'},$curlast);
			$w->raw($messages);
			$w->endTag("messages");
			$w->startTag("viewstyle");
			my $viewstyle = getViewStyleWidget($params,$method);
			$w->raw($viewstyle);
			$w->endTag("viewstyle");
			$w->startTag("classification");
			my $class = printclass( $table, $objid );
			$w->raw($class);	
			$w->endTag("classification");
			$w->startTag("owners");
			$w->raw(get_authors_html($rec->{'uid'}, $params->{'from'}));
			$w->endTag("owners");
			$w->endTag("object");
			$w->end();
		}
	}

	warn "getobjxml returning [$output]";
	return $output;
}


sub getOwnersInfo{ 
	my $rec= shift;
	my $table = shift;

	$table = 'objects' if ( $table eq '' );


	my $title = mathTitle( $rec->{'title'} );
	my $text= "$title is owned by ";
	if ( $table eq 'objects' ) {
		my $authors = get_authors_html( $rec->{'uid'}, $table );
		$text .= "$authors.";
	} else {
#warn "GETTING OWNER INFO FOR $title / $table";
		my $stmt = "select userid from $table where uid=?";
		my $sth = $dbh->prepare($stmt);
		$sth->execute( $rec->{'uid'} );
		if ( my $row = $sth->fetchrow_hashref() ) {
			my $userid = $row->{'userid'};
			$text .= "<a href=\"".getConfig("main_url")."/?op=getuser&amp;id=".$userid."\">".getUserDisplayName($userid).  "</a>.";
		}
	}
	return $text;
}


#Carriquiry, Alicia L. and David, Herbert A. (2009-06-13, version 2). "George Waddel Snedecor." Springer Encyclopedia of Probability & Statistics. Freely available at http://encyclopedia-dev.springerwiki.com/encyclopedia/GeorgeWaddelSNEDECOR.html
# authors, title, link, version 
sub getCitationInfo {
	my $rec = shift;
	my $authors = get_authors_html( $rec->{'uid'} );
	my $title = mathTitle( $rec->{'title'} );

	my $version = $rec->{'version'} || 1;

	my $objxml = '';
	my $w = new XML::Writer(OUTPUT=>\$objxml, NEWLINES=>1, UNSAFE=>1);

	$w->startTag('object');
	$w->startTag('id');
	$w->characters($rec->{'uid'});
	$w->endTag('id');
	$w->startTag('authors');
	$w->raw( $authors );
	$w->endTag('authors');
	$w->startTag('title');
	$w->raw($title);
	$w->endTag('title');
	$w->startTag('version');
#TODO update version number
	$w->characters($version);
	$w->endTag('version');
	$w->endTag('object');
	$w->end();

	my $xslfile = getConfig('stemplate_path') . "/citation.xsl";
	my $output = buildStringUsingXSLT( $objxml, $xslfile );

	return $output;	
}

# getObj - main object retrieval point, calls more specialized functions
#
sub getObj {
	my $params = shift;
	my $userinf = shift;

	my $id = $params->{'id'};
	my $name = $params->{'name'};
	my $desc = 0;
	my $nomsg = 0;

	my $template;	# the object display output template

# resolve name query into id so we only have one method to write code for
#
		if (defined($name)) {
			$id = getidbyname($name);
		}


	return errorMessage('Could not find object! Contact an admin!') if ($id == -1);

# query up the object
#
	(my $rv, my $sth) = dbSelect($dbh,{WHAT =>'*', 
			FROM => $params->{from},
			WHERE => "uid=$id"});

	if (! $rv || $sth->rows()<1) {
		dwarn "object not found!";
		return errorMessage("Object not found! Please <a href=\"".getConfig('bug_url')."\">report this</a> to us!");
	}

	my $rec = $sth->fetchrow_hashref();	

#this is the check we want if our system does not
#allow non-logged in users to read the content.
# we need to add this as a configuration variable.
	my $wideopen = 0;

	if ( ! $wideopen  ) {
# handle access to the object
#
		if (!can_read($userinf->{'uid'},$id)) {

			warn $userinf->{'uid'} . " doesn't have permission to access $id";

			my $msg = "You don't have permission to view that object.<p>";
			$msg .= "This may be a mistake.  Try contacting the <a href=\"".getConfig('main_url')."/?op=getuser&id=$rec->{userid}\">object owner</a> (preferably) or <a href=\"mailto:".getAddr('feedback')."\">administration</a> (if the owner is unresponsive).";
			return errorMessage($msg);
		}
	}

# handle watch changing
#
#changeWatch($params, $userinf, $params->{'from'}, $id);


# hit the object
#
	hitObject($id,$params->{'from'},'hits');


# get user name (handle negative user id)
#
	if ($rec->{'userid'} <= 0) {
		$rec->{'username'} = "nobody";
	} else {
		$rec->{'username'} = lookupfield('users','username',"uid=$rec->{userid}");
	}

# set title
#
	if (nb($rec->{'title'})) {
		$NoosphereTitle = TeXtoUTF8($rec->{'title'});
	}


# render object type specific stuff
#
	if ($params->{'from'} eq 'news') {
		$template = renderNews($rec);
	} 
	elsif ($params->{'from'} eq getConfig('en_tbl')) {
		$template = renderEncyclopediaObj($rec, $params, $userinf);
	}
	elsif ($params->{'from'} eq getConfig('collab_tbl')) {
		$template = renderCollab($rec, $params, $userinf);
	}
	elsif ($params->{'from'} eq 'forums') {
		$template = renderForum($rec);
	} 
	elsif ($params->{'from'} eq getConfig('papers_tbl') || 
			$params->{'from'} eq getConfig('exp_tbl') ||
			$params->{'from'} eq getConfig('books_tbl')) {

		$template = renderGeneric($params,$userinf, $rec);
	} 
	elsif ($params->{'from'} eq getConfig('polls_tbl')) {
		$template = viewPoll($params,$userinf);
	}
	elsif ($params->{'from'} eq getConfig('req_tbl')) {
		$template = getReq($params,$userinf);
	}
	elsif ($params->{'from'} eq getConfig('user_tbl')) {
		$template = getUser($params,$userinf);
	}
	elsif ($params->{'from'} eq getConfig('cor_tbl')) {
		$template = renderCorrection($params,$userinf);
	}
	else {
		return errorMessage('object type not supported for viewing yet.'); 
	}

	return $template if ($nomsg);

# handle messages - this is unified accross object types. we know the object
# supports messages based on whether the template contains a $messages flag.
#
	if ($template->requestsKey('messages')) {
		dwarn "**** OBJECT REQUESTS messages; $id\n", 3;
		my $lastmsg = get_lastseen($params->{'from'},$id,$userinf->{'uid'});
		my $messages = clearBox('Discussion',getMessages($params->{'from'},$id,$desc,$params,$userinf,($userinf->{'uid'} < 0 ) ? undef : $lastmsg));
		$template->setKey('messages', $messages);
		my $curlast = get_lastmsg($params->{'from'},$id);
		update_lastseen($params->{'from'},$id,$userinf->{'uid'},$curlast);
	}

	if ($template->requestsKey('watch')) {
		$params->{'id'} = $id;
		my $watchwidget = getWatchWidget($params, $userinf);
		$template->setKey('watch', $watchwidget);
	}

# likewise for corrections
#
	if($template->requestsKey('corrections')) {
		my $corrections = clearBox('Pending Errata and Addenda',getPendingCorrections($id));
		$template->setKey('corrections', $corrections);
	} 

# admin controls
#
	if ($params->{'from'} eq getConfig('en_tbl')) {
		getEncyclopediaAdminControls($template,$userinf,$params->{'from'},$id,$params->{'method'});
	} elsif ($params->{'from'} eq getConfig('polls_tbl')) {
		getPollAdminControls($template, $userinf, $params);		
	}

#editor controls
	my $editor = "";
	if ( is_editor( $userinf->{'uid'}, $rec->{'uid'} ) ) {
		$editor = getEditorControls( $params->{'from'}, $rec->{'uid'}, $userinf->{'uid'});
	}
	$template->setKey('editor', $editor);

# get owner controls
# 
	my $author = '';
	if ($userinf->{'uid'} == $rec->{'userid'}) {
		$author = getOwnerControls($params->{'from'},$rec->{'uid'});
	}

# or author controls
#
	elsif ($userinf->{'uid'} > 0 && can_edit($userinf->{'uid'}, $id)) {
		$author = getAuthorControls($params->{'from'},$rec->{'uid'},$userinf);
	}


	$template->setKey('author', $author);


	return $template->expand();
}

# invalidate an object's cache and re-view it.
#
sub reRenderObj {
	my $params = shift;
	my $userinf = shift;

	setvalidflag_off($params->{'from'},$params->{'id'});
	setvalid_htmlflag_off($params->{'from'},$params->{'id'});
	setbuildflag_off($params->{'from'},$params->{'id'});

	my $html = getObjHtml($params,$userinf);

	return $html;
}

sub reLinkObj {
	my $params = shift;
	my $userinf = shift;

	setvalidflag_off($params->{'from'},$params->{'id'});
	setbuildflag_off($params->{'from'},$params->{'id'});

	my $html = getObj($params,$userinf);

	return $html;
}

sub renderNews {
	my $rec = shift;

	my $html = new Template('newsobj.html');

	my $newsbox = clearBox($rec->{'title'},formatnewsitem_full($rec));
	my $interact = makeBox('Interact',getNewsInteract($rec));
	$html->setKeys('newsbox' => $newsbox, 'interact' => $interact);


	return $html;
}

# get the author controls menu
#
sub getAuthorControls {
	my $table = shift;
	my $id = shift;
	my $userinf = shift;

	my $html = '';

	$html .= "<center>";
	$html .= "<a href=\"".getConfig("main_url")."/?op=edit&amp;from=$table&amp;id=$id\">edit content</a> ";
	$html .= " | <a href=\"".getConfig("main_url")."/?op=linkpolicy&amp;from=$table&amp;id=$id\">edit linking policy</a> ";
	$html .= " | <a href=\"".getConfig("main_url")."/?op=rerender&amp;from=$table&amp;id=$id\">rerender</a> ";
	$html .= " | <a href=\"".getConfig("main_url")."/?op=relink&amp;from=$table&amp;id=$id\">relink</a> ";

	if ( !is_published($id) && can_request_publication( $userinf->{'uid'} , $id ) ) {
		$html .= "| <a href=\"".getConfig("main_url")."/?op=requestpublication&amp;from=$table&amp;id=$id\">request publication</a>";
	}


	$html .= "</center>";


	return makeBox('Author Controls',$html);
}

sub getEditorControls {
	my $table = shift;
	my $id = shift;
	my $userid = shift;

	my $html = '';


	$html .= "<center>";
	$html .= "<a href=\"".getConfig("main_url")."/?op=edit&amp;from=$table&amp;id=$id\">edit content</a> ";
	$html .= " | <a href=\"".getConfig("main_url")."/?op=rerender&amp;from=$table&amp;id=$id\">rerender</a> ";
	$html .= " | <a href=\"".getConfig("main_url")."/?op=relink&amp;from=$table&amp;id=$id\">relink</a> ";
	$html .= "| <a href=\"".getConfig("main_url")."/?op=editroles&amp;from=$table&amp;id=$id\">edit roles</a> ";
	if ( can_publish( $userid ) ) {
		if ( ! is_published( $id ) ) {
			$html .= "| <a href=\"".getConfig("main_url")."/?op=publish&amp;from=$table&amp;id=$id\">publish</a>";
		} else {
			$html .= "| <a href=\"".getConfig("main_url")."/?op=unpublish&amp;from=$table&amp;id=$id\">unpublish</a>";
		}
	}


	$html .= "</center>";


	return makeBox('Editor Controls',$html);
}

# get the owner controls menu
#
sub getOwnerControls {
	my $table = shift;
	my $id = shift;

	my $html = '';


	$html .= "<center>";
	$html .= "<a href=\"".getConfig("main_url")."/?op=edit&amp;from=$table&amp;id=$id\">edit content</a>";
	$html .= " | <a href=\"".getConfig("main_url")."/?op=rerender&amp;from=$table&amp;id=$id\">rerender</a>";
	$html .= " | <a href=\"".getConfig("main_url")."/?op=relink&amp;from=$table&amp;id=$id\">relink</a>";
	$html .= " | <a href=\"".getConfig("main_url")."/?op=linkpolicy&amp;from=$table&amp;id=$id\">edit linking policy</a>";
	if ( !is_published($id) ) {
		if (! publication_requested($id) ) {
			$html .= " | <a href=\"".getConfig("main_url")."/?op=requestpublication&amp;from=$table&amp;id=$id\">request publication</a>";
		} else {
			$html .= " | publication already requested";
		}
	}
	$html .= " | <a href=\"".getConfig("main_url")."/?op=editroles&amp;from=$table&amp;id=$id\">edit roles</a>";
	$html .= " | <a href=\"".getConfig("main_url")."/?op=transfer&amp;from=$table&amp;id=$id\">transfer</a>";
	$html .= " | <a href=\"".getConfig("main_url")."/?op=delobj&amp;from=$table&amp;id=$id&amp;ask=yes\">delete</a>";
	$html .= " | <a href=\"".getConfig("main_url")."/?op=abandon&amp;from=$table&amp;id=$id&amp;ask=yes\">abandon</a>" if $table ne getConfig('collab_tbl');
	$html .= "</center>";

	return makeBox('Owner Controls',$html);
}

# get interact menu for encyc
#
sub getEncyclopediaInteract {
	my $rec = shift;
	my $userinf = shift;
	my $html = "";
	my $table = getConfig('en_tbl');


# get classification string, so we can propegate it to attachments
#
	my $class = urlescape(classstring($table,$rec->{uid}));


	$html .= "<center>";
	$html .= " <a href=\"".getConfig("main_url")."/?op=postmsg&amp;from=$table&amp;id=$rec->{uid}\">post</a>";
	$html .= " | <a href=\"".getConfig("main_url")."/?op=correct&amp;from=$table&amp;id=$rec->{uid}\">correct</a>";
	$html .= " | <a href=\"".getConfig("main_url")."/?op=updatereq&amp;identifier=$rec->{name}\">update request</a>";

	if ($rec->{type} == THEOREM() || $rec->{type} == CONJECTURE() ) {
		$html .= " | <a href=\"".getConfig("main_url")."/?op=adden&amp;class=$class&amp;type=Proof&amp;parent=$rec->{name}&title=".urlescape("proof of ".$rec->{title})."\">prove</a>";
		$html .= " | <a href=\"".getConfig("main_url")."/?op=adden&amp;class=$class&amp;type=Result&amp;parent=$rec->{name}&amp;title=".urlescape($rec->{title}." result")."\">add result</a>";
		$html .= " | <a href=\"".getConfig("main_url")."/?op=adden&amp;class=$class&amp;type=Corollary&amp;parent=$rec->{name}&amp;title=".urlescape("corollary of ".$rec->{title})."\">add corollary</a>";
	}

	if ($rec->{type} == DEFINITION() ) {
		$html .= " | <a href=\"".getConfig("main_url")."/?op=adden&amp;class=$class&amp;type=Derivation&amp;parent=$rec->{name}&amp;title=".urlescape("derivation of ".$rec->{title})."\">add derivation</a>";
	}

	$html .= " | <a href=\"".getConfig("main_url")."/?op=adden&amp;class=$class&amp;type=Example&amp;parent=$rec->{name}&amp;title=".urlescape("example of ".$rec->{title})."\">add example</a>";

	$html .= " | <a href=\"".getConfig("main_url")."/?op=adden&amp;class=$class&amp;parent=$rec->{name}&amp;title=".urlescape("something related to ".$rec->{title})."\">add (any)</a>";

	my $objectid = $rec->{'uid'};
	my $userid = $userinf->{'uid'};
	if ( ! (is_LA($objectid, $userid) || is_CA($objectid, $userid) ) ) {
		$html .= " | <a href=\"".getConfig("main_url")."/?op=requestcastatus&from=$table&id=$rec->{uid}\">request co-author status</a>";
	}

	$html .= "</center>";

	return $html;
}

# get interact menu for collab 
#
sub getCollabInteract {
	my $rec = shift;

	my $html = "";
	my $table = getConfig('collab_tbl');

	$html .= "<center>";
	$html .= " <a href=\"".getConfig("main_url")."/?op=postmsg&amp;from=$table&amp;id=$rec->{uid}\">post</a>";

	$html .= "</center>";


	return $html;
}

# get interact menu for lectures
#
sub getExpInteract {
	my $rec = shift;

	my $html = "";
	my $table = getConfig('exp_tbl');

	$html .= "<center>";
	$html .= " <a href=\"".getConfig("main_url")."/?op=postmsg&amp;from=$table&amp;id=$rec->{uid}\">post</a>";

	return $html;
}

# get interact menu for books
#
sub getBookInteract {
	my $rec = shift;

	my $html = '';
	my $table = getConfig('books_tbl');

	$html .= "<center>";
	$html .= " <a href=\"".getConfig("main_url")."/?op=postmsg&amp;from=$table&amp;id=$rec->{uid}\">post</a>";

	return $html;
}

# get interact menu for papers
#
sub getPaperInteract {
	my $rec = shift;

	my $html = '';
	my $table = getConfig('papers_tbl');

	$html .= "<center>";
	$html .= " <a href=\"".getConfig("main_url")."/?op=postmsg&amp;from=$table&amp;id=$rec->{uid}\">post</a>";

	return $html;
}

sub getNewsInteract {
	my $rec = shift;

	my $html = "";
	my $table = getConfig('news_tbl');

	$html .= "<center> ";
	$html .= "<a href=\"".getConfig("main_url")."/?op=postmsg&amp;from=$table&amp;id=".$rec->{'uid'}."\">post</a>";
	$html .= "</center>";

	return $html;
}


1;

