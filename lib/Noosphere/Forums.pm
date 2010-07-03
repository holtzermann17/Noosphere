package Noosphere;
use strict;

# get a top view list of forums
#
sub getForumsTop {
	dwarn "Start of getForumsTop\n";
	my $params = shift;	 # not used currently
	my $userinf = shift;

	my $index="";
	my $table=getConfig('forum_tbl');

	(my $rv,my $sth)=dbSelect($dbh,{WHAT=>'uid,title,data',
																	FROM=>$table,
									WHERE=>'parentid is null',
									'ORDER BY'=>'lower(title)'});

	if (! $rv) {
		dwarn "error querying forums\n";
	return "error querying forums!";
	}

	my @rows = dbGetRows($sth);
	my $template = new Template('forums_main.html');
	
	if (@rows) {
		$index .= "<dl>";
		foreach my $row (@rows) {
			$index .= "<dt>";	
			$index .= "<a href=\"".getConfig("main_url")."/?op=getobj;from=$table;id=$row->{uid}\">$row->{title}</a>";
			my $messages = msgCountWithNew($table,$row->{uid},$userinf->{uid});
			$index .= " $messages";
			$index .= "</dt>";
			$index .= "<dd>$row->{data}</dd>";
		}
		$index .= "</dl>";
	} else {
		$index = "No forums.";
	}

	$template->setKey('index', $index);
	return paddingTable(clearBox('Forums',$template->expand())); 
}

# called by getobj, this interprets the object table entry in terms of a forum
#
sub renderForum {
	my $rec = shift;
	my $table = getConfig('forum_tbl');
	
	my $template = new Template('forumobj.html');
	
	my $forumobj = clearBox("Forum: $rec->{title}","<center>Welcome to the $rec->{title} forum!</center><hr width=\"100%\" size=1 noshade>".$rec->{data}."<p><center>[ <a href=\"".getConfig("main_url")."/?op=forums\">back to forums top</a> ]</center>");
	
	my $interact = makeBox("Interact","<center><a href=\"".getConfig("main_url")."/?op=postmsg;from=$table;id=$rec->{uid}\">post</a></center>");
	
	$template->setKeys('forumobj' => $forumobj, 'commands' => $interact);
	
	return $template;
}

sub getForumInteract {

}

1;
