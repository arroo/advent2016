#!/usr/bin/perl

use strict;
use warnings;


my $sum = 0;

my (@s1, @s2, @s3);

while (<>) {
	chomp;

	if (my (@s) = $_ =~ /(\d+)\s+(\d+)\s+(\d+)/) {
		my ($s1, $s2, $s3) = @s;

		push @s1, $s1;
		push @s2, $s2;
		push @s3, $s3;

		if (scalar @s1 == 3) {

			for (\@s1, \@s2, \@s3) {

				my ($t1, $t2, $t3) = sort { $a <=> $b } @$_;

				if ($t1 + $t2 > $t3) {
					$sum++;
				}
			}

			@s1 = @s2 = @s3 = ();
		}
	}
}

print "$sum\n";
