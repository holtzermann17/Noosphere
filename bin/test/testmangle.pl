#!/usr/bin/perl

use lib '/var/www/pm/lib';
use Noosphere;
use Noosphere::Indexing;

use strict;

my @titles = ('$GL(n, \mathbb{F}_q)$', 'proof of the foo', 'proof of bar', 'proof that bar', 'example of bar', 'example of the bar', 'the point of no return');

foreach my $title (@titles) {
  print Noosphere::mangleTitle($title)."\n";
}
