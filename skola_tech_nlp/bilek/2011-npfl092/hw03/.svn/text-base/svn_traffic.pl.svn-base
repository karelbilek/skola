#!/usr/bin/env perl
use warnings;
use strict;

use 5.010;


#nutno spustit z adresare hw03
open my $INFILE, "cd ../; svn log -q |";

my %stats;

while (<$INFILE>) {
	if (/^r\d* \| \w* \| 2011-\d*-\d* (\d\d):\d\d:\d\d/) {
		$stats{0+$1}++;
	}
}


for my $h (0..23) {
	say $h."-".($h+1)."\t".($stats{$h}||0);
}

