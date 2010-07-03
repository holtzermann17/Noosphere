package Noosphere;
use strict;

# callback to get top news XML
#
sub getTopNews_data {
	my $xml = '';

	my ($rv, $sth) = dbSelect($dbh, {WHAT=>'*', FROM=>getConfig('news_tbl'), 'ORDER BY'=>'created', DESC=>'1', LIMIT=>'5'});

	$xml .= "	<news>";

	while (my $row = $sth->fetchrow_hashref()) {
		my $href = getConfig('main_url')."/?op=getobj&amp;from=news&amp;id=$row->{uid}";
		my $date = md($row->{'created'});
		my $title = htmlescape($row->{'title'});

		$xml .= "		<item>";
		$xml .= "			<date>$date</date>";
		$xml .= "			<title>$title</title>";
		$xml .= "			<href>$href</href>";
		$xml .= "		</item>";
	}
	$sth->finish();

	$xml .= "	</news>";

	return $xml;
}

# post a news item
#
sub postNews {
	my $params = shift;
	my $userinf = shift;

	return noAccess() if ($userinf->{data}->{access} < getConfig('access_postnews'));
	
	my $template=new Template('postnewsform.html');
	
	if (defined($params->{submit})) {
		if ($params->{submit} eq "spell") {
		my $spell = checkdoc($params->{intro} . $params->{body});
		$template->setKey('spell', "$spell<hr>");
		$template->setKeys(%$params);
	} else {
			my $error = checkPostNews($params); 
		$template->setKey('error', $error);
		$template->setKeys(%$params);
		if ($error eq '') {
			return insertNewsItem($params,$userinf); 
		}
	}
	}
	return paddingTable(makeBox('Post News Item',$template->expand()));
}

# actually insert a news item
#
sub insertNewsItem {
	my $params = shift;
	my $userinf = shift;
	
	my $name = normalize($params->{'headline'});
	my $table = getConfig('news_tbl');
	
	my $nextid = nextval($table.'_uid_seq');
	
	my ($rv,$sth) = dbInsert($dbh,{INTO=>$table,
								 COLS=>'uid,created,modified,title,userid,intro,body',
								 VALUES=>"$nextid, now(), now(), '".sq($params->{'headline'})."',$userinf->{uid}, '".sq($params->{'intro'})."', '".sq($params->{'body'}||'')."'"});

	if (! $rv) {
		dwarn "Error adding news item!";
		return errorMessage("Couldn't add news item!");
	}

	$sth->finish();

	# invalidate top news statistics
	#
	$stats->invalidate('top_news');

	return paddingTable(makeBox('News Item Added',"Your post made it. Click <a href=\"".getConfig("main_url")."/?op=main\">here</a> to check it out."));
}

# check for okay-ness of a news post
#
sub checkPostNews {
	my $params = shift;
	my $error = '';
	
	if (not defined($params->{headline}) or $params->{headline} eq '') {
		$error .= "Need a headline.<br />";
	}
	if (not defined($params->{intro}) or $params->{intro} eq '') {
		$error .= "Need an intro copy.<br />";
	}
	# APK - we shouldn't require this for news briefs.
	#if (not defined($params->{body}) or $params->{body} eq '') {
	#	$error .= "Need some story content.<br />";
	#}
	
	return $error;
}

# get the top $count news items.	shows unread comments for the user 
#
sub getTopNews {
	my $userinf = shift;

	my $count = getConfig('news_frontpage_count');
	my $html = ''; 
	my $table = getConfig('news_tbl');
 
 (my $rv,my $sth) = dbSelect($dbh,{WHAT => "$table.uid,$table.userid,users.username,$table.title,$table.intro,$table.body,$table.created",
																	FROM => "$table,users",
									WHERE => "users.uid=$table.userid",
									'ORDER BY' => 'created',
									LIMIT => "$count",
									DESC => ''});
 # object does not exist
 if (!$sth->rows()) {
	 #dwarn "no news found!\n";
	 return clearBox("News", "No news yet.");
 }

 my @rows = dbGetRows($sth);

 my $news = "<table width=\"100%\">";
 foreach my $row (@rows) {
	 my $unread = count_unseen($table,$row->{uid},$userinf->{uid});
	 $news .= formatnewsitem($row,$unread);
 }
 $news .= '</table>';

 $news .= "<center>[<a href=\"".getConfig("main_url")."/?op=oldnews\">more news</a>]</center>";

 $html = clearBox("News",$news);

 return $html;
}

# get $count news items in a summary page
# 
sub getNewsSummary {
	my $params = shift;
	my $userinf = shift;
	
	my $offset = $params->{offset}||0;
	#my $pagesize=getConfig('news_list_page');
	my $pagesize = $userinf->{'prefs'}->{'pagelength'};
	my $html = '';
	my $table = getConfig('news_tbl');

	# list element query
	#
	(my $rv,my $sth) = dbSelect($dbh,{
		WHAT => "$table.uid,$table.userid,users.username,$table.title,$table.created",
		FROM => "$table,users",
	WHERE => "users.uid=$table.userid",
	'ORDER BY' => 'created',
	LIMIT => $pagesize,
	OFFSET => $offset,
	DESC =>''},$params,"$table.created");
	
	if (! $rv) {
		dwarn "no news items!";
		return "no news items to summarize!";
	}

	my @rows = dbGetRows($sth);
	
	my $i = $offset+1;
	foreach my $row (@rows) {
		my $time = mdhm($row->{created});
		$html .= "$i. <font size=\"-1\">$time</font> <a href=\"".getConfig("main_url")."/?op=getobj&from=$table&id=".$row->{uid}."\">".$row->{'title'}."</a>";
	$html .= " by $row->{username}<br>";
	$i++;
	}

	$html .= getPager($params,$userinf);

	return paddingTable(clearBox("Old News",$html));
}

sub formatnewsitem {
	my $row = shift;
	my $unread = shift;	 # unread discussion items

	my $news = new Template("newsitem.html");
	my $intro = $row->{intro};

	if (nb($row->{body}) && $row->{body} ne 'null') {
		$intro .= ' <b>...</b>';	 # signify there is a body to this story
	}

	$news->setKeys(
			'title' => $row->{title},
		'user' => "<a href=\"".getConfig("main_url")."/?op=getuser&id=$row->{userid}\">$row->{username}</a>", 
		'date' => $row->{created},
		'intro' => $intro
	);
	
	my $table = getConfig('news_tbl');
	my $count = getmsgcount($table,$row->{uid});
 
	if ($unread <= 0) {	
		$news->setKey('more', "<font size=-1>($count comments) [<a href=\"".getConfig("main_url")."/?op=getobj&from=$table&id=$row->{uid}\">more...</a>]</font>"); 
	} else {
		$news->setKey('more', "<font size=-1>($count comments, <b>$unread unread</b>) [<a href=\"".getConfig("main_url")."/?op=getobj&from=$table&id=$row->{uid}\">more...</a>]</font>"); 
	}

	return $news->expand();
}

sub formatnewsitem_full {
	my $row = shift;
	my $news = new Template("newsbox.html");
 
	$news->setKeys(
			'title' => $row->{'title'},
		'date' => $row->{'created'},
			'user' => "<a href=\"".getConfig("main_url")."/?op=getuser&id=$row->{'userid'}\">$row->{'username'}<\/a>",
		'body' => (!$row->{'body'} || $row->{'body'} eq 'null' ? '' : $row->{'body'}),
		'intro' => $row->{'intro'}
	);
	return $news->expand();
}

1;
