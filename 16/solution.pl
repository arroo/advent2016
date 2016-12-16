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

	my ($input, $size);

	for my $line (@$lines) {

		($input, $size) = split / /, $line;

	}

	# fill up the disk
	while ((length $input) < $size) {

		my $copy = reverse $input;

		$copy =~ s/0/=/g;
		$copy =~ s/1/0/g;
		$copy =~ s/=/1/g;

		$input = join('', $input, '0', $copy);

	}

	$input = substr($input, 0, $size);

	# calculate checksum
	my $checksum;
	do {
		$input = $checksum = join('', map { ($_ =~ /(.)\1/) ? '1' : '0' } unpack('(a2)*', $input));

	} while (((length $checksum) % 2) == 0);

	return $checksum;
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
