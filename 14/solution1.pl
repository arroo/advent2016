#!/usr/bin/perl

use strict;
use warnings;

use Term::ANSIColor;
$Term::ANSIColor::EACHLINE=$/;

use Digest::MD5 qw( md5_hex );

my $salt;

while (<>) {
	chomp;
	$salt = $_;
}

my $solutions = 0;

my $n = 0;

my %md5s;

while ($solutions < 64) {
	$md5s{$n} = my $checksum = $md5s{$n} // md5_hex($salt, $n);

#	if (not defined $md5s{$n}) {
#		$md5s{$n} = md5_hex($salt, $n);
#	}
#
#	my $checksum = $md5s{$n};

	if (my ($char) = $checksum =~ /(\S)\1\1/) {
		my $r = $char x 5;

		my $msg = "$n repeated: $char   checksum:$checksum\n";

		for (my $next = $n+1; $next - $n <= 1000; $next++) {
			$md5s{$next} = my $futuresum = $md5s{$next} // md5_hex($salt, $next);

#			if (not defined $md5s{$next}) {
#				$md5s{$next} = md5_hex($salt, $next);
#			}
#			my $futuresum = $md5s{$next};

			if ($futuresum =~ /$r/) {

				$futuresum =~ s/$r/:/;

				my ($before, $after) = split /:/, $futuresum;

				$futuresum = join('', $before, colored($r, 'bold red'), $after);

				$solutions++;
				print "$msg\t$next: $solutions : $futuresum\n";

				last;
			}
		}
	}

	delete $md5s{$n};

	$n++;
#	last;
}

print --$n,"\n";
