package Noosphere;

use strict;
use IO::Socket;
use Noosphere::Latex;
use Noosphere::Stopper;
use Noosphere::Roles;

# get a corrected query back from the spell daemon
#
sub fixQuery {
	my $query = shift;

	my $remote = IO::Socket::INET->new(
		Proto => "tcp", 
		PeerAddr => "localhost", 
		PeerPort => Noosphere::getConfig('spell_port'),)

	or return "";	 # give up if we couldn't contact the daemon
	
	print $remote $query."\n";
	my $result = <$remote>;
	$result =~ s/\s*$//;
	$remote->close();

	my @newquery = ();
	my @oldquery = split(/\s+/,$query);
	my @corrections = split(/\s+/,$result);

	my $cor = 0;

	foreach my $i (0..$#corrections) {
	$oldquery[$i] =~ /^([+\-])/;
	my $attr = $1;
		if ($corrections[$i] eq "+") {
		push @newquery,$oldquery[$i];
	}
	elsif ($corrections[$i] eq "-") {
		push @newquery,$oldquery[$i];
	}
	else {
		push @newquery,$attr.$corrections[$i];
		$cor = 1;
	}
	}

	return "" unless ($cor);

	return join(' ',@newquery);
}

# update search result rankings and promote exact matches
#
sub exactMatches {
	my $token = shift;
	my $query = shift;

	my $exactrank = getConfig('exactrank');
	
	my ($rv, $sth) = dbSelect($dbh, {WHAT=>'objectid, tbl',FROM=>getConfig('index_tbl'),WHERE=>"lower(title)='".sq(lc($query))."'"});

	my @rows = dbGetRows($sth);

	foreach my $row (@rows) {
		
		my ($rv, $sth) = dbUpdate($dbh,{WHAT=>getConfig('results_tbl'),SET=>"rank=$exactrank",WHERE=>"objectid=$row->{objectid} and tbl='$row->{tbl}'"});
		$sth->finish();
	}
}

# interface to the new (vector space) search engine
#
sub vsSearch {
	my $params = shift;
	my $userinf = shift;

	#warn "Parameters: $params->{'objects'}  $params->{'users'}";	
	# special operations - look up object by id
	# 
	if ($params->{'term'} =~ /^(\d+)$/) {

		my $en = getConfig('en_tbl');

		my $id = $1;
		my $newparams = {op => 'getobj',
			id => $id,
			from => $en};

		return getObj($newparams, $userinf);
	}
	
	# init paging variables and others
	#
	my $offset = $params->{'offset'} || 0;
	my $total = $params->{'total'} || 0;
	my $token = $params->{'token'} || undef;
	my $nmatches = $params->{'nmatches'} || 0;
	my $limit = $userinf->{'prefs'}->{'pagelength'};
	my $html = '';
	my $query = $params->{'term'};
	my $table = getConfig('results_tbl');

	# zap hyphenation
	#
	# why do this here and not in irSearch?
	#$query =~ s/(\w)-(\w)/$1 $2/g; 
	
	$limit = int($limit / 4);

	# issue a new search if we aren't continuing
	#
	if (not defined $token) {
		my @tables = getTables($params);
		warn "Table is: @tables";
		($token, $nmatches) = irSearch($query, "normal", \@tables);
		exactMatches($token, $query);
	}

	if (defined $token && $nmatches == 0) {
		my $fixed = fixQuery($query);
		if ($fixed) {
			return paddingTable(clearBox('Search',"Didn't find anything. <br><br>Perhaps you meant '<a href=\"".getConfig("main_url")."/?op=search&term=".urlescape($fixed)."\">$fixed</a>'?"));
		} else {
			return paddingTable(clearBox('Search',"No results found."));
		}
	}
	#return errorMessage("Could not contact search engine! Please report this to <a href=\"mailto:".getAddr('feedback')."\">".getAddr('feedback')."</a><p/>
	return errorMessage("The search engine is out of service temporarily.  We are working on resolving this as soon as possible.<p/>") if (not defined $token);

	# get total
	#
	if (not defined $params->{'total'}) {
		my ($rv,$sth) = dbSelect($dbh,{WHAT=>'rank',FROM=>$table,WHERE=>"token=$token"});
	
		$total = $sth->rows();
		$sth->finish();
	}

	# get rows
	#
	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'*',FROM=>$table,WHERE=>"token=$token",'ORDER BY'=>'rank',DESC=>'',OFFSET=>$offset,LIMIT=>$limit});
	my $returned = $sth->rows();
	my @rows = dbGetRows($sth);
	
	if ($returned <= 0) {
		return paddingTable(clearBox('Search',"Search expired, please re-issue your query."));
	}

	# get a clean list of words from the query for use in highlighting
	#
	my @querywords = getQueryWords($query);

	$html .= "<table width=\"100%\">\n";

	my $ord = 1 + $offset;
	foreach my $row (@rows) {
		$html .= "<tr>\n";
		$html .= "<td>\n";
		$html .= searchRender($row->{'tbl'},$row->{'objectid'},$row->{'rank'},$ord,\@querywords);
		$html .= "</td>\n";
		$html .= "</tr>\n";
		$ord++;
	}

	$html .= "</table>\n";
	
	my $start = $offset+1;
	my $finish = $start+$returned-1;
	
	$params->{'total'} = $total;
	$params->{'offset'} = $offset;
	$params->{'token'} = $token;
	$params->{'nmatches'} = $nmatches;
	$html .= getPager($params,$userinf,4);
	
	return paddingTable(clearBox("Found: $start-$finish of $total results" ,$html));
}

sub getTables {
	my $params = shift;
	my $indexablefields = getConfig('indexablefields');
	my @array = ();
	for my $table ( keys %$indexablefields ) {
		warn "Checking table $table";
		if (defined $params->{$table}) {
			warn "table selected: $table  Table: @array";
			push(@array, $table);
		}
	}
	return @array;
}

# pull + and - prefixes from a word
#
sub strip {
  my $word=shift;

  if ($word=~/^[\+\-](.+)$/) {
    return $1;
  }

  return $word;
}

# return a clean list (minus - and +) of words in a query
#
sub getQueryWords {
	my $query = shift;

	my @list;

	$query =~ s/^\s+//; # remove leading and trailing blanks
	$query =~ s/\s+$//;

	foreach my $word (split(/\s+/,lc($query))) {
		my $sword = strip($word);
		my $processed = TeXtoUTF8($sword);
		
		push @list,$processed;

		# add an uninternationalized alias term if needed
		if ($processed ne $sword) {
			my $alias = UTF8ToAscii($processed);
			push @list, $alias;
			#warn "added alias word [$alias] for [$processed]";
		}
	}

	return @list;
}

# get context for a term in some text
#
sub contextHighlight {
	my $text = shift;
	my $terms = shift;
	my $clip = shift||0;

	$terms = [stopList(@$terms)];

	my $preh = "<b>";	# highlighting brackets
	my $posth = "</b>";
	my $maxlen = 540;	# length to turn on chunk shrinking
	my $chunklen = 30;	# max length of chunk between occurances

	my @hlist = ();		# list of occurrences of terms to highlight

	# build a regexp for filtering out search terms
	#
	my $regexp = '('.join('|',(map { quotemeta($_) } @$terms)).')';

	# put in special tags where the highlighted terms are
	#
	while ($text =~ /$regexp/ig) {
		my $term = $1;
		push @hlist, $term;
	}
	foreach my $term (@hlist) {
		$term = quotemeta($term);
		$text =~ s/(^|[^#])$term([^#]|$)/$1\@#$term#\@$2/;
	} 

	# process the text .. split on the highlighted terms
	#
	my @array = split(/\@#.+?#\@/," ".$text." ");	# pad to make split predictable
	my $first = 1;
	my $last = 0;
	my $n = $#array;
	
	$clip = 0 if (length($text)<$maxlen);
	
	if ($clip && $#hlist>=0) {
		foreach my $i (0..$n) {
			$last = 1 if ($i == $n);

			my $chunk = $array[$i];

			# initial text chunk
			#
			if ($first) {
				if (length($chunk)>$chunklen) {
				$chunk =~ /(.{$chunklen})$/;
				$chunk = "...$1";
			}
		} 
		
		# final text chunk
		#
		elsif ($last) {
			if (length($chunk)>$chunklen) {
				$chunk =~ /^(.{$chunklen})/;
				$chunk = "$1...";
			} 
		} 
		
		# text chunk is between two occurrences
		#
		else {	
			if (int(length($chunk)/2)>$chunklen) {
				my $len = length($chunk);
				my $c2 = int($chunklen/2);
				$chunk =~ /^(.{$c2}).*(.{$c2})$/;
				$chunk = "$1...$2";
			}
		}

		$array[$i] = $chunk;

		$i++;
		$first = 0;
		}
	}
	
	# reassemble the highlighted terms and inter-term text arrays
	#
	my @final = ();
	for my $i (0..$#array) {
		push @final, $array[$i];
		if (defined $hlist[$i]) {
			push @final, $preh.$hlist[$i].$posth;
		}
	}
	my $context = join('',@final);

	# fix up some stuff
	#
	$context =~ s/\S*[.]{3}\S*/.../g;
	$context =~ s/(\s*[.]{3}\s*)+/ ... /g;
	$context =~ s/^\s*//;
	$context =~ s/\s*$//;
 
	# there were no matches, we can clip the text
	#
	if ($#hlist<0 && length($context)>$maxlen) {
		$context =~ /^(.{0,$maxlen})/;
		$context = "$1 ...";
	}
	
	return $context;
}

# render an object for inclusion in search results screen
#
sub searchRender {
	my $table = shift;
	my $objectid = shift;
	my $rank = shift;
	my $ord = shift;
	my $words = shift;

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'*',FROM=>$table,WHERE=>"uid=$objectid"});
	my $rec=$sth->fetchrow_hashref();
	$sth->finish();

	if ($table eq getConfig('en_tbl')) {
		return searchRenderEn($rec,$rank,$ord,$words);
	} 
	#elsif ($table eq getConfig('papers_tbl')) {
	#}

	# generic record handler
	#
	else {
		my $html="";

		my $rankstr = "rank=$rank";
		if ($rank eq getConfig('exactrank')) {
			$rankstr = "(exact&nbsp;match)";
		}
		my $title = lookupfield(getConfig('index_tbl'),'title',"objectid=$rec->{uid} and tbl='$table'");
		my $htitle = contextHighlight($title, $words);
		my $tdesc = tabledesc($table);
		my $link;
		my $info = "<table><tr><td><font size=\"-1\"><u>From</u>: $tdesc</font></td>";
		if ($table eq 'messages') {
			my $msgRow = getMessageById($rec->{uid});
			$link = getConfig("main_url")."/?op=getmsg&id=$rec->{uid}";
			$info .= "<td><font size=\"-1\"><u>Author</u>: $msgRow->{'username'}</font></td>";
			$info .= "<td><font size=\"-1\"><u>Date posted</u>: $msgRow->{'created'}</font></td>";
		} else {
			$link = getConfig("main_url")."/?op=getobj&from=$table&id=$rec->{uid}";
		}
		$info .= "</tr></table>";
		$html.="<table width=\"100%\" cellpadding=\"2\" cellspacing=\"0\">
				<td valign=\"top\">$ord.</td>
			<td valign=\"top\" width=\"100%\">
				<table width=\"100%\" cellpadding=\"2\" cellspacing=\"0\">
				 <tr>
				 <td><a href=\"$link\">$htitle</a></td>
					 <td align=\"right\"><font size=\"-1\" color=\"#888888\">$rankstr</font></td>
			 </tr>
			 <tr><td>
			 	$info
			 </td></tr>
			 </table>
			 </td>
			</table>";

		return $html;
	}
}

sub getMessageById {
	my $msgid = shift;
	my ($rv, $sth) = dbSelect($dbh, {WHAT=>'username, a.created',FROM=>'messages a, users b',WHERE=>"a.userid = b.uid and a.uid=$msgid"});
	my $row = $sth->fetchrow_hashref();
	$sth->finish();
	return $row;
}

# render an encyclopedia object for search results screen
#
sub searchRenderEn {
	my $rec = shift;
	my $rank = shift;
	my $ord = shift;
	my $words = shift;

	my $html = "";

	my $ts = getTypeString($rec->{type});

	my $bars = "";
	if ($Noosphere::baseconf::base_config{RATINGS_MODULE}) {
		$bars = Noosphere::Ratings::Ratings::getObjectRating($rec->{'uid'}, $rec->{'userid'});
	}
	
	$html .= "<table width=\"100%\">";
	$html .= "<tr>";
	$html .= "<td valign=\"top\">$ord.</td>";
	$html .= "<td><table><tr><td>".$bars."</td><td><a href=\"?op=getobj&from=objects&id=$rec->{'uid'}\">".mathTitle(contextHighlight($rec->{title},$words), 'highlight')."</a></td><td> <font size=\"-1\">($ts)</font></td></tr></table></td>";
	
	my $rankstr = "rank=$rank";
	if ($rank eq getConfig('exactrank')) {
		$rankstr = "(exact&nbsp;match)";
	}
	$html .= "<td align=\"right\"><font size=\"-1\" color=\"#888888\">$rankstr</font></td>";
	$html .= "</tr>";

	if (nb($rec->{synonyms})) {
		$html .= "<tr><td></td><td colspan=\"2\"><font size=\"-1\">";
		my $syns1= $rec->{synonyms};
		my $syns2 = contextHighlight(displayTitleList($syns1),$words);
		my $indicator = ($syns1 eq $syns2 ? "" : "<font color=\"#ff0000\"><b>*</b> </font>");
		$html .= "$indicator<u>Other Names</u>: $syns2";
		$html .= "</font></tr>";
	}

	if (nb($rec->{defines})) {
		$html .= "<tr><td></td><td colspan=\"2\"><font size=\"-1\">";
		my $defines1 = $rec->{defines};
		my $defines2 = contextHighlight(displayTitleList($defines1),$words);
		my $indicator = ($defines1 eq $defines2 ? "" : "<font color=\"#ff0000\"><b>*</b> </font>");
		$html .= "$indicator<u>Also defines</u>: $defines2";
		$html .= "</font></tr>";
	}

	$html .= "<tr>";
	$html .= "<td></td><td colspan=\"2\" width=\"100%\"><font size=\"-1\">".contextHighlight(TeXtoUTF8(getEncyclopediaSynopsis($rec)),$words,1)."</font></td>";
	$html .= "</tr>";

	my $tdesc = tabledesc(getConfig('en_tbl'));
	$html .= "<tr>";
	$html .= "<td></td><td colspan=\"1\" align=\"left\"><font size=\"-1\"><u>From</u>: $tdesc";

	my $cs = classstring(getConfig('en_tbl'),$rec->{uid});
	if ($cs) {
		$html .= ", <u>Classification</u>: $cs";
	}

	if ($rec->{userid} <= 0) {
		$html .= ", <u>Author</u>: [not owned]";
	} else {
#		my $urec = getUserData($rec->{'userid'});
		my $authors = get_authors_html( $rec->{'uid'} );
		$html .= ", <u>Author(s)</u>: $authors.";
	}
	
	$html .= "</font></td>";
	$html .= "</tr>";

	$html .= "</table>";

	return $html;
}

# get advanced search form
#
sub advSearch {
	my $params=shift;
	my $template=new Template('advsearch.html');

	return stubMessage();
	#return paddingTable(makeBox('Advanced Search',$template->expand()));
}

# get the search box as shown on the main page
#
sub getSearchBox {
	my $params=shift;
	my $template=new Template("search.html");
	
	if (defined($params->{term})) {
		$template->setKey('term', $params->{'term'});
	}
	
	return $template->expand();
}

# get displayed text for encyclopedia search results.
# 
sub getEncyclopediaSynopsis {
	my $row = shift;
	my $plaintext = shift;
	
	return getLaTeXSynopsis($row->{'data'}, $plaintext);

}

sub advancedSearch {
	my $box = new Template("advancedsearch.html");
	return paddingTable(makeBox("Advanced Search", $box->expand()));
}

1;

