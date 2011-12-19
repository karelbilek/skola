#!/usr/bin/env perl
use warnings;
use strict;

use 5.010;
use MyTagger;

sub get_test_data {
    my $test_size = shift;

    my @test_data;
    open my $corpus_file, "<:encoding(iso-8859-2)", "textcz2.ptg";
    READ:
    while (my $line = <$corpus_file>) {
        chomp $line;
        my ($word, $tag) = $line =~ m{([^/]*)/(.)};
        push @test_data, [$word, $tag];
        last READ if (scalar @test_data == $test_size); 
    }
    close $corpus_file;

    system("tail -n +".($test_size+1)." textcz2.ptg > textcz2_all_train.ptg");
    return @test_data;
}

sub evaluate {
    my $train_size = shift;
    my @test_data = @_;
    my @test_words = map {$_->[0]} @test_data;
    my @test_tags = map {$_->[1]} @test_data;

    system("head -$train_size textcz2_all_train.ptg > textcz2_train_$train_size.ptg");

    MyTagger::train("iso-8859-2", "textcz2_train_$train_size.ptg");

    my @told_tags = MyTagger::tag(@test_words);
    my $same = scalar grep {$test_tags[$_] eq $told_tags[$_]} (0..$#test_tags);

    return $same;
}

open my $count_tex_file, ">", "count.tex";

my $test_size = 100;
my @test_data = get_test_data($test_size);
for my $train_size (qw(1 10 100 1000 10000 100000 384000)){
    my $correct = evaluate($train_size, @test_data);
    say $count_tex_file $train_size." & ".($correct/$test_size)." \\\\";
}

close $count_tex_file;
