use strict;
use warnings;

mkdir "current_results";

my $sloveso=$ARGV[0];
my $type = $ARGV[1];
my $binary = ($type eq "SVM") ? "binary" : "";

#first I have to process the files into all_data
system("perl transform.pl $sloveso $binary > current_results/all_data");

#then, I need to select the right feature vectors by running evolutionary
#algorithm
#(this calls R, but also needs CPAN's AI::Genetic module)
system("perl evoluce.pl $type");

#die ":D" if $type eq "bagging";

#then, with the feature set, I need to find the best parameters
system("R --no-save --args $type < muj_grid_search.R");

#and, in the end, I just use the found parameters to one final testing
system("R --no-save --args $type < muj_grid_final.R");

mkdir "results";
system ("cp current_results/test_result results/$type.muj_search.perc.$sloveso");
system ("cp current_results/feature_took_final results/$type.feats.$sloveso");
system ("cp current_results/best_options results/$type.muj_search.opts.$sloveso");
