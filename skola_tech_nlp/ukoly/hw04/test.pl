use warnings;
use strict;

use Verb::English;

use Test::More tests=>1;

my @words = (qw(lay see die moan move lie please beg force sneeze));

my @pasts = map {
    my $verb = new Verb::English(infinitive=>$_); 
    $verb->past_tense;
} @words;

my @should_be 
= qw(laid saw died moaned moved lay pleased begged forced sneezed);

is_deeply(\@pasts, @should_be, "Pasts tenses working fine.");
