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
use Noosphere::DB;
use Noosphere::Config;
use Noosphere::Notices;

sub publish {
	my ($params,$userinf) = @_;

	my $objectid = $params->{'id'};
	my $userid = $userinf->{'uid'};
	if ( can_publish($userid) ) {
		#do it
		do_publish($objectid, $userid);
		my @authors = get_authors( $objectid );
		foreach my $a (@authors){
			fileNotice( $a, $userid,
				"Congratulations. " .
				getTitle( $objectid) .
				" with id $objectid" .
				" has been published.",
				"Congratulations. An article you author or coauthor has been published. Article " . getTitle ($objectid) . " with id $objectid has been published." );
		}
		return paddingTable(makeBox('Article Published',
		"The article has been published. You may  <a href=\"".getConfig("main_url")."/?op=getobj&from=$params->{from}&id=$params->{id}\">view the article</a>."));
	} else {
		return paddingTable(makeBox('Publication Error',
			"You do not have permission to publish to the encyclopedia."));
	}
}

sub do_publish {
	my $objectid = shift;
	my $userid = shift;
	my $sth = $dbh->prepare("insert into tags (objectid, tag, userid) values (?,?,?)");
	$sth->execute( $objectid, "NS:published", $userid );
}

sub unpublish {
	my ($params,$userinf) = @_;

	my $objectid = $params->{'id'};
	my $userid = $userinf->{'uid'};
	if ( can_publish($userid) ) {
		#do it
		my $sth = $dbh->prepare("delete from tags where objectid = ? and tag = ?");
		$sth->execute( $objectid, "NS:published" );
		return paddingTable(makeBox('Article Removed From Publication',
		"The article has been unpublished. You may  <a href=\"".getConfig("main_url")."/?op=getobj&from=$params->{from}&id=$params->{id}\">view the article</a>."));
	} else {
		return paddingTable(makeBox('Publication Error',
			"You do not have permission to alter the publication of the encyclopedia."));
	}
}

sub publication_requested {
	my $objectid = shift;

	my $sth = $dbh->prepare("select * from tags where objectid = ? and tag = ?");
	$sth->execute( $objectid, "NS:requestforpublication" );
	if ( my $row = $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;
	}
}

sub request_publication {
	my ($params,$userinf) = @_;

	my $objectid = $params->{'id'};
	my $userid = $userinf->{'uid'};
	if ( can_request_publication($userid, $objectid) ) {
		#do it
		my $sth = $dbh->prepare("insert into tags (objectid, tag) values (?,?)");
		$sth->execute( $objectid, "NS:requestforpublication" );
		
		my @editors = get_editors($objectid);
		foreach my $e (@editors) {
			fileNotice ( $e, $userid, "Request for publication for article $objectid", "Author " . getUserDisplayName( $userid ) . " has requested publication of article $objectid with title " . getTitle( $objectid ) . "." );
		}

		
		return paddingTable(makeBox('Article Publication Requested',
			"Your article has been requested for publication. You may  <a href=\"".getConfig("main_url")."/?op=getobj&from=$params->{from}&id=$params->{id}\">view the article</a>."));
	} else {
		return paddingTable(makeBox("You can't request to publish this article"));
	}
}
sub is_published {
	my $objectid = shift;
	my $table = shift;

	my $query = "select objectid from tags where objectid = ? and tag = 'NS:published'";
	my $sth = $dbh->prepare($query);
	$sth->execute($objectid);

	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;
	}
}

sub unpublished {
	my $html = "";

	# get unpublished objects
	#
	my $indextbl = getConfig('index_tbl');

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>"title,objectid,tbl,userid",FROM=>"$indextbl" ,WHERE=>'type=1 and tbl=' . "'" . getConfig('en_tbl') . "'"});
	my @all = dbGetRows($sth);

	my @requested = ();

	#remove the objects that are published already
	my $tagsth = $dbh->prepare("select * from tags where objectid = ? and tag = 'NS:published'");
	my $reqsth = $dbh->prepare("select * from tags where objectid = ? and tag = 'NS:requestforpublication'");
	for (my $i = 0; $i < $#all+1; $i++) {
		my $objectid = $all[$i]->{'objectid'};
		$tagsth->execute($objectid);
		if ( $tagsth->fetchrow_hashref() ) {
			splice( @all, $i, 1 );	
			$i--;
		} else {
			$reqsth->execute($objectid);
			if ( $reqsth->fetchrow_hashref() ) {
				push @requested, splice(@all, $i, 1);
				$i--;
			}
		}
	}

	my @unpublished = @all;
	my $en = "objects";

	if ($#all >= 0) {
		$html .= "<center><b>Unpublished articles:</b></center><br/>";

		if ( @requested > 0 ) {
		$html .= "<center><b>Requested for Publication:</b></center><br/>";
		foreach my $row (@requested) {
			my ($lastid, $lastname) = getLastData($en, $row->{'objectid'});

			$html .= "[ <a href=\"".getConfig("main_url")."/?op=publish&from=$row->{tbl}&id=$row->{objectid}&ask=yes\">publish</a> ] <a href=\"".getConfig("main_url")."/?op=getobj&from=$row->{tbl}&id=$row->{objectid}\">".TeXtoUTF8($row->{'title'})."</a>";
			if ( $row->{'userid'} != 0 ) {
				$html .= " by <a href=\"".getConfig("main_url")."/?op=getuser&id=$row->{userid}\">" . getUserDisplayName($row->{'userid'}) . "</a>";
				if ( is_approved_author( $row->{'userid'} ) ) {
					$html .= " [author approved].";
				} else {
					$html .= " [<a href=\"".getConfig("main_url")."/?op=approveauthor&userid=$row->{userid}\">approve author</a>].";
				}
			}
			if ( $lastname ne "" ) {
				$html .= "(was owned by <a href=\"".getConfig("main_url")."/?op=getuser&id=$lastid\">$lastname</a>)";
			}
			$html .= "<br>";
		}
		} else {
			$html .= "There are no articles requested for publication.";
		}
		$html .= "<br/><center><b>Unrequested and unpublished articles:</b></center><br/>";

		foreach my $row (@unpublished) {
			my ($lastid, $lastname) = getLastData($en, $row->{'objectid'});

			$html .= "[ <a href=\"".getConfig("main_url")."/?op=publish&from=$row->{tbl}&id=$row->{objectid}&ask=yes\">publish</a> ] <a href=\"".getConfig("main_url")."/?op=getobj&from=$row->{tbl}&id=$row->{objectid}\">".TeXtoUTF8($row->{title})."</a>";
			$html .= " by <a href=\"".getConfig("main_url")."/?op=getuser&id=$row->{userid}\">" . getUserDisplayName($row->{'userid'}) . "</a> [<a href=\"".getConfig("main_url")."/?op=approveauthor&userid=$row->{userid}\">approve author</a>]." if ( $row->{'userid'} != 0 );
			if ( $lastname ne "" ) {
				$html .= "(was owned by <a href=\"".getConfig("main_url")."/?op=getuser&id=$lastid\">$lastname</a>)";
			}
			$html .= "<br>";
		}

		$html .= "<br>";
	}

	if ($#unpublished < 0) {
		$html .= "All articles are currently published!";
	}

	return paddingTable(clearBox('Article Publisher',$html));
}

sub deleted {
	my $html = "";

	# get deleted objects
	#
	my $indextbl = getConfig('index_tbl');

	my $en = "objects";
	my ($rv,$sth) = dbSelect($dbh,{WHAT=>"objectid",FROM=>"tags" ,WHERE=>"tag = 'NS:deleted'"});
	my @all = dbGetRows($sth);

	my @requested = ();

	warn "WE FOUND " . scalar(@all) . " DELETED OBJECTS";


	if ($#all >= 0) {
		$html .= "<center><b>Deleted Articles:</b></center><br/>";
		foreach my $row ( @all ) {
			my $title = getTitle( $row->{'objectid'} );
			my $authors = get_authors_html($row->{'objectid'});

			$html .= "<a href=\"".getConfig("main_url")."/?op=getobj&id=$row->{objectid}\">$title</a> by $authors.";
	#  [ <a href=\"".getConfig("main_url")."/?op=undelete&id=$row->{objectid}&ask=yes\">undelete</a> ]";
			$html .= "<br/>";
		}
	} else {
		$html .= "There are no deleted articles";
	}

	return paddingTable(clearBox('Deleted Articles',$html));
}

# getEditorMenu - get the editor toolbar menu
#                               TODO: show varying options based on access level
#
sub getEditorMenu {
    my $userid = shift;

    my $html = '';
    my $menu = '';
	

    if (is_editor($userid)) {
        my $bullet = getBullet();
    $menu .= "$bullet&nbsp;<a href=\"".getConfig("main_url")."/?op=unpublished\">unpublished</a><br>";
    $menu .= "$bullet&nbsp;<a href=\"".getConfig("main_url")."/?op=deleted\">deleted</a><br>";
    $html = adminBox('Editor Menu',$menu);
    $html = "<tr><td>$html</td></tr>";
    }
    return $html;
}


1;
