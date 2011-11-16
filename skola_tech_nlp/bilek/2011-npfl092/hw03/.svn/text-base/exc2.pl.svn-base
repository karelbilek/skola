#!/usr/bin/env perl
use warnings;
use strict;
#use 5.014;

my $hash={jedna=>1, dva=>2, tri=>3};


sub printhash{
	#kdyby slo o perl 5.14, slo by tohle
	#while  ( my ($k, $v) = each $_[0] ) {
	while ( my ($k, $v) = each %{$_[0]} ) {
		print $k."\t".$v."\n";
	}
}

sub printhash2 {
	print map {$_."\t".$hash->{$_}."\n"} keys %{$_[0]};
}

printhash2($hash)

