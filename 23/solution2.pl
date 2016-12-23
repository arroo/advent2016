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

$register{'a'} = 7;
$register{'a'} = 12;

while ($i < scalar @instruction) {

	if (my ($op, $t1, $t2) = $instruction[$i] =~ /\A(\w+) (\S+)(?: (\S+))?\z/) {

		my $oldInstruction = $instruction[$i];

#		print Dumper($i, \%register, \@instruction);
#		print "\n";

		if (not isNumeric($t1)) {
			$register{$t1} = $register{$t1} // 0;
		}

		if (defined $t2 and not isNumeric($t2)) {
			$register{$t2} = $register{$t2} // 0;
		}

		if ($op eq 'cpy') {
			$register{$t2} = isNumeric($t1) ? $t1 : $register{$t1};

		} elsif ($op eq 'inc') {
			$register{$t1}++;

		} elsif ($op eq 'dec') {
			$register{$t1}--;

		} elsif ($op eq 'jnz') {
			$i += (isNumeric($t1) and $t1 or $register{$t1}) ? (isNumeric($t2) ? $t2 : $register{$t2}) - 1 : 0;

		} elsif ($op eq 'tgl') {
			my $ins = isNumeric($t1) ? $t1 : $register{$t1};

#			print "$instruction[$i] has tgl value of $ins\n";

			$instruction[$ins+$i] = toggle($instruction[$ins+$i]) if (defined $instruction[$ins+$i]);
		} else {
			die "unknown instruction $i: $instruction[$i]\n";
		}

#		print "$oldInstruction: $instruction[$i]\n";

		$i++;
	}
}

sub toggle {
	my ($instruction) = @_;

	my $altered = '';

#	print "toggle '$instruction' to ";

	if (my ($op, $t1, $t2) = $instruction =~ /\A(\w+) (\S+)(?: (\S+))?\z/) {
	
		if ($op eq 'cpy') {
			$altered = "jnz $t1 $t2";

		} elsif ($op eq 'inc') {
			$altered = "dec $t1";

		} elsif ($op eq 'dec') {
			$altered = "inc $t1";

		} elsif ($op eq 'jnz') {
			$altered = "cpy $t1 $t2";
			

		} elsif ($op eq 'tgl') {
			$altered = "inc $t1";
		} else {
			die "unable to toggle: $instruction\n";
		}
	}

#	print "$altered\n";

	return $altered;
}

print "$register{'a'}\n";

sub isNumeric {
	my ($string) = @_;

	return (defined $string and length $string and $string =~ /\A-?\d+\z/);
}
