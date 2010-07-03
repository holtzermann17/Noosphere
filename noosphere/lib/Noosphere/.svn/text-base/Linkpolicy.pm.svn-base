package Noosphere;

###############################################################################
#
# Routines for handling linking policies.
# 
# Written by Aaron Krowne
# 	- last modified by James Gardner (06/15/2006)
###############################################################################

use Noosphere::NNexus;
use strict;

sub edit_linkpolicy {
	my $params = shift;
	my $userinf = shift;

	return loginExpired() if ($userinf->{'uid'} <= 0);

	my $en = getConfig('en_tbl');

	#return errorMessage("You can't edit that object!") unless ((hasPermissionTo($en,$params->{'id'},$userinf,'write')) || ($userinf->{'data'}->{'access'} >= getConfig('access_admin')) || is_LA($params->{'id'}, $userinf->{'uid'}) || is_CA( $params->{'id'}, $userinf->{'uid'} ) );
	return errorMessage("You can't edit that object!") unless ( can_edit(
		$userinf->{'uid'}, $params->{'id'} ) );

	my ($title, $linkpolicy) = lookupfields($en, 'title, linkpolicy', "uid=$params->{id}");

	my $template;

	if (defined $params->{'submit'}) {
	
		my $sth = $dbh->prepare("update $en set linkpolicy = ? where uid = ?");
		$sth->execute($params->{'policy'}, $params->{'id'});
		$sth->finish();
		NNexus_Update_LinkPolicy( 'localhost', 7071, $params->{'id'}, $params->{'policy'} );

		$template = new XSLTemplate('linkpolicy_updated.xsl');

		$template->addText("<linkpolicy_updated title=\"".qhtmlescape($title)."\">");

		$template->setKeys(%$params);

		$template->addText('</linkpolicy_updated>');
		#invalidate the links into this object
		xrefDeleteLinksTo( $params->{'id'}, $en );
	}

	else {
		$template = new XSLTemplate('linkpolicy.xsl');

		$template->addText("<linkpolicy title=\"".qhtmlescape($title)."\">");
		
		$template->setKeys(%$params);
		$template->setKey('policy', $linkpolicy);

		$template->addText('</linkpolicy>');
	}


	return $template->expand();
}

# decide which object to link to from the target object, given a list of 
# candidate object IDs and the concept label
# sub by Aaron Krowne and James Gardner
sub post_resolve_linkpolicy {
	my $target = shift;
	my $idmap = shift;		# maps concept IDs to object IDs
	my $concept = shift;
	my @pool = @_;

	my %policies;
	
	foreach my $pid (@pool) {
		$policies{$pid} = loadpolicy($idmap->{$pid});
	}

	# pull out link policy information and compare 
	my %compare;

	#we have that compare contains a value for the matching concept label.
	foreach my $pid (@pool) {
		if (defined $policies{$pid}->{'priority'} &&
			( (not defined $policies{$pid}->{'priority'}->{'concept'}) ||
			($policies{$pid}->{'priority'}->{'concept'} eq $concept))) {
			
				$compare{$pid} = $policies{$pid}->{'priority'}->{'value'};
			
		} else {
			$compare{$pid} = 100; # default priority
		}
	}

	my $table = getConfig('en_tbl');
	my @classes = getclass( $table, $target );
	my @remove = ();
	my %permitted = ();

	foreach my $pid (@pool){	
		my $numforbids = $policies{$pid}->{'numforbids'}->{'value'};
		my $numpermits = $policies{$pid}->{'numpermits'}->{'value'};
		foreach my $c (@classes) {
			if ($numforbids > 0) {
			#remove the forbidden candidates -James
				for (my $i = 0; $i < $numforbids; $i++) {
					warn "checking forbid " . $policies{$pid}->{"forbid$i"}->{'concept'} .  " against concept $concept";
					if ( defined $policies{$pid}->{"forbid$i"} && 
							( (not defined $policies{$pid}->{"forbid$i"}->{'concept'}) ||
							 ($policies{$pid}->{"forbid$i"}->{'concept'} eq $concept)) ){
						if ( "$c->{cat}" =~ /^$policies{$pid}->{"forbid$i"}->{'value'}/){
							warn "we are forbidding $pid from $target";
							push @remove, $pid;
						} 
					}
				}
			}

			if ($numpermits > 0){
			#remove those candidates not in a permit directive
				for ( my $i = 0; $i < $numpermits; $i++) {
					if ( defined $policies{$pid}->{"permit$i"} && 
						( (not defined $policies{$pid}->{"permit$i"}->{'concept'}) ||
						 ($policies{$pid}->{"permit$i"}->{'concept'} eq $concept) ) ){

					#if permit is defined then we exclude all that are not included
					#in the permit directive
						# if a category is not permitted then add it to the remove array
 						if ( "$c->{cat}" !~ /^$policies{$pid}->{"permit$i"}->{'value'}/ ){
							warn "removing $pid based on permit directive from $target";
							push @remove, $pid;
						} else {
							#if a category is permitted we add it to the permitted hash in
							#case it was added to the remove array by another permit or forbid directive
							$permitted{$pid} = 1;
							warn "re-permitting $pid based on permit directive from $target";
						}
					}
				}
			}
		}
	}

	#now remove those pids that are forbidden and also not permitted 
	#if a pid is permitted it will always override the forbidden directive
	foreach my $lose (@remove){
		if (not defined $permitted{$lose}){
			#warn "*** forbidding $target to link to $lose";
			delete $compare{$lose};
		} 
	}

	my @winners = ();

	my $topprio = 32768;
	foreach my $pid (sort { $compare{$a} <=> $compare{$b} } keys %compare) {
		if ($compare{$pid} <= $topprio) {
			push @winners, $pid;

			$topprio = $compare{$pid};
		} else {
			last;
		}
	}

	return @winners;	
}

# load a link policy (read from DB and parse it to a hash structure)
# sub by Aaron Krowne and James Gardner
sub loadpolicy {
	my $objectid = shift;

	my $sth = $dbh->prepare("select linkpolicy from objects where uid = ?");
	$sth->execute($objectid);

	my $row = $sth->fetchrow_arrayref();
	$sth->finish();

	if (not defined $row) {
		return {};
	}
	
	my $policytext = $row->[0];

	my %policy;
	#my $table = getConfig('en_tbl');
	#my $class = classstring( $table, $objectid );
	#$class =~ s/msc://g;
	#warn "The class for $objectid is $class";
	#$policy{'class'} = {value => $class};
	my $numforbids = 0;
	my $numpermits = 0;
	
	foreach my $line (split(/\s*\n+\s*/,$policytext)) {
		# parse out priority
		#
		if ($line =~ /^\s*priority\s+(\d+)(?:\s+("[\w\d\s]+"|[\w\d]+))?/) {
			my $prio = $1;
			my $concept = $2;
			
			$policy{'priority'} = {value => $prio};
			$policy{'priority'}->{'concept'} = $concept if defined $concept;
		}

# TODO - change this code to use multiple permit and forbid directives.
		# parse out the permit and forbid classification directives. - James Gardner
		if (   $line =~ /^\s*permit\s+(\S+)(?:\s+("[\w\d\s]+"|[\w\d]+))?/   ) {
			my $category = $1;
			my $concept = $2;
			$concept =~ s/"//g;
			#warn "permit category is $category";
			#warn "permit concept is $concept";
			
#	warn " * permitting ($category) [$concept] to $objectid";
			$policy{"permit$numpermits"} = {value => $category};
			$policy{"permit$numpermits"}->{'concept'} = $concept if defined $concept;
			$numpermits++;
		}
		if (   $line =~ /^\s*forbid\s+(\S+)(?:\s+("[\w*\s]+"|[\w\d]+))?/   ) {
			my $category = $1;
			my $concept = $2;
			$concept =~ s/"//g;
			#warn "forbid category is $category";
			#warn "forbid concept is $concept";
			
#	warn " * forbidding ($category) [$concept] from $objectid";
			$policy{"forbid$numforbids"} = {value => $category};
			$policy{"forbid$numforbids"}->{'concept'} = $concept if defined $concept;
			$numforbids++;
		}
		#tell the policy has the correct number of forbid and permit directives
		$policy{'numforbids'} = {value => $numforbids};
		$policy{'numpermits'} = {value => $numpermits};
#warn "we had $numforbids forbids and $numpermits permits";
		
		# TODO: parse out other stuff.
		
		
	}

	return {%policy};
}

1;
