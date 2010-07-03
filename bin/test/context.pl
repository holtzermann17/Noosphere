#!/usr/bin/perl

use lib '/var/www/lib';
use Noosphere;
use Noosphere::Search;

my $context=Noosphere::contextHighlight("what if i about adding some words to see what happens to euler relation and some other shit",['what','euler','shit']);

print "context highlighted is [$context]";
