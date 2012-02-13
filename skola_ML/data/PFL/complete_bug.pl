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
    #for my $type qw(bagging boosting SVM DT bayes) {
    for my $type qw(SVM) {
       
        my $print_as_YESNO = ($type eq "bayes")? "yes" : "no";

        SEARCH_STYLE:
        for my $feature_search_style qw(evolution cut_2 cut_5 cut_10 cut_20
                                        cut_50 cut_70) {
            if ($feature_search_style eq "evolution") {
                #I DON'T use evolution with bagging/boosting
                #it's too slow
                next SEARCH_STYLE if ($type eq "bagging" or $type eq "boosting");

                run_sys("perl transform.pl $sloveso 3 no $print_as_YESNO > current_results/all_data");
                run_sys ("cp results/$type.feats.$sloveso ".
                    "current_results/feature_took_final");
             } else {
                
                my ($cut_size) = $feature_search_style=~/cut_(.*)$/;
                run_sys("perl transform.pl $sloveso $cut_size yes ".
                                "$print_as_YESNO > current_results/all_data");

            }

            #0 - no tuning, simply try the default parameters
            #1 - default tuning (with svm and rpart)
            #2 - my own grid search tuning
            TUNE_STYLE:
            for my $param_tune_style (1) {
                run_sys("R --no-save --args $type < easytune_try.R");
                
                run_sys ("cp current_results/test_result ".
                    "results/$type.$feature_search_style.$param_tune_style.result.$sloveso");

                    
            }
          

        }


    }
}
