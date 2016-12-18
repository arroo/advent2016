#!/usr/bin/perl

use strict;
use warnings;

use Digest::MD5 qw( md5_hex );

use Data::Dumper;

$| = 1;

sub main {
	my $lines = slurp();

	my $result = process($lines);

	print "$result\n";
}

my $longest = 0;

sub process {
	my ($lines) = @_;

	my $hash = shift $lines;
	my $pos = [0, 0];
	my $path = '';

	my @ops = makeOp($hash, $path, $pos);

	while (scalar @ops) {

#		print Dumper(\@ops);

		my $op = shift @ops;

		if (defined $op) {
			push @ops, $op->();
		}
	}

	print "\r";

	return $longest;
}

sub move {
	my ($base, $path, $pos) = @_;

	my @ops;

	#check if at goal
	if ($pos->[0] == 3 and $pos->[1] == 3) {
		print "$path\n" unless $longest;

		if (length $path > $longest) {
			$longest = length $path;
			print "\r$longest";
		}

		return @ops;
	}

	my $hash = md5_hex("$base$path");

#	print "hash of $base$path: " , substr($hash, 0, 4), "\n";

	my ($u, $d, $l, $r) = split //, substr($hash, 0, 4);

#	print Dumper($pos) . "\$u:$u   \$d:$d  \$l:$l  \$r:$r\n";

	my %dirs = ('U' => $u, 'D' => $d, 'R' => $r, 'L' => $l);

	for my $dir (keys %dirs) {
		my $newPos = canMove($pos, $dirs{$dir}, $dir);

#		print "trying to move $dir with $dirs{$dir}\n";

		next unless defined $newPos;

#		print "moving $dir\n";

		push @ops, [$base, "$path$dir", $newPos];
	}

	return @ops;
}

sub canMove {
	my ($pos, $char, $dir) = @_;

	# check if moving off edge
	if ($pos->[0] == 0 and $dir eq 'L' or
	$pos->[0] == 3 and $dir eq 'R' or
	$pos->[1] == 0 and $dir eq 'U' or
	$pos->[1] == 3 and $dir eq 'D') {
		return;
	}

	if ($char !~ /[bcdef]/) {
		return;
	}

	my @pos = @$pos;

	if ($dir eq 'L') {
		$pos[0]--;
	} elsif ($dir eq 'R') {
		$pos[0]++;
	} elsif ($dir eq 'U') {
		$pos[1]--;
	} elsif ($dir eq 'D') {
		$pos[1]++;
	}

	return \@pos;
}

sub makeOp {
	my ($hash, $path, $pos) = @_;

	return sub {
		my @ops;

		for my $res (move($hash, $path, $pos)) {
			push @ops, makeOp(@$res);
		}

		return @ops;
	};
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
