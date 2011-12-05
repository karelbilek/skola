#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;
use Readonly

binmode (STDOUT, ":utf8");
say '<?xml version="1.0" encoding="utf-8" ?>';
say '<!DOCTYPE corpus SYSTEM "corpus.dtd">';
say '<corpus language="czech">';

Readonly my %longer_gender_of => (
    F=>"feminine", 
    H=>"feminine_or_neuter",
    I=>"masculine_inanimate",
    M=>"masculine_animate",
    N=>"neuter",
    Q=>"feminine_or_neuter",
    T=>"masculine_inanimate_or_feminine",
    X=>"any",
    Y=>"masculine",
    Z=>"not_feminine");

Readonly my %longer_pos_of => qw(
    A   adjective 
    C   numeral 
    D   adverb 
    I   interjection 
    J   conjunction 
    N   noun 
    P   pronoun 
    V   verb 
    R   preposition 
    T   particle 
    X   unknown 
    Z   punctuation);

Readonly my %longer_number_of => qw(
    D   dual 
    P   plural 
    S   singular 
    W   singular
    X   any);

Readonly my %longer_case_of => qw(
    1   nominative 
    2   genitive 
    3   dative 
    4   accusative 
    5   vocative 
    6   locative 
    7   instrumental 
    X   any
);

Readonly my %longer_person_of => qw(
    1   1 
    2   2 
    3   3 
    X   any
);

open my $corpus_file, "<:utf8", "corpus.txt";
while (my $line = <$corpus_file>) {
    chomp $line;
    my ($form, $lemma, $pos_short, $gender_short, $number_short, $case_short,
        $person_short) = $line =~ m{([^/]*)/([^/]*)/(.).(.)(.)(.)..(.)};
    
    my $description = 'pos="'.$longer_pos_of{$pos_short}.'"';
    if (exists $longer_gender_of{$gender_short}) {
        $description .= ' gender="'.$longer_gender_of{$gender_short}.'"';
    }
    if (exists $longer_number_of{$number_short}) {
        $description .= ' number="'.$longer_number_of{$number_short}.'"';
    }
    if (exists $longer_case_of{$case_short}) {
        $description .= ' case="'.$longer_case_of{$case_short}.'"';
    }
    if (exists $longer_person_of{$person_short}) {
        $description .= ' person="'.$longer_person_of{$person_short}.'"';
    }
    say "   <token $description>";
    say "       <form>$form</form>";
    say "       <lemma>$lemma</lemma>";
    say '   </token>';
}

say '</corpus>';

