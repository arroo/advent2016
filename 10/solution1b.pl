#!/usr/bin/perl

use strict;
use warnings;

use List::Util qw( product );

main();

sub main {

	my $lines = slurp();

	my $receiverFactories = makeFactories();

	my $result = process($lines, $receiverFactories);

	print "$result\n";
}

# sub to make factories that allow values to be passed around
sub makeFactories {
	my %receiverFactories = (
		'bot' => sub {
			my ($dstRef, $b) = @_;

			# call give() for correct bot
			return sub {
				my ($value) = @_;

				return sub {
					return $dstRef->{$b}{'give'}($value);
				}
			};
		},

		'output' => sub {
			my ($dstRef, $b) = @_;

			# store output in hash
			return sub {
				my ($value) = @_;

				$dstRef->{$b} = $value;

				return;
			}
		},
	);

	return \%receiverFactories;
}

sub giveFactory {
	my ($values, $dstRef) = @_;

	return sub {
		my ($value) = @_;

		# store first value as low
		if (not defined $values->{'low'}) {
			$values->{'low'} = $value;

			return;
		}

		$values->{'high'} = $value;

		# determine order of input values
		if ($value < $values->{'low'}) {
			$values->{'high'} = $values->{'low'};
			$values->{'low'} = $value;
		}

		my @ops;
		for my $type (keys %$values) {
			# give to correct recipient
			push @ops, sub {
				return $dstRef->{$type}($values->{$type});
			};
		}

		return @ops;
	};
}

sub process {
	my ($lines, $receiverFactories) = @_;

	my %buckets = (
		'bot'    => {},
		'output' => {},
	);

	my @ops;

	for my $line (@$lines) {

		# set up give chain
		if (my ($bot, $lowOp, $lowDst, $highOp, $highDst) = $line =~ /\Abot (\d+) gives low to (\S+) (\d+) and high to (\S+) (\d+)\z/) {

			$buckets{'bot'}{$bot}{'values'} = {};

			$buckets{'bot'}{$bot}{'give'} = giveFactory($buckets{'bot'}{$bot}{'values'}, {
				'low' => $receiverFactories->{$lowOp}($buckets{$lowOp}, $lowDst),
				'high' =>  $receiverFactories->{$highOp}($buckets{$highOp}, $highDst)
			});

		# set up give commands
		} elsif ((my $value, $bot) = $line =~ /\Avalue (\d+) goes to bot (\d+)\z/) {

			push @ops, sub {
				return $buckets{'bot'}{$bot}{'give'}($value);
			}
		}
	}

	# run through give/receive commands
	while (scalar @ops) {
		my $op = shift @ops;

		next unless (defined $op);

		push @ops, $op->();
	}

	# determine final output
	my $result = (grep { $buckets{'bot'}{$_}{'values'}{'low'} == 17 and $buckets{'bot'}{$_}{'values'}{'high'} == 61 } keys %{$buckets{'bot'}})[0];

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
