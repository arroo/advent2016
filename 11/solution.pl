#!/usr/bin/perl

use strict;
use warnings;
no warnings 'recursion';

use JSON::XS;

use Data::Dumper;

my $totalSteps = 0;
my $totalOps = 0;
my $currentOps = 0;

$| = 1;

my $json = JSON::XS->new->ascii->canonical;

my %oldStates;
my $bestSolution = 193;

my @statesSeen;
my %statesSeen;

sub main {
	my $lines = slurp();

#	#print Dumper($lines);

	my $result = process($lines);

	print "\n \n$result\n";
}

sub process {
	my ($lines) = @_;

	my @floors;
	my $f=0;

	for my $line (@$lines) {
		my @stuff = split / an? /, $line;
		shift @stuff;

		for (@stuff) {
			s/(microchip|generator).*$/$1/;
			s/\A(\w)\w+/$1/;
			s/-compatible microchip/M/;
			s/ generator/G/;
		}

		$floors[$f++] = { map {$_ => 1} @stuff };
	}


	$floors[0]{'e'} = 1;

	print Dumper(\@floors);

	my $solution = serialize(createSolutionState(\@floors));

	print Dumper($solution);

	my $result;

	my @ops;

	push @ops, stateToSub(\@floors, 0, \$solution);


	#$result = move($e, [-1, {}, 0], \@floors);

	while (scalar @ops) {
		#print 'ops:' . scalar @ops . "\n";

		my $op = shift @ops;

		$currentOps = scalar @ops;
		$totalOps++;

		next unless (defined $op);

		push @ops, $op->();

	}

	return $result;
}



sub move {
	my ($state, $steps, $solution) = @_;

	my $serialized = serialize($state);

	if ($serialized eq $$solution) {
#	if (sameStateEh($state, $solution)) {
#	if (Compare($state, $solution)) {
		print "\n$steps\n";
		exit 0;
	}

	#print "on floor $e, move:" . Dumper($move) . Dumper($state);

#	die "unable to solve\n" if $steps > 2000;

	if ($steps > $totalSteps) {
		$totalSteps = $steps;

		if ($totalOps > 10) {
			print "\n";
		}

#		print "\rtotalSteps: $totalSteps        ops: $totalOps        remaining ops: $currentOps        seen states:",scalar @statesSeen,"\n";
		print "\rtotalSteps: $totalSteps        ops: $totalOps        remaining ops: $currentOps        seen states:",scalar keys %statesSeen,"\n";
		$totalOps = 0;
	} else {
#		print "\r$totalOps/" , $currentOps + $totalOps, " seen states:", scalar @statesSeen ;
		print "\r$totalOps - " , $currentOps, " seen states:", scalar keys %statesSeen ;
	}

	# have to take something and change floors

	my @ops;

	my %pairs;

	my $e;

#	print "steps: $steps " . Dumper($state);

	for my $floor (0 .. $#$state) {
		$e = $floor if ($state->[$floor]{'e'});
	}

	for my $thing (keys %{$state->[$e]}) {
		next if ($thing eq 'e');

		for my $otherThing (undef, keys %{$state->[$e]}) {
			next if (defined $otherThing and ($thing eq $otherThing or $otherThing eq 'e'));

			if (defined $otherThing) {
				my $pairString = join('', sort($thing, $otherThing));
				next if (defined $pairs{$pairString});
				 $pairs{$pairString} = 1;
			}


			my $floorAbove = $e < 3 ? $e + 1 : undef;
			my $floorBelow = $e > 0 ? $e - 1 : undef;

			if (defined $floorBelow) {
				my $belowThings = 0;
				for my $floor (0 .. $floorBelow) {
					$belowThings += scalar keys %{$state->[$floor]};
				}

				$floorBelow = undef unless ($belowThings);
			}

			for my $nextFloor (grep { defined } ($floorAbove, $floorBelow)) {

				# copy this state
#				my $changedState = clone($state);
				my $changedState = $json->decode($json->encode($state));

				#print "moving $thing ";

				$changedState->[$nextFloor]{'e'} = delete $changedState->[$e]{'e'};

				if (defined $otherThing) {
					delete $changedState->[$e]{$otherThing};
					$changedState->[$nextFloor]{$otherThing} = 1;

					#print "and $otherThing ";
				}

				#print "to floor $nextFloor\n";

				delete $changedState->[$e]{$thing};
				$changedState->[$nextFloor]{$thing} = 1;

				next unless (validStateEh($changedState));

				my $seenBefore;

#				for my $seenState (@statesSeen) {
#					if (sameStateEh($changedState, $seenState)) {
##					if (Compare($changedState, $seenState)) {
#						$seenBefore = 1;
#						last;
#					}
#				}

				my $serializedState = serialize($changedState);

				next if ($statesSeen{$serializedState});

				$statesSeen{$serializedState} = 1;

				next if ($seenBefore);

#				unshift @statesSeen, $changedState;

				push @ops, $changedState;
				#my $stepCount = move($nextFloor, \@newMove, $changedState);
				#if (defined $stepCount and $stepCount < $furtherSteps) {
				#	$furtherSteps = $stepCount;
				#
				#}
			}
		}
	}

#	return $furtherSteps;

	return @ops;

}

sub stateToSub {
	my ($state, $steps, $solution) = @_;

	return sub {
		my @out;

		for my $newState (move($state, $steps, $solution)) {
			#print "Adding state to ops: " . Dumper($op);

			push @out, stateToSub($newState, $steps + 1, $solution);
		}

		return @out;
	};
}

sub slurp {
	my @lines;

	while (my $line = <>) {
		chomp $line;

		push @lines, $line;
	}

	return \@lines;
}

sub createSolutionState {
	my ($state) = @_;

	my %everything;

	my @solution;

	for my $floorInfo (@$state) {
		push @solution, {};
		for my $thing (keys %$floorInfo) {
			$everything{$thing} = 1;
		}
	}

	pop @solution;
	push @solution, \%everything;

	return \@solution;
}

sub validStateEh {
	my ($state) = @_;

	for my $floor (@$state) {

		# elevator on same floor as something else
		if ($floor->{'e'}) {
			return 0 unless (scalar grep { $_ ne 'e' } keys %$floor);
		}

		my $gens = generatorsPlease([keys %$floor]);
		if (scalar @$gens) {

			my %gens = map { $_ => 1 } @$gens;
			my $chips = microchipsPlease([keys %$floor]);

			for my $chip (@$chips) {
				return 0 unless (defined $gens{$chip});
			}
		}

	}

	return 1;
}

# it doesn't matter which elements are in which order, encode them in the order they appear floorwise & alphabetically
sub serialize {
	my ($state) = @_;

	my $genericState = $json->decode($json->encode($state));

	my %mapping = qw( e 0 );

	my $nextMapping = 1;

	for my $floor (0 .. $#$genericState) {
		for my $m (sort { $mapping{$a} <=> $mapping{$b} } keys %mapping) {
			for my $thing (keys %{$genericState->[$floor]}) {

				my $mappedThing = $thing;
				$mappedThing =~ s/\A$m/$mapping{$m}/;

				$genericState->[$floor]{$mappedThing} = delete $genericState->[$floor]{$thing};
			}
		}

		for my $thing (sort grep { not defined $mapping{$_} } keys %{$genericState->[$floor]}) {
			my $element = substr($thing, 0, 1);
			$mapping{$element} = $nextMapping++;
		}

		for my $m (sort { $mapping{$a} <=> $mapping{$b} } keys %mapping) {
			for my $thing (keys %{$genericState->[$floor]}) {
				my $mappedThing = $thing;
				$mappedThing =~ s/\A$m/$mapping{$m}/;

				$genericState->[$floor]{$mappedThing} = delete $genericState->[$floor]{$thing};
			}
		}
	}

	return $json->encode($genericState);
}

sub generatorsPlease {
	my ($things) = @_;

	my @gens = map { s/G\z//r } grep {/G\z/} @$things;

	return \@gens;
}

sub microchipsPlease {
	my ($things) = @_;

	my @chips = map { s/M\z//r } grep {/M\z/} @$things;

	return \@chips;
}

sub sameStateEh {
	my ($stateA, $stateB) = @_;

	# A contains B
	for my $floor (0 .. $#$stateA) {
		for my $thing (keys %{$stateA->[$floor]}) {
			return 0 unless (defined $stateB->[$floor]{$thing});
		}
	}

	# B contains A
	for my $floor (0 .. $#$stateB) {
		for my $thing (keys %{$stateB->[$floor]}) {
			return 0 unless (defined $stateA->[$floor]{$thing});
		}
	}
	return 1;
}

main();
