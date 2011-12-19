#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;

binmode(STDOUT, ":utf8");
say '<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE corpus SYSTEM "corpus.dtd">';

say '<corpus language="catalan">';

my $last_was_token = 0;

open my $sample_file, "<:utf8", "sample0.txt" or die "cannot open sample0.txt";
while (my $line=<$sample_file>) {
        chomp $line;

        if ($line eq "") {
            say '   </sentence>';
            $last_was_token=0;
        } else {
            if ($last_was_token==0) {
                $last_was_token = 1;
                say '   <sentence>';
            }
            my (undef, $form, $lemma, $pos, $rest) = split (/\t/, $line);
            print  qq(       <token pos="$pos");
            if ($rest ne "_") {
                for my $part (split (/\|/, $rest)) {
                    my ($key, $value) = $part =~ /(.*)=(.*)/;
                    if (!defined $key) {die $part}
                    print qq( $key="$value");
                }
            }
            say ">";
            say "           <form>$form</form>";
            say "           <lemma>$lemma</lemma>";
            say "       </token>";
        }
}

say '</corpus>';
