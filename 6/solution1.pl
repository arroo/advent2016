#!/usr/bin/perl

use strict;
use warnings;

my @letters;

while (<>) {
	chomp;

	my $i = 0;

	$letters[$i++]{$_}++ for (split //,$_);
}


print '', ((sort { $_->{$b} <=> $_->{$a}} keys %$_)[0]) for (@letters);


print "\n";
