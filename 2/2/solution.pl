#!/usr/bin/perl

use strict;
use warnings;

my %directions = qw(
	U 1
	R 1
	D -1
	L -1
);

my %turns = qw(
	U 1
	R 0
	D 1
	L 0
);

my %pad = (
	'0,2' => 5,
	'1,1' => 'A',
	'1,2' => 6,
	'1,3' => 2,
	'2,0' => 'D',
	'2,1' => 'B',
	'2,2' => 7,
	'2,3' => 3,
	'2,4' => 1,
	'3,1' => 'C',
	'3,2' => 8,
	'3,3' => 4,
	'4,2' => 9,
);

my @pos = (2,2);

while (<>) {
	chomp;
	for (split //) {
		my @tPos = @pos;

		$tPos[$turns{$_}] += 1 * $directions{$_};

		if (defined $pad{join(',', @tPos)}) {
			@pos = @tPos;
		}
	}

	print $pad{join(',', @pos)};
}

print "\n";
