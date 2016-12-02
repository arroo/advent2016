#!/usr/bin/perl

use strict;
use warnings;

use List::Util qw(sum);

use Data::Dumper;


my @movements;
my $facing='N';

my $segmentSeparator = 'k';
my $posSeparator = ',';

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

my %idx = (
	'N' => 1,
	'S' => 1,
	'E' => 0,
	'W' => 0,
);


my %sign = (
	'N' => 1,
	'E' => 1,
	'S' => -1,
	'W' => -1,
);

my @segments;

my @pos = (0,0);

my $file = $ARGV[0] // die "need input file\n";

open (my $fh, '<', $file) or die "cannot open $file: $!\n";

while (my $line = <$fh>) {
	chomp $line;

	push @movements, split /, /, $line;
}

close($fh) or warn "unable to close $file: $!\n";

for my $move (@movements) {

	my ($dir, $amount) = $move =~ /\A([LR])(\d+)\z/;

	$facing = $turn{"$facing$dir"};

	my $start = join($posSeparator, @pos);

	$pos[$idx{$facing}] += $sign{$facing} * $amount;

	my $end = join($posSeparator, @pos);

	push @segments, join('', $start, $segmentSeparator, $end);
}

my @allPoints = map { @{generatePoints(split /$segmentSeparator/)} } @segments;

push @allPoints, (split /$segmentSeparator/, $segments[-1])[1];

my %visited;

my $firstTwice;

for my $point (@allPoints) {
	if (defined $visited{$point}) {
		$firstTwice = $point;

		last;
	}

	$visited{$point} = 1;
}

print sum(map {abs} split /$posSeparator/, $firstTwice);

print "\n";

# generate all integer points on a line segment
sub generatePoints {
	my ($start, $end) = @_;

#	print "\tgenerating points for $start to $end\n";

	my @points;

	my ($sx, $sy) = split /$posSeparator/, $start;
	my ($ex, $ey) = split /$posSeparator/, $end;

	my $dir;

	# vertical line
	if (verticalEh($start, $end)) {

		# going south
		if ($sy > $ey) {
			$dir = -1;
		# going north
		} else {
			$dir = 1;
		}

		for (my $y = $sy; $y != $ey; $y += $dir) {
			push @points, join('', $sx, $posSeparator, $y);
		}

	# horizontal line
	} else {
		# going west
		if ($sx > $ex) {
			$dir = -1;
		# going east
		} else {
			$dir = 1;
		}

		for (my $x = $sx; $x != $ex; $x += $dir) {
			push @points, join('', $x, $posSeparator, $sy);
		}
	}

#	print "\tpoints are " . join(', ', @points) . "\n";

	return \@points;
}


sub verticalEh {
	my ($start, $end) = @_;

	my ($sx, $sy) = split /$posSeparator/, $start;
	my ($ex, $ey) = split /$posSeparator/, $end;

	return ($sx == $ex);
}
