#!/usr/bin/perl

use strict;
use warnings;

use List::Util qw( product );

main();

sub main {
	my $lines = slurp();

	my $result = process($lines);

	print "$result\n";
}

sub process {
	my ($lines) = @_;

	my %bots;

	for my $line (@$lines) {
		if (my ($bot, $lowOp, $lowDst, $highOp, $highDst) = $line =~ /\Abot (\d+) gives low to (\S+) (\d+) and high to (\S+) (\d+)\z/) {
			
			$bots{$bot} = $bots{$bot} // {};

			$bots{$bot}{'low'} = [$lowOp, $lowDst];
			$bots{$bot}{'high'} = [$highOp, $highDst];

		} elsif ((my $value, $bot) = $line =~ /\Avalue (\d+) goes to bot (\d+)\z/) {

			$bots{$bot} = $bots{$bot} // {};

			$bots{$bot}{'values'}{$value} = 1;
		}
	}

	my $result;
	my %outputs;

	while (scalar grep({ m/\A[012]\z/ } keys %outputs) < 3) {

		for my $bot (keys %bots) {
			my $info = $bots{$bot};

			next unless (defined $info->{'values'} and 2 == scalar keys %{$info->{'values'}});

			my ($low, $high) = (sort { $a <=> $b } keys %{$info->{'values'}});

			my ($lowOp, $lowOut) = @{$info->{'low'}};

			if ($lowOp eq 'bot') {
				$bots{$lowOut}{'values'}{$low} = 1;

			} elsif ($lowOp eq 'output') {
				$outputs{$lowOut} = $low;
			}

			my ($highOp, $highOut) = @{$info->{'high'}};

			if ($highOp eq 'bot') {
				$bots{$highOut}{'values'}{$high} = 1;

			} elsif ($highOp eq 'output') {
				$outputs{$highOut} = $high;
			}
		}
	}

	$result = product(@outputs{qw( 0 1 2 )});

	return $result;
}


sub slurp {
	my @lines;

	while (my $line = <>) {
		chomp $line;

		push @lines, $line;
	}

	return \@lines;
}
