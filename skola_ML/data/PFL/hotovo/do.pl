use warnings;
use strict;

my $training_file = $ARGV[0];
my $testing_file = $ARGV[1];
my $word = $ARGV[2];

my %settings = (
    ally=>{type=>'bagging', cut=>20},
    arrive=>{type=>'boosting', cut=>50},
    cry=>{type=>'boosting', cut=>5},
    halt=>{type=>'bagging', cut=>5},
    plough=>{type=>'boosting', cut=>5},
    submit=>{type=>'bagging', cut=>10},
);

system "perl transform.pl $training_file ".$settings{$word}{cut}." $word > train_data";
system "perl transform.pl $testing_file ".$settings{$word}{cut}." $word > test_data";

system "R --no-save --args ". $settings{$word}{type} ." $word < train_and_test.R";
