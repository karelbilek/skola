use strict;
use warnings;

mkdir "current_results";

mkdir "results";

sub run_sys {
    my $w = shift;
    print "PRIKAZ - ".$w."\n";
    system($w);
}

my $sloveso = $ARGV[0];
my $parallel = $ARGV[1];
my $alldataname = "current_results/all_data_".$parallel;
my $resultname = "current_results/test_result_$parallel";
my $options = "current_results/options_$parallel";
my $features = "results/itero_feats_$sloveso";

#for my $sloveso qw(submit) { 
#for my $sloveso qw(ally arrive cry halt plough submit) { 
    TYPE:
    for my $type qw(SVM bayes bagging boosting DT) {
#            next TYPE if !($sloveso ne "ally" or ($type eq "DT" or $type eq
 #           "SVM"));

        my $print_as_YESNO = ($type eq "bayes")? "yes" : "no";
        run_sys("perl transform.pl $sloveso 1 no $print_as_YESNO> $alldataname");

        #0 - no tuning, simply try the default parameters
        #1 - default tuning (with svm and rpart)
        #2 - my own grid search tuning
        TUNE_STYLE:
        #for my $param_tune_style (2) {
        for my $param_tune_style (0,1,2) {
            if ($param_tune_style == 0) {                
                run_sys("R --no-save --args $type $alldataname $features".
                    " $resultname < firststep_0_again.R");
            } elsif ($param_tune_style == 1) {
                next TUNE_STYLE if ($type ne "SVM" and $type ne "DT");

                run_sys("R --no-save --args $type $alldataname $features".
                    " $resultname < firststep_1_again.R");
            } else {
                #grid searching - all except bayes that has no parameters
                next TUNE_STYLE if ($type eq "bayes");


                run_sys("R --no-save --args $type $alldataname $features $resultname".
                    " $options < firststep_2_again.R");

                #and, in the end, I just use the found parameters to one final testing
                #run_sys("R --no-save --args $type < muj_grid_final.R");
                
                run_sys ("mv $options results/$type.muj_search2.opts.$sloveso");

            }

            run_sys ("mv $resultname ".
                "results/$type.$param_tune_style.result2.$sloveso");
               #die "here"; 
        }
        #die "gere";

    }
#}
