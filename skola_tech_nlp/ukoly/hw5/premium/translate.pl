use warnings;
use strict;

binmode (STDOUT, ":utf8");

sub do_for_all_paradata {
    my $sub_ref = shift;
    open my $paradata, "<:utf8", "paradata.txt";
    while (my $line = <$paradata>) {
        chomp($line);
        my ($czech, $english) = $line =~ /(.*)\t(.*)/;

        my @czech_split = split /[\s[:punct:]]+/, $czech;
        my @english_split = split /[\s[:punct:]]+/, $english;
        
        $sub_ref->(\@czech_split, \@english_split, $czech, $english);
    }
}


my %probability_of_czech_english_translation;

do_for_all_paradata(sub {
    
    my ($czech_split_ref, $english_split_ref, $czech, $english) = @_;

    my $i = ((scalar @$czech_split_ref) * (scalar @$english_split_ref))**2;

    for my $czech (@$czech_split_ref) {
        for my $english (@$english_split_ref) {
            $probability_of_czech_english_translation{$czech."\t".$english}+=1/$i;
        }
    }
});

my @best = sort {$probability_of_czech_english_translation{$b} <=>
  $probability_of_czech_english_translation{$a}} keys
  %probability_of_czech_english_translation;

use 5.010;
for (@best[0..200]) {
    say $_;
}
  

