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

my %settings = {type=>'2', model=> 'SVM', options => 
    '"scale" "kernel" "degree" "gamma" "coef0" "cost" "shrinking" "probability"
    "1379" TRUE "polynomial" 2 0.1 1 1 TRUE TRUE'};

use File::Slurp;

write_file("current_results/options_$paral", $settings{options}."\n");


run_sys("perl transform_bigger.pl $word 1 $paral no >".
    " current_results/all_data_$paral");

use File::Slurp;
my $count = read_file("current_results/feature_count_$paral");

my @features = (1);
push @features, (0)x($count - 1);

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

my $step = (scalar (@features)-1) / 50;

my $current_state = do_experiment(\@features);
for my $i (0..50) {
    my @copied_features = @features;
    for my $j ($i*$step.. ($i+1)*$step) {
        $copied_features[$j]=1 if ($j>0 and $j < scalar @features);
    }

    my $new_state = do_experiment(\@copied_features);
    if ($new_state >= $current_state) {
        say "na $i je 1 zlepseni, new state je $new_state";
        $current_state = $new_state;
        @features = @copied_features;
    } else {
        say "na $i 1 nic nezlepsi";
    }
}
for my $i (0..0) {
    my @copied_features = @features;
    $copied_features[$i] = 1 - $features[$i];

    my $new_state = do_experiment(\@copied_features);
    if ($new_state >= $current_state) {
        say "na $i je 1 zlepseni, new state je $new_state";
        $current_state = $new_state;
        @features = @copied_features;
    } else {
        say "na $i 1 nic nezlepsi";
    }
}

say "Posledni stav je $new_state.";
write_out(\@features, "results/feats_$word");
