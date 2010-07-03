package Noosphere;

use strict;
use Noosphere::Template;

# take a table and object ID and return the path fragment leading to that 
# object's cache directory
#
sub getCachePath {
	my $table = shift;
	my $id = shift;
	
	my $cacheroot = getConfig('cache_root');

	my $dir = "$cacheroot/$table/$id";

	return $dir;
}

# take same as above, but for file box 
#
sub getFilePath {
	my $table = shift;
	my $id = shift;

	my $fileroot = getConfig('file_root');

	my $dir = "$fileroot/$table/$id";

	return $dir;
}

# build a URL to file box directory
#
sub getFileUrl {
	my $table = shift;
	my $id = shift;

	my $fileurl = getConfig('file_url');

	my $dir = "$fileurl/$table/$id";

	return $dir;
}

# determine if a directory is "bad"; either nonexistant, equal to root
#	or containing a //
#
sub baddir {
	my $dir = shift;

	if ($dir =~ /^\/*$/ || $dir=~/^\/\//) {
		dwarn "*** filebox : bad dir [$dir]"; 
		return 1 
	}
	if (not -e "$dir") {
		dwarn "*** filebox : nonexistant dir [$dir]";
		return 1;
	}

	return 0;
}

# cleanCache - clear out a cache dir
#
sub cleanCache {
	my $table = shift;
	my $id = shift;
	my $method = shift;
	
	my $dir = getCachePath($table, $id)."/$method";
	dwarn "*** filebox : cleancache in [$dir]";

	return if (baddir($dir));

	$ENV{'PATH'} = "/bin:/usr/bin:/usr/local/bin";
#	`rm -r $dir/*`;

	my @files = <$dir/*>;
	for my $file (@files) {
#		warn "cleanCache: issuing rm of $file";
		system "sh", '-c', "/bin/rm -rf $file";
	}
}

# cacheFileBox - copy filebox to a cache dir
#
sub cacheFileBox {
	my $table = shift;
	my $id = shift;
	my $method = shift;

	my $fdir = getFilePath($table, $id);

	return if (not -e $fdir);
	
	my $cdir = getCachePath($table, $id);

	mkdir $cdir if (not -e $cdir);
	mkdir "$cdir/$method" if (not -e "$cdir/$method");

	my @files = <$fdir/*>;

	for my $file (@files) {
		$ENV{'PATH'} = "/bin:/usr/bin:/usr/local/bin";
		warn "cacheFileBox: copying file $file to $cdir/$method";
		system "sh", '-c', "/bin/cp $file $cdir/$method";
	}
}

# does what it says
#
sub deleteFileBox {
	my $table = shift;
	my $id = shift;
	
	my $dir = getFilePath($table, $id);
	
	return if (baddir($dir));

	$ENV{'PATH'} = "/bin:/usr/bin:/usr/local/bin";
	`rm -rf $dir`;
}

# cloneFileBox - copy filebox to a new one
#
sub cloneFileBox {
	my $table = shift;
	my $old = shift;	# source box id
	my $new = shift;	# dest box id

	my $src = getFilePath($table, $old);
	my $dest = getFilePath($table, $new);
	
	$ENV{'PATH'} = "/bin:/usr/bin:/usr/local/bin";
	`cp -rf $src $dest` if (-e $src);
}

# copyBoxFilesToTemp - make a temporary directory and move filebox
#	contents into it (this way editing can happen 
#	without disrupting object viewing) 
#
sub copyBoxFilesToTemp {
	my $table = shift;
	my $params = shift;

	my $id = $params->{'id'};
	my $cacheroot = getConfig('cache_root');

	# make a new cache dir and remember it 
	$params->{'tempdir'} = makeTempCacheDir();

	my $source = getFilePath($table, $id);
	my $dest = "$cacheroot/$params->{tempdir}";

	$ENV{'PATH'} = "/bin:/usr/bin:/usr/local/bin";
	`cp -r $source/* $dest`;
}

# moveTempFilesToBox - move temporary cache dir files to file box.
#
sub moveTempFilesToBox {
	my $params = shift;
	my $id = shift;
	my $table = shift;

	# we need a temp dir
	#
	if (!nb($params->{'tempdir'})) {
		dwarn "*** moveTempFilesToBox: no tempdir is set!";
		return;
	}
	
	# preliminaries - get file root, make dir
	#
	my $cacheroot = getConfig('cache_root');
	
	my $dest = getFilePath($table, $id);
	my $source = "$cacheroot/$params->{tempdir}";
	
	# make sure file box directory exists and is clear
	#
	if (-e $dest) {
		$ENV{'PATH'} = "/bin:/usr/bin:/usr/local/bin";
		`rm -r $dest/*`;
	} else {
		$ENV{'PATH'} = "/bin:/usr/bin:/usr/local/bin";
		`mkdir $dest`;
	}

	# move non-rendering dir files over.
	#
	dwarn "*** move temp files to box: changing to dir $source";
	chdir "$source";
	$ENV{'PATH'} = "/bin:/usr/bin:/usr/local/bin";
	my $dir = `pwd`;
	$dir =~ s/\s*$//;
	if (baddir($dir)) {
		dwarn "*** move temp files to box: failed to change to dir $source, ended up in root! aborting.";
	return;
	}
	my @files = <*>;
	my @methoddirs = getMethods();
	foreach my $file (@files) {
		if (not inset($file,@methoddirs)) {
			$ENV{'PATH'} = "/bin:/usr/bin:/usr/local/bin";
			`mv $file $dest`;
		} else {
			$ENV{'PATH'} = "/bin:/usr/bin:/usr/local/bin";
			`rm -rf $file`;
		}
	}

	# clean up cache dir
	#
	removeTempCacheDir($params->{'tempdir'});
}

# handleFileManager - get files, display manager.  returns a list of 
# files in the file box.
# 
sub handleFileManager {
	my $template = shift;
	my $params = shift;
	my $upload = shift;
	
	my $ftemplate = new Template('filemanagerform.html');
	my $table = $params->{'from'};
	my $dest = '';
	my $ferror = '';
	my $changes = 0;

	# figure out destination. if we are editing an existing objects, 
	# copyBoxFilesToTemp should already have been called to make a temp dir 
	# and set $params->{tempdir}
	#
	if (nb($params->{'tempdir'})) {
		$ftemplate->setKey('tempdir', $params->{'tempdir'});
		$dest = getConfig('cache_root')."/$params->{tempdir}";
	} elsif (nb($params->{'id'})) {
		$dest = getFilePath($table, $params->{'id'});
	} else {	# make a new cache dir if we have no info
		$params->{'tempdir'} = makeTempCacheDir();
		$ftemplate->setKey('tempdir', $params->{'tempdir'});
		$dest = getConfig('cache_root')."/$params->{tempdir}";
	}

	dwarn "managing files in box at $dest";

	# grab URLs 
	#
	if (defined $params->{filebox} && $params->{filebox} eq "upload" && nb($params->{fb_urls})) {
		my @urls = split(/\s*\n\s*/,$params->{fb_urls});
		foreach my $url (@urls) {
			if (not wget($url,$dest)) {
				$ferror .= "Problem getting $url<br/>" if (not wget($url,$dest));
			} else {
				$changes = 1;
			}
		}
		if ($ferror ne '') {
		$ftemplate->setKey('fb_urls', $params->{fb_urls});
		}
	} else {
		$ftemplate->setKey('fb_urls', $params->{fb_urls});
	}
	
	# move an uploaded file
	#
	if (defined $upload and $upload->{'filename'}) {
		#dwarn "moving uploaded file $upload->{tempfile} to $dest/$upload->{filename}";
		$ENV{'PATH'} = "/bin:/usr/bin:/usr/local/bin";
		`mv $upload->{tempfile} $dest/$upload->{filename}`;
		$changes = 1;
	}

	# handle file removal request
	# 
	if (nb($params->{'remove'})) {
		my @files = map("$dest/$_", split(',', $params->{'remove'}));
		my $cnt = unlink @files; 
	if ($cnt > 0 ) { $changes = 1; }
	}

	# generate the file removal chooser and file list
	#
	my $flisttext = '';
	my @filelist = ();
	my $rmlist = '';
	if ( -e $dest ) {
		$ENV{'PATH'} = "/bin:/usr/bin:/usr/local/bin";
		my $cwd = `pwd`;
		chomp $cwd;
		chdir $dest; 
		my @files = <*>;
		chdir $cwd;
		if ($#files < 0) {
			$rmlist = "[no files]"; 
		} else {
		my @methoddirs = getMethods();
		my $count = 0; 
	
		foreach my $file (@files) {

			if (not inset($file,@methoddirs)) {
				my $ftext;
				if (defined $params->{'id'}) {
					$ftext = "<a href=\"".getFileUrl($table, $params->{'id'})."/$file\">$file</a>";
				} else { 
					$ftext = "<a href=\"".getConfig('cache_url')."/$params->{tempdir}/$file\">$file</a>";
				}
		
				$rmlist .= "<input type=\"checkbox\" name=\"remove\" value=\"$file\" />$ftext<br />";
				push @filelist, $file; 
				$count++;
			}
		}
		if ($count == 0) {
				$rmlist = "[no files]";
			} else {
				$flisttext = join(';', @filelist);
			}
		}
	} else {
		$rmlist = "[no files]";
	}
	
	# put info in the file manager template
	#
	$ftemplate->setKeys('rmlist' => $rmlist, 'ferror' => $ferror, 'filelist' => $flisttext);
	$params->{'filechanges'} = "yes" if ($changes == 1);
	if (nb($params->{'filechanges'})) {
		$ftemplate->setKey('filechanges', $params->{'filechanges'});
	}
	
	# combine file manager template and parent template
	#
	$template->setKey('fmanager', $ftemplate->expand());

	return @filelist;
}

# wget - low level interface to wget method. return 1 success, 0 fail.
#
sub wget { 
	my $source = shift;	 # source url to download from
	my $dest = shift;		# local location (directory) to place file in
	my $cmd = getConfig('wgetcmd');

	$ENV{'PATH'} = "/bin:/usr/bin:/usr/local/bin";
	my $cwd = `pwd`;
	
	if (not -d $dest) {
		return 0;
	}

	chdir $dest;
	
	my @args = split(/\s+/,$cmd);
	push @args,$source;
	system(@args);

	my $ret = (($?>>8)==0)?1:0;
	chdir $cwd;

	return $ret;
}

sub httpUpload { 
	my $params = shift;
	my $userinf = shift;
	my $upload = shift;
	my $html = '';

	$html .= "<form method=\"post\" action=\"".getConfig("main_url")."/?op=httpupload\" enctype=\"multipart/form-data\">";
	$html .= "<input type=\"file\" size=\"50\" name=\"upload\" />";
	$html .= "<input type=\"submit\" name=\"submit\" value=\"upload\" />";
	$html .= "</form>";
	if (defined($params->{submit})) {
		$html .= "got file: $upload->{filename} @ $upload->{tempfile}";
	}
	
	return paddingTable(makeBox('upload',$html));

}

1;

