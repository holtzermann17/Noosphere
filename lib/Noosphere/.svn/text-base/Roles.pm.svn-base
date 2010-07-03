package Noosphere;
use strict;

use Noosphere::DB;
use Noosphere::Notices;
use Data::Dumper;
use URI::Escape;

#roles package

sub edit_user_roles {
	my $params = shift;
	my $userinf = shift;
	my $userid = $userinf->{'uid'};

	if ( is_EB($userid) ) {
		if ( defined $params->{'post'} ) {
			$params->{'deluser'} = 1;
			do_edit_roles($params, $userinf);
			return paddingTable(makeBox('Roles Updated', "You may continue <a href=\"".getConfig('main_url')."/?op=edituserroles&id=$params->{id}\">updating roles</a>."));
		} else {
			#display role edit form	
			my $html = generate_user_role_edit_table($params->{id});
			return paddingTable(makeBox('Roles Editor' .
						" for " . getUserDisplayName($params->{id}) , $html));
		}

	} else {
		return paddingTable(makeBox('Roles Editor', "You cannot edit user level roles unless you are an Editorial Board Member."));
	}

}

sub edit_roles {
	my $params = shift;
	my $userinf = shift;

	my $objid = $params->{'id'};
	my $table = $params->{'from'};
	my $userid = $userinf->{'uid'};

	if ( can_edit_roles($userid, $objid) ) {
		if ( defined $params->{'post'} ) {
		
			$params->{'delobj'} = 1;
			do_edit_roles($params, $userinf);
			return paddingTable(makeBox('Roles Updated', "You may continue <a href=\"".getConfig('main_url')."/?op=editroles&from=$table&id=$objid\">updating roles</a> for article $objid."));
		} else {
			#display role edit form	
			my $html = generate_role_edit_table($userid, $objid, $table);
			my $userlisthtml = userList($params,$userinf);
			return paddingTable(makeBox('Roles Editor' .
						" for article $objid",
							$html . $userlisthtml));
		}
	} else {
		return paddingTable(makeBox('Roles Editor' .
						" for article $objid", "You cannot edit the roles for this article."));
	}
}

#this function does the actual datbase update
sub do_edit_roles {
	my $params = shift;
	my $userinf = shift;

	my %AEs = ();


	if (defined $params->{'deluser'}) {
		my $userid = $params->{'id'};
		my $sth = $dbh->prepare("select userid from roles where userid=$userid and role='EA'");
		$sth->execute();
		if ( my $row = $sth->fetchrow_hashref() ) {
			$AEs{$userid} = 1;
		}
		$dbh->do("delete from roles where userid=$userid");
	} else {
		my $objectid = $params->{'id'};
		my $sth = $dbh->prepare("select userid from roles where objectid=$objectid and role='EA'");
		$sth->execute();
		while ( my $row = $sth->fetchrow_hashref() ) {
			$AEs{$row->{'userid'}} = 1;
		}
		$dbh->do("delete from roles where objectid=$objectid");
	}

	warn Dumper(\%AEs);

	my $sth = $dbh->prepare("insert into roles (userid, role, objectid) values (?,?,?)");
	my $i = 1;
	while( defined $params->{"role$i"} ) {
		if ( $params->{"userid$i"} != 0 && ! (defined $params->{"delete$i"}) && $params->{"objectid$i"} != 0) {
			$sth->execute(	$params->{"userid$i"},
					$params->{"role$i"},
					$params->{"objectid$i"} );
			my $objectid = $params->{"objectid$i"};
			my $from = 'objects';
			#check the existing AE's and see if there are any new AE's
			if ( not defined $AEs{$params->{"userid$i"}} and ($params->{"role$i"} eq 'EA') ) {
				warn $params->{"userid$i"} . " is not already an AE";
				my $notice = "Probability and Statistics Online Notice: Associate Editor Assignment\n". 
				"By user: " + getUserDisplayName( $userinf->{'uid'} ) .
				"\nFor article: " + getTitle( $params->{"objectid$i"} ) .
				"\n\n" + getUserDisplayName( $userinf->{'uid'} ) .
				" has assigned you as an associate editor for ".
				getTitle( $params->{"objectid$i"} ) .
				" and would like you to help ensure the quality of this article." .
				" As associate editor, you will be able to edit the article, approve or deny any requests for co-authorship, and roll back the article to a previous version if you see fit." .
				"\n\nThank you.\n\nStatistics Team\n\n" .
				'This message is from a server. Please do not reply if you wish to contact us, please send an email to statisticswiki@springerwiki.com';

 
				my $link = contextLink('objects', $objectid, getTitle($objectid));
				$link =~ s/&/&amp;/g;
				my $xml = "<notice><userfrom>" . 
				getUserDisplayName( $userinf->{'uid'} ) .
				"</userfrom><titlelink>" . 
				$link .
				"</titlelink></notice>";

				my $xsl = getConfig("stemplate_path") . "/mail/grant_ae.xsl";

				my $htmlemail =	buildStringUsingXSLT( $xml, $xsl ); 
				my $textemail = $notice; #TODO change this
				#if so send a notice to notify the new AE
				fileNoticeNew( $params->{"userid$i"}, $userinf->{'uid'}, "Associate Editor Assignment",
					$notice,
					$htmlemail,
					$textemail,
					[{id=>$objectid, table=>$from}]);
				}
		}
		$i++;
	}
}

sub generate_role_edit_table {
	my $userid = shift;
	my $objid = shift;
	my $table = shift;

	my $sth = $dbh->prepare("select * from roles where objectid = ? order by userid");
	$sth->execute($objid);

	my $html = "<form method=\"POST\" action=\"".getConfig("main_url")."/?op=editroles&from=$table&id=$objid\">";
	my $iseditor = 0;
#	if ( ( is_EA( $objid, $userid ) || is_EB( $userid)) ) {
#		$iseditor = 1;	
#	}
	if ( is_EB( $userid) ) {
		$iseditor = 1;	
	}
	if ( my $row = $sth->fetchrow_hashref() ) {
		my $rolenum = 1;
		$html .= "The current roles for article <a href=\"/?op=getobj;from=$table;id=$objid\">$objid</a> are:<br/>";
		$html .= "<input type=\"hidden\" name=\"post\" value=\"post\"/>";
		$html .= "<center>";
		$html .= "<table>\n";
		$html .= "<tr><td align=\"center\"><b>Display Name</b></td><td align=\"center\"><b>Userid</b></td><td align=\"center\"><b>Role</b></td><td align=\"center\">";
		$html .= "<b>Delete?</b></td></tr>\n";
		$html .= "<tr><td align=\"center\">" . getUserDisplayName($row->{'userid'}) . "</td>";
		$html .= "<td align=\"center\">";
		$html .= "<input type=\"hidden\" name=\"objectid$rolenum\" value=\"$objid\"/>";

		
		my $readonly = "";
		my $role = $row->{'role'};

		if ( !($iseditor) ) {
			if ( $role eq 'EA' ) {
				$readonly = "readonly = \"readonly\"";
			} 
		}
		
		$html .= "<input size=\"8\" type=\"text\" name=\"userid$rolenum\" value=\"$row->{userid}\" $readonly /></td>";
		$html .= "<td align=\"center\">";
		if ( $readonly eq "" ) {
			$html .= "<select name=\"role$rolenum\">";
			$html .= "<option value=\"$row->{role}\">".get_role_name($row->{role})."</option>";
			my @oroles = get_other_roles( $userid, $row->{'role'}, 1, !($iseditor) );
			foreach my $r ( @oroles ) {
				$html .= "<option value=\"$r\">".get_role_name($r)."</option>";
			}
			$html .= "</select>";
			$html .="</td>\n";
			$html .= "<td align=\"center\"><input type=\"checkbox\" name=\"delete$rolenum\" value=\"delete\"/></td>\n";
		} else {
			$html .= "<input type=\"hidden\" name=\"role$rolenum\" value=\"$role\" />";
			$html .= get_role_name($row->{role});
		}
		$html .= "</tr>";
		while ( my $row = $sth->fetchrow_hashref() ) {
			$rolenum++;
			$html .= "<tr><td align=\"center\">" . getUserDisplayName($row->{'userid'}) . "</td>";
			my $readonly = "";
			my $role = $row->{'role'};
			if ( !( $iseditor ) ) {
				if ( $role eq 'EA' ) {
					$readonly = "readonly=\"readonly\"";
				} 
			}
			$html .= "<td align=\"center\"><input size=\"8\" type=\"text\" name=\"userid$rolenum\" value=\"$row->{userid}\" $readonly /></td>";
			$html .= "<input type=\"hidden\" name=\"objectid$rolenum\" value=\"$objid\" />";
			$html .= "<td align=\"center\">";
		if ( $readonly eq "" ) {
			$html .= "<select name=\"role$rolenum\">";
			$html .= "<option value=\"$row->{role}\">".get_role_name($row->{role})."</option>";
			my @oroles = get_other_roles( $userid, $row->{'role'}, 1, !($iseditor));
			foreach my $r ( @oroles ) {
				$html .= "<option value=\"$r\">".get_role_name($r)."</option>";
			}
			$html .= "</select>";
			$html .= "<td align=\"center\"><input type=\"checkbox\" name=\"delete$rolenum\" value=\"delete\"/></td>\n";
		} else {
			$html .= "<input type=\"hidden\" name=\"role$rolenum\" value=\"$role\" />";
			$html .= get_role_name($row->{role});
		}
			$html .= "</tr>";
		}
		$rolenum++;
		$html .= "<tr><td/>";
		$html .= "<td align=\"center\">";
		$html .= "<input size=\"8\" type=\"text\" name=\"userid$rolenum\" value=\"0\"/></td>";
		$html .= "<input type=\"hidden\" name=\"objectid$rolenum\" value=\"$objid\"/>";
		$html .= "<td align=\"center\">";
		$html .= "<select name=\"role$rolenum\">";
		$html .= "<option value=\"CA\">".get_role_name('CA')."</option>";
		my @oroles = get_other_roles( $userid, 'CA', 1, !($iseditor) );
		foreach my $r ( @oroles ) {
			$html .= "<option value=\"$r\">".get_role_name($r)."</option>";
		}
		$html .= "</select>";
		$html .= "</td></tr>";
		$html .= "<td/><td/><td/><td align=\"center\"><input type=\"submit\" value=\"Update Roles\"/></td>";
		$html .= "</table>\n";
		$html .= "</center>\n";
	} else {
		$html .= "There are currently no roles for this article. Please add authors or editors.";
		my $rolenum = 1;
		$html .= "<input type=\"hidden\" name=\"post\" value=\"post\"/>";
		$html .= "<center>";
		$html .= "<table>\n";
		$html .= "<tr><td align=\"center\"><b>Userid</b></td><td align=\"center\"><b>Role</b></td><td align=\"center\">";
		$html .= "<tr>";
		$html .= "<td align=\"center\">";
		$html .= "<input size=\"8\" type=\"text\" name=\"userid$rolenum\" value=\"$row->{userid}\"/></td>";
		$html .= "<td align=\"center\">";
		$html .= "<select name=\"role$rolenum\">";
		$html .= "<option value=\"CA\">".get_role_name("CA")."</option>";
		my @oroles = get_other_roles( $userid, 'CA', 1, !($iseditor) );
		foreach my $r ( @oroles ) {
			$html .= "<option value=\"$r\">".get_role_name($r)."</option>";
		}
		$html .= "</select>";
		$html .="</td>";
		$html .= "</tr>\n";
		$html .= "<td/><td align=\"center\"><input type=\"submit\" value=\"Update Roles\"/></td>";
		
	}
	$html .= "</form>";
	return $html;
}

sub generate_user_role_edit_table {
	my $userid = shift;

	my $sth = $dbh->prepare("select * from roles where userid = ? order by objectid");
	$sth->execute($userid);

	my $html = "<form method=\"POST\" action=\"".getConfig("main_url")."/?op=edituserroles&from=table&id=$userid\">";
	if ( my $row = $sth->fetchrow_hashref() ) {
		my $rolenum = 1;
		$html .= "The current roles for user " . getUserDisplayName($userid) . " are:<br/>";
		$html .= "<input type=\"hidden\" name=\"post\" value=\"post\"/>";
		$html .= "<center>";
		$html .= "<table>\n";
		$html .= "<tr><td align=\"center\"><b>Objectid</b></td><td align=\"center\"><b>Title</b></td><td align=\"center\"><b>Role</b></td><td align=\"center\">";
		$html .= "<b>Delete?</b></td></tr>\n";
		$html .= "<tr><td align=\"center\">" . $row->{'objectid'} . "</td>";
		$html .= "<td align=\"center\">" . getTitle($row->{'objectid'}) . "</td>";
		$html .= "<input type=\"hidden\" name=\"objectid$rolenum\" value=\"$row->{objectid}\"/>";
		$html .= "<input type=\"hidden\" name=\"userid$rolenum\" value=\"$row->{userid}\"/>";
		$html .= "<td align=\"center\">";
		$html .= "<select name=\"role$rolenum\">";
		$html .= "<option value=\"$row->{role}\">".get_role_name($row->{role})."</option>";
		my @oroles = get_other_roles( $userid, $row->{'role'} );
		foreach my $r ( @oroles ) {
			$html .= "<option value=\"$r\">".get_role_name($r)."</option>";
		}
		$html .= "</select>";
		$html .="</td>\n";
#<a href=\"".getConfig("main_url")."/?op=adopt&from=objects&id=$row->{objectid}&ask=yes\">adopt</a>
		$html .= "<td align=\"center\"><input type=\"checkbox\" name=\"delete$rolenum\" value=\"delete\"/></td></tr>\n";
		while ( my $row = $sth->fetchrow_hashref() ) {
			$rolenum++;
			$html .= "<tr><td align=\"center\">" . $row->{'objectid'} . "</td>";
			$html .= "<td align=\"center\">" . getTitle($row->{'objectid'}) . "</td>";
			$html .= "<input type=\"hidden\" name=\"userid$rolenum\" value=\"$row->{userid}\"/>";
			$html .= "<input type=\"hidden\" name=\"objectid$rolenum\" value=\"$row->{objectid}\"/>";
			$html .= "<td align=\"center\">";
			$html .= "<select name=\"role$rolenum\">";
			$html .= "<option value=\"$row->{role}\">".get_role_name($row->{role})."</option>";
			my @oroles = get_other_roles( $userid, $row->{'role'} );
			foreach my $r ( @oroles ) {
				$html .= "<option value=\"$r\">".get_role_name($r)."</option>";
			}
			$html .= "</select>";
			$html .= "<td align=\"center\"><input type=\"checkbox\" name=\"delete$rolenum\" value=\"delete\"/></td></tr>\n";
		}
		$rolenum++;
		$html .= "<tr>";
		$html .= "<td align=\"center\">";
		$html .= "<input type=\"hidden\" name=\"userid$rolenum\" value=\"$userid\"/>";
		$html .= "<input size=\"8\" type=\"text\" name=\"objectid$rolenum\" value=\"0\"/></td>";
		$html .= "<td/>";
		$html .= "<td align=\"center\">";
		$html .= "<select name=\"role$rolenum\">";
		$html .= "<option value=\"EA\">".get_role_name("EA")."</option>";
		my @oroles = get_other_roles( $userid, 'EA' );
		foreach my $r ( @oroles ) {
			$html .= "<option value=\"$r\">".get_role_name($r)."</option>";
		}
		$html .= "</select>";
		$html .= "</td></tr>";
		$html .= "<td/><td/><td/><td align=\"center\"><input type=\"submit\" value=\"Update Roles\"/></td>";
		$html .= "</table>\n";
		$html .= "</center>\n";
	} else {
		$html .= "There are currently no roles for this user.";
		my $rolenum = 1;
		$html .= "<input type=\"hidden\" name=\"post\" value=\"post\"/>";
		$html .= "<center>";
		$html .= "<table>\n";
		$html .= "<tr><td align=\"center\"><b>Objectid</b></td><td align=\"center\"><b>Title</b></td><td align=\"center\"><b>Role</b></td><td align=\"center\">";
		$html .= "<tr>";
		$html .= "<td align=\"center\">";
		$html .= "<input type=\"hidden\" name=\"userid$rolenum\" value=\"$userid\"/>";
		$html .= "<input size=\"8\" type=\"text\" name=\"objectid$rolenum\" value=\"0\"/></td>";
		$html .= "<td/>";
		$html .= "<td align=\"center\">";
		$html .= "<select name=\"role$rolenum\">";
		$html .= "<option value=\"EA\">".get_role_name("EA")."</option>";
		my @oroles = get_other_roles( $userid, 'EA' );
		foreach my $r ( @oroles ) {
			$html .= "<option value=\"$r\">".get_role_name($r)."</option>";
		}
		$html .= "</select>";
		$html .= "</td></tr>";
		$html .= "<td/><td/><td/><td align=\"center\"><input type=\"submit\" value=\"Update Roles\"/></td></tr>";
		$html .= "</table>\n";
		$html .= "</center>\n";
	}
	$html .= "</form>";
	return $html;
}

#this function returns all roles that a user can assign that are not the current role for an
#article
sub get_other_roles {
	my $userid = shift;
	my $role = shift;
	my $excludeEB = shift || 0;
	my $excludeEA = shift || 0;
	my @roles = ('LA', 'CA');
	push @roles, 'EA' if (not $excludeEA);
	push @roles, 'EB' if (not $excludeEB);
	for ( my $i=0; $i < @roles; $i++ ) {
		splice( @roles, $i, 1)	if ($roles[$i] eq $role) ;
	}
	return @roles;	
}

sub can_edit_roles {
	my $userid = shift;
	my $objid = shift;

	my $sth = $dbh->prepare("select userid from roles where userid=? and ((objectid = ? and (role = 'LA') || (role = 'EA') ) || role = 'EB')");
	$sth->execute($userid, $objid);
	if ( my $row = $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;
	}
}

sub is_approved_author {
	my $userid = shift;
	#TODO:  read from the db here

	my $sth = $dbh->prepare("select approved from users where uid = ?");
	$sth->execute($userid);
	if ( my $row = $sth->fetchrow_hashref() ) {
		return $row->{'approved'};
	} else {
		return 0;
	}
}

sub can_approve_author {
	my $userid = shift;

	my $sth = $dbh->prepare("select * from roles where userid=? and ( role = 'EB' || role = 'EA' )");
	$sth->execute( $userid );
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;
	}
}

sub can_read {
	my $userid = shift;
	my $objectid = shift;

	warn "Checking read permssions for u=$userid and o=$objectid";
	
	#if the object is published everyone can view it
	if ( is_published ($objectid) ) {
		warn "article is published. Everyone can read.";
		return 1;
	} elsif ( can_edit($userid, $objectid) ) {
		warn "article can be edited by $userid. So read ok";
		return 1;
	} else { 
		#the object isn't published and the user isn't an author
		# of the article so they can't view it.
		return 0;
	}
}

sub can_publish {
	my $userid = shift;

	if ( is_approved_author($userid) ) {
		return 1;
	}

	my $stmt = "select userid from roles where userid=? and role = 'EB'"; 
	my $sth = $dbh->prepare( $stmt );
	$sth->execute( $userid );
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;	
	}
}

sub can_request_publication {
	my $userid = shift;
	my $objectid = shift;

	my $stmt = "select userid from roles where userid=? and ( (objectid=? and role = 'LA') || role = 'EA' || role = 'EB')"; 
	my $sth = $dbh->prepare( $stmt );
	$sth->execute( $userid, $objectid );
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;	
	}
}

sub can_delete {
	my $userid = shift;
	my $objectid = shift;

	my $stmt = "select userid from roles where userid=? and ( (objectid=? and role = 'LA') || role = 'EA' || role = 'EB')"; 
	my $sth = $dbh->prepare( $stmt );
	$sth->execute( $userid, $objectid );
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;	
	}
}

sub can_edit {
	my $userid = shift;
	my $objectid = shift;

	if (isWorldWriteable( 'objects', $objectid )) {
		warn "$objectid is world editable";
		return 1;
	}

	my $stmt = "select userid from roles where userid=? and (objectid=? || role = 'EA' || role = 'EB')"; 
	my $sth = $dbh->prepare( $stmt );
	$sth->execute( $userid, $objectid );
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;	
	}
}

sub can_create {
	my $userid = shift;

	my $sth = $dbh->prepare("select * from users where uid=?");
	$sth->execute( $userid );
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;	
	}
}

sub can_watch {
	my $userid = shift;
	my $objectid = shift;

	return can_read( $userid, $objectid );
}

sub can_assign_ae {
	my $userid = shift;

	my $sth = $dbh->prepare("select userid from roles where userid = ? and role = 'EB'");
	$sth->execute( $userid );
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;	
	}
}

sub get_editors{
	my $objectid = shift;
	my $sth = $dbh->prepare("select distinct userid from roles where (role=? and objectid=?) || role = 'EB'");
	$sth->execute( 'EA', $objectid );
	my @editors = ();
	while( my $row = $sth->fetchrow_hashref() ) {
		push (@editors, $row->{'userid'});
	}

	return @editors;
}

sub get_associate_editors{
	my $objectid = shift;
	my $sth = $dbh->prepare("select distinct userid from roles where (role=? and objectid=?)");
	$sth->execute( 'EA', $objectid );
	my @editors = ();
	while( my $row = $sth->fetchrow_hashref() ) {
		push (@editors, $row->{'userid'});
	}

	return @editors;
}

sub get_coauthors{ 
	my $objectid = shift;
	my $sth = $dbh->prepare("select distinct userid from roles where objectid=? and role=?");


	$sth->execute($objectid, "CA");
	my @authors =();
	while( my $row = $sth->fetchrow_hashref() ) {
		push @authors, $row->{'userid'};
	}
	$sth->finish();
	return @authors;
}

sub get_authors_html {
	my $objectid = shift;
	my $table = shift || 'objects';

	my $html = "";

	my @authors = get_authors($objectid, $table);
	if ( @authors > 0 ) {
	my $a = splice ( @authors, 0, 1);
	$html .= "<a href=\"".getConfig("main_url")."/?op=getuser&amp;id=".$a."\">".getUserDisplayName($a).  "</a>";
	foreach my $a ( @authors ) {
		$html .= ", <a href=\"".getConfig("main_url")."/?op=getuser&amp;id=$a\">".getUserDisplayName($a)."</a>";
	}
	} else {
		$html = "[none]";
	}
	return $html;
}

#TODO - modify this to work with all object types not just 'objects'
sub get_authors {
	my $objectid = shift;
	my $table = shift || "objects";

	my $sth = $dbh->prepare("select distinct userid from roles where tbl=? and objectid=? and (role=? || role=?)");


	$sth->execute($table, $objectid, "LA", "CA");
	my @authors =();
	while( my $row = $sth->fetchrow_hashref() ) {
		push @authors, $row->{'userid'};
	}
	$sth->finish();
#	warn "get authors called for object $objectid";
	return @authors;
}

sub get_author {
	my $objectid = shift;
	my $sth = $dbh->prepare("select userid from roles where objectid=? and role=?");
	$sth->execute($objectid, 'LA');
	my $row = $sth->fetchrow_hashref();
	return $row->{'userid'};
}

sub is_LA {
	my $objectid = shift;
	my $userid = shift;
	my $sth = $dbh->prepare("select userid from roles where objectid=? and userid = ? and role='LA'");
	$sth->execute($objectid, $userid);
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;
	}
}

sub is_CA {
	my $objectid = shift;
	my $userid = shift;
	my $sth = $dbh->prepare("select userid from roles where objectid=? and userid = ? and role='CA'");
	$sth->execute($objectid, $userid);
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;
	}
}

sub is_EB {
	my $userid = shift;
	my $sth = $dbh->prepare("select userid from roles where userid = ? and role='EB'");
	$sth->execute($userid);
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;
	}
}

sub is_EA {
	my $objectid = shift;
	my $userid = shift;
	my $sth = $dbh->prepare("select userid from roles where userid = ? and objectid = ? and role='EA'");
	$sth->execute($userid, $objectid);
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;
	}
}

sub can_view_versions {
	my $table = shift;
	my $objectid = shift;
	my $userid = shift;

	#all users can view version history
	if ( getConfig('open_history') eq "1" ) {
		return 1;
	}

	if (  is_CA ($objectid, $userid) || is_LA ($objectid, $userid) || is_EB($userid) || is_EA( $objectid, $userid) ) {
		return 1;
	} else {
		return 0;
	}
}

sub can_rollback {
	my $table = shift;
	my $objectid = shift;
	my $userid = shift;

	if ( is_LA( $objectid, $userid ) || is_EA( $objectid, $userid ) || is_EB($userid) ) {
		return 1;
	} else {
		return 0;
	}
}

sub is_admin {
	my $userid = shift;
	my $sth = $dbh->prepare("select userid from roles where userid = ? and role = 'Admin'");
	$sth->execute( $userid );
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;	
	}
}

sub is_editor {
	my $userid = shift;

	my $sth = $dbh->prepare("select userid from roles where userid = ? and (role = 'EB' || role = 'EA' || role = 'Admin')");
	$sth->execute( $userid );
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;	
	}
}

sub can_assign_ca {
	my $userid = shift;
	my $objectid = shift;
	my $sth = $dbh->prepare("select userid from roles where (userid = ? and objectid = ? and role = 'LA') || ( userid = ? and (role = 'EB' || role = 'EA') )");
	$sth->execute( $userid, $objectid, $userid );
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;	
	}
}

sub can_approve_ca {
	my $userid = shift;
	my $objectid = shift;
	my $sth = $dbh->prepare("select userid from roles where userid = ? and (role = 'EB' || role = 'EA' || role = 'LA')");
	$sth->execute( $userid );
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;	
	}

}

sub can_change_roles {
	my $userid = shift;
	my $objectid = shift;
	my $sth = $dbh->prepare("select userid from roles where userid = ? and role = 'EB'");
	$sth->execute( $userid );
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;	
	}
}

sub can_create_users {
	my $userid = shift;
	my $sth = $dbh->prepare("select userid from roles where userid = ? and role = 'EB'");
	$sth->execute( $userid );
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;	
	}
}

sub add_author {
	my $userid = shift;
	my $objectid = shift;
	my $role = shift; 
	my $table = shift || 'objects';

	my $sth = $dbh->prepare("insert into roles (objectid, userid, role, tbl) values (?,?,?,?)");
	$sth->execute( $objectid, $userid, $role, $table );

	return 1;
}

sub get_role_name {
	my $short = shift;
	my $rolehash = $Noosphere::baseconf::base_config{ROLE_NAMES};

	return $rolehash->{$short};
}

sub getLAs {
	my $objectid = shift;
	my $sth = $dbh->prepare("select userid from roles where objectid= ? and role = 'LA'");
	$sth->execute($objectid);
	my @authors = ();

	while ( my $row = $sth->fetchrow_hashref() ) {
		push @authors, $row->{'userid'};	
	} 
	return @authors;
}

sub getEAs {
	my $objectid = shift;
	my $sth = $dbh->prepare("select userid from roles where objectid= ? and role = 'EA'");
	$sth->execute($objectid);
	my @editors = ();

	while ( my $row = $sth->fetchrow_hashref() ) {
		push @editors, $row->{'userid'};
	} 
	return @editors;
}

sub requestCAStatus {
	my $params = shift;
	my $userinf = shift;

	my $objectid = $params->{'id'};
	my $userid = $userinf->{'uid'};

	my @peopleToPrompt = ();
	push @peopleToPrompt, getLAs($objectid);
	push @peopleToPrompt, getEAs($objectid);
	
	#build the prompt.
	my @accept = ("Grant Co-authorship", "approve url goes here" );
	my @deny = ("Deny Co-authorship", "deny url goes here" );
	my @choices = (\@accept, \@deny);
	
	foreach my $p ( @peopleToPrompt ) {
		my $notice = getUserDisplayName($userid) . " has requested co-authorship for " . getTitle($params->{'id'}) . " and would like to be permitted to contribute to this article.";

		my $link = contextLink('objects', $objectid, getTitle($objectid));
		$link =~ s/&/&amp;/g;
		my $xml = "<notice><userto>" . 
			getUserDisplayName( $p ) .
			"</userto><titlelink>" . 
			$link .
			"</titlelink>" .
			"<userfrom>" . 
			getUserDisplayName( $userid ) .
			"</userfrom>" .
			"</notice>";

		my $xsl = getConfig("stemplate_path") . "/mail/request_ca.xsl";

		my $htmlemail =	buildStringUsingXSLT( $xml, $xsl ); 
		my $textemail = $notice; #TODO change this


		filePromptNew( $p, $userid, "Request for co-authorship",
			$notice,
			$htmlemail,
			$textemail,
			1, #default is to reject
			[
			   [ 'Grant Co-authorship' , urlescape ("op=grantca&from=$params->{from}&id=$params->{id}&userid=$userid") ],
			   [ 'Deny Co-authorship' , urlescape ("op=denyca&from=$params->{from}&id=$params->{id}&userid=$userid") ]
			],
			[{id=>$params->{'id'}, table=>$params->{'from'}}]
		);
			
	}

	return paddingTable(makeBox('Co-authorship Requested',
		"A notice has been sent to the current lead author and associate editors of <a href=\"" . getConfig("main_url") . "/?op=getobj&from=objects&id=" . $params->{'id'} . "\">" . getTitle($params->{'id'}) . "</a>") ) ;

}

sub grant_ca {
	my $params = shift;
	my $userinf = shift;
	
	my $from = $params->{'from'}; # we may need to use this at some point.
	my $userid = $params->{'userid'};
	my $objectid = $params->{'id'};


	if ( can_approve_ca( $userinf->{'uid'}, $objectid ) ) {
		my $sth = $dbh->prepare( "insert into roles (objectid, userid, role) values ( ?,?,?)" );
		$sth->execute( $objectid, $userid, 'CA' );
		my $notice = "Dear ". getUserDisplayName( $userid ) . 
			"\n\nYour request for co-authorship for " . 
			contextLink($objectid, $from, getTitle($objectid)) . 
			" has been granted.\n\nSincerely\n\nStatistics Team";

		my $link = contextLink($from, $objectid, getTitle($objectid));
		$link =~ s/&/&amp;/g;
		my $xml = "<notice><userto>" . 
			getUserDisplayName( $userid ) .
			"</userto><titlelink>" . 
			$link .
			"</titlelink></notice>";

		my $xsl = getConfig("stemplate_path") . "/mail/grant_ca.xsl";

		my $htmlemail =	buildStringUsingXSLT( $xml, $xsl ); 
		my $textemail = $notice; #TODO change this

		#notify the user that he/she is now a CA.
		fileNoticeNew( $userid, $userinf->{'uid'}, "Request for co-authorship",
				$notice,
				$htmlemail,
				$textemail,
				[{id=>$objectid, table=>$from}]);
		
	}
			
}

sub deny_ca {
	my $params = shift;
	my $userinf = shift;
	
	my $from = $params->{'from'}; # we may need to use this at some point.
	my $userid = $params->{'userid'};
	my $objectid = $params->{'id'};


	if ( can_approve_ca( $userinf->{'uid'}, $objectid ) ) {
		my $notice = "Dear ". getUserDisplayName( $userid ) . 
			"\n\nYour request for co-authorship for " . 
			contextLink($objectid, $from, getTitle($objectid)) . 
			" has been denied.\n\nSincerely\n\nStatistics Team";

		my $link = contextLink($from, $objectid, getTitle($objectid));
		$link =~ s/&/&amp;/g;
		my $xml = "<notice><userto>" . 
			getUserDisplayName( $userid ) .
			"</userto><titlelink>" . 
			$link .
			"</titlelink></notice>";

		my $xsl = getConfig("stemplate_path") . "/mail/deny_ca.xsl";

		my $htmlemail =	buildStringUsingXSLT( $xml, $xsl ); 
		my $textemail = $notice; #TODO change this

		
		fileNoticeNew( $userid, $userinf->{'uid'}, "Request for co-authorship",
				$notice,
				$htmlemail,
				$textemail,
				[{id=>$objectid, table=>$from}]);
	}
			
}
sub getObjectCount {
	my $userid = shift;

	my $sth = $dbh->prepare_cached( "select count( distinct objectid ) as cnt from roles where userid = ?");
	$sth->execute( $userid );
	if ( my $row = $sth->fetchrow_hashref() ) {
		return $row->{'cnt'};
	}
	return 0;
}



1;
