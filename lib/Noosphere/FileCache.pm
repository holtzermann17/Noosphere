package Noosphere;

use strict;
use File::stat;
use vars qw(%cached_files $cache_invalidations $cache_references);

sub FileCache::new
{
	my ($class, $path) = @_;

	$cache_references++;
	return $cached_files{$path}->load() if $cached_files{$path};

	my $obj = { 'PATH' => $path, 'TEXT' => readFile($path), 'CACHETIME' => time };
	dwarn "read file $path\n", 3;

	bless $obj, $class;
	$cached_files{$path} = $obj;
	$cache_invalidations++;
	return $obj;
}

sub FileCache::load
{
	my $obj = shift;

    $obj->reload() unless $obj->isCurrent();
	return $obj;
}

sub FileCache::reload
{
	my $obj = shift;

	$obj->{"TEXT"} = readFile($obj->{"PATH"});
	$obj->{"CACHETIME"} = time;
	$cache_invalidations++;
}

sub FileCache::getText
{
	my $obj = shift;

	return $obj->{"TEXT"};
}

sub FileCache::setStatKeys
{
	my $template = shift;

	$template->setKeys(
			'filecache:invalidations' => $cache_invalidations,
			'filecache:hits' => $cache_references,
			'filecache:files' => scalar keys(%cached_files)
		);
}

sub FileCache::isCurrent
{
    my $obj = shift;
    my $info = stat $obj->{"PATH"};

	if ( $info ) {
    		return $info->mtime <= $obj->{"CACHETIME"};
	} else {
		warn "warning. couldn't stat object path";
		return 0;
	}
}

1;

