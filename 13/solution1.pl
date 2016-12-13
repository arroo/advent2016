#!/usr/bin/perl

#use strict;
#use warnings;

use Data::Dumper;

#use AI::Pathfinding::AStar;

use Map::Package qw (new);
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

	my $n;

	my @pos = (1,1);
	my @dst = (31, 39);
	my @map;

	for my $line (@$lines) {

		if (my ($a) = $line =~ /\A(\d+)\z/) {
			$n = $a;

		} else {
			die "poorly formatted line: $line\n";
		}

	}

#	$n = 10;
#	@dst = (7,4);

	my $getTerrain = terrainFactory($n);

	my $map = Map::Package->new($getTerrain) or die "no map for you\n";

#	my $map = AI::Pathfinding::AStar->_init({'can' => sub {1}, 'getSurrounding' => sub {}});

	my $path = $map->findPath(join(',', @pos), join(',', @dst));

	$result = scalar( @$path) - 1;

	return $result;
}


sub terrainFactory {
	my ($n) = @_;

	return sub {
		my ($x, $y) = @_;

		my $num = $n + $x*$x + 3*$x + 2*$x*$y + $y + $y*$y;

#		my $bits = scalar grep {$_} split(//, unpack('b*', $num));

		my $bits = scalar( grep {$_} split(//, sprintf('%b', $num)));

#		print "\$x:$x \$y:$y \$num:$num \$bit:$bits\n";

		return !($bits % 2);	
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

main();
