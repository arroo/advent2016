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
	'0,0' => 7,
	'0,1' => 4,
	'0,2' => 1,
	'1,0' => 8,
	'1,1' => 5,
	'1,2' => 2,
	'2,0' => 9,
	'2,1' => 6,
	'2,2' => 3,
);

my @pos = (1,1);

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
