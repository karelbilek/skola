#!/usr/bin/env perl

use strict; use warnings;
use 5.010;

use Readonly;
use utf8;
binmode (STDIN, ":utf8");
binmode (STDOUT, ":utf8");

my $whole;
while (my $line = <STDIN>) {
    my $count=0;
    
    Readonly my @words => split / /, $line;

    #for my $word (@words) {
    #    Readonly my @parts => split /[aeiouyáéíóúýůě]+/, $word;
    #
    #    $count += (scalar @parts > 0) ? (scalar @parts) : 1;
    #    say "Slovo $word je rozdeleno na ", join (q{ }, @parts);
    #}

    for my $word (@words) {
        say "Slovo $word";
        while ($word =~ /([aeiouyáéíúóúýůě])/gi) {
            say "Dalsi je $1";
            $count++;
        }

        while ($word =~ /(au|eu|ou)/gi) {
            say "Odecitam $1";
            $count--;
        }

        while ($word =~ /([^aeiouyáéíúóúýůě][lr][^aeiouyáéíúóúýůě])/gi) {
            say "Pricitam $1";
            $count++;
        }


    }

    say $count;
    $whole += $count;
    say "whole - $whole";
}


