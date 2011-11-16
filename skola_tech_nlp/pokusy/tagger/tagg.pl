#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;

my %tags;

open my $IN, "<", "tagger-devel.tsv";
while (<$IN>) {
	chomp;
	/(.*)\t(.*)/;
	$tags{$1}{$2}++;
}

close $IN;

while (<STDIN>) {
	my $line = $_;
	chomp $line;
	if ($line =~ /(.*)\t(.*)/) {
		my $sel;
		if (!exists $tags{$1}) {
			$sel = "N";
		} else {
			my @arr = sort {$tags{$1}{$b} <=> $tags{$1}{$a}} keys %{$tags{$1}};
			$sel = $arr[0];
		}
		say $line."\t".$sel; 
	} else {
		say "";
	}
}
