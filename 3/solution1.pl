#!/usr/bin/perl

use strict;
use warnings;


my $sum = 0;

while (<>) {
	chomp;

	if (my (@s) = $_ =~ /(\d+)\s+(\d+)\s+(\d+)/) {
		my ($s1, $s2, $s3) = @s;

		if ($s1 + $s2 > $s3) {
			$sum++;
		}
	}
}

print "$sum\n";
