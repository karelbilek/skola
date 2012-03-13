use strict;
use warnings;

mkdir "current_results";

mkdir "results";

sub run_sys {
    my $w = shift;
    print "PRIKAZ - ".$w."\n";
    system($w);
}

#my $sloveso = $ARGV[0];
#{
for my $sloveso qw(ally arrive cry halt plough submit) { 
    for my $type qw(SVM bayes bagging boosting DT) {
       
        my $print_as_YESNO = ($type eq "bayes")? "yes" : "no";
        run_sys("perl transform.pl $sloveso 1 no $print_as_YESNO > current_results/all_data");

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
                
                run_sys("R --no-save --args $type < muj_grid_try.R");

                #and, in the end, I just use the found parameters to one final testing
                #run_sys("R --no-save --args $type < muj_grid_final.R");
                

            }

            run_sys ("cp current_results/test_result ".
                "results/$type.$param_tune_style.result.$sloveso");
            run_sys ("cp current_results/best_options results/$type.muj_search.opts.$sloveso");
               #die "here"; 
        }
        die "gere";

    }
}
