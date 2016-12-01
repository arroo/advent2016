#!/usr/bin/perl

use strict;
use warnings;

use List::Util qw(sum);

use Data::Dumper;


my @movements;
my $facing='N';


my %turn = (
	'NL' => 'W',
	'NR' => 'E',
	'EL' => 'N',
	'ER' => 'S',
	'SL' => 'E',
	'SR' => 'W',
	'WL' => 'S',
	'WR' => 'N',
);

my @pos = (0,0);

my $file = $ARGV[0] // die "need input file\n";

open (my $fh, '<', $file) or die "cannot open $file: $!\n";

while (my $line = <$fh>) {
	chomp $line;

	push @movements, split /, /, $line;
}

for my $move (@movements) {

	my ($dir, $amount) = $move =~ /\A([LR])(\d+)\z/;

	$facing = $turn{"$facing$dir"};

	if ($facing =~ /\A[SW]\z/) {
		$amount = -$amount;
	}

	if ($facing =~ /\A[NS]\z/) {
		$pos[1] += $amount;
	} elsif ($facing =~ /\A[EW]\z/) {
		$pos[0] += $amount;
	}
}

my $streetDistance = sum(map {abs} @pos);

print "$streetDistance\n";
