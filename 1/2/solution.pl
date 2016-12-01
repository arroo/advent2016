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

	if ($facing =~ /\A[SW]\z/) {
		$amount = -$amount;
	}

	$pos[$idx{$facing}] += $amount;

	my $end = join($posSeparator, @pos);

	push @segments, join('', $start, $segmentSeparator, $end);
}


# find intersection of lines
for my $i (0 .. $#segments) {
	for my $j (0 .. $i - 1) {
		my $intersection = intersection($segments[$i], $segments[$j]);

		if (defined $intersection) {
			print sum(map {abs} split /$posSeparator/, $intersection);

			print "\n";

			exit 0;
		}
	}
}

exit 1;

# determine intersection of 2 line segments
# shortcuts for horizontal/vertical lines
sub intersection {
	my ($l1, $l2) = @_;


#	print "finding intersection between segments $l1 and $l2\n";

	my ($s1, $e1) = split /$segmentSeparator/, $l1;
	my ($s2, $e2) = split /$segmentSeparator/, $l2;


#	print "l1s:$s1 l1e:$e1, l2s:$s2 l2e:$e2\n";

	my $points1 = generatePoints($s1, $e1);
	my $points2 = generatePoints($s2, $e2);

	for my $p1 (@$points1) {
		for my $p2 (@$points2) {
			if ($p1 eq $p2) {
				return $p1;
			}
		}
	}

	return;
}

sub horizontalEh {
	my ($start, $end) = @_;

	my ($sx, $sy) = split /$posSeparator/, $start;
	my ($ex, $ey) = split /$posSeparator/, $end;

	return ($sy == $ey);
}

sub verticalEh {
	my ($start, $end) = @_;

	my ($sx, $sy) = split /$posSeparator/, $start;
	my ($ex, $ey) = split /$posSeparator/, $end;

	return ($sx == $ex);
}

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


