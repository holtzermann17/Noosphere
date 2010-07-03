package Noosphere;
use strict;

use Noosphere::IR;

# take a collab and add it as a site doc
#
sub addSiteDoc {
	my $params = shift;
	my $userinf = shift;
	
	return loginExpired() if ($userinf->{'uid'} <= 0);
	
	return errorMessage("You don't have access to that function") if ($userinf->{data}->{access} < getConfig('access_admin'));

	# process an addition
	#
	if (defined $params->{'id'}) {
		
		my $collab = getConfig('collab_tbl');

		# set site doc flag
		#
		my $sth = $dbh->prepare("update $collab set sitedoc = 1 where uid = $params->{id}");
		$sth->execute();
		$sth->finish();

		# update ACL to ensure world-writeable flag
		#
		my $acl = getConfig('acl_tbl');
		$sth = $dbh->prepare("update acl set _write = 1 where tbl='$collab' and objectid = $params->{id} and default_or_normal = 'd'");
		$sth->execute();
		$sth->finish();
	}

	my $template = new XSLTemplate('addsitedoc.xsl');

	$template->addText('<addsitedoc>');

	$template->addText("	<loggedin>1</loggedin>") if $userinf->{'uid'} > 0;

	my $collab = getConfig('collab_tbl');

	# get the intersection of the above list of IDs and the collaborations
	# that are site docs
	#
	my $xml = getCollabObjList($userinf, "sitedoc = 0 and published = 1");
	$template->addText($xml);

	$template->addText('</addsitedoc>');

	return $template->expand();
}


# admin score editing function
#
sub editScore {
	my $params = shift;
	my $userinf = shift;

	my $html = '';
	my $error = '';

	return loginExpired() if ($userinf->{'uid'} <= 0);
	
	return errorMessage("You don't have access to that function") if ($userinf->{data}->{access} < getConfig('access_admin'));

	my $user = $params->{'user'} || '';
	my $delta = $params->{'delta'} || '';

	# process submission 
	#
	if (defined $params->{'submit'}) {
		
		if ($user && $delta) {
			my $userid = 0;

			# try to resolve the user
			#
			if ($user !~ /^\s*(\d+)\s*$/) {
				my $uid = lookupfield(getConfig('user_tbl'), 'userid', "username='$user'");	

				$error .= "Could not find user '$user'!<br/>" if (not defined $uid);
			} else {
				$userid = $1;
			}

			# look up the user and process score
			#
			if ($userid) {
				
				if (lookupfield(getConfig('user_tbl'), 'username', "uid=$userid")) {
					# do the score delta
					#
					changeUserScore($userid, $delta);

					my $root = getConfig('web_root');
					return paddingTable(makeBox('Changed score', "Changed the score for user $userid.  <p/> Quick links: <p/> 
	<ul>
		<li>Go to the user's <a href=\"$root/?op=getuser&amp;id=$userid\">info page</a></li>
	</ul>"));

				} else {
					$error .= "Could not resolve the user with id $userid!<br/>";
				}

			} 

		} else {
			$error .= "Need a user id or name!<br/>" if (!$user);
			$error .= "Need a score delta!<br/>" if (!$delta);
		}
	}

	$html .= "<table cellpadding=\"2\" border=\"0\" width=\"100%\"><tr><td>";

	# show error
	#
	if ($error) {
		$html .= "<center>";
		$html .= "<font size=\"+1\" color=\"#ff0000\">";
		$html .= $error;
		$html .= "</font>";
		$html .= "</center>";
		$html .= "<br/>";
	}
	
	# show form
	#
	$html .= "<form action=\"".getConfig('web_root')."\" method=\"post\">";
	$html .= "User name or id: <br/>";
	$html .= "<input type=\"text\" name=\"user\" value=\"$user\" size=\"30\"/>";
	$html .= "<br/><br/>";
	$html .= "Score delta (+/- #): <br/>";
	$html .= "<input type=\"text\" name=\"delta\" value=\"$delta\" size=\"10\"/>";
	$html .= "<center>";
	$html .= "<input type=\"submit\" name=\"submit\" value=\"change\"/>";
	$html .= "</center>";
	$html .= "</form>";

	$html .= "</td></tr></table>";

	return paddingTable(makeBox('Change User Score', $html));
}

# the admin email blacklist editor
#
sub blacklistEditor {
	my $params = shift;
	my $userinf = shift;

	my $html = '';
	my $feedback = '';

	return loginExpired() if ($userinf->{uid} <= 0);
	
	my $isadmin = ($userinf->{data}->{access}>=getConfig('access_admin'));

	# handle deletions/updates
	#
	foreach my $key (keys %$params) {

		if ($key =~ /^delete_(\d+)$/) {

			my $id = $1;
			my $mask = lookupfield(getConfig('blist_tbl'), 'mask', "uid=$id");

			my ($rv, $sth) = dbDelete($dbh, {FROM=>getConfig('blist_tbl'), WHERE=>"uid=$id"});
			$sth->finish();

			$feedback = "Mask '".htmlescape($mask)."' deleted.";
				
		}
		elsif ($key =~ /^update_(\d+)$/) {
			my $id = $1;

			my $oldmask = lookupfield(getConfig('blist_tbl'), 'mask', "uid=$id");
			my $newmask = $params->{"mask_$id"};

			my $sth = $dbh->prepare("update ".getConfig('blist_tbl')." set mask=? where uid=$id");
			my $rv = $sth->execute($params->{"mask_$id"});

			$sth->finish();

			$feedback = "Record $id modified.";
			$feedback = "Mask '".htmlescape($oldmask)."' changed to '".htmlescape($newmask)."'.";
		}
	}

	# add a record
	#
	if ($params->{'add'}) {

		my $tbl = getConfig('blist_tbl');
		my $nextid = nextval($tbl.'_uid_seq');
		my $sth = $dbh->prepare("insert into $tbl (uid, mask) values (?, ?)");
		$sth->execute($nextid, $params->{'new_mask'});

		$sth->finish();

		$feedback = "Mask '".htmlescape($params->{'new_mask'})."' added.";
	}

	# get the current blacklist
	#
	my ($rv, $sth) = dbSelect($dbh, {WHAT=>'*', FROM=>getConfig('blist_tbl'), 'ORDER BY'=>'uid'});
	my @rows = dbGetRows($sth);

	# display feedback
	#
	if ($feedback) {

		$html .= "<font size=\"+1\" color=\"#ff0000\">$feedback</font><p>";
	}

	$html .= "<b>Current Blacklist:</b>";

	$html .= "<p>";
	
	# display rows, row editor
	#
	if (@rows) {
		$html .= "<table align=\"center\">";

		# output the mask, along with a form to update or delete it
		#
		foreach my $row (@rows) {
			$html .= "<tr>";

			$html .= "<form method=\"post\" action=\"".getConfig('main_url')."/\">";

			$html .= "<td>";
	
			$html .= "<input type=\"text\" size=\"50\" name=\"mask_$row->{uid}\" value=\"$row->{mask}\">";
						
			$html .= "</td>";

			$html .= "<td>";

			$html .= "<input type=\"submit\" name=\"update_$row->{uid}\" value=\"update\"> ";
			$html .= "<input type=\"submit\" name=\"delete_$row->{uid}\" value=\"delete\">";

			$html .= "</td>";


			$html .= "<input type=\"hidden\" name=\"op\" value=\"$params->{op}\">";
			$html .= "</form>";

			$html .= "</tr>";
		}

		$html .= "</table>";

	} else {
		$html .= '<center>No entries in the blacklist currently</center>.';
	}

	$html .= "<p>";

	# output add control
	#
	$html .= "<b>Add Blacklist Mask:</b>";

	$html .= "<p>";

	$html .= "<form method=\"post\" action=\"".getConfig('main_url')."/\">";
	$html .= "<center><input type=\"text\" size=\"50\" name=\"new_mask\"> 
		<input type=\"submit\" name=\"add\" value=\"add mask\"></center>";
	$html .= "<input type=\"hidden\" name=\"op\" value=\"$params->{op}\">";
	$html .= "</form>";

	$html .= "<p>";

	# about blurb
	#
	$html .= "<p><i>The blacklist is a list of perl regular expression masks which are checked against the email address of each new user.	When there is a match, the user's application is rejected.	This can be used to prevent attacks where one person creates many accounts, each with an email address that fits a regular pattern.</i>";

	return paddingTable(makeBox('Blacklist Editor', $html));
}


# reactivate a user. allows them to log in again.
#
sub reactivate {
	my $params = shift;
	my $userinf = shift;

	my $utbl = getConfig('user_tbl');

	return loginExpired() if ($userinf->{uid} <= 0);
	
	my $isadmin = ($userinf->{data}->{access}>=getConfig('access_admin'));
	
	if (!$isadmin) {
		return errorMessage("Only admins can reactivate users.");
	}
 
	if ($params->{ask} eq "yes") {
		return paddingTable(makeBox('Reactivate User',
		"<center><Br><font color=\"#ff0000\" size=\"+1\"><b>User will be able to log in.	Are you SURE? </b>
		<br><br>
	<a href=\"".getConfig("main_url")."/?op=reactivate&id=$params->{id}\">YES!</a><br><br>
	</center></font>"));
	}

	if (!objectExistsByUid($params->{id},$utbl)) {
		return errorMessage("User doesn't exist! Something might be broken.");
	}

	# change the "active" flag.
	#
	my ($rv, $sth) = dbUpdate($dbh, {WHAT=>$utbl, SET=>"active=1", WHERE=>"uid=$params->{id}"});

	return paddingTable(makeBox('Reactivate User',"User reactivated.	<ul><li>Click <a href=\"".getConfig('main_url')."\">here</a> to go home.</li><li>Click <a href=\"".getConfig('main_url')."/?op=getobj&from=users&id=$params->{id}\">here</a> to return to viewing the user</li></ol>"));
}

# deactivate a user. this just prevents them from ever logging in.
#
sub deactivate {
	my $params = shift;
	my $userinf = shift;

	my $utbl = getConfig('user_tbl');

	return loginExpired() if ($userinf->{uid} <= 0);
	
	my $isadmin = ($userinf->{data}->{access}>=getConfig('access_admin'));
	
	if (!$isadmin) {
		return errorMessage("Only admins can deactivate users.");
	}
 
	if ($params->{ask} eq "yes") {
		return paddingTable(makeBox('Deactivate User',
		"<center><Br><font color=\"#ff0000\" size=\"+1\"><b>User will not be able to log in.	Are you SURE? </b>
		<br><br>
	<a href=\"".getConfig("main_url")."/?op=deactivate&id=$params->{id}\">YES!</a><br><br>
	</center></font>"));
	}

	if (!objectExistsByUid($params->{id},$utbl)) {
		return errorMessage("User doesn't exist! Something might be broken.");
	}

	# change the "active" flag.
	#
	my ($rv, $sth) = dbUpdate($dbh, {WHAT=>$utbl, SET=>"active=0", WHERE=>"uid=$params->{id}"});

	return paddingTable(makeBox('Deactivate User',"User deactivated.	<ul><li>Click <a href=\"".getConfig('main_url')."\">here</a> to go home.</li><li>Click <a href=\"".getConfig('main_url')."/?op=getobj&from=users&id=$params->{id}\">here</a> to return to viewing the user</li></ol>"));
}

# delete a user
#
sub delUser {
	my $params = shift;
	my $userinf = shift;

	my $utbl = getConfig('user_tbl');

	return loginExpired() if ($userinf->{uid} <= 0);
	
	my $isadmin = ($userinf->{data}->{access}>=getConfig('access_admin'));
	
	if (!$isadmin) {
		return errorMessage("You can't delete other people!");
	}
 
	if ($params->{ask} eq "yes") {
		return paddingTable(makeBox('Delete User',
		"<center><Br><font color=\"#ff0000\" size=\"+1\"><b>User will be gone forever, are you SURE? </b>
		<br><br>
	<a href=\"".getConfig("main_url")."/?op=deluser&id=$params->{id}\">YES!</a><br><br>
	</center></font>"));
	}

	if (!objectExistsByUid($params->{id},$utbl)) {
		return errorMessage("User doesn't exist! Something might be broken.");
	}

	# handle situation where a user has created some objects
	#
	if (userCreatedObjects($params->{id})) {

		return errorMessage("User has created objects! Deleting will put the system in an inconsistent state.	Please <a href=\"".getConfig('main_url')."/?op=deactivate&id=$params->{id}&ask=yes\">deactive</a> the account instead.");
	}

	my $rv;
	
	# generic row delete
	#
	$rv = delrows($utbl,"uid=$params->{id}");

	# delete the user's watches
	#
	delUserWatches($params->{'id'});

	# delete the user's ACL stuff
	#
	deleteUserDefaultACL($params->{'id'});

	# delete from object index
	# 
	deleteTitle($utbl,$params->{'id'});
		
	# delete from search engine
	#
	irUnindex($params->{'from'}, $params->{'id'});

	return paddingTable(makeBox('Delete User',"User deleted.	Click <a href=\"".getConfig('main_url')."\">here</a> to go home."));
}

# cache control - ability to selectively invalidated cache groups
#
sub cacheControl {
	my $params = shift;
	my $userinf = shift;

	my $html = '';
	my $group = '';

	return noAccess() if ($userinf->{data}->{access} < getConfig('access_admin'));

	if ($params->{group} eq 'stats') {

		# handle an invalidation
		#
		if ($params->{invalidate}) {

			$stats->invalidate($params->{key});

			$html .= "<center>";
			$html .= "<font size=\"+1\" color=\"#ff0000\">";
			$html .= "Invalidated key $params->{key}";
			$html .= "</font>";
			$html .= "<br /><br />";
			$html .= "</center>";
		}

		# print out rows with invalidate control
		#
		my ($rv, $sth) = dbSelect($dbh, {WHAT=>'_key, valid, lastupdate', FROM=>getConfig('storage_tbl')});
		my @rows = dbGetRows($sth);

		$html .= "<p />Cache table for statistics (<a href=\"".getConfig("main_url")."/?op=cachecont&group=stats\">refresh</a>):<p/>";

		$html .= "<table align=\"center\" cellpadding=\"2\">";
		$html .= "<tr><td align=\"center\">key</td><td align=\"center\">last update</td><td align=\"center\">control</td></tr>";

		my $ord = 0;
		foreach my $row (@rows) {
			my $color = ($ord % 2 == 0) ? '#eeeeee' : '#dddddd';
			$html .= "<tr bgcolor=\"$color\">";	

			$html .= "<td>";
			$html .= $row->{'_key'};
			$html .= "</td>";

			$html .= "<td>";
			my $date = makeDate($row->{'lastupdate'},1);
			$html .= $date;
			$html .= "</td>";

			$html .= "<td>";
			if ($row->{'valid'}) {
				$html .= "<form method=\"post\" action=\"/\">";
				$html .= "<input type=\"submit\" name=\"invalidate\" value=\"invalidate\"/>";
				$html .= "<input type=\"hidden\" name=\"key\" value=\"$row->{_key}\"/>";
				$html .= "<input type=\"hidden\" name=\"op\" value=\"cachecont\"/>";
				$html .= "<input type=\"hidden\" name=\"group\" value=\"stats\"/>";
				$html .= "</form>";
			} else {
				$html .= "(invalid)";
			}
			$html .= "</td>";

			$html .= "</tr>";	
			$ord++;
		}
		$html .= "</table>";

		$html .= "<p />";
		$html .= "<center>";
		$html .= "<a href=\"".getConfig("main_url")."/?op=dbadmin&freeform=1&query=select+*+from+".getConfig('storage_tbl')."\">freeform edit this table</a> | ";
		$html .= "<a href=\"".getConfig("main_url")."/?op=cachecont\">back</a>";
		$html .= "</center>";
		$html .= "<br />";

		$group = 'Statistics';
	}
	elsif ($params->{group} eq 'en') {

		my $scale = 1/2;	 # pager scale

		my $method = $params->{method} || 'l2h';
		my $offset = $params->{offset} || 0;
		my $limit = int($userinf->{'prefs'}->{'pagelength'} / $scale);

		my $total = getrowcount(getConfig('cache_tbl'), "method='$method'");

		# handle an invalidation
		#
		if ($params->{invalidate}) {

			setbuildflag_off($params->{from}, $params->{id}, $method);
			setvalidflag_off($params->{from}, $params->{id}, $method);

			my $title = lookupfield($params->{from}, 'title', "uid=$params->{id}");

			$html .= "<center>";
			$html .= "<font size=\"+1\" color=\"#ff0000\">";
			$html .= "Invalidated entry '$title'";
			$html .= "</font>";
			$html .= "<br /><br />";
			$html .= "</center>";
		}

		# print out rows with invalidate control
		#
		# TODO: there is no really nice way to look up titles in a way that
		# is fast and not table-dependent.... perhaps we could wrap this into
		# a function that splits based on tbl and groups the lookups.
		#
		my $cache = getConfig('cache_tbl');
		my $en = getConfig('en_tbl');
		my ($rv, $sth);
		($rv, $sth) = dbLowLevelSelect($dbh, "select e.title, c.* from $en as e,$cache as c where e.uid=c.objectid and c.method='l2h' order by lower(e.title) offset $offset limit $limit")
			if (getConfig('dbms') eq 'pg');
		($rv, $sth) = dbLowLevelSelect($dbh, "select e.title, c.* from $en as e,$cache as c where e.uid=c.objectid and c.method='l2h' order by lower(e.title) limit $offset, $limit")
			if (getConfig('dbms') eq 'mysql');

		my @rows = dbGetRows($sth);

		$html .= "<p />Cache table for encylcopedia (<a href=\"".getConfig("main_url")."/?op=cachecont&group=en&method=$method&offset=$offset\">refresh</a>):";

		$params->{total} = $total;
		$html .= getPager($params, $userinf, $scale);

		# get the method selector
		#
		$html .= "<center>";
		my $methodsel = getSelectBox('method',
			getConfig('prefs_schema')->{method}->[3],
			$method,
			'onchange="methodform.submit()"');
		my $formvars = hashToFormVars(hashExcept($params,'method','offset'));		
		$html .= "<form method=\"get\" action=\"/\" name=\"methodform\">
			 Viewing for:	$methodsel
			 $formvars	
			 <input type=\"submit\" value=\"reload\"></form>";
		$html .= "</center>";

		$html .= "<br />";

		# main table, and header
		#
		$html .= "<table align=\"center\" cellpadding=\"2\">";
		$html .= "<tr><td align=\"center\">title</td><td align=\"center\">last update</td><td>valid</td><td>build</td><td align=\"center\">control</td></tr>";

		my $ord = 0;
		foreach my $row (@rows) {
			my $color = ($ord % 2 == 0) ? '#eeeeee' : '#dddddd';
			$html .= "<tr bgcolor=\"$color\">";	

			$html .= "<td>";
			$html .= "<a href=\"".getConfig("main_url")."/?op=getobj&from=$row->{tbl}&id=$row->{objectid}\">$row->{title}</a>";
			$html .= "</td>";

			$html .= "<td>";
			my $date = mdhm($row->{touched});
			$html .= $date;
			$html .= "</td>";

			$html .= "<td>$row->{valid}</td>";
			$html .= "<td>$row->{build}</td>";

			$html .= "<td>";
			$html .= "<form method=\"post\" action=\"/\">";
			$html .= "<input type=\"submit\" name=\"invalidate\" value=\"invalidate\"/>";
			$html .= "<input type=\"hidden\" name=\"id\" value=\"$row->{objectid}\"/>";
			$html .= "<input type=\"hidden\" name=\"from\" value=\"$row->{tbl}\"/>";
			$html .= "<input type=\"hidden\" name=\"op\" value=\"cachecont\"/>";
			$html .= "<input type=\"hidden\" name=\"group\" value=\"en\"/>";
			$html .= "</form>";
			$html .= "</td>";

			$html .= "</tr>";	
			$ord++;
		}
		$html .= "</table>";

		$html .= "<p />";
		$html .= "<center>";
		$html .= getPager($params, $userinf, $scale);
		$html .= "<br />";
		$html .= "<a href=\"".getConfig("main_url")."/?op=cachecont\">back</a>";
		$html .= "</center>";
		$html .= "<br />";

		$group = 'Encyclopedia Entries';
	}
	elsif ($params->{group} eq 'files') {

		$html = "Cache control for this group is not yet implemented.";

		$group = 'Files';
	}

	# show group selection menu
	#	
	else {

		$html .= "<table align=\"center\"><tr><td>";
		$html .= "<br />Please select a cache group:<br />";

		$html .= "<ul>";
		$html .= "<li><a href=\"".getConfig("main_url")."/?op=cachecont&group=stats\">statistics</a></li>";
		$html .= "<li><a href=\"".getConfig("main_url")."/?op=cachecont&group=en\">encyclopedia entries</a></li>";
		$html .= "<li><a href=\"".getConfig("main_url")."/?op=cachecont&group=files\">files</a></li>";
		$html .= "</ul>";
		$html .= "</td></tr></table>";

		$html .= "<br/><br/>";
	}

	my $title = 'Cache Control';
	if ($group) {
		$title .= " : $group";
	}
	return paddingTable(makeBox($title, $html));
}

# database admin interface (really this is a slightly specialized web version 
#	of a query client)
#
sub dbAdmin {
	my $params = shift;
	my $userinf = shift;

	my $history_max = 15;

	return noAccess() if ($userinf->{data}->{access} < getConfig('access_admin'));
	
	my $html = '';
	my $output = '';
	my $rv = 0;		 # query return value
	my $table = ''; # table for select query

	my $query = $params->{query} || '';

	# update query history 
	#
	my @history = map { urlunescape($_); } split(/;/, $params->{qhist});
	if (nb($query)) {
		splice @history, 0, 0, $query;	# "push" onto front latest entry
	}
	if (scalar @history > $history_max) {	# remove overfill entries
		my $over = scalar @history - $history_max;
		splice @history, scalar @history - $over, $over;
	}
	my $firstval = scalar @history > 0 ? $history[0] : '';
	my $histsel = getSelectBoxFromArray('history', \@history, $firstval,
	 'onChange="document.freeform.query.value=unescape(this.value)"');
	my $newqhist = join(';', map { urlescape($_); } @history);

	# process a query
	#
	my @resultset = ();		 # result row set

	# process schema query 
	#
	if ($params->{'schema'}) {

		my ($cols, $indices) = dbGetSchema($dbh, $params->{table});
		
	$output .= "<center><b>Schema for table '$params->{table}'</b>:</center><br>";

		# print out column schema
	#
	$output .= printTabular($cols, ['colname', 'typename', 'notnull', 'default']);

	# print out indices info
		#
	if (scalar @$indices > 0) {
		$output .= "<br><center><b>Indices on table '$params->{table}'</b>:</center><br>";
		$output .= printTabular($indices, ['indname', 'oncol', 'primary', 'unique']);
		}

	# other statistics
	#
	my $sth = $dbh->prepare("select count(*) as cnt from $params->{table}");
	$sth->execute();
	my $row = $sth->fetchrow_hashref();
	
	$output .= "<br><center><b>Rows in table</b>:</center><br>";
	$output .= "<center>$row->{cnt}</center>";
	}
	
	# handle a result set delete
	#
	elsif ($params->{'delete'}) {

		my $sth = $dbh->prepare("delete from $params->{table} where oid=$params->{oid}");
	$rv = $sth->execute();
	$sth->finish();

	if ($rv) {
			$output = "Delete successful.";
	}
	}

	# handle a query result update
	#
	elsif ($params->{'update'}) {

	my @sets = ();
	my @vals = ();
	
	# look for params of form col_fieldname
	#
	foreach my $key (keys %$params) {
			if ($key =~ /^col_(.+)$/) {
				my $colname = $1;
			push @sets, "$colname=?";
		push @vals, $params->{$key};
		}
	}
	my $set = join (', ', @sets);
	
		my $sth = $dbh->prepare("update $params->{table} set $set where oid=$params->{oid}");
	$rv = $sth->execute(@vals);
	$sth->finish();

	if ($rv) {
			$output = "Update successful.";
	}
	}

	# handle a freeform query
	#
	elsif ($params->{freeform}) {

	my $query = $params->{query};
	my $showoid = 0;

	if ($query =~ /^\s*select\s+(.+?)\s+from\s+(\w+)(.*)$/i) {
		my $rowlist = $1;
		$table = $2;
		my $rest = $3;

			# if oid is in query, make it visible
			if ($rowlist =~ /(^|\W)oid(\W|$)/) {
			$showoid = 1;
		} 
		
		# otherwise, add it to query, keep it invisible, assuming this isn't
		# an aggregate query
		#
		elsif (not $rowlist =~ /(^|\W)(avg|count|max|min|stddev|sum|variance)(\W|$)/) {
			$query = "select $rowlist, $table.oid from $table$rest";
		}
	}

		my $sth = $dbh->prepare($query);
	$rv = $sth->execute;
	if ($rv > 0) {
			@resultset = dbGetRows($sth);
	}
		
	if (scalar @resultset > 0) {
		$output = printResultRows(\@resultset, $table, $showoid, $newqhist);
	} else {
		if (!$rv) {
				my $error = $dbh->errstr;
		$output = "<font size=\"+1\" color=\"#ff0000\">$error</font>";
		} else {
			if ($params->{query} =~ /^\s*select/) {
				$output = "No matching rows.";
			}
		}
	}
	}

	# prep some stuff
	#
	my @tables = dbGetTables($dbh);
	my $tblhash = {map {$_ => $_} @tables};
	my $tblsel = getSelectBox('table', $tblhash, $params->{'table'});
	
	# ok, start outputting the form interface
	#
	$html .= "<table align=\"center\"><tr><td>";	 # main table

	# schema query section
	#
	$html .= "<table align=\"center\" cellpadding=\"5\" width=\"100%\"><tr><td bgcolor=\"#eeeeee\">";
	$html .= "<form action=\"/\" method=\"post\">";
	$html .= "<b>Get table information</b>:<br><br>";
	$html .= "Select a table: $tblsel ";
	$html .= "<input type=\"submit\" name=\"schema\" value=\" go \">";
	$html .= "<input type=\"hidden\" name=\"op\" value=\"dbadmin\">";
	$html .= "<input type=\"hidden\" name=\"qhist\" value=\"$newqhist\"><br>";
	$html .= "</form>";
	$html .= "</td></tr></table>";
	
	# build-a-query section
	#
=disabled
	$html .= "<table align=\"center\" cellpadding=\"5\" width=\"100%\"><tr><td bgcolor=\"#eeeeee\">";
	$html .= "<form action=\"/\" method=\"post\">";
	$html .= "<b>Build-a-query</b>:<br><br>";
	$html .= "Select a table: $tblsel<br>";
	$html .= "Proceed to next step for: ";
	$html .= "<input type=\"submit\" name=\"build_select\" value=\"select\"> ";
	$html .= "<input type=\"submit\" name=\"build_update\" value=\"update\"> ";
	$html .= "<input type=\"submit\" name=\"build_insert\" value=\"insert\"> ";
	$html .= "<input type=\"submit\" name=\"build_delete\" value=\"delete\">";
	$html .= "<input type=\"hidden\" name=\"op\" value=\"dbadmin\">";
	$html .= "</form>";
	$html .= "</td></tr></table>";
=cut

	# freeform query section
	#
	$html .= "<table align=\"center\" cellpadding=\"5\" width=\"100%\"><tr><td bgcolor=\"#eeeeee\">";
	$html .= "<form name=\"freeform\" action=\"/\" method=\"post\">";
	$html .= "<b>Freeform query</b>:<br><br>";
	$html .= "History: $histsel <br>";
	$html .= "<textarea rows=\"5\" cols=\"70\" name=\"query\">$query</textarea>";
	$html .= "<input type=\"hidden\" name=\"op\" value=\"dbadmin\"><br>";
	$html .= "<input type=\"hidden\" name=\"qhist\" value=\"$newqhist\"><br>";
	$html .= "<center>";
	$html .= "<input type=\"submit\" name=\"freeform\" value=\"submit\">";
	$html .= "</center>";
	$html .= "</form>";
	$html .= "</td></tr></table>";

	$html .= "</td></tr></table>";	# main table

	# display result output
	#
	if ($output) {
		$html .= '<hr>' . $output . '<br>';
	}
	elsif (nb($params->{query})) {
	if (!$rv) {
		$html .= "<font size=\"+1\" color=\"#ff0000\">Query error.</font>";
	}
	}

	return paddingTable(makeBox('Database Admin', $html));
}

# do a tabular html print, using an arrayref to hashrefs, all of which have
# the same keys
#
sub printTabular {
	my $rows = shift;
	my $order = shift;
	
	my $output = '';

	$output .= "<table cellpadding=\"2\" border=\"1\" align=\"center\" bgcolor=\"#ccccff\">";

	# print header, using key names
	#
	$output .= "<tr>";
	foreach my $key ($order ? @$order : keys %{$rows->[0]}) {
		$output .= "<td align=\"center\">$key</td>";
	}
	$output .= "</tr>";

	# print rows
	#
	foreach my $row (@$rows) {
		$output .= "<tr>";
		foreach my $key ($order ? @$order : keys %$row) {
		$output .= "<td bgcolor=\"#eeeeee\">$row->{$key}</td>";
	}
		$output .= "</tr>";
	}

	$output .= "</table>";

	return $output;
}

# prints dbadmin select query result rows, augmented with update/delete 
# controls.
#
sub printResultRows {
	my $resultset = shift;
	my $table = shift;
	my $showoid = shift;
	my $qhist = shift;		 # query history

	my $default_size = 15; # default form input size
	my $max_size = 75;
	my $fudge_factor = 10; # if average is only this much off from max, then 
						 # max will be used instead of average.

	my $html = '';
	
	# print rows
	#
	my $cnt = scalar @$resultset;
	$html .= "Results ($cnt):<br>";

	# compute average lengths of each field, for formatting
	#
	my %averages;
	foreach my $key (keys %{$resultset->[0]}) {
		my $count = 0;
		my $sum = 0;
		my $max = 0;

		# get sum of nonblank field lengths
		foreach my $row (@$resultset) {
			if (nb($row->{$key})) {
			my $len = length($row->{$key});
		$sum += $len;
		if ($len > $max) {
					$max = $len;
		 }
		$count++;
		}
	}

		# calculate average
	if ($count > 0) {
			$averages{$key} = int($sum/$count);
		if ($averages{$key} == 0) {
				$averages{$key} = $default_size;
		}
		if ($averages{$key} < $max && $max - $averages{$key} < $fudge_factor) {
		$averages{$key} = $max;
		}
	} 
	}

	$html .= "<table cellspacing=\"0\" cellpadding=\"5\" width=\"100%\">";

	# data rows, each with an update and delete control
	#
	my $ord = 0;
	foreach my $row (@$resultset) {
		
		my $color = $ord % 2 == 0 ? '#ccccff' : '#dddddd';
	$html .= "<form method=\"post\" action=\"/\">";
		$html .= "<tr><td bgcolor=\"$color\">";
	my $col = 0;
	foreach my $key (keys %$row) {
		next if ($key eq 'oid' && !$showoid);

		my $size = $averages{$key} || $default_size;
		$size = $size > $max_size ? $max_size : $size;

		# calculate linebreak.
		$col += $size + length($key);
		if ($col > $max_size) {
			$html .= "<br>";
			$col = $size + length($key);
	 		}
		
		$html .= "<font face=\"courier, fixed\" size=\"-1\">$key: </font><input type=\"text\" size=\"$size\" name=\"col_$key\" value=\"".qhtmlescape($row->{$key})."\"> ";
	}

		$html .= "</td></tr>";

	if ($row->{oid}) {
			$html .= "<tr><td align=\"center\" bgcolor=\"$color\">";
		$html .= "<input type=\"submit\" name=\"update\" value=\"update\"> ";
		$html .= "<input type=\"submit\" name=\"delete\" value=\"delete\">";
		$html .= "<input type=\"hidden\" name=\"oid\" value=\"$row->{oid}\"> ";
		$html .= "<input type=\"hidden\" name=\"table\" value=\"$table\"> ";
		$html .= "<input type=\"hidden\" name=\"op\" value=\"dbadmin\">";
			$html .= "<input type=\"hidden\" name=\"qhist\" value=\"$qhist\"><br>";
			$html .= "</td></tr>";
	}
	
	$html .= "</form>";

	$ord++;
	}

	$html .= "</table>";

	return $html;
}

# encyclopedia-specific admin controls
#
sub getEncyclopediaAdminControls {
	my $template = shift;
	my $userinf = shift;
	my $from = shift;
	my $id = shift;
	my $method = shift;

	my $methodstr = "";
	$methodstr = "&method=$method" if ($method);

	if ($userinf->{data}->{access} >= getConfig('access_admin')) {
		my $admin = '';

		$admin .= "<center> \n";

		$admin .= "<a href=\"".getConfig("main_url")."/?op=rerender&amp;from=$from&amp;id=$id$methodstr\">rerender</a> | ";
		$admin .= "<a href=\"".getConfig("main_url")."/?op=relink&amp;from=$from&amp;id=$id$methodstr\">relink</a> | ";
		$admin .= "<a href=\"".getConfig("main_url")."/?op=linkinvalidate&amp;from=$from&amp;id=$id\">invalidate inlinks</a> | ";

		$admin .= "<a href=\"".getConfig("main_url")."/?op=adminedit&amp;from=$from&amp;id=$id\">qwik-edit</a> | ";
		$admin .= " <a href=\"".getConfig("main_url")."/?op=linkpolicy&amp;from=$from&amp;id=$id\">edit linking policy</a> | ";

		if (getConfig('classification_supported')) {
			$admin .= "<a href=\"".getConfig("main_url")."/?op=adminclassify&amp;from=$from&amp;id=$id\">classify</a> | ";
		}

		if ( is_published($id) ) {
			$admin .= "<a href=\"".getConfig("main_url")."/?op=unpublish&amp;from=$from&amp;id=$id&amp;ask=yes\">unpublish</a> | ";
		} else {
			$admin .= "<a href=\"".getConfig("main_url")."/?op=publish&amp;from=$from&amp;id=$id&amp;ask=yes\">publish</a> | ";
		}

		$admin .= "<a href=\"".getConfig("main_url")."/?op=delobj&amp;from=$from&amp;id=$id&amp;ask=yes\">delete</a>";

		$admin .= "</center>";

		$template->setKey('admin', adminBox('Admin Controls', $admin));
	}
}

# poll admin controls
#
sub getPollAdminControls {
	my $template = shift;
	my $userinf = shift;
	my $params = shift;

	if ($userinf->{data}->{access} >= getConfig('access_admin')) {
		my $admin = '';

		$admin .= "<center> \n";

		$admin .= "<a href=\"".getConfig("main_url")."/?op=delobj&amp;from=$params->{from}&amp;id=$params->{id}&amp;ask=yes\">delete</a>";

		$admin .= "</center>";

		$template->setKey('admin', adminBox('Admin Controls', $admin));
	}
}

# getAdminMenu - get the administrator toolbar menu
#								TODO: show varying options based on access level
#
sub getAdminMenu {
	my $access = shift;
	
	my $html = '';
	my $menu = '';
	
	if ($access >= getConfig('access_admin') ) {
		my $bullet = getBullet();
	$menu .= "$bullet&nbsp;<a href=\"".getConfig("main_url")."/?op=postnews\">post news</a><br>";
	$menu .= "$bullet&nbsp;<a href=\"".getConfig("main_url")."/?op=newpoll\">new poll</a><br>";
	$menu .= "$bullet&nbsp;<a href=\"".getConfig("main_url")."/?op=adminstats\">statistics</a><br>";
	$menu .= "$bullet&nbsp;<a href=\"".getConfig("main_url")."/?op=dbadmin\">DB admin</a><br>";
	$menu .= "$bullet&nbsp;<a href=\"".getConfig("main_url")."/?op=cachecont\">cache control</a><br>";
	$menu .= "$bullet&nbsp;<a href=\"".getConfig("main_url")."/?op=blacklist\">blacklist</a><br>";
	$menu .= "$bullet&nbsp;<a href=\"".getConfig("main_url")."/?op=addsitedoc\">add site doc</a><br>";
	$menu .= "$bullet&nbsp;<a href=\"".getConfig("main_url")."/?op=unpublished\">unpublished</a><br>";
	$html = adminBox('Admin Menu',$menu);
	$html = "<tr><td>$html</td></tr>";
	}
	return $html;
}

# Admin object metadata editor 
#
sub adminObjectEditor {
	my $params = shift;
	my $userinf = shift;

	my $schema;
	if ($params->{from} eq getConfig('en_tbl')) {
		$schema = getConfig('en_schema'); 
	}
	else {
	$schema = getConfig('generic_schema')->{$params->{from}};
	}

	return noAccess() if ($userinf->{data}->{access} < getConfig('access_editobj'));

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'*',FROM=>$params->{from},WHERE=>"uid=$params->{id}"});
	my $rec = $sth->fetchrow_hashref();
	$sth->finish();
	
	my $html = '';

	if (defined $params->{submit} || defined $params->{submit2}) {
	my $homeflag = defined $params->{submit2} ? 1 : 0;
		if (nb($params->{remark})) {
			$html = adminUpdateObjectMetadata($schema,$params,$userinf,$rec, $homeflag);
	} else {
			$html = errorMessage("You <b>must</b> enter a remark for your modification! Please hit 'back' and do this.");
	}
	} else {
			my $title = $params->{from} eq getConfig('en_tbl') ? 'Qwik-editing' : 'Editing metadata';
			$html = paddingTable(makeBox($title, getAdminMetadataEditor($params,$schema,$rec)));
	}

	return $html;
}

# Admin classifier
#
sub adminClassify {
	my $params = shift;
	my $userinf = shift;
	
	my $template = new XSLTemplate('adminclassify.xsl');

	return noAccess() if ($userinf->{data}->{access} < getConfig('access_editobj'));

	$template->addText('<adminclassify>');

	my $title = lookupfield($params->{from},'title',"uid=$params->{id}");
	my $userid = lookupfield($params->{from},'userid',"uid=$params->{id}");

	if (defined $params->{submit}) {
	if ($params->{invalidate} eq 'on') {
			setvalidflag_off($params->{from},$params->{id});
	}
		classify($params->{from},$params->{id},$params->{class});

	# send notice
	#
	if ($userid != $userinf->{uid}) {
		fileNotice($userid,
							 $userinf->{uid},
					 'Entry classified (or reclassified)',
					 'You may want to inspect the new classification.',
					 [{id=>$params->{id},table=>$params->{from}}]);
		}
	return paddingTable(makeBox('Object Classified',"To go back to the object, click <a href=\"".getConfig("main_url")."/?op=getobj&from=$params->{from}&id=$params->{id}\">here</a>.
	<meta http-equiv=\"refresh\" content=\"0; url=".getConfig("main_url")."/?op=getobj&from=$params->{from}&id=$params->{id}\">"));
	} else {
		$template->setKeys(%$params);
	$template->setKey('class', classstring($params->{from},$params->{id}));
	}

	$template->setKey('hascache', 1) if ($params->{from} eq getConfig('en_tbl'));
	$template->setKey('title', $title);
	$template->addText('</adminclassify>');

	return $template->expand();
}

# get the form for editing metadata
# 
sub getAdminMetadataEditor {
	my $params = shift;
	my $schema = shift;
	my $rec = shift;
	
	my $html = '';

	# initial form output
	#
	$html .= "<form method=\"post\" action=\"/\">";

	# build metadata editing portion of form
	#
	foreach my $key (sort { humanReadableCmp $a, $b } keys %$schema) {
		my ($widget,$desc) = getFormWidget($schema,$key,$rec);
	next if (blank($widget) || blank($desc));
		$html .= "$desc:<br> $widget <br>";
	}

	# add editing fields
	#
	$html .= "<br>Editing remark: <br><textarea name=\"remark\" rows=\"5\" cols=\"50\"></textarea>";
	$html .= "<input type=\"hidden\" name=\"op\" value=\"adminedit\">";
	$html .= "<input type=\"hidden\" name=\"id\" value=\"$params->{id}\">";
	$html .= "<input type=\"hidden\" name=\"from\" value=\"$params->{from}\">";
	$html .= "<br><br>";
	$html .= "<center><input type=\"submit\" name=\"submit\" value=\"submit\">";
	$html .= " <input type=\"submit\" name=\"submit2\" value=\"submit and go to home\"></center>";
	$html .= "</form>";
	
	return $html;
}

sub adminUpdateObjectMetadata {
	my $schema = shift;
	my $params = shift;
	my $userinf = shift;
	my $rec = shift;
	my $gohome = shift;

	my @update;
	
	# find fields which have changed
	#
	foreach my $key (keys %$schema) {
		my $val = $params->{$key};

		# convert checkbox values to boolean 0/1
		if ($schema->{$key}->[1] eq 'check') {
			if (defined $val) {
				$val = ($val eq 'on')?1:0;
			}
		}
	
		if (defined $val && ($val ne $rec->{$key})) {
			#dwarn "*** admin edit: going to update $key to $val";
			push @update,"$key='".sq($val)."'";
		} 
	
		elsif (not defined $val) {
			if ($schema->{$key}->[1] eq 'check') {
				#dwarn "*** admin edit: going to update $key to 0";
				push @update,"$key=0";
			} elsif ($schema->{$key}->[1] eq 'text' ||
						 $schema->{$key}->[1] eq 'tbox') { 
				#dwarn "*** admin edit: going to update $key to ''";
				push @update,"$key=''";
			}
		}
	}

	# make the changes
	#
	if ($#update >= 0) {

		# encyclopedia stuff
		if ($params->{from} eq getConfig('en_tbl')) {
			# save a snapshot of the current version
			snapshot($params->{from}, $rec->{uid}, "$rec->{name}_$rec->{version}", $userinf->{uid}, $params->{remark});
			
			# increment version
			my ($rv, $sth) = dbUpdate($dbh,{WHAT=> $params->{from}, SET => 'version=version+1', WHERE=>"uid=$params->{id}"});
		}
	
		# generic field updating
		my ($rv,$sth) = dbUpdate($dbh,{
			WHAT => $params->{from},
 			SET => join(',',@update),
			WHERE => "uid=$params->{id}"
		});
	
		$sth->finish();

		# do stuff for updating of encyclopedia objects. (invalidate, xref, etc) 
		#
		if ($params->{from} eq getConfig('en_tbl')) {
			handleEncyclopediaChange($params,$rec);
		}
	}

	# build the notice and send it out
	#
	my $nid = adminEditNote($userinf,$rec->{userid},$params->{remark});
	makeObjLink('notices',$nid,$params->{from},$rec->{uid},(defined $rec->{title}?$rec->{title}:'object'));

	# give some points
	#
	changeUserScore($userinf->{uid},getScore('edit_en_minor'));

	# update stats
	#
	$stats->invalidate('latestadds');
	$stats->invalidate('latestmods');

	# finish up
	#
	if (! $gohome) {
		return paddingTable(makeBox('Update Successful',"You will now be redirected back to the object. If this does not work, click <a href=\"".getConfig("main_url")."/?op=getobj&from=$params->{from}&id=$params->{id}\">here</a>.
		<meta http-equiv=\"refresh\" content=\"0; url=".getConfig("main_url")."/?op=getobj&from=$params->{from}&id=$params->{id}\">"));
	} else {
		return paddingTable(makeBox('Update Successful',"You will now be redirected back home. If this does not work, click on the ".getConfig('projname')." logo or just do something else.
		<meta http-equiv=\"refresh\" content=\"0; url=/\">"));
	}
}

# file notice for admin edit 
#
sub adminEditNote {
	my $userinf = shift;
	my $userto = shift;
	my $remark = shift||'';
	
	# get the insert id so we can return it
	#
	my $id = nextval('notices_uid_seq');

	# do the insert
	#
	my ($rv,$sth) = dbInsert($dbh,{
	INTO => 'notices',
	COLS => 'uid,userid,userfrom,title,data',
	VALUES => "$id,$userto,$userinf->{uid},'Your object was edited','".sq($remark)."'"
	});
	$sth->finish();
	
	return $id;
}

sub adminStats
{
	my $params = shift;
	my $userinf = shift;

	return noAccess() if ($userinf->{data}->{access} < getConfig('access_editobj'));

#my $template = new Template("adminstats.html");

# various statistics are computed here
#adminDBStats($template);
#FileCache::setStatKeys($template);

		my $template = new XSLTemplate("adminstats.xsl");

		adminDBStats($template);

	return paddingTable(clearBox("Administrative Statistics", $template->expand()));
}

sub adminDBStats
{
	my $template = shift;
	my @countstats = (
#			ord, label, DBsel, DBtbl, DBwhere, output
			[ 'Entries', '*', getConfig('en_tbl'), '', undef ],
			[ 'Invalid Entries', 'distinct objectid', getConfig('cache_tbl'), 'valid = 0 and method=\'l2h\' and tbl=\''.getConfig('en_tbl').'\'', undef ],
			[ 'Entries in Build', 'distinct objectid', getConfig('cache_tbl'), 'not build = 0 and method=\'l2h\' and tbl=\''.getConfig('en_tbl').'\'', undef ],
			[ 'Cross References', '*', getConfig('xref_tbl'), '', undef ],
			[  'Users', '*', 'users', '' , undef],
		);

	my $ec = $countstats[0];	# pointer to entry count countstats row
	my $cr = $countstats[3];	# pointer to cross-references countstats row

	# add object type queries to stats table
	#
	foreach my $ot (keys(%{getConfig("typechars")})) {
		push @countstats, [ 'Count of type: '.getConfig("typestrings")->{$ot}, '*', getConfig('en_tbl'), "type = '$ot'", undef ];
	}

	# add results to stats array
	#
	foreach my $s (@countstats) {
		$s->[4] = dbRowCountWithWhat($s->[1], $s->[2], $s->[3]);
	}
	
	# BB: avoid division by zero on empty database
	#
	if ($ec->[4] != 0) {
		splice @countstats, 4, 0, [ 'Cross-references/Entry', undef, undef, undef, sprintf("%.02f", $cr->[4] / $ec->[4]) ];
	} 

	push @countstats, ['Unproven Theorems', undef, undef, undef, scalar keys(%{getUnprovenTheorems()}) ];

	foreach my $s (@countstats) {
			$template->addText("<stat name=\"$s->[0]\">$s->[4]</stat>\n");
	}
	return $template;
}

1;

