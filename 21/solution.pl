#!/usr/bin/perl

use strict;
use warnings;

use Algorithm::Permute;


use Data::Dumper;

$| = 1;

sub main {
	my $lines = slurp();

	my $p = new Algorithm::Permute([qw( f b g d c e a h)]);

	my $result;
	my $pass;
	while (my @res = $p->next) {
		$pass = join('', @res);
	
		print "trying $pass\r";

		$result = process($lines, $pass);
		last if ($result eq 'fbgdceah');
	}

	print "\n$pass\n";
}

sub process {
	my ($lines, $pass) = @_;

#	my $pass;
#	$pass = 'abcdefgh';
#	$pass = 'abcde';

	my $oldPass = $pass;

	for my $line (@$lines) {
		if (my ($x, $y) = $line =~ /\Aswap position (\d+) with position (\d+)\z/) {
			my @pass = split //, $pass;
			($pass[$x], $pass[$y]) = ($pass[$y], $pass[$x]);
			$pass = join('', @pass);

		} elsif (($x, $y) = $line =~ /\Aswap letter (\S+) with letter (\S+)\z/) {
			$pass =~ s/$x/=/g;
			$pass =~ s/$y/$x/g;
			$pass =~ s/=/$y/g;

		} elsif (my ($op, $n) = $line =~ /\Arotate (\S+) (\d+) steps?\z/) {

			my @pass = split //, $pass;

			if ($op eq 'right') {
				for (1 .. $n) {
					unshift @pass, pop @pass;
				}
			} elsif ($op eq 'left') {
				for (1 .. $n) {
					push @pass, shift @pass;
				}
			
			} else {
				die "unknown op: $line\n";
			}
			$pass = join('', @pass);

		} elsif (my ($l) = $line =~ /\Arotate based on position of letter (\S+)\z/) {
			 my @pass = split //, $pass;
			$n = index($pass, $l);

#			print "index of $l in $pass is $n\n";

			if ($n >= 4) {
				$n++;
			}
			$n++;

			for (1 .. $n) {
				unshift @pass, pop @pass;
			}

			$pass = join('', @pass);

		} elsif (($x, $y) = $line =~ /\Areverse positions (\d+) through (\d+)\z/) {
			
#			$pass = substr($pass, 0, $x - 1) . reverse(substr($pass, $x, $y - $x + 1)) . substr($pass, $y);
#			$pass = substr($pass, 0, $x - 1) . reverse(substr($pass, $x, $y - $x + 1)) . substr($pass, $y);
#			$pass = join('', (split //, $pass)[0 .. $x, ($y - $x) .. $x, $y .. length $pass]);

			my @pass = split //, $pass;
			$pass = '';
			for (my $i = 0; $i < $x; $i++) {
				$pass .= $pass[$i];
			}

			for (my $i = $y; $i >= $x; $i--) {
				$pass .= $pass[$i];
			}
			for (my $i = $y + 1; $i < scalar @pass; $i++) {
				$pass .= $pass[$i]; 
			}

		} elsif (($x, $y) = $line =~ /\Amove position (\d+) to position (\d+)\z/) {
			my @pass = split //, $pass;
			$n = splice @pass, $x, 1;
#			$pass[$y] = $n;
			splice @pass, $y, 0, $n;
			$pass = join('', @pass);

		} else {
			die "unknown line: $line\n";
		}

#		print "$line: $oldPass -> $pass\n";

		$oldPass = $pass;
	}


	return $pass;
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
