#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

$| = 1;

sub main {
	my $lines = slurp();

	my $result = process($lines);

	print "$result\n";
}

my $longest = 0;

sub process {
	my ($lines) = @_;

	my @rows;
	push @rows, shift @$lines;


	my $lastRow = $rows[0];

	my $totalSafe = 0;

	my $t = $lastRow;
	$t =~ s/\^//g;
	$totalSafe += length $t;

	my $max = 40;
	$max--;

	for (1 .. $max) {

		print "\r$_";

		my $curRow = $lastRow;

#		push @rows, makeRow($rows[-1]);

		my $newRow = makeRow($curRow);

		$lastRow = $newRow;

		$newRow =~ s/\^//g;

		$totalSafe += length $newRow;

#		print Dumper(\@rows);
	}

	print "\n";

#	my $totalSafe = 0;
#	for my $row (@rows) {
#		$row =~ s/\^//g;
#		$totalSafe += length $row;
#	}

	return $totalSafe;
}


sub makeRow {
	my ($above) = @_;

	my @tiles = split //, $above;

	unshift @tiles, '.';
	push @tiles, '.';

	my $out = '';
	for my $i (0 .. (length ($above) - 1)) {
		my ($left, $centre, $right) = @tiles[$i, $i+1, $i+2];

		if ((isTrap($left) and isTrap($centre) and not isTrap($right))
		or (isTrap($centre) and isTrap($right) and not isTrap($left))
		or (isTrap($left) and not isTrap($centre) and not isTrap($right))
		or (isTrap($right) and not isTrap($centre) and not isTrap($left))) {
			$out .= '^';
		} else {
			$out .= '.';
		}

	}

	if (length $out != length $above) {
		die "mismatching lengths";
	}

	return $out;
}

sub isTrap {
	my ($tile) = @_;

	return ($tile eq '^');
}
sub slurp {
	my @lines;

	while (<>) {
		chomp;
		push @lines, $_;
	}

	return \@lines;
}

main();
