package Noosphere;
use strict;

use Noosphere::Util;
use Noosphere::UserData;
use Noosphere::Indexing;
use Noosphere::Pronounce;
use Noosphere::Watches;
use Noosphere::Classification;
#use Noosphere::ACL;
use Noosphere::IR;
use Noosphere::Crossref;
use Noosphere::Authors;
use Noosphere::NNexus;
use Noosphere::Roles;
use Noosphere::Editor;

use vars qw{$LoadjsMath};

# display an encyclopedia object
# 
sub renderEncyclopediaObj {
	my $rec = shift;      # $rec->{uid} , $rec->{objectid}, ...  (from objects table)
		my $params = shift;
	my $userinf = shift; 

	my $method = $params->{'method'} || $userinf->{'prefs'}->{'method'};
	my $template = new Template('encyclopediaobject.html');
	my $en = getConfig('en_tbl');
	my $contentbox = '';
	my $title = $rec->{'title'};
	$params->{'id'} = $rec->{'uid'} if ( not defined $params->{'id'} );

	if ( $method eq "js" ) {
		$LoadjsMath = 1;	
	} else {
		$LoadjsMath = 0;	
	}

	my $content = "";
	if ( is_deleted( $params->{id} ) ) {
		$content .= "<b>This object is deleted from the encyclopedia. You can view it only because you knew where to look.</b>";
	}

	$content .= getRenderedContentHtml($params, $en,$rec,$method);


	if ( nb($content) ) {

# print world-writeable comment
#
		if (isWorldWriteable($en, $rec->{'uid'})) {

			$content .= "<br /><i>Anyone <a href=\"".getConfig("main_url")."/?op=newuser\">with an account</a> can edit this entry.  Please help improve it!</i><br />";
		}

# print authorship/ownership information
# 
		if (not defined $params->{'anonymous'}) {
# print owner comment. handles no owner.
#
			my $userid = get_author( $params->{'id'} );
			if ($userid > 0) {
				$content .= "<br /><font size=\"-1\">\"".
						mathTitle($title)."\" is owned by ";
				$content .= get_authors_html( $params->{'id'} );
				$content .= ".</font>";
			} else {
				my ($lastid, $lastname) = getLastData($en, $rec->{'uid'});
				$lastname = getUserDisplayName($lastid);
				$content .= "<br /><font size=\"-1\">\"".mathTitle($title)."\" has no owner. (";
				if ( $lastname ne "" ) {
					$content .= "Was owned by <a href=\"".getConfig("main_url")."/?op=getuser&amp;id=$lastid\">$lastname</a>. "; 
				}
				$content .= "<a href=\"".getConfig("main_url")."/?op=adopt&amp;from=$params->{from}&amp;id=$rec->{uid}&amp;ask=yes\">Adopt</a>)</font>";

			}

			my @editors = get_associate_editors($rec->{'uid'});
			if (@editors) {
			$content .= "<br/><font size=\"-1\">";
			$content .= (@editors > 1) ? "Associate Editors: " : "Associate Editor: ";
			foreach my $e ( @editors ) {
				$e = "<a href=\"".getConfig("main_url")."/?op=getuser&amp;id=$e\">".getUserDisplayName($e)."</a>";
			}
			$content .= join(', ', @editors) . ".</font>";
			}
			


# print author/owner list links
#
			my $acount = getAuthorCount($en, $rec->{'uid'});
			my $ocount = getPastOwnerCount($en, $rec->{'uid'});
			if ($acount > 1 || $ocount > 0) {
				$content .= " <font size=\"-1\">[ ";

				my @links;
				push @links, "<a href=\"".getConfig("main_url")."/?op=authorlist&amp;from=$en&amp;id=$rec->{uid}\">full author list</a> ($acount)" if $acount > 1;
				push @links, "<a href=\"".getConfig("main_url")."/?op=ownerhistory&amp;from=$en&amp;id=$rec->{uid}\">owner history</a> ($ocount)" if $ocount > 0; 

				$content .= join(' | ', @links);

				$content .= " ]</font>";
			}
		}


# print title bar, with "up" arrow for attachments, and type string.
#
		my $up = '';
		if (defined $rec->{'parentid'} && $rec->{'parentid'} >= 0) {
			$up = getUpArrow("".getConfig("main_url")."/?op=getobj&amp;from=$en&amp;id=$rec->{parentid}",'parent');
		}
		my $ratingbars = "";
		if ($Noosphere::baseconf::base_config{RATINGS_MODULE}) {
			$ratingbars .= "<td style=\"padding-left: 10px; padding-right: 10px;\">";
			$ratingbars .= Noosphere::Ratings::Ratings::getObjectRating($rec->{'uid'},$rec->{'userid'});
			$ratingbars .= "</td>";
		}

		my $btitle = "
			<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">
			<tr>
			".$ratingbars."
			<td align=\"left\" style=\"width: 100%;\">$up 
			<font color=\"#ffffff\">".mathTitle($title, 'title')."</font>
			</td>
			<td align=\"right\"> 
			<font color=\"#ffffff\" size=\"-2\">(".getTypeString($rec->{type}).")
			</font>
			</td>
			</tr>
			</table>";


# ugly hack to handle failed rendering, since we don't really return
# an error code from rendering, just an error log.
#
		my $failed = ($content =~ /rendering\s+failed/i);
		my $isowner = ($userinf->{'uid'} == $rec->{'userid'});
		if ($failed && !$isowner) {
			my $ftemplate = new XSLTemplate('render_fail.xsl');	
			$ftemplate->addText('<render_fail>');
			$ftemplate->addText("<user id=\"$rec->{userid}\">$rec->{username}</user>");
			$ftemplate->setKey('id',$rec->{'uid'});
			$ftemplate->addText('</render_fail>');
			$content = $ftemplate->expand();
		}
#		warn "got here! " . $Noosphere::baseconf::base_config{RATINGS_MODULE};
		$contentbox = mathBox($btitle, $content);

	} else	{
		my $contact = getAddr('feedback');
		$contentbox = errorMessage("Missing cached output! Please <a href=\"mailto:$contact\">contact</a> an admin."); 

# APK debug : need to be notified when this happens.
		sendMail('akrowne@vt.edu', 'missing cached output', 
				"A missing cached output event just occurred for object $rec->{uid}.
				See http://planetmath.org/?op=getobj&from=objects&id=$rec->{uid}
				" );
	}
	my $metadata = getEncyclopediaMetadata($rec,$method,$userinf,$params);


# get method select box
#
	my $viewstyle = getViewStyleWidget($params,$method);
	$template->setKey('viewstyle', $viewstyle);

	my $interact = makeBox('Interact',getEncyclopediaInteract($rec, $userinf));


	$template->setKey('id',$rec->{'uid'});
	$template->setKeys('mathobj' => $contentbox, 'metadata' => $metadata, 'interact' => $interact);


	return $template;
}

# get a random entry
#
sub getRandomEntry {
	my $params = shift;
	my $userinf = shift;

	my $tbl = getConfig('en_tbl');

# select a random in-bounds index
#
	my $index;
#$index = dbEval("round(random()*(select count(*) from $tbl))")
#	if getConfig('dbms') eq 'pg';
#$index = dbEval("round(rand()*count(*)) from $tbl")
#	if getConfig('dbms') eq 'mysql';
	my $count;
	$count = dbEval("count(*) from $tbl")
		if getConfig('dbms') eq 'pg';
	$count = dbEval("count(*) from $tbl")
		if getConfig('dbms') eq 'mysql';

	$index = int(rand($count));

# get a uid randomly from the database
#

	my $uid;
	my $count = 0;
	my $sth = $dbh->prepare_cached("select count(*) as cnt from $tbl");
	$sth->execute();
	if ( my $row = $sth->fetchrow_hashref() ) {
		$count = $row->{'cnt'};
	}
	$sth = $dbh->prepare_cached("select uid from $tbl LIMIT ?,1");

	while ( 1 ) {
		my $rand = int(rand($count));	
		$sth->execute( $rand);
		if ( my $row = $sth->fetchrow_hashref() ) {
			$uid = $row->{'uid'};
			warn "checking $uid\n";
			if ( is_published( $uid ) ) {
				last;
			}
			
		}
	}
	
# "stuff" the proper getobj params
#
	$params->{'op'} = 'getobj';
	$params->{'from'} = $tbl;
	$params->{'id'} = $uid;

	my $target = "http://" . getConfig("siteaddrs")->{'main'} . "/?op=getobj&from=$tbl&id=$uid";
#	my $val = 'Status: 302 Moved', "\r\n", "Location: $target", "\r\n\r\n";
	return "<meta http-equiv=\"refresh\" content=\"0;URL=$target\">";
	
#return getObj($params, $userinf);
}

# show the "rest" of the encyclopedia metadata (below the main rendered 
# content)
#
sub getEncyclopediaMetadata {
	my $rec = shift;
	my $method = shift;
	my $userid = shift->{uid};
	my $params = shift;

	my $name = $rec->{'name'};
	my $html = '';
	my $table = getConfig('en_tbl');

	my $rating = "";

	if ($Noosphere::baseconf::base_config{RATINGS_MODULE}) {
		$rating .= Noosphere::Ratings::Ratings::ratingForm($rec->{'uid'},$params, $userid);
	}

# related
#
	my $seealso = "";
	if (nb($rec->{'related'})) {
		my @rels = ();
		foreach my $related (split(/\s*,\s*/,$rec->{'related'})) {
			next if (blank($related));
			my $title = objectTitleByName($related);
			if (blank($title)) {
				dwarn "*** encyclopedia metadata: couldn't resolve title for $related";
				next;
			}
			push @rels,"<a href=\"".getConfig("main_url")."/?op=getobj&amp;from=$table&amp;name=$related\">".mathTitle($title, 'highlight')."</a>";
		}
		if (scalar @rels) {
			$seealso .= "See Also: ";
			$seealso .= join(', ',@rels)."<br /><br />\n";
		}
	}

# table for basic metadata plus ratings box
#
	$html .= "<table><tr><td valign=\"top\" style=\"width: 100%;\">";

	$html .= $seealso;

# synonyms
#
	if (nb($rec->{'synonyms'})) { 
		$html.="<table cellpadding=\"0\" cellspacing=\"0\">
			<tr>
			<td valign=\"top\">Other&nbsp;names:&nbsp;</td>
			<td>".displayTitleList($rec->{'synonyms'})."</td>
			</tr>
			</table>";
	}
# defines
#
	if (nb($rec->{'defines'})) { 
		$html.="<table cellpadding=\"0\" cellspacing=\"0\">
			<tr>
			<td valign=\"top\">Also&nbsp;defines:&nbsp;</td>
			<td>".displayTitleList($rec->{'defines'})."</td>
			</tr>
			</table>\n";
	}

# keywords
#
	if (nb($rec->{'keywords'})) { 
		$html.="<table cellpadding=\"0\" cellspacing=\"0\">
			<tr>
			<td valign=\"top\">Keywords:&nbsp;</td>
			<td>".displayTitleList($rec->{'keywords'})."</td>
			</tr>
			</table>\n";
	}

# pronunciation
#
	if (nb($rec->{'pronounce'})) {
		my $text = generatePronunciations($rec->{'title'}, $rec->{'pronounce'});
		my $staticsite = getConfig('siteaddrs')->{'static'};

		$html .= "<br />Pronunciation <font size=\"-1\">(<a href=\"http://$staticsite/doc/jargon.html\">guide</a>)</font>: $text";
	}

	my ($rv,$sth);

# handle parent (this object is /attached/)
#
	if (defined $rec->{'parentid'} && $rec->{'parentid'} != -1) {
		$html .= "<br />";
		$html .= "This object's <a href=\"".getConfig("main_url")."/?op=getobj&amp;from=$table&amp;id=$rec->{parentid}\">parent</a>.<br />";
	} 

# handle attachments 
#
	($rv,$sth) = dbSelect($dbh,{WHAT=>"$table.uid as id,$table.type,$table.name,$table.title,users.username, users.uid as uid",
						  FROM=>"$table, users",
						  WHERE=>"$table.userid=users.uid and parentid=$rec->{uid}",
						  'ORDER BY'=>"created"});
	my @rows = dbGetRows($sth);
	if ($#rows >= 0) {
		$html.="<br />";
		$html .= "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">
			<tr>
			<td class=\"attachmentbox\"><dl><dt><b>Attachments:</b></dt>\n";
		$html .= "<dd>\n";
		foreach my $row (@rows) {
			$html .= getBullet()." ";
			my $tstring = getTypeString($row->{'type'});
			my $name = getUserDisplayName( $row->{'uid'} );
			$html .= "<a href=\"".getConfig("main_url")."/?op=getobj&amp;from=$table&amp;id=$row->{id}\">".mathTitle($row->{'title'},'highlight')."</a> <font size=\"-1\">($tstring)</font> by $name<br />\n";
		}
		$html .= "</dd></dl></td></tr></table>\n";
	}

	$html .= "</td>

		<td style=\"margin-right: 20px;\">" . $rating . "</td></tr></table>";

	$html .= "<font size=\"-1\"><br />\n";

# reference links
#
	my $links = getRenderedObjectLinks($table,$rec->{'uid'},$method);
	warn "\n[$links]\n";
	$links =~ s/&amp,/&amp;/g;	# bugfix
		if (nb($links)) {
			$html.="Cross-references: $links<br />\n";
		}
	my $linksto = xrefGetLinksToCount($table,$rec->{'uid'});
	if ($linksto > 0) {
		$html .= "There ".( ('is','are')[$linksto<=>1] )." <a href=\"".getConfig("main_url")."/?op=getrefs&amp;from=$table&amp;name=$rec->{name}\" title=\"see entries that link to (mention) this entry\">$linksto reference".( ('','s')[$linksto<=>1] )."</a> to this entry.<br />\n";
	}
	if (nb($links) || $linksto > 0) { $html .= "<br />\n" }

# print provenance if object has foreign origin
#
	my $prov = getSourceCollection($table, $rec->{'uid'});	
	if ($prov ne getConfig('proj_nickname')) {
		my $provURL = getProvenanceURL($prov);
		$html .= "Provenance: $provURL.<br />";
	}

# versions
#
	my $mod = ymd($rec->{modified});
	my $cre = ymd($rec->{created});
	my $modprn = ($rec->{modified} eq $rec->{created}) ? '' : ", modified $mod";

	my $main = getConfig('main_url');

	$html .= "This is <a href=\"$main/?op=vbrowser&amp;from=$table&amp;id=$rec->{uid}\" title=\"see past versions of this entry\">version $rec->{version}</a> of ";

	$html .= "<a href=\"$main/encyclopedia/$rec->{name}.html\" title=\"name-based permalink to this entry\">".mathTitle($rec->{'title'}, 'highlight')."</a>";

	$html .=", born on $cre$modprn.<br />\n";

	$html .= "Object id is <a href=\"$main/?op=getobj&amp;from=$table&amp;id=$rec->{uid}\" title=\"id-based permalink to this entry\">$rec->{uid}</a>, canonical name is <a href=\"$main/encyclopedia/$rec->{name}.html\" title=\"name-based permalink to this entry\">$rec->{name}</a>.<br />\n";

	my $tags = getTags($table, $rec->{'uid'});
	$html .= "Tags: " . join(', ', keys %$tags) . "<br/>";
	$html .= "Accessed $rec->{hits} times total.<br />\n";

	$html .= "</font>";

# classification
#
	my $class = printclass($table,$rec->{uid},'-1');
	if (nb($class)) {
		$html .= "<br />Classification:<br />\n";
		$html .= "$class";
	}

	return $html;
}


# get a list of all encyclopedia entries by various sort orders
#
sub encyclopediaList {
	my $params = shift;
	my $userinf = shift;

	my $otbl = getConfig('en_tbl');
	my $utbl = getConfig('user_tbl');
	my $ltbl = getConfig('xref_tbl');

	my $xml = '';
	my $template = new XSLTemplate('encyclopedialist.xsl');
	$params->{'offset'} = $params->{'offset'} || 0;
	my $limit = $userinf->{'prefs'}->{'pagelength'};

	my $mode = $params->{'mode'}; # sort key 

# define available filters
# 
	my $ts = getConfig('typestrings');
	my $type_filters = [ map "= $_", keys %$ts ];			# array of relational RHS's ( = 1, etc)
	my $type_strings = [ map "= $ts->{$_}", keys %$ts ];	# array of readable RHS's ( = theorem, etc)
	my %filters = (
			'type' => {'strings' => $type_strings, 'filters' => $type_filters}
		);

# pull out filter clause, if supplied, and make relational statement
#
	my $filterstr = "";
	foreach my $key (keys %$params) {
		if ($key =~ /^filters\.(\w+)$/io && $params->{$key} ne 'null') {
			my $attribute = lc($1);

			my $index = $params->{$key};
			my $fs = "$otbl.".$attribute.' '.$filters{$attribute}->{'filters'}->[$index];

			$filterstr .= 'and '.$fs;
		}
	}

# build query.  dont do hideous 3-table join unless we're in 'inlinks' mode.
#
	my $qcount = "select * from $otbl, tags where tags.objectid = $otbl.uid and tags.tag = 'NS:published' $filterstr";
	my $query = "select distinct $otbl.*, username, $utbl.uid as userid, 1 as inlinks from $otbl, $utbl, tags where tags.objectid = $otbl.uid and tags.tag = 'NS:published' and $otbl.userid=$utbl.uid $filterstr order by $mode desc limit $params->{offset}, $limit";

	if ($mode eq 'inlinks') {
		$query = "select $otbl.*, username, count($ltbl.toid) as inlinks from $otbl, $utbl left outer join $ltbl on $otbl.uid = $ltbl.toid, tags where tags.objectid = $otbl.uid and tags.tag = 'NS:published' and $otbl.userid=$utbl.uid and (($ltbl.fromtbl = '$otbl' and $ltbl.totbl = '$otbl') or ($ltbl.toid is NULL)) $filterstr group by $otbl.uid order by $mode desc limit $params->{offset}, $limit";
	}
	my $sth = $dbh->prepare($query);

	$sth->execute();

	if ( $sth->rows() < 0 ) {
		
		warn "$dbh->errstr in encyclopediaList";
#		print "We are currently upgrading this action. Current error for development purposes is printed here: " .$dbh->errstr;
	}

	my $sth2 = $dbh->prepare($qcount);
	$sth2->execute();
	$params->{'total'} = $sth2->rows();
	$sth2->finish();

	$template->addText("<entries mode=\"$mode\">");

# define available filters
#
	if (scalar keys %filters) {
		$template->addText("	<filters ");

# pass through current filters as CGI string suffix
# 
		my $currentstr = "";
		my $readable = "";
		foreach my $key (keys %$params) {
			if ($key =~ /^filters\.(\w+)$/io && $params->{$key} ne 'null') {
				my $attr = lc($1);

				my $cs = "$key=$params->{$key}";
				my $cr = "$attr $filters{$attr}->{'strings'}->[$params->{$key}]";
				if ($currentstr) {
					$currentstr .= "&amp;$cs";
					$readable .= ", $cr";
				} else {
					$currentstr = $cs;
					$readable = $cr;
				}
			}
		}
		if ($currentstr) {
			$template->addText("current=\"$currentstr\" current_readable=\"$readable\"");
		}

		$template->addText(">");
		foreach my $key (keys %filters) {
			$template->addText("		<filter attribute=\"$key\" ");

# output selected attribute value if any
#
			if (defined($params->{"filters.$key"}) && $params->{"filters.$key"} ne 'null') {
				$template->addText(" selected=\"".$params->{"filters.$key"}."\"");
			}

			$template->addText(">");

			my $fstrings = $filters{$key}->{'strings'};

			for (my $i = 0; $i < scalar @$fstrings ; $i++) {

				$template->addText("			<option name=\"$fstrings->[$i]\" code=\"$i\" ");

# output selected flag if this attribute-value is selected
#
				if ($params->{"filters.$key"} == $i) {
					$template->addText(" selected=\"yes\"");
				}

				$template->addText("/>");
			}

			$template->addText("		</filter>");
		}

		$template->addText("	</filters>");

	}

# output entries
#
	while (my $row = $sth->fetchrow_hashref()) {

		my $cdate = mdhm($row->{'created'});
		my $mdate = mdhm($row->{'modified'});
		my $title = mathTitleXSL($row->{'title'}, 'highlight');
		my $authors = get_authors_html ( $row->{'uid'} );
		my $username = getUserDisplayName( $row->{'userid'} );
#		my $username = htmlescape($row->{'username'});
		my $href = getConfig('main_url')."/?op=getobj&amp;from=objects&amp;id=$row->{uid}";
		my $uhref = getConfig('main_url')."/?op=getuser&amp;id=$row->{userid}";

		$xml .= "		<entry>";
		$xml .= "			<inlinks>$row->{inlinks}</inlinks>";
		$xml .= "			<hits>$row->{hits}</hits>";
		$xml .= "			<mdate>$mdate</mdate>";
		$xml .= "			<cdate>$cdate</cdate>";
		$xml .= "			<title>$title</title>";
		$xml .= "			<username>$authors</username>";
		$xml .= "			<href>$href</href>";
		#$xml .= "			<uhref>$uhref</uhref>";
		$xml .= "		</entry>";
	}

	$template->addText($xml);
	$template->addText('</entries>');

	getPageWidgetXSLT($template, $params, $userinf);

	return $template->expand();
}

# format a raw list of titles (synonyms, defines) in string form, suitable for
# display
#
sub displayTitleList {
	my $list = shift;	# comma-separated list

		my ($text, $math) = escapeMathSimple($list);

	return join(', ',(map { mathTitle(unescapeMathSimple($_, $math)) } split(/\s*,\s*/, $text)));
}

# display the preamble of an entry
#
sub getPreamble {
	my $params = shift;

	my $template = new XSLTemplate('preamble.xsl');

	my $preamble = htmlescape(lookupfield(getConfig('en_tbl'),'preamble',"uid=$params->{id}"));
	my $title = htmlescape(lookupfield(getConfig('en_tbl'),'title',"uid=$params->{id}"));

	$template->addText("<preamble>\n");
	$template->addText("	<objectid>$params->{id}</objectid>\n");
	$template->addText("	<table>".getConfig('en_tbl')."</table>\n");
	$template->addText("	<title>$title</title>\n");
	$template->addText("	<text>$preamble</text>\n");
	$template->addText("</preamble>\n");

	return $template->expand();
}

# show screen with references to an object
#
sub getEnRefsTo {
	my $params = shift;

	my $html = '';

	my $id = ($params->{'name'} ? getidbyname($params->{'name'}):$params->{'id'});
	my $table = $params->{'from'};

	my @refs = xrefGetLinksTo($table,$id);

	my $idx = 1;
	foreach my $ref (@refs) {
		$html .= "$idx. 

			<a href=\"".getConfig("main_url")."/?op=getobj&from=$table&name=$ref->{name}\">$ref->{title}</a>

			<font size=\"-1\">
			by <a href=\"".getConfig("main_url")."/?op=getuser&id=$ref->{userid}\">$ref->{username}</a>
			</font>

			<br />";
		$idx++;
	}

	my $title = lookupfield($table,'title',"uid=$id");

	return paddingTable(clearBox("References to '$title'",$html));
}

# get a character for a type
#
sub getTypeChar {
	my $type = shift;

	my $typechars = getConfig('typechars');

	return $typechars->{$type} if (defined $typechars->{$type});

	return '?';
}

# get a string for a type
#
sub getTypeString {
	my $type = shift;

	my $typestrings = getConfig('typestrings');

	return $typestrings->{$type} if (defined $typestrings->{$type});

	return '?';
}
# interface to Encyclopedia browsing (alphabetical by default) 
#
sub browseEncyclopedia {
	my $params = shift;

	my $idx = $params->{idx};
	my $content = '';
	my $letter = '';

	my $table = getConfig('en_tbl');
	my $index = getConfig('index_tbl');

	if (defined($idx)) {
		$letter = pack('C',$idx);
	}

# link to the msc browser for encylcopedia
#
	$content .= "<center><font size=\"+1\"><i>You can also browse by:</i> 

		<a href=\"".getConfig("main_url")."/browse/objects/\">subject</a> |
		<a href=\"".getConfig("main_url")."/?op=enlist&amp;mode=hits\">popularity</a> |
		<a href=\"".getConfig("main_url")."/?op=enlist&amp;mode=modified\">latest modified</a> |
		<a href=\"".getConfig("main_url")."/?op=enlist&amp;mode=created\">latest added</a>

		</font></center>";

# build the index selector with an initial query.
#
	my ($rv,$sth) = dbSelect($dbh,{WHAT=>"ichar as idx, count(distinct $index.objectid) as cnt", FROM=>"$index,tags", WHERE=>"tbl='$table' AND tags.objectid=$index.objectid AND tag = 'NS:published'", 'GROUP BY'=>'idx'});

	my @rows = dbGetRows($sth);
	$content .= "<table width=\"90%\" align=\"right\"><td><dl>";
	foreach my $row (@rows) {
		my $num = ord($row->{idx});
		$content .= "<dt>";
		$content .= "<font class=\"indexfont\" size=\"+1\"><a href=\"/encyclopedia/$row->{idx}/\">$row->{idx}</a></font> - $row->{cnt} ";
		$content .= ($row->{'cnt'}>1) ? 'entries' : 'entry';
		$content .= "</dt>";
		if ($letter eq $row->{'idx'}) {
			$content .= "<dd>";
			($rv,$sth) = dbSelect($dbh,{WHAT=>"distinct $index.objectid,$index.type,$index.cname as name,$index.title,users.username,$index.userid as userid", FROM=>"$index,users,tags", WHERE=>"ichar = '$letter' AND ((users.uid=$index.userid AND tbl='".getConfig('en_tbl')."')) AND tags.objectid=$index.objectid AND tags.tag = 'NS:published'"});

			my @objects = dbGetRows($sth);
			$content .= "<table>";
			foreach my $object (sort {cleanCmp(mangleTitle($a->{title}),mangleTitle($b->{title}))} @objects) {
				$content .= "<tr><td>";

				my $mtitle = mangleTitle($object->{title});
				$content .= "<a href=\"/encyclopedia/$object->{name}.html\">".mathTitle($mtitle, 'highlight')."</a>";

# take account of synonyms 
#
				if ($object->{'type'} == 2) {
					my $parenttitle = lookupfield($index,'title',"objectid=$object->{objectid} and type=1 and tbl='$table'");

					$content .= " (=<i>".mathTitle($parenttitle)."</i>)";
				}	

# take account of defines
#
				elsif ($object->{'type'} == 3) {
					my $parenttitle = lookupfield($index,'title',"objectid=$object->{objectid} and type=1 and tbl='$table'");

					$content .= " (in <i>".mathTitle($parenttitle)."</i>)";
				}
				$content .= ' owned by ';
				$content .= get_authors_html($object->{'objectid'});
#				$content .= getUserDisplayName($object->{'userid'});
				$content .= "</td></tr>";
			}
			$content .= "</table>";
			$content .= "</dd>";
		}
	}
	$content .= "</dl>";
	$content .= "</td></table>";

# count distinct entries
#
#	($rv,$sth) = dbSelect($dbh,{WHAT=>'count(uid) as cnt',FROM=>"$table,tags",WHERE=>"tag = 'NS:published' and $table.uid = tags.objectid'"});
	my $sth = $dbh->prepare("select count(uid) as cnt from $table,tags where tag = 'NS:published' and $table.uid = tags.objectid");
	$sth->execute();
	my $row = $sth->fetchrow_hashref();
	my $count = $row->{'cnt'};
	$sth->finish();

# count titles and defines entries; these are individual "concepts"
#
#	($rv,$sth) = dbSelect($dbh,{WHAT=>'count(*) as cnt',FROM=>$index,WHERE=>"tbl = '$table' and (type = 1 or type = 3)"});
	my $sth = $dbh->prepare("select count(*) as cnt from $index,tags where tbl='$table' and (type=1 or type=3) and $index.objectid = tags.objectid and tag = 'NS:published'");
	$sth->execute();
	$row = $sth->fetchrow_hashref();
	my $concepts = $row->{'cnt'};
	$sth->finish();

# build output
#
	$content = clearBox(getConfig('projname').' Encyclopedia',$content);
	my $interact .= makeBox("Interact","<center><a href=\"".getConfig("main_url")."/?op=adden\">add</center>");
	my $html = "<table cellpadding=\"2\" cellspacing=\"0\">
		<tr>
		<td>$content</td>
		</tr>
		<tr>
		<td><center>
		$count published entries total.  <br />
		$concepts published concepts total.
		</center>
		</td>
		</tr>
		<tr>
		<td>$interact</td>
		</tr></table>";
	return $html;
}

# addEncyclopedia - main interface to adding something to the Encyclopedia
#
sub addEncyclopedia {
	my ($params,$user_info,$upload) = @_;

	my $template = new XSLTemplate('addencyclopedia.xsl');
	my $table = getConfig('en_tbl');



	$template->addText('<entry>');
	

	return errorMessage('You can\'t post anonymously.') if ($user_info->{uid} <= 0);

# handle post - done editing
#
	if (defined $params->{'post'}) {
		return insertEncyclopedia($params, $user_info, 0);
	}
	if (defined $params->{'postandrequest'}) {
		if ( ! is_approved_author( $user_info->{'uid'} ) ) {
			request_publication( $params, $user_info);
		}
		return insertEncyclopedia($params, $user_info, 1);
	}

# handle preview 
#
	elsif (defined $params->{'preview'}) {
		$AllowCache = 0;	# kill caching

		previewEncyclopedia($template,$params,$user_info);
		handleFileManager($template,$params,$upload);
	} 

	elsif (defined($params->{filebox})) {
		handleFileManager($template, $params, $upload);
	}

# initial request, return blank form
#
	else {
# initialize parent data
#
		if ($params->{parent}) {
			$template->setKeys(
					'parent' => $params->{parent},
					'title' => $params->{title},
					'class' => classstring($table, getidbyname($params->{parent}))
					);
		}
# initialize request data
#
		if ($params->{request}) {
			$template->setKey('title', $params->{title});
		}
		$template->setKey('preamble', $user_info->{data}->{preamble});

		handleFileManager($template, $params);
	}

	refreshAddEncyclopedia($template, $params);
	my $tagstring = getNSTagsControl();
	$template->setKey('optionaltags', $tagstring);

	$template->addText('</entry>');

	return paddingTable(clearBox('Add to the Encyclopedia',$template->expand()));
}

# delete synonyms for an object
#
sub deleteSynonyms { 
	my $table = shift;
	my $uid = shift;	

	my $index = getConfig('index_tbl');

# delete existing synonyms if existing record
#
	if (defined $uid) {
		my ($rv,$sth) = dbDelete($dbh,{FROM=>$index,WHERE=>"tbl='$table' and objectid=$uid and type>1"});

		$sth->finish();
	}
}

# get a list of synonyms for an object
#
sub getSynonymsList {
	my $id = shift;

	my $table = getConfig('en_tbl');

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'synonyms',FROM=>$table,WHERE=>"uid=$id"});
	my $row = $sth->fetchrow_hashref();
	my $string = $row->{synonyms};
	$sth->finish();
	if (nb($string)) {
		return [splitindexterms($string)];
	} else {
		return [()];
	}
}

# get a list of defines for an object
#
sub getDefinesList {
	my $id = shift;

	my $table = getConfig('en_tbl');

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'defines',FROM=>$table,WHERE=>"uid=$id"});
	my $row = $sth->fetchrow_hashref();
	my $string = $row->{defines};
	$sth->finish();

	if (nb($string)) {
		return [splitindexterms($string)];
	} else {
		return [()];
	}
}

# createSynonyms - set the synonym records for an object
#
sub createSynonyms {
	my $synonyms = shift;	# synonym string
		my $userid = shift;		# user id of creator
		my $title = shift;		# title of master object
		my $name = shift;		# unique name of master object
		my $uid = shift;		# unique id of master object 
		my $type = shift || 2;	# 2=synonym, 3=defines (1 is master object)
		my $source = shift || getConfig('proj_nickname'); # source collection

		my $table = getConfig('en_tbl');
	my $index = getConfig('index_tbl');

# make synonym links 
#
	if (nb($synonyms)) {
		my @syns = splitindexterms($synonyms);
		foreach my $syn (@syns) {
#warn "processing synonym $syn";
#dwarn "processing synonym (type=$type) $syn";
			$syn =~ s/^\s*//;
			$syn =~ s/\s*$//;	
				my $sname = uniquename(swaptitle($syn),$name);

			my $ichar = getIndexChar(mangleTitle($syn));

# insert records into main object index table
#
			my $sth = $dbh->prepare("insert into $index (objectid,tbl,userid,title,cname,type,source,ichar) values (?,?,?,?,?,?,?,?)");
			my $rv = $sth->execute($uid, $table, $userid, $syn, $sname, $type, $source, $ichar);
			$sth->finish();
		}
	}
}

# actually insert the item into the database
#
sub insertEncyclopedia {
	my ($params,$userinf, $requestpub) = @_;

	$params->{title} = htmlToLatin1($params->{title}); 
	$params->{title} =~ s/^\s*//;
	$params->{title} =~ s/\s*$//;

	my $thash = {reverse %{getConfig("typestrings")}};
	my $type = $thash->{$params->{'type'}}; 
	my $name = uniquename(swaptitle($params->{'title'}));

# some browsers may be doing something weird and sending the POST data
# twice, if this is the case, checking for $name in the database should stop
# the second submit
#
# APK 2003-06-11 : this check has to be rewritten, it is flawed and cannot
# possibly work (think about how names are generated)
# 
# APK 2003-10-12 : best way would be to get a new entry ID on the blank
# submission form, then force the insert to use this ID.  multiple submits
# would then have an ID collision. (duh)
# 
	return errorMessage('Something strange happened; your browser may have sent your submission twice.	Check to make sure your object is there, and is there only once.') if (objectExistsByName($name));


	my $related = (defined($params->{related}))?$params->{related}:'';
	my $synonyms = (defined($params->{synonyms}))?$params->{synonyms}:'';
	my $defines = (defined($params->{defines}))?$params->{defines}:'';
	my $keywords = (defined($params->{keywords}))?$params->{keywords}:'';
	my $pronunciation = normalizePronunciation($params->{title}, $params->{pronounce});

	my $table = getConfig('en_tbl'); 
	my $next = nextval("${table}_uid_seq");

	my $cols = 'created, modified,uid,version,type,userid,title,preamble,data,name,related,synonyms,defines,keywords,pronounce,self, parentid';

	my $parentid = undef;
	if (nb($params->{'parent'})) {
		$parentid = getidbyname($params->{'parent'});
	}

	my $sth = $dbh->prepare("insert into $table ($cols) values (now(), now(), ?, 1, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

	my $rv = $sth->execute($next, $type, $userinf->{'uid'}, $params->{'title'}, $params->{'preamble'}, $params->{'data'}, $name, $related, $synonyms, $defines, $keywords, $pronunciation, ($params->{'self'} eq 'on' ? 1 : 0), $parentid);

	if (! $rv) {
		return errorMessage("Couldn't insert your item");
	}

	$params->{id} = $next;
	#handle tags
        my $newtagstring = $params->{'tags'};
        my @newtags = split( /\s*,\s*/, $newtagstring );
        my $userid = $userinf->{'uid'};
        my %newmap = map { $_ => $userid } @newtags;
#        foreach my $k (keys  %$oldtags ) {
#                $newmap{$k} = $oldtags->{$k};
#        }

        updateTags( $params->{'id'}, \%newmap );


# take care of files
#
	moveTempFilesToBox($params,$next,getConfig('en_tbl'));

# handle title indexing
#
#we turn off indexing the title because we don't want the entry to show up until
# an admin or editor approves the entry to be added to the collection.
#
	indexTitle($table,$params->{id},$userinf->{uid},$params->{title},$name);
	deleteSynonyms($table,$params->{id});
	createSynonyms($synonyms,$userinf->{uid},$params->{title},$name,$params->{id},2);
	createSynonyms($defines,$userinf->{uid},$params->{title},$name,$params->{id},3);

# handle scoring
#
	changeUserScore($userinf->{uid},getScore('addgloss'));

# new watch on the object
#
	addWatchIfAllowed(getConfig('en_tbl'),$params->{id},$userinf,'objwatch');

# index this entry (for link invalidation) this now handled by nnexus and should not
# be done in Noosphere.
#
#	invalIndexEntry($params->{'id'});
#	warn "made it passed invalIndexEntry";

# index this entry (for IR)
#
	irIndex(getConfig('en_tbl'),$params) if ( is_published( $params->{id} ) );
#	warn "made it past irindex\n";

# handle classification
#
	my $classcount = classify($table,$params->{id},$params->{class});
#	warn "made it past classify\n";

	add_author( $userinf->{'uid'}, $params->{'id'}, 'LA' );


# add an ACL record
#
#	installDefaultACL($table,$params->{id},$userinf->{uid});

#	warn "made it past installDefaultACL\n";
# invalidate objects based on title (for cross referencing)
#
#	xrefTitleInvalidate($params->{'title'},$table);
#	warn "made it past xrefTitleInvalidate\n";

# make "related" links symmetric
#
	symmetricRelated($name,$related,$userinf);

	warn "made it past symmetricRelated\n";

	NNexus_addobject( 'localhost', '7071',
				$params->{'title'},
					$params->{'data'},
					$next,
					$userinf->{'uid'},
					"",
					$params->{'class'},
					$synonyms,
					$defines);

# fill any requests
#
		if ($params->{request} && $params->{request} != -1) {
			fillReq($params->{request},$userinf,$table,$params->{id});
		}

# update statistics
#
		$stats->invalidate('unproven_theorems') if ($type == THEOREM());
		$stats->invalidate('unclassified_objects') if (!$classcount);
		$stats->invalidate('latestadds');

		my $id = $params->{'id'};
		my $published = "The entry has not been published publicly; click <a href=\"" . getConfig("main_url")."/?op=requestpublication&amp;from=$table&amp;id=$id\">here</a> to request publication.";
		if ( is_approved_author( $userinf->{'uid'} ) and $requestpub ) {
			do_publish( $id, $userinf->{'uid'} );
			
			irIndex($table, $params); 
			$published = "Congratulations! You are an approved author and your entry has been published publicly." 
		}

		return paddingTable(clearBox('Added',"Thank you for your addition to ".getConfig('projname').".	Click <a href=\"".getConfig("main_url")."/?op=getobj&from=$table&name=$name\">here</a> to see it. $published <br/><br/>The submission of an article assumes acceptance of the conditions stated in the section \"<a href=\"".getConfig("main_url")."/?op=license\">Legalese</a>.\" "));
}

# "publish" an item from a foreign collection.  note: need a local userid.
#
	sub publishEncyclopedia {
		my ($params, $userid, $source) = @_;

		my $userinf = {userInfoById($userid)};

		$params->{title} = htmlToLatin1($params->{title}); 
		$params->{title} =~ s/^\s*//;
		$params->{title} =~ s/\s*$//;

		my $thash = {reverse %{getConfig("typestrings")}};
		my $type = $thash->{$params->{type}}; 
		my $name = uniquename(swaptitle($params->{title}));

		my $related = (defined($params->{related}))?$params->{related}:'';
		my $synonyms = (defined($params->{synonyms}))?$params->{synonyms}:'';
		my $defines = (defined($params->{defines}))?$params->{defines}:'';
		my $keywords = (defined($params->{keywords}))?$params->{keywords}:'';
		my $pronunciation = normalizePronunciation($params->{title}, $params->{pronounce});

		my $table = getConfig('en_tbl'); 
		my $next = nextval("${table}_uid_seq");

		my $cols = 'created, modified,uid,version,type,userid,title,preamble,data,name,related,synonyms,defines,keywords,pronounce,self, parentid';

		my $parentid = undef;
		if (nb($params->{'parent'})) {
			$parentid = getidbyname($params->{'parent'});
		}

		my $sth = $dbh->prepare("insert into $table ($cols) values (now(), now(), ?, 1, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

		my $rv = $sth->execute($next, $type, $userinf->{'uid'}, $params->{'title'}, $params->{'preamble'}, $params->{'data'}, $name, $related, $synonyms, $defines, $keywords, $pronunciation, ($params->{'self'} eq 'on' ? 1 : 0), $parentid);

		if (! $rv) {
			return 0;
		}

		$params->{id} = $next;

# handle title indexing
#
		indexTitle($table,$params->{id},$userinf->{uid},$params->{title},$name, $source);
		deleteSynonyms($table,$params->{id});
		createSynonyms($synonyms,$userinf->{uid},$params->{title},$name,$params->{id},2, $source);
		createSynonyms($defines,$userinf->{uid},$params->{title},$name,$params->{id},3, $source);

# handle scoring
#
		changeUserScore($userinf->{uid},getScore('addgloss'));

# new watch on the object
#
		addWatchIfAllowed(getConfig('en_tbl'),$params->{id},$userinf,'objwatch');

# index this entry (for linking)
#
		invalIndexEntry($params->{'id'});

# index this entry (for IR)
#
		irIndex(getConfig('en_tbl'),$params);

# handle classification
#
		my $classcount = classify($table,$params->{id},$params->{class});

# add an ACL record
#
#		installDefaultACL($table,$params->{id},$userinf->{uid});

# invalidate objects based on title (for cross referencing)
#
		xrefTitleInvalidate($params->{title},$table);

# make "related" links symmetric
#
		symmetricRelated($name,$related,$userinf);

# add the user to the author list
#
		addAuthorEntry($table,$params->{id},$userinf->{uid});

# update statistics
#
		$stats->invalidate('unproven_theorems') if ($type == THEOREM());
		$stats->invalidate('unclassified_objects') if (!$classcount);
		$stats->invalidate('latestadds');

		return 1;
	}

# refreshAddEncyclopedia - carry over param values for the Add form
#
	sub refreshAddEncyclopedia {
		my $template = shift;
		my $params = shift;

		my $type = $params->{type} || 'Definition';

		my $fillreq = getRequestFiller($params);

		my $ttext = gettypebox({reverse %{getConfig("typestrings")}}, $type);

		$template->setKeys('fillreq' => $fillreq, 'tbox' => $ttext, 'typeis' => $type);
		$template->setKeysIfUnset(%$params);
	}

# preview the math item (render it) and handle the preview form
#
	sub previewEncyclopedia {
		my ($template, $params, $userinf) = @_;

		my $name = normalize(swaptitle($params->{'title'}));
		my $error = '';
		my $warn = '';

		my $method = $userinf->{'prefs'}->{'method'} || 'l2h';

# check for errors in entered data
#
		($error,$warn) = checkEncyclopediaEntry($params,1, $userinf->{'uid'});

# do our rendering if there were no errors
#
		if ($error eq '') {
			my $preview = renderEnPreview(1, $params, $method);
			$template->setKey('showpreview', $preview);
		} 

# if there were no errors, put up the "post" button.
#
		if ($error eq '') {
			$template->setKey('post', '<input TYPE="submit" name="post" VALUE="post" />');
		}

# insert error messages
#
		$error .= $warn;	 # toss in warnings now
			if ($error ne '') { $error .= '<hr />'; }
		$template->setKey('error', $error);
	}

# make sure encyclopedia metadata is kosher
#
	sub checkEncyclopediaEntry {
		my $params = shift;
		my $checktitle = shift;
		my $userid = shift;

		$params->{title} = htmlToLatin1($params->{title});

		my $name = uniquename(swaptitle($params->{title}));
		my $error = '';
		my $warn = '';

		warn "Checking and getting tags for $params->{id}";
		my $oldtags = getTags($params->{'from'}, $params->{'id'});
	        my $newtagstring = $params->{'tags'};
       		my @newtags = split( /\s*,\s*/, $newtagstring );
	        my %newmap = map { $_ => 1 } @newtags;
		if ( not ( is_editor( $userid ) or is_admin($userid) ) ) {
       		foreach my $k (keys  %$oldtags ) { 
               		if ( $k =~ /^NS:/ && ! (defined $newmap{$k}) ) { 
				$error .= "You cannot change tag $k<br />";
			}
                }
		}


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

# check title
#
		if ($checktitle == 1) {
			if (blank($params->{title})) {
				$error .= "Need a title!<br	/>";
			} else {
# check for duplicate name
#
				my $dname = normalize(swaptitle($params->{title}));
				if (objectExistsByName($dname)) {
					$warn .= "warning: Possible duplicate entry. Please check out <a href=\"/encyclopedia/$dname.html\" target=\"viewwin\">this</a> object, and related objects, to see if you really want to proceed.<br />";
				}
			}
		}

# check content
#
		if (blank($params->{data})) {
			$error .= "Need some content!<br />";
		}

# clean up association fields
#
		foreach my $key ('related','synonyms','keywords') {
			$params->{$key} =~ s/,\s+,/, /g;
			$params->{$key} =~ s/, *$//;
		}

# check related's
#
		if (nb($params->{related})) {
			my @rels=split(/\s*,\s*/,$params->{related});
			foreach my $rel (@rels) {
				if (not objectExistsByName($rel)) {
					$error .= "Cannot find related object '$rel'<br />";
				}
			}
		}

# bad parent reference check 
#
		if (isAttachmentType($params->{type})) {
			if (blank($params->{parent}) || !objectExistsByAny($params->{parent})) {
				$error .= "Need a valid parent object reference for that type of entry.<br />";
			}
		}

# check for later version in database. for new addition, version will be 0
# and this check will be skipped.
#
		if ($params->{'version'}) {

			my $dbversion = lookupfield($params->{'from'}, 'version', "uid=$params->{id}");

# if database verison is greater than checked out version, we're in
# trouble. that means someone else did an update since we checked out.
#
			if ($dbversion > $params->{'version'}) {

				$error .= "Someone else has checked in a more recent copy of this entry! To resolve any possible edit conflicts, you should open up a new edit window for this entry, integrate the new source with the current source you are working on, and check in the new version.<br />";
			}
		}

		return ($error,$warn);
	}

# rendering wrapper - returns an error message if rendering fails.
#
sub renderEnPreview {
	my $newent = shift;	 # new entry flag
	my $params = shift;
	my $method = shift;

	my $name = normalize($params->{'title'});
	my $title = htmlescape(swaptitle($params->{'title'}));
	my $math = $params->{'data'};
	my $dir = '';
	my $root = getConfig('cache_root');

# figure out cache dir. it really should already exist for us.
#
	if (defined $params->{'tempdir'}) {
		$dir = $params->{'tempdir'};
	} else {
		$dir = makeTempCacheDir();
		warn "temp cache dir = $dir";
		$params->{'tempdir'} = $dir;
	}
warn "going to try to render a preview to $dir";

# copy files from main dir to method subdir
#
warn "preview files go in $root/$dir/$method";
	if (not -e "$root/$dir/$method") {
		mkdir "$root/$dir/$method";
	}
#dwarn "changing dir to $dir";
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
#	my $outfile = getConfig('rendering_output_file');
	my $outfile = "unlinked.html";

	#preview does not show linked mode. We only show linked
	#mode after the article is added to the encyclopedia
	if (-e "$root/$dir/$method/$outfile") {
		`rm $root/$dir/$method/$outfile`;
	}

# do the rendering
#
	my ($latex,$links) = prepareEntryForRendering($newent,
				$params->{'preamble'},
				$math,
				$method,
				$title,
				[splitindexterms($params->{synonyms}),
				splitindexterms($params->{defines})],
				$params->{'table'},
				defined $params->{'id'} ? $params->{'id'} : '0',
				$params->{'class'});

	my $table = getConfig('en_tbl');
	renderLaTeX('.', $dir, $latex, $method, $name);

# if we succeeded, show preview
#
	my $file = "$root/$dir/$method/$outfile";

	warn "READING Preview from $file\n";
#my $size = (stat($file))[7];
#if ( defined($size) && $size > 0 ) {
#	my $preview = readFile($file);
	my $text = readFile($file);
	warn "PREVIEW FILE CONTAINS $text";
#	my $preview = mathBox(mathTitle($title,'title'),$text);

	return mathBox(mathTitle($title), $text);
#	return $preview;
#} 
	}

	sub getStyleGuidelines {
		my $guidelines = new Template('style_guidelines.html');
		return paddingTable(clearBox('Content and Style Guidelines', $guidelines->expand()));
	}

	sub getUserGuidelines {
		my $guidelines = new Template('user_guidelines.html');
		return paddingTable(clearBox('User Guidelines', $guidelines->expand()));
	}

# get a little associations guidelines screen 
#
	sub getAssocGuidelines {
		my $guidelines = new Template('assoc_guidelines.html');

		return paddingTable(clearBox('Association Guidelines', $guidelines->expand()));
	}

# get a little latex guidelines screen 
#
	sub getLatexGuidelines {
		my $guidelines = new Template('latex_guidelines.html');
		my $file = getConfig('entry_template');
		my $latextemplate = new Template($file);

		$latextemplate->setKeys('packages' => '$packages', 'preamble' => '$preamble', 'math' => '$math');
		$guidelines->setKey('template', $latextemplate->expand());

		return paddingTable(clearBox('LaTeX Guidelines',$guidelines->expand()));
	}

# make "related" links symmetric
#
	sub symmetricRelated {
		my $name = shift;		# name of parent object
			my $related = shift; # related string
			my $userinf = shift; # user info

# we only do this if the user wants it
#
			return if (not $userinf->{prefs}->{symrelated});

		my @rels = split(/\s*,\s*/,$related);

		foreach my $rel (@rels) {
			my $id = getidbyname($rel);
			dwarn "*** related: checking id $id from related line";
			if ($id != -1) {
				my $userid = lookupfield(getConfig('en_tbl'),'userid',"uid=$id");

# the only way we can set symmetric for sure is if the same user owns
# both objects, and they have "accept related" on as well
#
				if ($userid == $userinf->{uid} &&
						$userinf->{prefs}->{acceptrelated} eq 'on') {

					addRelated($id,$name); 
				}

# send notice to user who owns the other entry
#
				else {
					notifyRelated($rel,$id,$userid,$name,$userinf->{uid});
				}
			}
		}
	}

# send a related notice, OR, if the user has auto-accept on, make the link 
# and send a notice
#	OR send them a prompt
#
	sub notifyRelated {
		my $rel = shift;				# the related object (target) name
			my $id = shift;				 # the id of that object
			my $userid = shift;		 # the user who owns it
			my $name = shift;			 # name of the invoking (source) object
			my $owner = shift;			# owner of the invoking object

			my $en = getConfig('en_tbl');
		my $related = lookupfield($en,'related',"uid=$id");

		my $target_title = lookupfield(getConfig('index_tbl'), 'title', "objectid=$id and tbl='$en'");
		my $source_title = lookupfield(getConfig('index_tbl'), 'title', "cname='$name' and tbl='$en'");

		if (not inset($name,split(/\s*,\s*/,$related))) {

# auto-accept is on, set the link and send a notice
#
			my $relpref = userPref($userid,'acceptrelated');
			if ($relpref eq 'on') {
				fileNotice($userid,
						$owner,
						'An entry has been set as related to one of yours',
						'(Your entry has automatically been set related to it.)',
						[{id=>$id,table=>$en},
						{id=>getidbyname($name),table=>$en}]
						);
				addRelated($id,$name); 
			} 

# suggest
#
			elsif ($relpref eq 'off') {

				if (not madeSuggestion($id,$en,$name)) {
					fileNotice($userid,
							$owner,
							'An entry has been set as related to one of yours',
							'(you may want to set yours related to it as well.)',
							[{id=>$id,table=>$en},
							{id=>getidbyname($name),table=>$en}]
							);
					addSuggestion($id,$en,$name);
				}
			}

# prompt
#
			elsif ($relpref eq 'ask') {
				if (not madeSuggestion($id, $en, $name)) {
					filePrompt($userid,
							$owner, 
							'An entry has been set as related to one of yours',
							"Shall I set '$target_title' related to '$source_title'?",
							-1, # default = do nothing
							[['make symmetric link', urlescape("op=make_symmetric&from=$en&id=$id&to=$name")]],
							[{id=>$id,table=>$en},
							{id=>getidbyname($name),table=>$en}]
							);

					addSuggestion($id,$en,$name);
				}
			}
		}
	}

# complete the symmetry of a related link by adding the given name to the 
# related list of a target object.
#
# this is meant to be called from the notice options dispatch, not directly.
#
	sub makeSymmetric {
		my $params = shift;
		my $userinf = shift;

		my %fields = getfieldsbyid($params->{id}, $params->{from}, 'title, userid');
		my $desttitle = lookupfield(getConfig('index_tbl'), 'title', "cname='".sq($params->{to})."'");

		return "You don't own '$fields{title}'!" if ($userinf->{uid} != $fields{userid});

		my $set = addRelated($params->{id}, $params->{to});	

		return $set 
			? "Related link added from '<a href=\"".getConfig("main_url")."/?op=getobj&from=$params->{from}&id=$params->{id}\">$fields{title}</a>' to '<a href=\"".getConfig("main_url")."/?op=getobj&from=&params->{from}&name=$params->{to}\">$desttitle</a>'" 
			: "Related link to '<a href=\"".getConfig("main_url")."/?op=getobj&from=&params->{from}&name=$params->{to}\">$desttitle</a>' was already present in '<a href=\"".getConfig("main_url")."/?op=getobj&from=$params->{from}&id=$params->{id}\">$fields{title}</a>'!";
	}

# add a related to a particular entry if it's not already there
#
	sub addRelated {
		my $id = shift;	 # id of the target entry
			my $rel = shift;	# related name to add

			my $set = 0;	 # set flag

			my $related = lookupfield(getConfig('en_tbl'),'related',"uid=$id");

		if (! inset($rel,split(/\s*,\s*/,$related))) {
			if (nb($related)) {
				$related = "$related, $rel";		 
			} else {
				$related = "$rel";
			}

			my ($rv,$sth) = dbUpdate($dbh,{WHAT=>getConfig('en_tbl'),SET=>"related='$related'",WHERE=>"uid=$id"}); 
			$sth->finish();

			$set = 1;
		}

		return $set;
	}

# see if a related link was already suggested
#
	sub madeSuggestion {
		my $id = shift;			 # the object "address"
			my $tbl = shift; 
		my $name = shift;		 # canonical name of the related item

			my $table = getConfig('rsugg_tbl');

		my ($rv,$sth) = dbSelect($dbh,{WHAT=>'objectid',FROM=>$table,WHERE=>"objectid=$id and tbl='$tbl' and related='$name'"});
		my $count = $sth->rows();
		$sth->finish();

		return $count ? 1 : 0;
	}

# add a record for a related suggestion
#
	sub addSuggestion {
		my $id = shift;
		my $tbl = shift;
		my $name = shift;

		my $table = getConfig('rsugg_tbl');

		my ($rv,$sth) = dbInsert($dbh,{INTO=>$table,COLS=>'objectid,tbl,related',VALUES=>"$id,'$tbl','$name'"});
		$sth->finish();
	}

	1;
