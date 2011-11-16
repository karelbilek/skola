#!/usr/bin/env perl
use MyTagger;
use Test::More tests => 3;
use warnings;
use strict;

require LWP::UserAgent;
LWP::UserAgent->new->get('http://ufal.mff.cuni.cz/~hajic/courses/npfl067/textcz2.ptg', ':content_file'   => "textcz2.ptg");

MyTagger::train("iso-8859-2", "textcz2.ptg");

open my $TOP_LINES, "<", "top_endings" or die "Cannot open top_lines";

chomp(my $line = <$TOP_LINES>);

is($line, ".\tZ", "First line of top_lines OK");

chomp($line = <$TOP_LINES>);

is($line, "##\t#", "Second line of top_lines OK");

use utf8;
my @sentence = qw(Romové podle něj žijí na hranici chudoby , bezmála 70 procent z nich bydlí v holobytech .);

#neni rozhodne spravna, je spravna 'podle me'
my @my_version = qw(A R P V R N N Z V C N R P N R A Z);

my @tags = MyTagger::tag(@sentence);
is_deeply(\@tags, \@my_version, "resulting tags OK");
