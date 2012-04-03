use warnings;
use strict;
use 5.010;

use utf8;
binmode(STDOUT, ":utf8");

open my $slavnost_file, "<:utf8", "zahradni-slavnost.txt";

my %utterances;


sub add_utterance {
    my $person = shift;
    my $utterance = shift;
    if (defined $utterance) {
        $utterance =~ s/\([^)]*\)//g;
        my @sentences = split (/\s*[.!?–]+\s*/, $utterance);
        for my $sentence (@sentences) {
            $utterances{$sentence}{$person} = 1;
        }
    }
}

my $current_utterance;
my $current_person;

READ:
while (my $line = <$slavnost_file>) {
    chomp $line;
    $line =~ s/\r//g;
    $line =~ s/\f//g;
    if ($line =~ /^([[:upper:]]+) (?:\([^(]*\) )?(.+)$/ and $1 ne "A") {
        add_utterance($current_person, $current_utterance);

        $current_person = $1;
        $current_utterance = $2;

        
    }else {
        $current_utterance .= $line;
    }

}


for my $sentence (keys %utterances) {
     if (scalar keys %{$utterances{$sentence}} > 1) {
         print "Vetu $sentence rikaji: ";
         for my $person (keys %{$utterances{$sentence}}) {
             print $person." ";
         }
         print "\n";
    }

}
