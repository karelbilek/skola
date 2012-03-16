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

my %settings = (type=>'2', model=> 'SVM', options => 
    '"scale" "kernel" "degree" "gamma" "coef0" "cost" "shrinking" "probability"
    "1379" TRUE "polynomial" 2 0.1 1 1 TRUE TRUE');

use File::Slurp;

write_file("current_results/options_$paral", $settings{options}."\n");


run_sys("perl transform_bigger.pl $word 1 $paral no >".
    " current_results/all_data_$paral");

use File::Slurp;
my $count = read_file("current_results/feature_count_$paral");

my %did;
sub write_out {
    my $what = shift;
    my $where = shift;

    my $to_write;
    for (@$what) {
        if ($_) {
            $to_write.="1 ";        
        } else {
            $to_write.="0 ";
        }
    }

    open my $outf, ">", $where;
    print $outf $to_write."\n";
    close $outf;
    
    return $to_write;
}

sub do_experiment {
    my $array = shift;
    my $to_write = write_out($array, "current_results/feature_took_$paral");
    if (exists $did{$to_write}) {return $did{$to_write}}
    
    system("rm current_results/experiment_output_$paral");
    system ( "R --no-save --args ".
            $settings{model}." ".
            $settings{type}.
            " current_results/all_data_$paral current_results/options_$paral".
            " current_results/experiment_output_$paral".
            " current_results/feature_took_$paral < secondstep.R");
    
    if (!-e "current_results/experiment_output_$paral") {
        die "DEATH TO AMERICA";
    }
    open my $inf, "<", "current_results/experiment_output_$paral";
    my $line = <$inf>;
    close $inf;
    chomp $line;
    
    $did{$to_write}=0+$line;
    return 0+$line;
}

say "Zacatek";
my $best_result = 0;
my $best_features = "";
for my $iteration (0..100) {
    my @features = (1);
    push @features, (0)x($count - 1);

   my $count = int(rand(100))+10;
    my $step = (scalar (@features)-1) / $count;

    my $current_state = do_experiment(\@features);
  
    use List::Util qw(shuffle);
    for my $i (shuffle(0..$count)) {
        my @copied_features = @features;
        for my $j ($i*$step.. ($i+1)*$step) {
            $copied_features[$j]=1 if ($j>0 and $j < scalar @features);
        }

        my $new_state = do_experiment(\@copied_features);
        if ($new_state >= $current_state) {
            say "na $i je  zlepseni, new state je $new_state";
            $current_state = $new_state;
            @features = @copied_features;
        } else {
            say "na $i  nic nezlepsi";
        }
    }
    if ($current_state > $best_result) {
        say "Tato iterace zlepsila, je to $current_state";
        $best_result = $current_state;
        $best_features = \@features;
    } else {
        say "Tato iterace zlepsila prd.";
    }
}
say "Best stav je $best_result.";
write_out($best_features, "results/itero_feats_$word");
