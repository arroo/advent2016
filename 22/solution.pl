#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

use JSON::XS qw(encode_json decode_json);

use constant USED => 0;
use constant AVAIL => 1;

$| = 1;

my $separator = ':';
my $sepReg = qr/$separator/;

sub main {
	my $lines = slurp();

	my $result = process($lines);

	print "$result\n";
}

sub process {
	my ($lines) = @_;

	shift @$lines;
	shift @$lines;

	my %nodes;

	my ($minX, $minY) = (1000, 1000);
	my ($maxX, $maxY) = (0, 0);

	

	for my $line (@$lines) {

		my ($x, $y, $size, $sizeUnits, $used, $usedUnits, $avail, $availUnits, $percent) = $line =~ /\A\/dev\/grid\/node-x(\d+)-y(\d+)\s+(\d+)(\S)\s+(\d+)(\S)\s+(\d+)(\S)\s+(\d+)%\z/;

#		printf("x:%d, y:%d, size:%d%s, used:%d%s, avail:%d%s, percent:%d%%\n", $x, $y, $size, $sizeUnits, $used, $usedUnits, $avail, $availUnits, $percent);

#		$nodes{"$x$separator$y"} = [$size, $used, $avail, $percent];

		# condense required info
		$nodes{"$x$separator$y"} = [$used, $avail];

		$maxX = $maxX < $x ? $x : $maxX; 
		$minX = $minX > $x ? $x : $minX; 
		$maxY = $maxY < $y ? $y : $maxY; 
		$minY = $minY > $y ? $y : $minY; 

	}

	my $target = join($separator, $maxX, 0);

#	my $pairs = generatePairs(\%nodes);

#	my $pairCount = scalar map { map { $_ } @{$pairs->{$_}} } keys %$pairs;

#	return $pairCount;

	my $startState = encode_json(\%nodes);

	my @ops;

	push @ops, makeMove(0, $target, $startState);

	while (scalar @ops) {
		my $op = shift @ops;

		next unless defined $op;

		push @ops, $op->();
	}

}

sub makeMove {
	my ($steps, $target, $state) = @_;

	return sub {

		my @out;

		for my $op (move($steps, $target, $state)) {
			push @out, makeMove(@$op);
		}

		return @out;
	};
}

sub move {
	my ($steps, $target, $stateString) = @_;

	if ($target eq '0:0') {
		print "$steps\n";
		exit 0;
	}

	my $state = decode_json($stateString);

	my $pairs = generatePairs($state);

	my @ops;

	for my $sender (keys %$pairs) {
		for my $receiver (@{$pairs->{$sender}}) {
			my $newState = decode_json($stateString);

			# move data
			$newState->{$receiver}[USED]  += $newState->{$sender}[USED];
			$newState->{$receiver}[AVAIL] -= $newState->{$sender}[USED];

			$newState->{$sender}[AVAIL] += $newState->{$sender}[USED];
			$newState->{$sender}[USED]   = 0;

			# check if target data has moved
			my $newTarget = $target;
			if ($sender eq $target) {
				$newTarget = $receiver;
			}

			push @ops, [$steps + 1, $newTarget, encode_json($newState)];
		}
	}

	return @ops;
}

sub generatePairs {
	my ($nodes) = @_;

	my %pairs;

	for my $node (keys %$nodes) {

#		my ($aSize, $aUsed, $aAvail, $aPercent) = @{$nodes->{$node}};
		my $aUsed = $nodes->{$node}[USED];

		next if ($aUsed == 0);

		for my $bNode (keys %$nodes) {

			next if ($node eq $bNode);

#			my ($bSize, $bUsed, $bAvail, $bPercent) = @{$nodes->{$bNode}};
			my $bAvail = $nodes->{$bNode}[AVAIL];

			next if ($aUsed > $bAvail);

			push @{$pairs{$node}}, $bNode;
		}
	}

	return \%pairs;
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
