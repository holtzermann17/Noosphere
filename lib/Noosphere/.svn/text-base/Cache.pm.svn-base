package Noosphere;

use strict;

require Noosphere::Filebox;
require Noosphere::Encyclopedia;
require Noosphere::Crossref;
require Noosphere::Layout;
require Noosphere::Latex;
require Noosphere::Template;
require Noosphere::NNexus;
require Noosphere::Charset;

use File::Path qw(make_path remove_tree);

use HTML::Tidy;
use HTML::Entities ();


# entry point for getting an image which is a single TeX math object.
#
sub getRenderedContentImage	{
	my $math = shift;
	my $variant = shift;
	my $make = shift;

	my ($url, $align) = getRenderedContentImageURL($math, $variant, $make);

# return the HTML for the image URL to the image 
#
	if (defined $url && defined $align) {
		return "<img title=\"\$".qhtmlescape($math)."\$\" alt=\"\$".qhtmlescape($math)."\$\" align=\"$align\" border=\"0\" src=\"$url\" />";
	} else {
		return "<img title=\"\$".qhtmlescape($math)."\$\" alt=\"\$".qhtmlescape($math)."\$\" border=\"0\"/>";
	}
}

# get the URL (and align) for an image of a single TeX math environment object
#
sub getRenderedContentImageURL	{
	my $math = shift;
	my $variant = shift;
	my $make = shift || getConfig('single_render_variants');

	my $rv = 0;	# render return value

# render the math if it isn't in the db
# 
		if (!variant_exists($math, $variant)) {

# only allow one single render at a time so we don't overload the server
# 
# TODO : change this to a limited parallelization, a-la regular entry rendering
#  a big problem is we dont have unique IDs to maintain cache entries for single
#  images; we'll have to start creating these before making rendering attempts.
#
			my $dir = getConfig('single_render_root');

			if (! -e $dir) {
				$rv = singleRenderLaTeX($math, $make);
			} else {
# see if the rending has timed out; if so, remove dir and start over.
				my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime,$mtime,$ctime,$blksize,$blocks) = stat($dir);
				my $now = time();

				if ($now - $mtime > getConfig('singlerender_failed')) {
# remove extant dir and start over
#
					$ENV{'PATH'} = "/usr/local/texlive/2008/bin:/bin:/usr/bin:/usr/local/bin";
					system("rm -rf \"$dir\"");

					$rv = singleRenderLaTeX($math, $make);
				} else {
					$rv = 1; # failed (for now)
				}
			}
		} 

	if ($rv == 0) {
# get unique id of the image variant
		my $id = lookupfield(getConfig('rendered_tbl'), "uid", "imagekey='".sq($math)."' and variant='".sq($variant)."'");

# get the align mode
		my $align = lookupfield(getConfig('rendered_tbl'), "align", "imagekey='".sq($math)."' and variant='".sq($variant)."'") || 'bottom';

# return the URL and alignment
#
		return (getConfig("main_url")."/?op=getimage&amp;id=$id", $align);
	}

	return (undef, undef); # failed return values
}

# get image data from database based on its id
# 
sub getImage {
	my $id = shift;

	my $image = lookupfield(getConfig('rendered_tbl'), "image", "uid=$id");

	return $image;
}

# main entry point for full rendering of a document. returns some HTML which
# can be output to display the rendered docuemnt.
#
sub getRenderedContentHtml {
	my $params = shift;
	my $table = shift;
	my $rec = shift;
	my $method = shift || getConfig('default_render_mode');	 # default default

	warn "GETTING HTML in for method = $method";

	my $path = getConfig('cache_root');
        my $dir = "$path/$table";
	if ( ! -d $dir ) {
		return "Setup Error: Please create the $dir directory";
	}


	my $html = '';

	my ($valid, $valid_html, $build, $staleness) = getcacheflags($table, $rec->{'uid'}, $method);

	my $showold = 0;

	if ($valid == 0 && !$params->{'old'}) {

		if (bad_entry($table, $rec->{'uid'}, $method)) {

			$html = "<br /><p>This current version of this entry, for this view style, is marked as <b>broken</b>, so it can't be shown.  This problem is probably being worked on, but you might want to contact the entry's owner just in case.  For now, you can also try selecting another view style below.</p>";
		}

		else {

			my $concurrent = concurrent_renders();

			incrrequests($table, $rec->{'uid'}, $method);

			if ( $concurrent >= getConfig('concurrent_renders') && (
						($build == 0) ||
						($build == 1 && $staleness >= getConfig('render_failed'))) ) {

				if ($params->{'new'} || !cachedVersionExists($table, $rec->{'uid'}, $method)) {
					$html = "<br /><p>I cannot retrieve this entry because the system is too busy.  Please try again later.</p>";
				} else {
					$showold = 1;
				}
			}
			elsif (! cacheObject($table, $rec, $method)) {
				$html = "<br /><p>Timed out waiting for render (rendering was initiated $staleness seconds before your query).  Please wait a few seconds and try again (longer documents will take more time.)</p>";
			} else {
				$valid = 1;
			}
		}
	}

# entry is valid now, retrieve up-to-date copy from cache and display
# 
	if ($valid) {

		$html = getRenderedObjectHtml($table, $rec->{'uid'}, $method);

	} 

# entry is not valid, determine what to do about out-of-date copy
# 
	else {

# if forcing or defaulting to showing old copy, then get it
#
		if ($showold || $params->{'old'}) {
			$html = getRenderedObjectHtml($table, $rec->{'uid'}, $method);

			$params->{'new'} = 1;
			my $url = getConfig('main_url').'?'.hashToParams($params);

			$html = "<p align=\"center\"><b><i>Note: you are viewing a possibly out-of-date cached copy of this entry!  This is happening because the system is currently too busy.  You may wait a while and refresh this page, or <a href=\"$url\">click here</a> to try again.</i></b></p>".$html;

		} 

# otherwise, not automatically showing old cached copy of entry; give manual link for it
#
		else {

			if (cachedVersionExists($table, $rec->{'uid'}, $method)) {

				$params->{'old'} = 1;
				my $url = getConfig('main_url').'?'.hashToParams($params);

				$html .= "<p>Optionally, you can elect to see an <a href=\"$url\">old copy</a> of this entry.</p>";

			} elsif (!$html) {

				$html = "Uh oh.  You should never be seeing this message, something is broken.";
			}
		}
	}


	return $html;

#	my $content = encode('utf8', $html );
#	return $content;
}

# determine if a cached version of an object exists
#
sub cachedVersionExists {
	my ($table, $id, $method) = @_;

	if ( -e getCachePath($table, $id.'/'.$method.'/'.getConfig('rendering_output_file') ) ) {
		return 1;
	}

	return 0;
}

# build an object and place it in the cache
#
sub cacheObject {	
	my $table = shift;
	my $rec = shift;
	my $method = shift;

	my $id = $rec->{'uid'};
	my $count = 0;
	my $max = getConfig('build_timeout');
	my $latex = '';

	my ($valid, $valid_html, $build, $staleness) = getcacheflags($table, $id, $method);


	warn "*************************** cacheObject called ***********\n";
	warn "Cache flags are valid = $valid, valid_html = $valid_html and build= $build";

# not valid, but building, so wait
#
	if ($build == 1 && $staleness < getConfig('render_failed')) {
		do { 
			sleep 1;
			if ($count >= $max) { return 0; }
			($valid, $valid_html,  $build) = getcacheflags($table, $id, $method);
			$count++;
		} while ($valid == 0 && $build == 1);
	}
# not valid, and not building, so build it
#
	else { 
		setbuildflag_on($table, $id, $method);
		my $path = getConfig('cache_root');
		my $dir = "$path/$table/$id/$method";
		if ( ! -e $dir ) {
			make_path("$dir");
			warn "just made directory $dir";
		}
		warn "WRITING TO $dir";
		my $text = "";
		if ($table eq getConfig('en_tbl')) {
			if ( $method eq 'src' ) {
				renderLaTeX($table, $rec->{'uid'}, $rec->{'data'}, $method, $rec->{'name'});
#				$rec->{'data'};
			#	open (OUTFILE, ">$dir/" .getConfig('rendering_output_file'));
			#	my $data = HTML::Entities::encode($rec->{'data'});

				#print OUTFILE "$data";
			#	close(OUTFILE);
			} else {
				my $nolink;
				if ( ! $valid_html ) {
					cleanCache($table, $id, $method);
					cacheFileBox($table, $id, $method);
					my $output;
					my $links;
					($output, $links, $nolink) = prepareEntryForRendering(
							0,
							$rec->{'preamble'},
							$rec->{'data'},
							$method,
							$rec->{'title'},
							[@{getSynonymsList($rec->{'uid'})},@{getDefinesList($rec->{'uid'})}],
							$table,
							$rec->{'uid'},
							classstring($table,$rec->{'uid'}));

				warn "Sending $output to renderLaTeX\n";

#renderLaTeX now writes unlinked.html instead of linked HTML.
#
					renderLaTeX($table, $rec->{'uid'}, $output, $method, $rec->{'name'});
				} else {
					warn "Unlinked object html has already been rendered. Just linking. ;-)";
				}

				if ( $method eq 'js' || $method eq 'l2h' ) {
#				$text = readFile(getConfig('tidycmd')." -wrap 1024 -numeric -asxhtml $dir/unlinked.html 2>/dev/null |");
				my $text = readFile("$dir/unlinked.html");

				
# we now call the new NNexus module that will handle linking
# 	and connecting to the NNexus server.
				my $linked = '';
				my $links = "";
				#warn Dumper( $nolink );
				($linked,$links) = linkEntry(  $rec->{'uid'},
						$text, 'html', $nolink);
				my $jslinks = '';  
				while ( $linked =~ s/<script[^<>]*>(.*?)<\/script>//si ) {
					$jslinks .= $1;
				}


				$linked = encode("utf8", $linked);
				#now tidy up the linked stuff returned from NNexus
				my $tidy = HTML::Tidy->new( {
                                    	'output_xhtml' => 1,
					'char-encoding' => 'utf8',
					});	
				my $allclean = $tidy->clean($linked);	
				#extract out only the body
				$allclean =~ /<body.*?>(.*?)<\/body>/sio;
				my $clean = $1;
				#extract out script to put in links.js
				open ( CLEAN, '>/tmp/clean.html');
				print CLEAN $clean;
				close (CLEAN);
				my $outfilepath = "$dir/" . getConfig('rendering_output_file');
				open (OUTPUTFILE, ">$outfilepath") || die "Couldn't open $outfilepath";
				binmode OUTPUTFILE, ":utf8";
				if ( $linked ne '' ) {
					writeLinksToFile($table, $id, $method, $links);
					open(JSLINKS, ">$dir/links.js");
					binmode JSLINKS, ":utf8";
					print JSLINKS $jslinks;	
					close(JSLINKS);
					
					print OUTPUTFILE "$clean";
					#warn "writing following to $dir/planetmath.html\n";
					#warn "$linked\n";

				} else {
					print OUTPUTFILE "$text";
				}
				close( OUTPUTFILE );
				}
				
			}
		}
		elsif ($table eq getConfig('collab_tbl')) {
			cacheFileBox($table, $id, $method);
			my $name = normalize($rec->{'title'});
			renderLaTeX($table, $rec->{'uid'}, $rec->{'data'}, $method, $name);
			my $text = readFile("$dir/unlinked.html");
			warn "COLLAB: $text";
			my $outfilepath = "$dir/" . getConfig('rendering_output_file');
			open (OUTPUTFILE, ">$outfilepath") || die "Couldn't open $outfilepath";
			binmode OUTPUTFILE, ":utf8";
			print OUTPUTFILE "$text";
			close(OUTPUTFILE);
		} else {
			warn Dumper( $rec );

			my $text = $rec;
			
			my $outfilepath = "$dir/" . getConfig('rendering_output_file');
			open (OUTPUTFILE, ">$outfilepath") || die "Couldn't open $outfilepath";
			binmode OUTPUTFILE, ":utf8";
			print OUTPUTFILE "$text";
			close(OUTPUTFILE);
		}

		setrrequests($table, $id, $method, 0);
		setbuildflag_off($table, $id, $method);
		setvalid_htmlflag_on($table, $id, $method) if ($method ne 'png');
		setvalidflag_on($table, $id, $method);
	}

	return 1;
}

# prepares an entry for rendering :
#	- combine with template
#	- get supplementary packages
#	- do cross-referencing
#
sub prepareEntryForRendering {
	my $newent = shift;	 # new entry flag
	my $preamble = shift;
	my $latex = shift;
	my $method = shift;
	my $title = shift;
	my $syns = shift;
	my $table = shift;
	my $id = shift;
	my $class = shift;

	my $file = getConfig('entry_template');
	my $template = new Template($file);	

	$latex = UTF8toTeX($latex);

# handle cross-referencing 
#
#crossReference doesn't do automatic linking anymore. It only handles user
#defined links.
	my ($linked,$links,$escaped) = crossReferenceLaTeX($newent,$latex,$title,$method,$syns,$id,$class);
	#escaped contains good stuff.
#	warn "crossReferenceLaTeX returned:\n$linked\n";
#	my $linked = $latex;
#	my $links = "";
	$linked = dolinktofile($linked,$table,$id);	# handle \PMlinktofile

# png uses the pre-processed output; that is, link directives are removed.
#
		if ($method eq "png") {
			$latex = $linked;
		}

# l2h uses the cross-referenced text as primary output
#
	if ($method eq "l2h" || $method eq "js") {
		$latex = $linked;
	}

# calculate supplementary packages to add (this now only includes
# the html package, for linking)
#
	my $packages = supplementaryPackages($latex,getConfig('latex_packages'),getConfig('latex_params'));

# combine with template
#
	$template->setKeys('preamble' => $preamble, 'math' => $latex);
	if (nb($packages)) { $template->setKey('packages', $packages) if (nb($packages)); }

	if ( $method eq "src" ) {
		return ($latex,$links);
	} else {
		return ($template->expand(),$links, $escaped);
	}
}

# cache flag util functions
#
sub setbuildflag_on {
	my $table = shift;
	my $id = shift;
	my @methods = @_;

	my $ctbl = getConfig('cache_tbl');

	my $methodq = '';
	$methodq = " and (".join(' or ',map("method='$_'",@methods)).")" if (@methods);

	(my $rv, my $sth) = dbUpdate($dbh,{WHAT => $ctbl, SET => 'build=1, touched=CURRENT_TIMESTAMP',
								 WHERE => "tbl='$table' and objectid=$id $methodq"});	
	$sth->finish();
}

sub setbuildflag_off {
	my $table = shift;
	my $id = shift;
	my @methods = @_;

	my $ctbl = getConfig('cache_tbl');

	my $methodq = '';
	$methodq = " and (".join(' or ',map("method='$_'",@methods)).")" if (@methods);

	(my $rv, my $sth) = dbUpdate($dbh,{WHAT => $ctbl, SET => 'build=0, touched=CURRENT_TIMESTAMP',
								 WHERE => "tbl='$table' and objectid=$id $methodq"}); 
	$sth->finish();
}

sub setvalid_htmlflag_on {
	my $table = shift;
	my $id = shift;
	my @methods = @_;

	my $ctbl = getConfig('cache_tbl');

	my $methodq = '';
	$methodq = " and (".join(' or ',map("method='$_'",@methods)).")" if (@methods);

	(my $rv, my $sth) = dbUpdate($dbh,{WHAT => $ctbl, SET => 'valid_html=1, touched=CURRENT_TIMESTAMP',
								 WHERE => "tbl='$table' and objectid=$id $methodq"}); 
	$sth->finish();
}

sub setvalid_htmlflag_off {
	my $table = shift;
	my $id = shift;
	my @methods = @_;

	my $ctbl = getConfig('cache_tbl');

	my $methodq = '';
	$methodq = " and (".join(' or ',map("method='$_'",@methods)).")" if (@methods);

	(my $rv, my $sth) = dbUpdate($dbh,{WHAT => $ctbl, SET => 'valid_html=0, touched=CURRENT_TIMESTAMP',
								 WHERE => "tbl='$table' and objectid=$id $methodq"}); 
	$sth->finish();

}
sub setvalidflag_on {
	my $table = shift;
	my $id = shift;
	my @methods = @_;

	my $ctbl = getConfig('cache_tbl');

	my $methodq = '';
	$methodq = " and (".join(' or ',map("method='$_'",@methods)).")" if (@methods);

	(my $rv, my $sth) = dbUpdate($dbh,{WHAT => $ctbl, SET => 'valid=1, touched=CURRENT_TIMESTAMP',
								 WHERE => "tbl='$table' and objectid=$id $methodq"}); 
	$sth->finish();
}

sub setvalidflag_off {
	my $table = shift;
	my $id = shift;
	my @methods = @_;

	my $ctbl = getConfig('cache_tbl');

	my $methodq = '';
	$methodq = " and (".join(' or ',map("method='$_'",@methods)).")" if (@methods);

	(my $rv, my $sth) = dbUpdate($dbh,{WHAT => $ctbl, SET => 'valid=0, touched=CURRENT_TIMESTAMP',
								 WHERE => "tbl='$table' and objectid=$id $methodq"}	); 
	$sth->finish();
}

# deletecacheflags - useful for removing cache flags for removed entries.
#
sub deletecacheflags {
	my $table = shift;
	my $id = shift;
	my @methods = @_;

	my $ctbl = getConfig('cache_tbl');

	my $methodq = '';
	$methodq = " and (".join(' or ',map("method='$_'",@methods)).")" if (@methods);

	my ($rv,$sth) = dbDelete($dbh,{FROM=>$ctbl,WHERE=>"objectid=$id and tbl='$table' $methodq"});
	$sth->finish();
}

# get a count of the number of concurrent renders
# 
sub concurrent_renders {

	my $ctbl = getConfig('cache_tbl');
	my $failed = getConfig('render_failed');

	my $query = "";
	$query = "select distinct objectid from $ctbl where build = 1 and valid = 0 and unix_timestamp(now()) - unix_timestamp(touched) < $failed" if getConfig('dbms') eq 'mysql';
	$query = "select distinct objectid from $ctbl where build = 1 and valid = 0 and date_part('epoch',now()) - date_part('epoch',touched) < $failed" if getConfig('dbms') eq 'pg';

	my $sth = $dbh->prepare($query);
	$sth->execute();

	my $count = $sth->rows();

	$sth->finish();

	return $count;
}

# getcacheflags - also makes new entry if there isn't one
#
sub getcacheflags {
	my $table = shift;
	my $id = shift;
	my $method = shift;

	warn "Getting cacheflags for $table, $id, $method";

	my $row;

	my $ctbl = getConfig('cache_tbl');

	my $query = "";
	$query = "select valid, valid_html, build, unix_timestamp(CURRENT_TIMESTAMP) - unix_timestamp(touched) as staleness from $ctbl where tbl = '$table' and objectid = $id and method = '$method'" if getConfig('dbms') eq 'mysql';
	$query = "select valid, valid_html, build, date_part('epoch',CURRENT_TIMESTAMP) - date_part('epoch', touched) as staleness from $ctbl where tbl = '$table' and objectid = $id and method = '$method'" if getConfig('dbms') eq 'pg';

	my $sth = $dbh->prepare($query);
	$sth->execute();
	$row = $sth->fetchrow_hashref();
	$sth->finish();

# if we got back nothing, create a new cache entry for the method and object
#
	if (not defined $row->{'valid'}) {
		createcacheflags($table, $id, $method);
		return (0,0,0);
	}

# otherwise return cache values for existing entry
#
	my $valid = NNexus_checkvalid( $id );

	my $rv = ($row->{'valid'}) ? $valid : 0;
	warn "getcacheflags returns valid = $rv, html = $row->{valid_html} stale= $row->{staleness}";
	return ( $rv, $row->{'valid_html'}, $row->{'build'}, $row->{'staleness'});
}

# bad_entry - determine if the entry's "bad" flag is marked (unrenderable)
#
sub bad_entry {
	my $table = shift;
	my $id = shift;
	my $method = shift;

	my $row;

	my $ctbl = getConfig('cache_tbl');

	my $query = "select bad from $ctbl where tbl = '$table' and objectid = $id and method = '$method'";

	my $sth = $dbh->prepare($query);
	$sth->execute();
	$row = $sth->fetchrow_hashref();
	$sth->finish();

	return ($row->{'bad'});
}

sub createcacheflags {
	my ($table, $id, $method) = @_;

	my $ctbl = getConfig('cache_tbl');

	my ($rv,$sth) = dbInsert($dbh,{INTO=>$ctbl,COLS=>'tbl,objectid,method,touched', VALUES=>"'$table',$id,'$method',CURRENT_TIMESTAMP"});
	$sth->finish();
}

# get count of render requests for a cache entry
# 
sub getrrequests {
	my ($table, $id, $method) = @_;

	my $ctbl = getConfig('cache_tbl');

	my $sth = $dbh->prepare("select rrequests from $ctbl where tbl = ? and objectid = ? and method = ?");
	$sth->execute($table, $id, $method);

	my $row = $sth->fetchrow_arrayref();

	$sth->finish();

	return 0 if (not defined $row);

	return $row->[0];
}

# set render requests for a cache entry to a value
# 
sub setrrequests {
	my ($table, $id, $method, $count) = @_;

	my $ctbl = getConfig('cache_tbl');

	my $sth = $dbh->prepare("update $ctbl set rrequests = ? where tbl = ? and objectid = ? and method = ?");
	$sth->execute($count, $table, $id, $method);

	my $re = $sth->rows();

	$sth->finish();

# if no row effected, create new one
	if (!$re) {
		createcacheflags($table, $id, $method);
	}
}

# increment render requests for a cache entry
# 
sub incrrequests {
	my ($table, $id, $method) = @_;

	my $ctbl = getConfig('cache_tbl');

	my $sth = $dbh->prepare("update cache set rrequests = rrequests + 1 where tbl = ? and objectid = ? and method = ?");
	$sth->execute($table, $id, $method);

	my $re = $sth->rows();

	$sth->finish();

# if no row effected, create, and then inc
#
	if (!$re) {
		createcacheflags($table, $id, $method);
		incrrequests($table, $id, $method);
	}
}

1;
