#!/usr/bin/perl

use strict;
use warnings;


my $sum = 0;

my (@s1, @s2, @s3);

while (<>) {
	chomp;
	# capture side lengths
	next unless (my (@s) = $_ =~ /\A\s*(\d+)\s+(\d+)\s+(\d+)\s*\z/);

	# add to arrays
	push @$_, shift @s for (\@s1, \@s2, \@s3);

}

my @a = (@s1, @s2, @s3);

while (scalar @a) {
	# check triangles 3 values at a time
	my ($t1, $t2, $t3) = sort { $a <=> $b } splice(@a, 0, 3);
	$sum++ if ($t1 + $t2 > $t3);
}

print "$sum\n";
