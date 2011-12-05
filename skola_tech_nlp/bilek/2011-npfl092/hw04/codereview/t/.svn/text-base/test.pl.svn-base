use MyTagger;
use Test::More tests=>1;

no warnings qw(qw);
my @slova = qw ( My Little Pony : Friendship Is Magic is an animated television
series that premiered on October 10 , 2010 on the United States cable network
The Hub , and is based on Hasbro's My Little Pony line of dragon toys and
animated works. );

my @tagged = posTagger( @slova );

my @correct = qw(P undecided undecided Punc undecided V undecided V Art V
undecided V P V Prep N undecided Art undecided Prep Art V V Adj undecided Art
undecided Art Conj V V Prep undecided P undecided undecided undecided Prep
undecided V Conj V undecided);

is_deeply(\@correct, \@tagged, "example tagged OK");



