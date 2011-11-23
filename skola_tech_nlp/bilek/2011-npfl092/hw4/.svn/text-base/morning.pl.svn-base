#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;

use Readonly;

#hash for beginnings and arrays of words
my %words_beginning_with;

#read each line of file
open my $frequency_file, "<", "bnc_freq_10000.txt";
while (my $line = <$frequency_file>) {
	chomp $line;
	Readonly my ($word) => $line =~ /^(.*)\t/;
	next if (!defined $word);

	#splitting into individual letters for creating all 
	#possible beginnings
	my @letters = split //, $word;

	#creating all possible beginnings
	while (scalar @letters > 4) {
		my $joined_letters = join q{}, @letters;
		push @{ $words_beginning_with{$joined_letters} }, $word; 
		pop @letters;
	}
}

#printing the words with the same beginnings
#(I suppose that same beginning, longer than 4 <=> are derived)
for my $words_ref (values %words_beginning_with) {
	if (scalar @$words_ref > 1) {
		say join q{ }, @$words_ref;
	}
}
