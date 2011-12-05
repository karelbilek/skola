#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use Readonly;


open my $english_file, "<", "english.0" or die "canot open english.0";

#For lines that has been read already will hold all longer string for every
#substring.
#(This is here partly because I misread the homework originally and thought
#that we need to print all the pairs of substring<->string, it may be a little
#overkill if all we need is just the substrings.)
my %longer_string_of_substring;

#All the words that has been read already. In hash, so the lookup is faster.
my %words;

#The results. In hash, so it's not repeated unnecessarily.
my %results;


#Read every line and destroy newlines and carriage returns.
while (my $word = <$english_file>) {
    chomp $word;
    $word =~ s/\r//; 

    #For every read word, check if it's not a substring of previously read
    #word
    #(note - add_to_results check the 's and s)
    if (exists $longer_string_of_substring{$word}) {
        for (@{$longer_string_of_substring{$word}}){
            add_to_results($word, $_);
        }
    }

    #Remember the word that has been read.
    $words{$word} = undef;

    #Remember all the substrings of the word that has been read;
    #also, check if some substring of a current word is not a word that has been
    #read before
    for my $word_substring (all_substrings($word)) {
        if (exists $words{$word_substring}) {
            add_to_results($word_substring, $word);
        }
        push @{$longer_string_of_substring{$word_substring}}, $word;
        
    }
    
}

#Give me the results!
#(the sorting is unnecessary, but it's quick and makes the results better to read)
for (sort keys %results) {say $_}

#Returns all the substrings of a string
#(including the 's and s substrings, not including the word itself)
#The substrings are not repeated
sub all_substrings {
    my @unfiltered_substrings;

    #$left_substring is something that "begins" with the word
    #but "ends sooner"
    #(example: Afric from Africans)
    my $left_substring = shift;
    while (length $left_substring > 0) {
        
        #right_substring "ends" with the left substring
        #but "begins" sooner
        #(example: Afric, fric, ric ...) 
        my $right_substring = $left_substring;
        while (length $right_substring>0) {
            push @unfiltered_substrings, $right_substring;
            $right_substring = substr $right_substring, 1;
        }
        $left_substring = substr $left_substring, 0, -1;
    }

    #Deletes the word itself
    shift @unfiltered_substrings;

    #filters the repeated substrings
    my %filtered_substrings;
    @filtered_substrings{@unfiltered_substrings} = ();
    return keys %filtered_substrings;
}

#Checks s and 's and add it to results
sub add_to_results {
    my ($shorter, $longer) = @_;
    
    #I would guess this is slightly quicker than regex
    if ($longer ne $shorter."'s" and $longer ne $shorter."s") {
        $results{$shorter} = undef;
    }
}
