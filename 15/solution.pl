#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

$| = 1;




sub main {
	my $lines = slurp();

#	print Dumper($lines);

	my $result = process($lines);

	print "$result\n";
}

sub process {
	my ($lines) = @_;

	my $result;

	my @discs;

	for my $line (@$lines) {

		if (my ($nPos, $start) = $line =~ /\ADisc #\d+ has (\d+) positions; at time=0, it is at position (\d+)\.\z/) {

			push @discs, [$nPos, $start];

		}

	}

	my $increment = 1;
	my $known = 0;
	for (my $t = 0; not defined $result; $t += $increment) {
		my $fallsThrough = 1;

		for (my ($i, $step) = ($known, $t+1+$known); $i < scalar @discs and $fallsThrough; $i++, $step++) {
			my ($nPos, $start) = @{$discs[$i]};

			$fallsThrough = ($start + $step) % $nPos == 0;

			# keep track of how many seconds until this scenario comes up again
			if ($fallsThrough) {
				$increment = lcm($increment, $nPos);
				$known++
			}
		}

		if ($fallsThrough) {
			$result = $t;
		}
	}	

	return $result;
}

sub lcm {
	my ($x, $y) = @_;

	return ($x * $y) / gcd($x, $y);
}

sub gcd {
	my ($x, $y) = @_;

	while ($x != $y) {
		if ($x > $y) {
			$x -= $y;
		} else {
			$y -= $x;
		}
	}

	return $x;
}

sub slurp {
	my @lines;

	while (my $line = <>) {
		chomp $line;

		push @lines, $line;
	}

	return \@lines;
}

main();
