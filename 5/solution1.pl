#!/usr/bin/perl

use strict;
use warnings;

use Digest::MD5 qw( md5_hex);

my $pass = '';

for (my $n = 0; length $pass != 8; $n++) {

	next unless (my ($d) = md5_hex(@ARGV, $n) =~ /\A00000([a-f0-9])/);

	$pass .= $d;
}

print "$pass\n";
