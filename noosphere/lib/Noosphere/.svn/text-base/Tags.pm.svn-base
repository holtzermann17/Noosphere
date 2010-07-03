package Noosphere;

use strict;

use Noosphere::DB;
use Data::Dumper;

sub getNSTags {
	my $nstags = getConfig( 'optionaltags' );
	my $tagstring = join( ', ', @$nstags);
	return $tagstring;
}

sub getNSTagsControl {
	my $nstags = getConfig('optionaltags');

	my $control = "<select onchange='addtag(this)' name='tagcontrol'>";
	$control .= "<option value='Select a Tag'>Select a Tag</option>";
	foreach my $t (@$nstags) {
		$control .= "<option value='$t'>$t</option>\n";
	}
	$control .= "</select>";

	return $control;
	
}

sub hasTags {
	my $table = shift;
	my $objectid = shift;
	my $tags = shift; #arrayref
	
#	warn "checking tags for $table, $objectid";
#	warn Dumper($tags);
	my $otags = getTags( $table, $objectid );
	for my $t (@$tags) {
		if (not defined $otags->{$t}) {
			return 0;
		}
	}

	return 1;
}


sub getTags {
	my $table = shift; # we don't really use the table at this point it's here incase we want to
	my $objectid = shift;

	my %tags = ();
	if ( $objectid > 0 ) {
	my $sth = $dbh->prepare("select tag,userid from tags where objectid=?");
	$sth->execute($objectid);

	while( my $row = $sth->fetchrow_hashref() ) {
		$tags{$row->{'tag'}} = $row->{'userid'};
	}
	}

	return \%tags;
}

sub updateTags {
	my $objectid = shift;
	my $tags = shift;

	$dbh->do("delete from tags where objectid = ?");
	my $sth = $dbh->prepare("insert into tags ( userid, objectid, tag )  values ( ?,?,? )");
	foreach my $k ( keys %$tags) {
		$sth->execute( $tags->{$k}, $objectid, $k );
	}
	$sth->finish();
	return 1;
}

sub isWorldWriteable {
	my $table = shift;
	my $objectid = shift;
	my $sth = $dbh->prepare("select * from tags where objectid = ? and tag = ?");
	$sth->execute($objectid, 'NS:worldeditable');
	if ( $sth->fetchrow_hashref() ) {
		return 1;
	} else {
		return 0;
	}
}

1;
