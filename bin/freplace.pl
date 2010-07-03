#!/usr/bin/perl

###############################################################################
#
# freplace 
#
# Replace strings in files via perl regular expressions.  A powerful way to 
# do global string replacements.  The user has access to all of the perks of
# perl, including character classes and accesing marked groupings for the 
# replacement string.
#
###############################################################################

use strict;

# write a string to a file
#
sub writeFile {
  my $filename = shift;
  my $content = shift;

  open OUTFILE, ">$filename" or die "cannot open file $filename for writing!";
  
  print OUTFILE $content;

  close OUTFILE;
}

# read in a file to a string
#
sub readFile {
 unless (open(FILE,"$_[0]")) {
  warn "file $_[0] does not exist";
  return '';
  }
 my $data = '';

 while (<FILE>) { $data .= $_; }

 return $data; 
}

# init the undo directory
#
sub initundo {
  
  my $home = $ENV{'HOME'};

  if (-e "$home/.freplace") {
    
	`rm "$home/.freplace/"* > /dev/null 2>&1`;
  } 

  else {

    mkdir "$home/.freplace";
  }
}

# main stuff
#
sub main {
  my $from = shift;
  my $to = shift;
  my @files = @_;

  my $home = $ENV{'HOME'};

  if (scalar @files == 0 && $from ne 'undo') {
    print "\nfreplace - replace strings in files using perl regexps\n\n";
	print " usage:\n\n";
	print "  freplace frompattern topattern files ...\n";
	print "  freplace undo\n\n";
	print " example: freplace 'warn(\\s)' 'debugwarn(\$1)' *.pm\n\n";

    return;
  }

  # do undo if first argument is "undo"
  #
  if ($from eq 'undo') {

	my @files = <$home/.freplace/*>;
	my $count = scalar @files;
	
    `mv "$home/.freplace/"* . > /dev/null 2>&1`;

	print "\nUndid replacements to $count files.\n\n";

	return;
  }
  
  print "\nperforming s/$from/$to/\n\n";

  # init the undo dir
  #
  initundo();

  # go through the files and do replacements
  #
  foreach my $file (@files) {
	if (-d "$file") {
	  print "$file is a directory\n";
      next;
	}
	
    print "$file:\n";
	
	# read in file and do replacement
	#
	my $contents = readFile($file);
	my $count = 0;
	eval "\$count = (\$contents =~ s/\$from/$to/g) || 0;";

	
    print "	$count replacements\n";

    # if there were replacements to the file, save it in the undo dir
	#
	if ($count) {
      `cp $file "$home/.freplace/$file"`;
	}

	# overwrite file
	#
	writeFile($file, $contents);
  }
}

main(@ARGV);
