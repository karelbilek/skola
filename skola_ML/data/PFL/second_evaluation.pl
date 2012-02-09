use strict;
use warnings;
use 5.010;
mkdir "current_results";

mkdir "results";

sub run_sys {
    my $w = shift;
    print "PRIKAZ - ".$w."\n";
    system($w);
}

for my $sloveso qw(ally arrive cry halt plough submit) {
    open my $results_filehandle, 
        "perl napis_vysledky.pl $sloveso | sort -k 3 -n -r |";
    
    my @all_results = <$results_filehandle>;
    chomp(@all_results);

#    my ($best_score) = $all_results[0] =~ /\s(0\.\d*)$/;

#    my @best_results = grep {$_ =~ /$best_score$/} @all_results;
    my @best_results = @all_results[0..19];
    my @best_configurations = map {/^(.*?)\s/;$1} @best_results;

    for my $configuration (@best_configurations) {
        my ($type, $feature_search_style, $param_tune_style) =
            split (/\./, $configuration);
            run_sys ("cp results/$type.feats.$sloveso current_results/second_features");
            run_sys ("cp results/$type.muj_search.opts.$sloveso ".
                            "current_results/second_options");
            my $print_as_YESNO = ($type eq "bayes")? "yes" : "no";
            if ($feature_search_style eq "evolution") {
                 run_sys("perl transform.pl $sloveso 3 no $print_as_YESNO > current_results/all_data");
            } else {
                my ($cut_size) = $feature_search_style=~/cut_(.*)$/;
                run_sys("perl transform.pl $sloveso $cut_size yes ".
                        "$print_as_YESNO > current_results/all_data");
            }
            run_sys("R --no-save --args $param_tune_style $type <".
                            "second_evaluation.R");
            run_sys ("cp current_results/second_result ".
                   "results/$type.$feature_search_style.$param_tune_style.secres.$sloveso");
##
    }
}

