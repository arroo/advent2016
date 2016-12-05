#!/usr/bin/perl

use strict;
use warnings;

use Digest::MD5 qw( md5_hex);

my ($n, $p, $d, %passChars) = (0);

($p,  !defined $p || defined $passChars{$p} ? undef : $passChars{$p}) = ($p, $d) = (md5_hex($ARGV[0], $n++) =~ /\A00000([0-7])([a-f0-9])/) while (scalar keys %passChars < 8);

print join('', map {$passChars{$_}} sort keys %passChars) , "\n";
