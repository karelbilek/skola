use warnings;
use strict;

my $word = $ARGV[0];

my %settings_for_word = (
    ally=>{type=>'2', model=> 'SVM', options => 
    '"scale" "kernel" "degree" "gamma" "coef0" "cost" "shrinking" "probability"
    "1379" TRUE "polynomial" 2 0.1 1 1 TRUE TRUE'},
);

sub run_sys {
    my $w = shift;
    print "PRIKAZ - ".$w."\n";
    system($w);
}


my %settings = %{$settings_for_word{$word}};

use File::Slurp;

write_file("current_results/options", $settings{options}."\n");


run_sys("perl transform_bigger.pl $word 1 yes no > current_results/all_data");
run_sys("perl evoluce.pl ".$settings{model}." ".$settings{type});


#run_sys( "R --no-save --args ".
#            $settings{model}." ".
#            $settings{type}.
#            " current_results/all_data current_results/options resfile featuresfile < secondstep.R");
