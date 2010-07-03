package Noosphere;

###############################################################################
#
# this package contains methods to handle Noosphere user groups
#
###############################################################################

use strict;

# create an editor group on a particular object
#
#  * makes a group name: title . ' editors'
#  * adds ACL rule for the object: this group can write
#
sub createEditorGroup {
	my $params = shift;
	my $userinf = shift;
	
	# add the group
	#
	my $title = lookupfield($params->{from}, 'title', "uid=$params->{id}");
	my $gname = "$title editors";
	my $gdesc = "Editors of the '$title' object.";
	
	my $groupid = addGroup($userinf->{uid}, $gname, $gdesc);

	# add the editor access rule for the group
	#
	my $aclspec = {subjectid => $groupid,
						user_or_group => 'g',
					default_or_normal => 'n',
					perms => {'read' => 1,
								'write' => 1,
								'acl' => 0}};
								
	addACL($params->{from}, $params->{id}, $aclspec);

	# send the user to the group editor for the group
	#
	$params->{gid} = $groupid;
	$params->{created} = 'yes';
	return memberEditor($params, $userinf);
}

# the editor for modifying/creating/deleting groups
#
sub groupEditor  {
	my $params = shift;
	my $userinf = shift;

	my $error = '';

	my $template = new Template('groupeditor.html');

	# handle adding a group
	#
	if (defined $params->{addgroup})  {
	  addGroup($userinf->{uid},$params->{groupname_new},$params->{groupdesc_new});
	}

	# handle deleting a group
	#
	if (defined $params->{delgroup}) {
	  foreach my $key (keys %$params) {
	  if ($key =~ /^selected_([0-9]+)$/) {
	    my $gid = $1;
	      deleteAllUsersFromGroup($gid);
		deleteGroup($gid);
	  }
	}
	}

	$template->unsetKeys('groupname_new','groupdesc_new');
	$template->setKey('error',($error?'<br />'.$error:''));

	# grab the adminned groups list
	#
	my $adminlist = getAdminGroups($userinf->{uid});
	$template->setKey('adminlist',$adminlist);

	return paddingTable(makeBox('Editing your groups', $template->expand()));
}

# get a hash of groups adminned by a user, of the format groupid => name
#
sub getAdminGroupHash {
	my $userid = shift;

	my $gtbl = getConfig('groups_tbl');

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>'groupid, groupname',FROM=>$gtbl, WHERE=>"userid=$userid"});
	my @rows = dbGetRows($sth);
	
	my %grouphash;
	
	foreach my $row (@rows) {
	  $grouphash{$row->{groupid}} = $row->{groupname};
	}
 
	return {%grouphash};
}

# This takes a hash of groupid => name and removes all entries that 
#  represent groups that the given userid is a member of.
#  This is useful for generating a hash that consists only of valid groups
#  a user could be added to that they are not already in.
#
sub subtractUserFromGroupHash {
	my $userid = shift;
	my $groups = shift;

	my $gmember = getConfig("gmember_tbl");

	foreach my $gid (keys %$groups) {
	  # check to see if user is already in group
	  if (defined lookupfield($gmember, 'userid',"groupid=$gid and userid=$userid")) {
	  delete $groups->{$gid};
	  }
	}
}

# get a list of groups adminned by a user, formatted for the group editor
# 
sub getAdminGroups {
	my $userid = shift;
	my $html = '';

	my $gtbl = getConfig('groups_tbl');

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>"*",FROM=>$gtbl, WHERE=>"userid=$userid"});

	my @rows = dbGetRows($sth);

	foreach my $row (@rows) {
	  $html .= "<input type=\"checkbox\" name=\"selected_$row->{groupid}\"> ";
	$html .= " <a href=\"".getConfig("main_url")."/?op=memberedit&gid=$row->{groupid}\">$row->{groupname}</a> ";
	my $count = getMemberCount($row->{groupid});
	  $html .= "($count ".($count == 1?'member':'members').")<br />";
	$html .= "<blockquote>$row->{description}</blockquote>";
	}

	return $html || "[none]";
}

# edit the membership of a group. also configure the group title/descr.
# 
sub memberEditor {
	my $params = shift;
	my $userinf = shift;

	my $gtbl = getConfig('groups_tbl');
	my $gid = $params->{gid};

	my $error = '';
	my $html = '';

	my $adminid = lookupfield($gtbl, 'userid', "groupid=$gid");

	return errorMessage("You aren't the admin of that group!") if ($userinf->{uid} != $adminid);
	
	# process deletions from group 
	#
	foreach my $key (keys %$params) {
	  if ($key =~/^del_([0-9]+)/) {
	  my $userid = $1;
	    deleteUserFromGroup($gid, $userid);
	  my $username = lookupfield(getConfig('user_tbl'), 'username', "uid=$userid");
	  $error .= "user '$username' removed.<br />";
	}
	}

	# process additions to group
	#
	if ($params->{adduser}) {
	
	my $userid;

	# check to see if user id exists
	if ($params->{addid} =~ /^\s*(\d+)\s*$/) {
	  my $id = $1;
	    if (not defined lookupfield(getConfig('user_tbl'),'uid',"uid=$id")) {
	      $error .= "User with id $id does not exist!<br />";
	    } else {
	    $userid = $id;
	  }
	
	} else {

	  my $username = $params->{addid};
	  $username =~ s/^\s*//;
	  $username =~ s/\s*$//;

	    $userid = lookupfield(getConfig('user_tbl'), 'uid', "username='$username'");
	  if (not defined $userid) {
	    $error .= "Could not resolve '$username' to an actual user!<br />";
	  }
	}

	# check to see if the user is already in the group
	#
	if (!$error) {
	  if (defined lookupfield(getConfig('gmember_tbl'),'userid',"groupid=$gid and userid=$userid")) {
	      $error .= "That user is already a member of this group!<br />";
	  }
	
	  # no errors- do the addition
	  else {
	      addUserToGroup($gid, $userid);
	  }
	}
	}

	# change group info (title, description)
	#
	my $groupname = '';
	my $groupdesc = '';
	if ($params->{changeinfo}) {
	  
	$groupname = $params->{groupname};
	$groupdesc = $params->{groupdesc};

	# do the update 
	#
	my ($rv, $sth) = dbUpdate($dbh, {WHAT=>$gtbl, SET=>'groupname='.sqq($groupname).', description='.sqq($groupdesc), WHERE=>"groupid=$gid"});
	$sth->finish();

	$error .= "Updated group info.<br />";
	} 
	
	# grab the group info from the table
	#
	else {
	  ($groupname, $groupdesc) = lookupfields($gtbl, 'groupname, description', "groupid=$gid");
	}

	# set a message if we just created this group
	#
	if ($params->{created}) {
	  $error .= "Group created.  You can modify it here.<br />"
	}

	$html .= "<table width=\"100%\" cellpadding=\"2\"><td>";
	$html .= "<form method=\"post\" action=\"/\">";

	# display errors 
	#
	$html .= "<center><font size=\"+1\" color=\"#ff0000\">$error</font></center><br />";
	
	# display group info change section
	#
	$html .= "<b>Change info for this group:</b><br /><br />";
	$html .= "<table width=\"90%\" align=\"center\"><tr><td>";

	$html .= "Group name: <br />";
	$html .= "<input type=\"text\" size=\"60\" name=\"groupname\" value=\"".qhtmlescape($groupname)."\" /> <br /> <br />";
	$html .= "Group description: <br />";
	$html .= "<textarea cols=\"60\" rows=\"5\" name=\"groupdesc\"/>$groupdesc</textarea>";
	$html .= "<br /><br />";
	$html .= "<center><input type=\"submit\" name=\"changeinfo\" value=\"update\" /></center>";
	$html .= "</td></tr></table>";

	$html .= "<br /><br />";

	# display member addition section
	#
	$html .= "<b>Add members to this group:</b><br /><br />";
	
	$html .= "<table width=\"90%\" align=\"center\"><tr><td>";

	$html .= "<center>User's name or id: ";
	$html .= "<input type=\"text\" size=\"30\" name=\"addid\" value=\"\" />";

	$html .= "<br /><br />";
	$html .= "<input type=\"submit\" name=\"adduser\" value=\"add user\" /></center>";

	$html .= "<br />";
	$html .= "<i>Tip: An easy way to add a user to a group is to simply search for their name in the search engine to retreive their info page.  From this page, you can select to add them to any of your groups.</i>";
	$html .= "</td></tr></table>";

	$html .= "<br /><br />";

	# display the current list 
	#
	my @members = getGroupMembers($gid);

	$html .= "<b>Members of this group:</b><br /><br />";
	
	if ($#members >=0 ) {
	foreach my $member (@members) {
	  $html.="<input type=\"checkbox\" name=\"del_$member->{userid}\">";
	$html.=" <a href=\"".getConfig("main_url")."/?op=getuser&id=$member->{userid}\">$member->{username}</a>";
	$html.="<br />";
	}
	} else {
	  $html.="<center>(no members)</center>";
	}

	# display deletion control
	#
	$html.="<br />";
	$html.="<center><input type=\"submit\" name=\"delete\" value=\"remove selected\"></center>";

	$html.="<input type=\"hidden\" name=\"op\" value=\"memberedit\">";
	$html.="<input type=\"hidden\" name=\"gid\" value=\"$gid\">";

	$html.="</form>";

	$html.="<center>";
	$html.="(<a href=\"".getConfig("main_url")."/?op=groupedit\">back to editing your groups</a>)";
	$html.="</center>";

	$html.="</td></table>";

	my $gname=lookupfield($gtbl,'groupname',"groupid=$gid");
	
	return paddingTable(makeBox("Editing members of group '$gname' ($gid)",$html));
}


# get all users in a group. returns array of hashes of {userid, username}
#
sub getGroupMembers { 
	my $groupid=shift;
	
	my $users=getConfig("user_tbl");
	my $gmember=getConfig("gmember_tbl");

	my ($rv,$sth)=dbLowLevelSelect($dbh,"select $gmember.userid, $users.username from $gmember, $users where $gmember.groupid=$groupid and $users.uid=$gmember.userid");

	my @rows=dbGetRows($sth);
	
	return @rows;
}

# get the number of members in a group
#
sub getMemberCount { 
	my $groupid=shift;
	
	my $gmember=getConfig("gmember_tbl");

	my ($rv,$sth)=dbLowLevelSelect($dbh,"select userid from $gmember where groupid=$groupid");

	my $rc=$sth->rows();
	$sth->finish();

	return $rc;
}

# get all groups a user is in. returns array of hashes of {groupid, groupname}
#
sub getUserGroups {
	my $userid=shift;

	my $gtbl=getConfig("groups_tbl");
	my $gmember=getConfig("gmember_tbl");

	my ($rv,$sth)=dbLowLevelSelect($dbh,"select $gmember.groupid, $gmember.userid, $gtbl.groupname from $gmember, $gtbl where $gmember.userid=$userid and $gtbl.groupid=$gmember.groupid");

	my @rows=dbGetRows($sth);

	return @rows;
}

# get a list of group IDs of groups the user is a member of, minus the groups
# they admin.
#
sub getMemberGroupIDs {
	my $userid = shift;

	my $gtbl = getConfig("groups_tbl");
	my $gmember = getConfig("gmember_tbl");

	my ($rv,$sth) = dbLowLevelSelect($dbh,"select $gmember.groupid from $gmember, $gtbl where $gtbl.groupid=$gmember.groupid and $gtbl.userid != $userid and $gmember.userid = $userid");

	my @garray;
	while (my $row = $sth->fetchrow_arrayref()) {
		push @garray, $row->[0];
	}
	$sth->finish();

	return @garray;
}

# like the above, but just an array of the group IDs
#
sub getUserGroupids {
	my $userid=shift;

	my @groups;
	my @ghashes=getUserGroups($userid);

	foreach my $ghash (@ghashes) {
	  push @groups, $ghash->{groupid};
	}

	return @groups;
}

# wrapper for direct call to this functionality
#
sub addUserToGroup_wrapper {
	my $params = shift;
	my $userinf = shift;

	addUserToGroup($params->{groupid}, $params->{userid});

	my $username = lookupfield(getConfig('user_tbl'), 'username', "uid=$params->{userid}");
	my $groupname = lookupfield(getConfig('groups_tbl'), 'groupname', "groupid=$params->{groupid}");

	return paddingTable(makeBox('User Added', "The user '$username' has been added to your group '$groupname'.  
	
	<p>Quick links:
	
	<p>
	<ul>
	  <li><a href=\"".getConfig("main_url")."/?op=getobj&from=users&id=$params->{userid}\">view ${username}'s info</a>
	<li><a href=\"".getConfig("main_url")."/?op=memberedit&gid=$params->{groupid}\">edit '$groupname'</a>
	<li><a href=\"".getConfig("main_url")."/?op=groupedit\">edit your groups</a>
	</ul>"));
}

# add user to a group
#
sub addUserToGroup {
	my $groupid = shift;
	my $userid = shift;

	my $gtbl = getConfig("groups_tbl");
	my $gmember = getConfig("gmember_tbl");

	my ($rv,$sth) = dbInsert($dbh,{INTO=>$gmember, COLS=>'groupid, userid', VALUES=>"$groupid, $userid"}); 
	
	$sth->finish();

	# lookup info
	#
	my $adminid = lookupfield($gtbl, 'userid', "groupid=$groupid");
	my $groupname = lookupfield($gtbl, 'groupname', "groupid=$groupid");
	my $adminname = lookupfield(getConfig('user_tbl'), 'username', "uid=$adminid");

	# send notice to the added user
	#
	if ($userid != $adminid) {
	  fileNotice($userid, $adminid, "You have been added to the group '$groupname'", "Contact group admin '$adminname' for further info.");
	}
}

# delete user from group
#
sub deleteUserFromGroup {
	my $groupid=shift;
	my $userid=shift;

	my $gtbl=getConfig("groups_tbl");
	my $gmember=getConfig("gmember_tbl");

	my ($rv,$sth)=dbDelete($dbh,{FROM=>$gmember, WHERE=>"groupid=$groupid and userid=$userid"}); 
	$sth->finish();

	# lookup info
	#
	my $adminid = lookupfield($gtbl, 'userid', "groupid=$groupid");
	my $groupname = lookupfield($gtbl, 'groupname', "groupid=$groupid");
	my $adminname = lookupfield(getConfig('user_tbl'), 'username', "uid=$adminid");

	# send notice to the removed user
	#
	if ($userid != $adminid) {
	  fileNotice($userid, $adminid, "You have been removed from the group '$groupname'", "Contact group admin '$adminname' for further info.");
	}
}

# delete all records of users being a member of a particular group. this should
# be called upon group deletion
#
sub deleteAllUsersFromGroup {
	my $groupid=shift;

	my $gmember=getConfig("gmember_tbl");

	my ($rv,$sth)=dbDelete($dbh,{FROM=>$gmember, WHERE=>"groupid=$groupid"}); 
	$sth->finish();
}

# create a default group for a user
#
sub makeDefaultGroup {
	my $userid = shift;

	my $username = lookupfield(getConfig('user_tbl'),'username',"uid=$userid");

	my $gtbl = getConfig("groups_tbl");

	my $nextid = nextval($gtbl."_groupid_seq");

	my ($rv,$sth) = dbInsert($dbh,{INTO=>$gtbl,COLS=>'groupid,userid,groupname,description', VALUES=>"$nextid, $userid, '$username', 'This is the default group for user $username.'"});
	$sth->finish();

	my $gid=lookupfield($gtbl,"groupid","userid=$userid");

	return $gid;
}

# add a group
#
sub addGroup {
	my $userid = shift;
	my $name = shift;
	my $desc = shift;

	my $gtbl = getConfig("groups_tbl");

	my $seq = $gtbl . "_groupid_seq";
	my $newid = nextval($seq);

	my ($rv,$sth) = dbInsert($dbh,{INTO=>$gtbl,COLS=>'groupid, userid,groupname,description', VALUES=>"$newid, $userid, '".sq($name)."', '".sq($desc)."'"});
	$sth->finish();

	return $newid;
}

# delete a group
#
sub deleteGroup {
	my $gid = shift;

	my $gtbl = getConfig("groups_tbl");
	my $atbl = getConfig("acl_tbl");

	my ($rv,$sth) = dbDelete($dbh,{FROM=>$gtbl,WHERE=>"groupid=$gid"});
	$sth->finish();

	# delete ACL rules which refer to this group
	#
	($rv, $sth) = dbDelete($dbh, {FROM=>$atbl, WHERE=>"subjectid=$gid and user_or_group = 'g'"});
	$sth->finish();
}

1;
