package Map::Package;
use base AI::Pathfinding::AStar;

use strict;
use warnings;

use List::Util qw( max );

use Data::Dumper;

#require Exporter;

#our @ISA = qw(Exporter);
#our @EXPORT_OK = qw(new);

sub new {
	my ($class, $g) = @_;

	my $self = {
		't' => $g,
		'map' => [],
	};

	bless($self, $class);

	return $self;
}

sub getSurrounding {
	my ($self, $id, $target) = @_;

	my ($X, $Y) = split /,/, $id;

	my @terrain;

	# only need to check compass points

	my $f = $self->{'t'};

	for my $pos ([$X-1, $Y],[$X+1, $Y],[$X, $Y-1],[$X, $Y+1]) {
		my ($x, $y) = @$pos;
		if ($x >= 0 and $y >= 0) {
			if ($f->(@$pos)) {
				push @terrain, [join(',', @$pos), 1, 0.5];
			}
#			else { push @terrain, [join(',', @$pos), 100, 0.5];}
			$self->{'map'}[$y][$x] = $f->(@$pos);
		}
	}

#	$self->printMap($X, $Y);

	return \@terrain;
}

sub printMap {
	my ($self, $curX, $curY) = @_;

	my ($maxX, $maxY);

	my $map = $self->{'map'};

#	print Dumper($map);
#	return;

	$maxX = $#$map;
	$maxY = max(map { $#{$map->[$_]} } (0..$#$map));

	
	print "\033[2J";   #clear the screen
	print "\033[0;0H"; #jump to 0,0

	for my $y (0 .. $#$map) {
		if ($y == 0) {
#			print 'x';
		}
		if ($y < 16) {
#			printf('%x', $y);
		}
		for my $x (0 .. $#{$map->[$y]}) {
			if ($y == 0 and $x == 0) {
#				print "0123456789ABCDEF\n";
			}
			if ($x == $curX and $y == $curY) {
				print '@';
			} elsif (not defined $map->[$y][$x]) {
				print ' ';
			} elsif ($map->[$y][$x]) {
				print '.';
			} else {
				print '#';
			}
		}

		print "\n";
	}

}

1;
