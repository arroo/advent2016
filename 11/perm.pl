#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

use Algorithm::Permute qw( permute );

my @elements = qw( C D E P R S T );

my @items = map { $_ . 'G', $_ . 'M' } @elements;
push @items, 'e';

print Dumper(\@elements);
print Dumper(\@items);

#my $p = new Algorithm::Permute(\@elements);

#print Dumper(\@elements);
#while (my @res = $p->next) {
#	my %mappings;
#	for my $i (0 .. $#res) {
#		$mappings{$res[$i]} = $elements[$i];
#	}
#
#	print Dumper(\%mappings);
#
#	last;
#}

my @elements2 = @elements;

permute {
	my %mappings = qw( e e );
	for my $i (0 .. $#elements) {
		$mappings{$elements[$i]} = $elements2[$i];
	}

	my @items2 = @items;
	for (@items2) {
		s/\A(\w)/$mappings{$1}/;
	}

	print Dumper(\@items2);

} @elements;
