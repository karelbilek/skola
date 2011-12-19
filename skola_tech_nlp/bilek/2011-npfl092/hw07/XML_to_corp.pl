#!/usr/bin/env perl
use warnings;
use strict;
use 5.010;

use XML::Twig;

my $twig = XML::Twig->new( twig_handlers => { sentence=>\&handle_sentence});

$twig->parsefile( 'corpus.xml');
$twig->purge;

binmode(STDOUT, ":utf8");

sub handle_sentence {
    my ($twig, $section)= @_;

    my $i = 1;
    my @tokens = $section->getElementsByTagName("token");
    for my $token (@tokens) {
        print $i;
        print "\t";

        #sadly, I don't have a clue why I have to use encode, but I do :/
        use Encode;
        print encode("utf8", $token->first_child("form")->xml_string());
        print "\t";
        
        print encode("utf8", $token->first_child("lemma")->xml_string());
        
        print "\t";
        
        my %atts = %{$token->atts};
        print $atts{pos};
        print "\t";


        delete $atts{pos};
        my $rest = join ("|", map {exists $atts{$_}?$_."=".$atts{$_}:()}
                qw(postype gen num person mood tense contracted punct
                    posfunction punctenclose case));
                    #this is NOT needed at all, but I want the same output in sample0
                    #and this script
        

        if ($rest eq "") {$rest = "_"}
        print $rest;
        print "\n";
    } continue {
        $i++;
    }
    say "";
    $section->purge;
}
