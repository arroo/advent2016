#!/usr/bin/perl

use strict;
use warnings;
no warnings 'recursion';

use JSON::XS;

use Algorithm::Permute qw (permute );

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

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

	my %elements;

	for my $line (@$lines) {
		my @stuff = split / an? /, $line;
		shift @stuff;

		for (@stuff) {
			s/(microchip|generator).*$/$1/;
			s/\A(\w)\w+/$1/;
			s/-compatible microchip/M/;
			s/ generator/G/;

			$elements{uc substr($_, 0, 1)} = 1;
		}

		$floors[$f++] = { map {uc $_ => 1} @stuff };
	}

	print Dumper(\%elements);

	$floors[0]{'e'} = 1;

	print Dumper(\@floors);

	my $solution = serialize(createSolutionState(\@floors));

	print Dumper($solution);

	my $result;

	my @ops;

	my @elementArray = keys %elements;

	push @ops, stateToSub(\@floors, 0, \$solution, \@elementArray);


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
	my ($state, $steps, $solution, $elements) = @_;

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

#			my $chips = microchipsPlease([keys %$floor]);
	for my $thing (keys %{$state->[$e]}) {
#	for my $thing (microchipsPlease([keys %{$state->[$e]}])) {
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

				my $clearedFloors = lowestClearedFloors($state);

				# don't move things to a cleared floor
				if ($clearedFloors->{$floorBelow}) {
					$floorBelow = undef;

				# don't move more than one thing to the lowest not-cleared floor
				} elsif (defined $otherThing and $clearedFloors->{$floorBelow - 1}) {
					$floorBelow = undef;

				# don't move microchips down alone
				} elsif (not defined $otherThing and microchipEh($thing)) {
					$floorBelow = undef;
				}
			}

			# don't move more than one thing down to most-cleared floor

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

				my $serializedState = serialize($changedState);

				next if ($statesSeen{$serializedState});

				for my $matchingState (@{allMatchingStatesPlease($serializedState, $json, $elements)}) {
					$statesSeen{$matchingState} = 1;
				}

				push @ops, $changedState;
			}
		}
	}

#	return $furtherSteps;

	return @ops;

}

sub stateToSub {
	my ($state, $steps, $solution, $elements) = @_;

	return sub {
		my @out;

		for my $newState (move($state, $steps, $solution, $elements)) {
			#print "Adding state to ops: " . Dumper($op);

			push @out, stateToSub($newState, $steps + 1, $solution, $elements);
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

	my @gens = map { s/G\z//r } grep { generatorEh($_) } @$things;

	return \@gens;
}

sub generatorEh {
	my ($thing) = @_;

	return $thing =~ m/G\z/;
}

sub microchipsPlease {
	my ($things) = @_;

	my @chips = map { s/M\z//r } grep { microchipEh($_) } @$things;

	return \@chips;
}

sub microchipEh {
	my ($thing) = @_;

	return $thing =~ m/M\z/;
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

sub lowestClearedFloors {
	my ($state) = @_;

	my %emptyFloors;

	for my $floor (0 .. $#$state) {
		if (scalar keys %{$state->[$floor]}) {
			last;
		}

		$emptyFloors{$floor} = 1;
	}

	return \%emptyFloors;
}

sub allMatchingStatesPlease {
	my ($serializedState, $json, $elements) = @_;

	my @states;# = ($baseState);

	# generate all permutations of elements because all matching states are the same
#	my $p = Algorithm::Permute($elements);
#
#	while (my @res = $p->next) {
#		my %matches = 
#	}

#	print Dumper($elements);

	my @elementsBackup = @$elements;

	# elevator base mapping
	my %mapping;# = qw( e e );

	permute {

		for my $i ( 0 .. $#elementsBackup) {
			$mapping{$elements->[$i]} = $elementsBackup[$i];
		}

		my $state = $serializedState;

		for my $baseElement (keys %mapping) {
			$state =~ s/$baseElement(\w)/$mapping{$baseElement}$1/g;
		}

#		push @states, $json->encode($state);	
		push @states, $state;
	} @elementsBackup;

	return \@states;
}

main();
