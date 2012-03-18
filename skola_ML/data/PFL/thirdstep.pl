use 5.010;
use warnings;
use strict;

my $word = $ARGV[0];

my $paral = $ARGV[1];

sub run_sys {
    my $w = shift;
    print "PRIKAZ - ".$w."\n";
    system($w);
}

my %settings_for_word = (ally=>{type=>'2', model=> 'SVM', options => 
    '"scale" "kernel" "degree" "gamma" "coef0" "cost" "shrinking" "probability"
    "1379" TRUE "polynomial" 2 0.1 1 1 TRUE TRUE'},
    );
my %settings = %{$settings_for_word{$word}};

use File::Slurp;

write_file("current_results/options_$paral", $settings{options}."\n");


run_sys("perl transform_bigger.pl $word 1 $paral no >".
    " current_results/all_data_$paral");

    
system("rm current_results/experiment_output_$paral");
system ( "R --no-save --args ".
        $settings{model}." ".
        $settings{type}.
        " current_results/all_data_$paral current_results/options_$paral".
        " results/itero_feats_$word ".
        " results/final_model_$word.RData < thirdstep.R");
