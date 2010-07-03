package Noosphere;

use strict;

# get useful user param/upload data into simple "global" variables
#
sub parseParams {
	my $req = shift;
#	my $req = Apache::Request->new(shift);

	my %upload;
	my %params;

	# get Apache2::Request params table
	my $paramtable = $req->param;

	# sanitize the values and put them in $params
	# 
	foreach my $key (keys %$paramtable) {
		my $val = join(',', $paramtable->{$key});
		$val =~ s/\r//gso;

		$params{$key} = $val;
	}

	# process file upload
	#
	my @ulist = $req->upload();
	if (scalar @ulist > 0) {
		my $u = $req->upload($ulist[0]);

		# build upload object
		# 
		# old ad hoc fields: formname, filename, type, tempfile
		# map to: Apache2::Upload ->name(), ->filename(), type(), tempname()
		#
		my $fname = $u->filename();
		if ($fname =~ /[\/\\]([^\/\\]+)$/) {
			$fname = $1;	# get base name if full path provided
		}

		%upload = (
			'formname' => $u->name(),
			'filename' => $fname,
			'tempfile' => $u->tempname(),
		);

	}

	return(\%params,\%upload); 
}

# split a param line into a hash
#
sub paramsToHash { 
	my $string = shift; 
	
	my %hash;
  
	my @pairs = split('&', $string);
	
	foreach my $pair (@pairs) {
		my ($key, $val) = split ('=', $pair); 
		$hash{$key} = $val;
	}

	return {%hash};
}

# turn a HASH into GET params string
#
sub hashToParams {
	my $params = shift;
	
	return join('&amp;', (map "$_=$params->{$_}", keys %$params));
}

1;
