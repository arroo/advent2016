#!/usr/bin/perl

use strict;
use warnings;

use constant HEIGHT => 6;
use constant WIDTH => 50;

my @grid = map { [ map { 0 } (1 .. HEIGHT)] } (1 .. WIDTH);


while (<>) {
	my @carry;

	if (my ($w, $h) = $_ =~ /rect (\d+)x(\d+)/) {
		for my $x (1 .. $w) {
			for my $y (1 .. $h) {
				$grid[$x][$y] = 1;
			}
		}

	} elsif (my ($col, $n) = $_ =~ /rotate column x=(\d+) by (\d+)/) {
		$col++;

		for my $y (1 .. $n) {
			push @carry, $grid[$col][$y];
		}

		for my $y ($n + 1 .. HEIGHT, 1 .. $n) {
			push @carry, $grid[$col][$y];

			$grid[$col][$y] = shift @carry;
		}

	} elsif ((my $row, $n) = $_ =~ /rotate row y=(\d+) by (\d+)/) {
		$row++;

		for my $x (1 .. $n) {
			push @carry, $grid[$x][$row];
		}

		for my $x ($n + 1 .. WIDTH, 1 .. $n) {
			push @carry, $grid[$x][$row];

			$grid[$x][$row] = shift @carry;
		}
	} else {
		die "badly formatted line\n";
	}
}

for my $y (1 .. HEIGHT) {
	for my $x (1 .. WIDTH) {
		print $grid[$x][$y] ? '#' : ' ';
	}

	print "\n";
}

my $sum = 0;
for my $x (@grid) {
	for my $y (@$x) {
		$sum++ if ($y);
	}
}

print "\n$sum\n";
