#!/usr/bin/perl

use lib '/var/www/pm/lib';
use Noosphere;
use Noosphere::Util;

Noosphere::sendMail('akrowne@vt.edu', "testing correct recipients line", "dummy contents");
