package Noosphere;
use strict;

use Noosphere::StatCache;

# get the content RSS feed.
#
# various object types/views are all presented as channels, from which the user
# can select.
#
sub getRSS {
	my $params = shift;

	my $channel = lc($params->{'channel'} || 'all');

	my $proj = getConfig('projname');
	my $site = getConfig('main_url');

	my $xml =  "<?xml version=\"1.0\"?>
<rss version=\"2.0\">\n";

	$xml .= "\t<channel>\n";

	if ($channel eq 'all') {
		$xml .= "\t\t<title>".$proj.": Latest Activity</title>\n";
		$xml .= "\t\t<link>$site/</link>\n";

		my $la = getLatestEntries_RSS('latestadds', 1);
		my $lm = getLatestEntries_RSS('latestmods', 1);
		my $m = getLatestMessages_RSS(1);

		$xml .= makeRSS_XML(combine_RSS_data($lm, $la, $m));
	}

	# latest (encyclopedia) additions
	#
	elsif ($channel eq 'latestadds') {
	
		$xml .= "\t\t<title>".$proj.": Latest Encyclopedia Additions</title>\n";
		$xml .= "\t\t<link>$site/?op=enlist&amp;mode=created</link>\n";
	
		$xml .= makeRSS_XML(linearize_datewise_RSS_stats(getLatestEntries_RSS('latestadds')));
	}

	# latest (encyclopedia) modifications 
	#
	elsif ($channel eq 'latestmods') {

		$xml .= "\t\t<title>".$proj.": Latest Encyclopedia Revisions</title>\n";
		$xml .= "\t\t<link>$site/?op=enlist&amp;mode=modified</link>\n";

		$xml .= makeRSS_XML(linearize_datewise_RSS_stats(getLatestEntries_RSS('latestadds')));

	}

	# latest messages
	#
	elsif ($channel eq 'latestmsgs') {

		$xml .= "\t\t<title>".$proj.": Latest Messages</title>\n";
		$xml .= "\t\t<link>$site/?op=messageschrono</link>\n";

		$xml .= makeRSS_XML(linearize_datewise_RSS_stats(getLatestMessages_RSS()));
	}
	
	$xml .= "\t</channel>\n";

	$xml .= "</rss>\n";;

	return $xml;
}

# format cached latest entry data as linear RSS channel data
# (this does not make the XML)
#
sub getLatestEntries_RSS {
	my $statkey = shift;
	my $prefix = shift;

	my %phash = ('latestadds' => 'new', 'latestmods' => 'rev');

	my @rsslist;
	my $metadata = $stats->get($statkey);

	# set prefix for multiplexed RSS feed
	#
	my $pstring = '';
	$pstring = "($phash{$statkey}) " if $prefix;

	# make into RSS data structure 
	#
	foreach my $daylist (@$metadata) {
		my ($date) = keys %$daylist;
	
		my ($items) = $daylist->{$date};

		foreach my $item (@$items) {
	 
			# add title-type prefix (may be blank)
			#
			$item->{'title'} = $pstring.$item->{'title'};

			$item->{'link'} = $item->{'url'};		# rename
			delete $item->{'url'};

			# leave timestamp in tact
		}
	}

	return $metadata;
}

# take a date-based stats RSS hash and turn it into a linear list
#
sub linearize_datewise_RSS_stats {
	my $metadata = shift;

	my @rsslist;

	foreach my $daylist (@$metadata) {
		my ($date) = keys %$daylist;
	
		my ($items) = $daylist->{$date};

		foreach my $item (@$items) {

			# note we are dropping the timestamp, which was only really useful
			# for sorting
			#
			push @rsslist, {
				'title' => htmlescape($item->{'title'}), 
				'link' => $item->{'link'}, 
				'author' => $item->{'author'},
				'pubDate' => $date, 
				'description' => htmlescape($item->{'description'}) 
				};
		}
	}

	return [@rsslist];
}

# turn an RSS items list into channel XML
#
sub makeRSS_XML {
	my $rssptr = shift;

	my @rsslist = @{$rssptr};

	my $xml = '';

	foreach my $item (@rsslist[0..($#rsslist > 19 ? 19 : $#rsslist)]) {
		
		$xml .= "\t<item>\n";

		foreach my $key (keys %$item) {
			$xml .= "\t\t<$key>$item->{$key}</$key>\n";
		}
		$xml .= "\t</item>\n";

	}

	return $xml;
}

# combine and linearize RSS data from many separate sources 
#
sub combine_RSS_data {
	my @sourcedata = @_;

	my @prelimlist;
	my @rsslist;

	# dump all the separate lists into a single flat list 
	# (not sorted)
	#
	foreach my $metadata (@sourcedata) {
		foreach my $daylist (@$metadata) {
			my ($date) = keys %$daylist;
	
			my ($items) = $daylist->{$date};

			foreach my $item (@$items) {
	 
				my $newitem = {%$item};
				$newitem->{'pubDate'} = $date;

				push @prelimlist, $newitem;
			}
		}
	}

	# sort the list; dump it into the final one
	#
	foreach my $item (sort { $b->{'timestamp'} <=> $a->{'timestamp'} } @prelimlist) {
		delete $item->{'timestamp'};	# don't need this anymore
		push @rsslist, $item;
	}

	return [@rsslist];
}

# get count of unproven theorems
#
sub unprovenCount {
	my $en = getConfig('en_tbl');
	my ($rv, $sth) = dbLowLevelSelect($dbh, "select o1.uid from $en as o1 left outer join $en as o2 on (o1.uid=o2.parentid and o2.type=".PROOF.") where o1.type=".THEOREM." and (o1.self is NULL or o1.self = 0) and o2.uid is NULL");
	my $total = $sth->rows();
	$sth->finish();

	return $total;
}

# getUnprovenTheorems - returns a hash containing all theorem objects that
# do not have any proof objects attached to them
#
sub getUnprovenTheorems
{
		my $en = getConfig('en_tbl');
		my ($rv, $sth) = dbLowLevelSelect($dbh, "select o1.* from $en as o1 left outer join $en as o2 on (o1.uid=o2.parentid and o2.type=".PROOF.") where o1.type=".THEOREM." and (o1.self is NULL or o1.self = 0) and o2.uid is NULL");
	my @rows = dbGetRows($sth);
		my $theorems = {};

		foreach my $row (@rows) {
			$theorems->{$row->{'uid'}} = $row;
		}
		return $theorems;
}

# unprovenTheorems - lists theorems that have not yet been proven
#
sub unprovenTheorems {
	my ($params, $userinf) = @_;

	my $limit = $userinf->{'prefs'}->{'pagelength'};
	my $offset = $params->{'offset'} || 0;

	my $unpts = getUnprovenTheorems();
	my %bytitle;
	my @titles;
	my $html = "";

	foreach my $uid (keys(%$unpts)) {
		my $i = "";
		my $title = $unpts->{$uid}->{title};

		$i++ while $bytitle{"$title$i"};
		push @titles, "$title$i";
		$bytitle{"$title$i"} = $uid;
	}

	@titles = sort { humanReadableCmp($a, $b); } @titles;
	my $total = scalar @titles;

	my $template = new XSLTemplate('unproven.xsl');

	$template->addText('<unprovenlist>');

	for (my $i = 0; $i < $limit && $offset + $i < scalar @titles; $i++) {
		my $row = $unpts->{$bytitle{$titles[$i + $offset]}};
		my $uenct = urlescape($row->{'title'});

		my $ord = $offset + $i + 1;
		my $ourl = getConfig("main_url")."/?op=getobj&amp;from=objects&amp;id=$row->{uid}";
		my $purl = getConfig("main_url")."/?op=adden&amp;request=$row->{uid}&amp;title=proof+of+$uenct&amp;type=Proof&amp;parent=$row->{name}";

		my $mathtitle = mathTitleXSL($row->{'title'}, 'highlight');

		$template->addText("	<item>");
		$template->addText("		<series ord=\"$ord\"/>");
		$template->addText("		<object href=\"$ourl\"/>");
		$template->addText("		<prove href=\"$purl\"/>");
		$template->addText("		<title>$mathtitle</title>");
		#$template->addText("		<user name=\"".qhtmlescape($row->{'username'})."\" href=\"".getConfig("main_url")."/?op=getuser;id=$row->{userid}\"/>");
		$template->addText("	</item>");

		$ord++;
	}

	$template->addText('</unprovenlist>');

	$params->{'total'} = $total;
	$params->{'offset'} = $offset;

	getPageWidgetXSLT($template, $params, $userinf);

	return $template->expand();
}

# show hit statistics
#
sub getHitInfo {
	my $params = shift;

	my $periods = [
		['total',"<=CURRENT_TIMESTAMP"],
		['last day',">CURRENT_TIMESTAMP+'-1 day'"],
		['last week',">CURRENT_TIMESTAMP+'-1 week'"],
		['last month',">CURRENT_TIMESTAMP+'-1 month'"],
		['last year',">CURRENT_TIMESTAMP+'-1 year'"]
	];
	
	my $html="";

	$html .= "<table align=\"center\" cellpadding=\"5\" cellspacing=\"0\">";
	$html .= "<tr bgcolor=\"#eeeeee\">";
	$html .= "<td>&nbsp;</td>";
	$html .= "<td>hits</td>";
	$html .= "</tr>";
	foreach my $period (@$periods) {
		my $tid = tableid($params->{'from'});

		$html .= "<tr>"; 
		$html .= "<td bgcolor=\"#eeeeee\">$period->[0]</td>";
		my $cnt = dbRowCount(getConfig('hit_tbl'),"objectid=$params->{id} and tblid=$tid and at$period->[1]");
		$html .= "<td align=\"center\">$cnt</td>";
		$html .= "</tr>";
	}
	$html .= "</table>";

	my $title = lookupfield($params->{from},'title',"uid=$params->{id}");
	return paddingTable(clearBox("Access Stats for '$title'",$html));
}

# get a count of unclassified objects
#
sub unclassifiedCount {
	my ($rv,$sth) = dbLowLevelSelect($dbh,"select distinct o.uid from objects as o left outer join classification as c on (o.uid=c.objectid) where c.objectid is null");
	my $total = $sth->rows();
	
	$sth->finish();

	return $total;
}

# get a list of unclassified objects
#
sub unclassifiedObjects {
	my $params = shift;
	my $userinf = shift;

	my $template = new XSLTemplate("unclassified.xsl");

	# init paging
	my $total = $params->{'total'} || -1;
	my $offset = $params->{'offset'} || 0;		
	my $limit = $userinf->{'prefs'}->{'pagelength'};

	
	# grab the data
	#
	my ($rv, $sth);
	($rv,$sth) = dbLowLevelSelect($dbh,"select distinct o.title, lower(o.title), o.uid, o.userid, u.username from users as u, objects as o left outer join classification as c on (o.uid=c.objectid) where c.objectid is null and u.uid=o.userid order by lower(o.title) limit $limit offset $offset")
		if (getConfig('dbms') eq 'pg');
	($rv,$sth) = dbLowLevelSelect($dbh,"select distinct o.title, lower(o.title), o.uid, o.userid, u.username from users as u, objects as o left outer join classification as c on (o.uid=c.objectid) where c.objectid is null and u.uid=o.userid order by lower(o.title) limit $offset, $limit")
		if (getConfig('dbms') eq 'mysql');


	#my $total = $sth->rows();
	$template->addText("<unclassifiedlist>");
	
	my $ord = $offset + 1;
	$total = 0;
	while (my $row = $sth->fetchrow_hashref()) {
		if ( is_deleted( $row->{'uid'} ) ){
			next;
		}
		$total++;
		my $authors = get_authors_html($row->{'uid'}, 'objects');
		my $mathtitle = mathTitleXSL($row->{'title'}, 'highlight');

		$template->addText("	<item>");
		$template->addText("		<series ord=\"$ord\"/>");
		#$template->addText("		<object title=\"".qhtmlescape($row->{'title'})."\" href=\"".getConfig("main_url")."/?op=getobj;from=".getConfig('en_tbl').";id=$row->{uid}\"/>");
		$template->addText("		<object href=\"".getConfig("main_url")."/?op=getobj;from=".getConfig('en_tbl').";id=$row->{uid}\"/>");
		$template->addText("		<title>$mathtitle</title>");
		$template->addText("            <authors>$authors</authors>");
#		$template->addText("		<user name=\"".qhtmlescape($row->{'username'})."\" href=\"".getConfig("main_url")."/?op=getuser;id=$row->{userid}\"/>");
		$template->addText("	</item>");

		$ord++;
	}
	$sth->finish();
	$template->addText("</unclassifiedlist>");

	# get total
	#
	
	$params->{'offset'} = $offset;
	$params->{'total'} = $total;

	getPageWidgetXSLT($template, $params, $userinf);
	
	return $template->expand();
}


# hitObject - add a hit for an object
#
sub hitObject { 
	my $objectid = shift;# uid of object
	my $table = shift;	 # table object is in
	my $field = shift;	 # field to increment in object (optional)

	#TODO: we need a transaction to both increment field and add to 
	# hits table at the same time

	# add to hits table
	#
	my $tid = tableid($table);
	my ($rv,$sth) = dbInsert($dbh,{
		INTO => 'hits',
		COLS => 'objectid,tblid',
		VALUES => "$objectid,$tid"});

	$sth->finish();
 
	# increment hit count in the object (we dont *really* need this, but it
	# saves us from doing a possibly huge summation over a huge table later)
	# 
	if (defined $field) {
		($rv,$sth) = dbUpdate($dbh,{
		 WHAT=>$table,
		 SET=>'hits=hits+1',
		 WHERE=>"uid=$objectid"});
		 
		 $sth->finish();
	}
}

# getSystemStats - get the system stats page
#
sub getSystemStats {
	my $html = '';
	my $periods;
	
	$periods = [
		['total',"<=CURRENT_TIMESTAMP"],
		['last day',">CURRENT_TIMESTAMP+'-1 day'"],
		['last week',">CURRENT_TIMESTAMP+'-1 week'"],
		['last month',">CURRENT_TIMESTAMP+'-1 month'"],
		['last year',">CURRENT_TIMESTAMP+'-1 year'"]
	] if getConfig('dbms') eq 'pg';

	$periods = [
		['total',"<= now()"],
		['last day',">now() - interval 1 DAY"],
		['last week',">now() - interval 7 DAY"],
		['last month',">now() - interval 30 DAY"],
		['last year',">now() - interval 365 DAY"]
	] if getConfig('dbms') eq 'mysql';
	
	my $timefields = {
		'objects'=>'created',
		'users'=>'joined',
		'corrections'=>'filed',
		'messages'=>'created',
		'hits'=>'at'
	};

	$html .= "<table align=\"center\" cellpadding=\"5\" cellspacing=\"0\">";
	$html .= "<tr bgcolor=\"#eeeeee\">";
	$html .= "<td>&nbsp;</td>";
	foreach my $table (keys %$timefields) {
		$html .= "<td>$table</td>";
	}
	$html .= "</tr>";
	foreach my $period (@$periods) {
		$html .= "<tr>"; 
		$html .= "<td bgcolor=\"#eeeeee\">$period->[0]</td>";
		foreach my $lookup (keys %$timefields) {
			my $cnt = dbRowCount($lookup,"$timefields->{$lookup}$period->[1]");
			$html .= "<td align=\"center\">$cnt</td>";
		}
		$html .= "</tr>";
	}
	$html .= "</table>";

	$html .= "<center>";

	my $uptime = `/usr/bin/uptime`;
	$uptime =~ /up ([0-9]+ [a-z]+),/;
	$html .= "<br>System uptime : $1<br><br>";

	$html .= "</center>";

	return paddingTable(clearBox(getConfig('projname').' Stats',$html));
}

# getTopUsers - get the top users box that shows top users by score
#
sub getTopUsers {

	# grab the cached statistics
	#
	my $topusers = $stats->get('topusers');

	# TODO - redo top user stuff with XML and XSLT

	my $topa = '';
	my $topw = '';

	# do top users of all time 
	#
	my $rows = $topusers->{'toparows'};
 
	if (@$rows) {
		$topa .= "<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">\n";
		foreach my $row (@$rows) {

			if ($row->{'uid'} > 0) {
				$topa .= "<tr>\n";

				$topa .= "<td>\n";
				$topa .= "<a href=\"".getConfig("main_url")."/?op=getuser;id=".$row->{'uid'}."\">".$row->{'username'}."</a>\n";
				$topa .= "</td>\n";
				$topa .= "<td align=\"right\">$row->{'score'}</td>\n";
				$topa .= "</tr>\n";
			}
		}
		$topa .= "</table>\n";
	} 
	else {
		$topa = "<font size=\"-1\">No data.\n</font>";
	}

	# do top users of the past 2 weeks
	#
	$rows = $topusers->{'topwrows'};

	if (@$rows) {
		$topw .= "<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">\n";
		foreach my $row (@$rows) {

			if ($row->{uid} > 0 && $row->{sum} > 0) {
				$topw .= "<tr>\n";

				$topw .= "<td align=\"left\"><font size=\"-1\">\n";
				$topw .= "<a href=\"".getConfig("main_url")."/?op=getuser;id=".$row->{'uid'}."\">".$row->{'username'}."</a>\n";
				$topw .= "</font></td>\n";
				$topw .= "<td align=\"right\"><font size=\"-1\">".$row->{'sum'}."</font></td>\n";
				$topw .= "</tr>\n";
			}
		}
		$topw .= "</table>\n";
	} else {
		$topw = "<font size=\"-1\">No data.\n</font>";
	}

#	$topa .= "</font>\n";
#	$topw .= "</font>\n";

	my $template = new Template("topusers.html");

	$template->setKeys('alltime' => $topa, 'twoweeks' => $topw);

	return clearBox("Top Users", $template->expand()); 
}

# grab the data needed to print top users statistics.	returns a hashref to two
#	arrayrefs
#
sub getTopUsers_callback {
	my $limita = getConfig('topusers_alltime');
	my $limitw = getConfig('topusers_2weeks');
 
	(my $rv, my $sth) = dbSelect($dbh,{WHAT => 'username,uid,score',
		 FROM => 'users',
		 'ORDER BY' => 'score',
		 'DESC' => '',
		 LIMIT => $limita});

	if (! $rv) {
		dwarn "no users found for top users statistics!\n";
	return [];
	}

	my $where;
	$where = "score.userid=users.uid and occured>(CURRENT_TIMESTAMP+'-2 weeks')" if getConfig('dbms') eq 'pg';
	$where = "score.userid=users.uid and occured>now()-interval 14 DAY" if getConfig('dbms') eq 'mysql';
	
	my ($rv2, $sth2) = dbSelect($dbh,{WHAT => 'sum(score.delta) as sum,users.username,users.uid',
		FROM => 'score,users',
		WHERE => $where,
		'ORDER BY'=> 'sum',
		'GROUP BY'=> 'users.username,users.uid',
		DESC => '',
		LIMIT => $limitw});
	
	my @toparows = dbGetRows($sth);
 
	my @topwrows = dbGetRows($sth2);

	return {toparows=>[@toparows], topwrows=>[@topwrows]}; 
}

# get and prepare the data for the latest additions/modifications marquee
#
# this returns a structure of the form:
# 
# [ 
#	{dateheader1 => [
#		{objtitle1 => url},
#		{objtitle2 => url},
#		{objtitle3 => url},
#				... ]
#	},
#	{dateheader2 => [
#		{objtitle1 => url},
#		{objtitle2 => url},
#		{objtitle3 => url},
#				... ]
#	},
#	...
# ]
# 
sub getLatestEntry_data {
	my $type = shift || 'additions';

	my $limit = getConfig('latest_additions');
	if ($type ne 'additions') {
		$limit = getConfig('latest_revisions');
	}
	my $html = '';

	my $datefield = ($type eq 'additions') ? 'created' : 'modified';

	my ($rv, $sth);

	my $en = getConfig('en_tbl');
	my $u = getConfig('user_tbl');
	
	($rv, $sth) = dbSelect($dbh,{WHAT=>"$en.uid,$en.name,$en.title,$en.data, extract(EPOCH FROM $en.$datefield) as unixtime, date_part('dow',$en.$datefield) as dow, date_part('year',$en.$datefield)||'-'||date_part('month',$en.$datefield)||'-'||date_part('day', $en.$datefield) as ymd, $u.username", FROM=>"$en, $u", 'ORDER BY'=>"$en.$datefield", DESC=>'', WHERE=>"$u.uid = $en.userid ".($type eq 'modifications' ? 'and modified > created' : '') . "and tags.objectid = $en.uid and tags.tag = 'NS:published'", LIMIT=>$limit})
		if getConfig('dbms') eq 'pg';

	($rv, $sth) = dbSelect($dbh,{WHAT=>"$en.uid,$en.name,$en.title,$en.data, unix_timestamp($en.$datefield) as unixtime, dayofweek($en.$datefield)-1 as dow, concat(extract(YEAR from $en.$datefield), '-', extract(MONTH from $en.$datefield), '-', extract(DAY from $en.$datefield)) as ymd, $u.username", FROM=>"$en, $u, tags", 'ORDER BY'=>$datefield, DESC=>'', WHERE=>"$u.uid = $en.userid ".($type eq 'modifications' ? 'and modified > created' : '') . "and tags.objectid = $en.uid and tags.tag = 'NS:published'"  , LIMIT=>$limit})
		if getConfig('dbms') eq 'mysql';
	
	if (! $rv) {
		warn "latest $type query error\n";
		return "query error";
	}
 
	my @rows = dbGetRows($sth);

	my @daystruct;
	
	my $date = '';
	my $daylist;

	foreach my $row (@rows) {

		# create a day list
		#
		my $day = dowtoa($row->{dow},'long');
		if ($row->{ymd} ne $date) {
			$date = $row->{ymd};
			my $dateheader = "$day, $date";
			$daylist = [];
			push @daystruct, {$dateheader => $daylist};
		}

		# create the new object entry and add to list for this day
		# 
		my $url = getConfig('main_url')."/encyclopedia/$row->{name}.html";
		my $title = $row->{'title'};
		my $desc = getLaTeXSynopsis($row->{'data'}, 'ascii');

		# make this a reasonable length
		if (length($desc) > 256) {
			$desc = substr($desc, 0, 256)." ...";
		}

		# literal quotes can break Data::Denter?
		$title =~ s/"/&quot;/g;
		$desc =~ s/"/&quot;/g;	

		push @$daylist, {title => $title, url  => $url, description => $desc, author => $row->{'username'}, timestamp => $row->{'unixtime'} };
	}

	# return a ref to the statistics
	return [@daystruct];
}

# pass-throughs to call the above for either modifications or additions
#
sub getLatestAdditions_data {
	return getLatestEntry_data('additions');
}
sub getLatestModifications_data {
	return getLatestEntry_data('modifications');
}
# format and output the data from above for either additions or modifications
#
sub getLatest {
	my $type = shift || 'additions';

	my $limit = getConfig('latest_additions');
	if ($type ne 'additions') {
		$limit = getConfig('latest_revisions');
	}
	my $html = '';

	my $statkey = ($type eq 'additions' ? 'latestadds' : 'latestmods');
	my $latestadds = $stats->get($statkey);

	# TODO : XML/XSLTify this all
	if ( ref ($latestadds) ) {
	
	my $date = '';
	my $table = '';
	foreach my $daylist (@$latestadds) {
		my ($day) = keys %$daylist;
	
		$table .= "<tr><td bgcolor=\"#ffffff\"><font size=\"-2\">";
		$table .= "<center><font color=\"#888888\"><i>$day</i></font></center>";
		$table .= "</font></td></tr>";

		my ($items) = $daylist->{$day};

		foreach my $item (@$items) {
	 
			my $title = $item->{'title'};
			my $url = $item->{'url'};

			$table .= "<tr><td><font size=\"-2\">";
			$table .= "<div class=\"tickeritem\">";
			$table .= "[&nbsp;<a href=\"$url\">".mathTitle($title, 'highlight')."</a>&nbsp;]";
			$table .= "</div>";
			$table .= "</font></td></tr>";
		}
	}

	if ($table) {
		$html .= "<table width=\"100%\" cellpadding=\"\" cellspacing=\"0\">$table";
		$html .= "</table>";
	} 
	} else {
		$html .= "<font size=\"-1\">No data.</a>";
	}

	my $title = ($type eq 'additions' ? 'Latest Additions' : 'Latest Revisions');
	
	return clearBox($title ,$html);
}

# pass-throughs to call the above for either additions or modifications
#
sub getLatestAdditions {
	return getLatest('additions');
}
sub getLatestModifications {
	return getLatest('modifications');
}

1;

