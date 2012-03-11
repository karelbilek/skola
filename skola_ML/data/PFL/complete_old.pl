use strict;
use warnings;

mkdir "current_results";

mkdir "results";

sub run_sys {
    my $w = shift;
    print "PRIKAZ - ".$w."\n";
    system($w);
}

for my $sloveso qw(ally arrive cry halt plough submit) { 
    for my $type qw(bagging boosting SVM DT bayes) {
       
        my $print_as_YESNO = ($type eq "bayes")? "yes" : "no";

        SEARCH_STYLE:
        for my $feature_search_style qw(evolution cut_2 cut_5 cut_10 cut_20
                                        cut_50 cut_70) {
            if ($feature_search_style eq "evolution") {
                #I DON'T use evolution with bagging/boosting
                #it's too slow
                next SEARCH_STYLE if ($type eq "bagging" or $type eq "boosting");

                #first I have to process the files into all_data
                run_sys("perl transform.pl $sloveso 3 no $print_as_YESNO > current_results/all_data");

                #then, I need to select the right feature vectors by running evolutionary
                #algorithm
                #(this calls R, but also needs CPAN's AI::Genetic module)
                run_sys("perl evoluce.pl $type");
                run_sys ("cp current_results/feature_took_final ".
                    "results/$type.features.$sloveso");
             } else {
                
                my ($cut_size) = $feature_search_style=~/cut_(.*)$/;
            
                run_sys("perl transform.pl $sloveso $cut_size yes ".
                                "$print_as_YESNO > current_results/all_data");

               
             }

            #0 - no tuning, simply try the default parameters
            #1 - default tuning (with svm and rpart)
            #2 - my own grid search tuning
            TUNE_STYLE:
            for my $param_tune_style (0,1,2) {
                if ($param_tune_style == 0) {                
                    run_sys("R --no-save --args $type < jednoduchy_try.R");
                } elsif ($param_tune_style == 1) {
                    next TUNE_STYLE if ($type ne "SVM" and $type ne "DT");

                    run_sys("R --no-save --args $type < easytune_try.R");
                } else {
                    #grid searching - all except bayes that has no parameters
                    next TUNE_STYLE if ($type eq "bayes");
                    
                    #then, with the feature set, I need to find the best parameters
                    run_sys("R --no-save --args $type < muj_grid_search.R");

                    #and, in the end, I just use the found parameters to one final testing
                    run_sys("R --no-save --args $type < muj_grid_final.R");
                    
    
                }

                run_sys ("cp current_results/test_result ".
                    "results/$type.$feature_search_style.$param_tune_style.result.$sloveso");
                run_sys ("cp current_results/feature_took_final results/$type.feats.$sloveso");
                run_sys ("cp current_results/best_options results/$type.muj_search.opts.$sloveso");
                    
            }
          

        }


    }
}
