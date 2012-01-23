use strict;
use warnings;

mkdir "current_results";

my $sloveso=$ARGV[0];
my $type = $ARGV[1];

#first I have to process the files into all_data
system("perl transform.pl $sloveso > current_results/all_data");

#then, I need to select the right feature vectors by running evolutionary
#algorithm
#(this calls R, but also needs CPAN's AI::Genetic module)
system("perl evoluce.pl $type");

#then, with the feature set, I need to find the best parameters
system("R --no-save --args $type < muj_grid_search.R");

#and, in the end, I just use the found parameters to one final testing
system("R --no-save --args $type < muj_grid_final.R");

mkdir "results";
system ("mv test_result results/$type.muj_search.perc.$sloveso");
system ("mv current_results/feature_took_final results/$type.feats.$sloveso");
system ("mv current_results/best_options results/$type.muj_search.opts.$sloveso");
