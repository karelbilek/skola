    use 5.010;
use warnings;
use strict;

my $word = $ARGV[0];

my %settings_for_word = (
    ally=>{type=>'2', model=> 'SVM', options => 
    '"scale" "kernel" "degree" "gamma" "coef0" "cost" "shrinking" "probability"
    "1379" TRUE "polynomial" 2 0.1 1 1 TRUE TRUE'},
    arrive=>{type=>'2', model=>'SVM', options=>
'"scale" "kernel" "degree" "gamma" "coef0" "cost" "shrinking" "probability"
"699" TRUE "polynomial" 1 0.5 0 0.5 TRUE TRUE'},
);

sub run_sys {
    my $w = shift;
    print "PRIKAZ - ".$w."\n";
    system($w);
}


my %settings = %{$settings_for_word{$word}};

use File::Slurp;

write_file("current_results/options", $settings{options}."\n");


run_sys("perl transform_bigger.pl $word 1 yes no > current_results/all_data");
#JOrun_sys("perl evoluce.pl ".$settings{model}." ".$settings{type});

#JOrun_sys("mv current_results/evolution_feature_took_final ".
#JO    "results/evolution.$word.features");

use File::Slurp;
my $count = read_file("current_results/feature_count");

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
    my $to_write = write_out($array, "current_results/feature_took");
    if (exists $did{$to_write}) {return $did{$to_write}}
    
    system("rm current_results/experiment_output");
    system ( "R --no-save --args ".
            $settings{model}." ".
            $settings{type}.
            " current_results/all_data current_results/options".
            " current_results/experiment_output".
            " current_results/feature_took < secondstep.R");
    
    if (!-e "current_results/experiment_output") {
        die "DEATH TO AMERICA";
    }
    open my $inf, "<", "current_results/experiment_output";
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

#run_sys( "R --no-save --args ".
#            $settings{model}." ".
#            $settings{type}.
#            " current_results/all_data current_results/options resfile featuresfile < secondstep.R");
