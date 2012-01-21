use strict;
use warnings;

mkdir "current_results";

my $sloveso=$ARGV[0];
#first I have to process the files into all_data
system("perl transform.pl $sloveso > current_results/all_data");

#then, I need to select the right feature vectors by running evolutionary
#algorithm
#(this calls R, but also needs CPAN's AI::Genetic module)
system("perl evoluce.pl");

#then, with the feature set, I need to find the best parameters
system("R --no-save <skript_step2.R");

#and, in the end, I just use the found parameters to one final testing
system("R --no-save <skript_step3.R");

mkdir "results";
system("mv test_result results/perc_$sloveso");
system("mv feature_took_final results/feats_$sloveso");
system("mv best_possibilities results/poss_$sloveso");
