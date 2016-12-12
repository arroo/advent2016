#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

my @instruction;

my %register;

while (<>) {
	chomp;
	push @instruction, $_;
}

my $i = 0;

$register{'c'} = 1;

while ($i < scalar @instruction) {

	if (my ($op, $t1, $t2) = $instruction[$i] =~ /\A(\w+) (\S+)(?: (\S+))?\z/) {

		if (not isNumeric($t1)) {
			$register{$t1} = $register{$t1} // 0;
		}

		if ($op eq 'cpy') {
			$register{$t2} = isNumeric($t1) ? $t1 : $register{$t1};

		} elsif ($op eq 'inc') {
			$register{$t1}++;

		} elsif ($op eq 'dec') {
			$register{$t1}--;

		} elsif ($op eq 'jnz') {
			$i += (isNumeric($t1) and $t1 or $register{$t1}) ? $t2 - 1 : 0;
		}

		$i++;
	}
}

print "$register{'a'}\n";

sub isNumeric {
	my ($string) = @_;

	return (defined $string and length $string and $string =~ /\A\d+\z/);
}
