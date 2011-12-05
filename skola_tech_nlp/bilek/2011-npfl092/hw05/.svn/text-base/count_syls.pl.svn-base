#!/usr/bin/env perl

use strict; use warnings;
use 5.010;

use Readonly;
use utf8;
binmode (STDIN, ":utf8");
binmode (STDOUT, ":utf8");

#reading words from STDIN
my $whole;
while (my $line = <STDIN>) {
    my $count = 0;

    my $controll = "";

    Readonly my @words => split / /, $line;
    for my $word (@words) {

        #every vowel is a syllable...
        while ($word =~ /([aeiouyáéíúóúýůě])/gi) {
            $count++;
            $controll.= $1."|";
        }

        #...except for au, eu or ou
        while ($word =~ /au|eu|ou/gi) {
            $count--;
        }

        #l and r are syllables when surrounded by consonants
        while ($word =~ /[^aeiouyáéíúóúýůě]([lr])[^aeiouyáéíúóúýůě]/gi) {
            $count++;
            $controll.=$1."|";
        }
    }

    say $controll;

    #Counting both whole number and on one line
    say "on this line - $count";
    $whole += $count;
    say "whole - $whole";
}


