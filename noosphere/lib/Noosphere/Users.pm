package Noosphere;
use strict;

use Noosphere::Layout;

sub getUserDisplayName {
	my $userid = shift;

	my $dispname = getConfig('display_real_name');

	my $displayname = "";
	my $sth = $dbh->prepare("select username, forename, middlename, surname, displayrealname from users where uid=?");
	$sth->execute($userid);
	if (  my $row = $sth->fetchrow_hashref() ) {
		if ( $row->{'displayrealname'} || $dispname ) {
			#build real name
			$displayname .= $row->{'forename'};
			$displayname .= " " . $row->{'middlename'} if ( $row->{'middlename'} ne "" );
			$displayname .= " " . $row->{'surname'} if ($row->{'surname'} ne "" );
		}
		if ( $displayname eq '' ) {
			$displayname = $row->{'username'};
		}
	}


	return $displayname;
}

sub approveAuthor {
	my $params = shift;
	my $userinf = shift;

	if ( can_approve_author($userinf->{'uid'}) ) {
		my $sth = $dbh->prepare("update users set approved=? where uid=?");
		$sth->execute( 1, $params->{'userid'} );
		return paddingTable(makeBox('Author Approved', "Author has been approved. Any new objects added by the author will be published to the encyclopedia without the need for approval."));
	} else {
		return paddingTable(makeBox('Cannot Approve', "You do not have the permission to approve an author"));
	}
}

# showUserActivity - display user list sorted by last access time.
#
sub showUserActivity {
	my $params = shift;
	my $userinf = shift;

	my $list = '';

	return loginExpired() if ($userinf->{'uid'} <= 0);
	
	my ($rv, $sth);
	($rv,$sth) = dbSelect($dbh,{WHAT=>'uid,username,last,CURRENT_TIMESTAMP-last as idle', FROM=>'users', WHERE=>"last is not null and uid != $userinf->{uid}", 'ORDER BY'=>'last', LIMIT=>getConfig('useractivity_max'), DESC=>''}) 
		if getConfig('dbms') eq 'pg';
	($rv,$sth) = dbSelect($dbh,{WHAT=>'uid,username,last,unix_timestamp(now())-unix_timestamp(last) as idle', FROM=>'users', WHERE=>"last is not null and uid != $userinf->{uid}", 'ORDER BY'=>'last', LIMIT=>getConfig('useractivity_max'), DESC=>''})
		if getConfig('dbms') eq 'mysql';
	
	my @rows = dbGetRows($sth);

	$list .= "<center><table cellpadding=\"2\">";
	$list .= "<tr><td align=\"center\">username</td><td align=\"center\">idle</td><td align=\"center\">last request @</td></tr>";
	foreach my $row (@rows) {
		$list .= "<tr>";
		$list .= "<td bgcolor=\"#eeeeee\" align=\"center\">$row->{username}</td>";
		my $idle = $row->{'idle'};
		$idle =~ s/\.\d+//;  # remove nths of a second 

		# turn idle interval into something more human-readable
		#
		my $d = int($idle / 86400);
		my $r = $idle % 86400;

		my $h = int($r / 3600);
		$r = $r % 3600;

		my $m = int($r / 60);
		my $s = $r % 60;

		my @idlearray;
		push @idlearray, $d.'d' if $d > 0;
		push @idlearray, $h.'h' if $h > 0;
		push @idlearray, $m.'m' if $m > 0;
		push @idlearray, $s.'s';

		my $idlestring = join (' ', @idlearray);
		
		$list .= "<td bgcolor=\"#eeeeee\" align=\"center\">$idlestring</td>"; 
		$list .= "<td bgcolor=\"#eeeeee\" align=\"center\">$row->{last}</td>"; 
		$list .= "</tr>";
	}
	$list .= "</table></center>";

	return paddingTable(clearBox('User Activity',$list));
}

# userList - get a user list
#
sub userList {
	my $params = shift;
	my $userinf = shift;
	
	$params->{'sortby'} = $params->{'sortby'} || 'uid';

	dwarn "*** userlist: sorting by $params->{sortby}";

	# info needed to organize/sort by columns
	#
	my %cols = (
		'uid' => {heading => 'user id', 
				sortsql => ['uid ASC', 'uid DESC'],
				order => 1,
				align => 'center'},
		'username' => {heading => 'username', 
				sortsql => ['lower(username) ASC', 'lower(username) DESC'],
				order => 2,
				align => 'left'},
		'score' => {heading => 'score',
				sortsql => ['score DESC', 'score ASC'],
				order => 3,
				align => 'center'},
		'entries' => {heading => 'entries',
				sortsql => ['entries DESC', 'entries ASC'],
				order => 4,
				align => 'center'},
		'productivity' => {heading => 'productivity',
				sortsql => ['productivity DESC', 'productivity ASC'],
				order => 5,
				align => 'center'},
#		'consistency' => {heading => 'consistency', 
#				sortsql => ['consistency DESC', 'consistency ASC'],
#				order => 6, 
#				align => 'center'}, 
		'joined' => {heading => 'joined on',
				sortsql => ['joined ASC', 'joined DESC'],
				order => 7,
				align => 'center'}
			);

	my $list = "";
	my $limit = $userinf->{prefs}->{pagelength};

	# get total if we don't have one
	#
	if (not defined $params->{total}) {
		my ($rv, $sth)=dbSelect($dbh,{WHAT=>'uid,username,joined,score', FROM=>'users', WHERE=>'uid > 0'});
		$params->{total}=$sth->rows();
		$sth->finish();
	}

	$params->{'offset'} = $params->{'offset'} || 0;
	
	my $sortkey = urlunescape($params->{'sortby'}) || 'uid';

	my ($rv, $sth);

	my $sortidx = (defined $params->{'sortidx'} ? $params->{'sortidx'} % 2 : 0);
	my $sortstmt = $cols{$sortkey}->{'sortsql'}->[$sortidx];
	
	($rv, $sth) = dbSelect($dbh,{WHAT=>'users.uid,
		users.username,
		users.joined,
		users.score,
		users.score/(date_part(\'days\',now()-users.joined)+1) as productivity,
		2/(1/(users.score/(date_part(\'days\',now()-users.joined)+1)+1)+1/(date_part(\'days\',now()-users.joined)+1)) as consistency, 
		sum(objects.uid IS NOT NULL) as entries', FROM=>'users left outer join objects ON objects.userid = users.uid', WHERE=>'users.uid > 0', 'GROUP BY' => 'users.uid', 'ORDER BY'=>$sortstmt, OFFSET=>$params->{'offset'}, LIMIT=>$limit}) if getConfig('dbms') eq 'pg';


	#compute everything we need.
	
	($rv, $sth) = dbSelect($dbh,{WHAT=>'users.uid,
		users.username,
		users.joined,
		users.score,
		users.score/(round((unix_timestamp(now())-unix_timestamp(users.joined))/86400)+1) as productivity, 
		2/(1/(users.score/(round((unix_timestamp(now())-unix_timestamp(users.joined))/86400)+1)+1)+1/(round((unix_timestamp(now())-unix_timestamp(users.joined))/86400)+1)) as consistency, 
		sum(users.uid) as entries',
		FROM=>'users left outer join objects ON users.uid = objects.userid', WHERE=>'users.uid > 0', 'GROUP BY' => 'users.uid', 'ORDER BY'=>$sortstmt, OFFSET=>$params->{'offset'}, LIMIT=>$limit}) if getConfig('dbms') eq 'mysql';

	my @rows = dbGetRows($sth);

	my $pager = getPager($params,$userinf);
	$pager =~ s/items/people/g;  # ugly hack

	$list .= "<center>";
	$list .= "$pager <p>";
	$list .= "<table cellpadding=\"2\">";

	my $main_url = getConfig('main_url');
	
	# populate column info with default selection CGI params, etc
	#
	foreach my $key (keys %cols) {
		$cols{$key}->{'params'} = {'op' => 'userlist', 'sortby' => $key};
		$cols{$key}->{'title'} = "Click on me to resort by ".$cols{$key}->{'heading'};
	}

	# alter column info based on selected or not
	#
	$cols{$sortkey}->{'heading'} = '<b>'.$cols{$sortkey}->{'heading'}.'</b>';
	$cols{$sortkey}->{'params'}->{'sortidx'} = ($sortidx + 1) % 2;
	$cols{$sortkey}->{'title'} = "Click on me to toggle the sort order.";
	
	$list .= "<tr> <td>&nbsp;</td>";

	# output column headings
	#
	foreach my $key (sort { $cols{$a}->{'order'} <=> $cols{$b}->{'order'} } (keys %cols)) {

		my $pstr = join('&amp;', map "$_=$cols{$key}->{params}->{$_}", (keys %{$cols{$key}->{'params'}}));

		$list .= "<td align=\"center\" valign=\"bottom\"><a href=\"$main_url/?$pstr\" title=\"$cols{$key}->{title}\">$cols{$key}->{heading}</a></td>";
	}
			 
	$list .= "</tr>";
			 
	my $i = $params->{'offset'} + 1;

	#modify the entries value for each row
	foreach my $row (@rows) {
		#users.uid, entries
		my $uid = $row->{'uid'};
		my $entries = getObjectCount($uid);
		$row->{'entries'} = $entries;
	}

	#re-sort if the sortby is 'entries'
	my @srows = ();
	if ( $params->{'sortby'} eq 'entries' ) {
		@srows = sort { $b->{'entries'} <=> $a->{'entries'} } @rows;
		@rows = @srows;
	}
		
	
	foreach my $row (@rows) {

		my %vals = ();

		# grab and format raw database values
		#
		%vals = %$row;
		$vals{'joined'} = ymd($row->{'joined'});
		$vals{'productivity'} = sprintf("%.2f",$row->{'productivity'});
#		$vals{'consistency'} = sprintf("%.2f",$row->{'consistency'});
		$vals{'username'} = "<a href=\"".getConfig("main_url")."/?op=getuser&id=$row->{uid}\">$row->{username}</a>";

		foreach my $key (keys %vals) {
			if ($sortkey eq $key) {
				$vals{$key} = '<b>'.$vals{$key}.'</b>';
			}
		}
	
		# print out columns
		#
		$list .= "<tr>"; 
		$list .= "<td align=\"left\">$i. </td>";

		foreach my $key (sort { $cols{$a}->{'order'} <=> $cols{$b}->{'order'} } keys %cols) {

			$list .= "<td align=\"".$cols{$key}->{'align'}."\">$vals{$key}</td>";
		}

		$list .= "</tr>"; 
		$i++;
	}
	
	$list .= "</table>";
	$list .= "<p>$pager";
	$list .= "</center>";

	$list .= "<br><br>
					<font size=\"-1\">
					<ol>
					<li>Productivity is approximately s/d, where s=score and d=number of days the user has been a member of ".getConfig('projname').".</li>
</ol>";

#			 <dt>2</dt>
# 	 		 <dd>Consistency is a metric of user value which attempts to recognize productivity over time.	It is approximately 2/(1/p+1/d), where p=productivity (as described above) and d=days of membership (this is then the harmonic mean of p and d).	The motivation for having such a metric is that new users can have a very high productivity at first, but then lose interest.	Since their productivity hasn't been spread over much time, they will hence not have a high consistency rating.</dd>
#			</dl>
#			</font> ";

	return paddingTable(clearBox(getConfig('projname').' Users',$list)); 
}

1;
