use strict;
use warnings;
use 5.010;

use AI::Genetic;

my $model = $ARGV[0];
my $stype = $ARGV[1];

my $degen=0;

my $counter_sames;
my $last_gen=0;
my $ga = new AI::Genetic(
    -fitness    =>  \&do_experiment ,
    -type       => 'bitvector',
    -population => 70,
    -crossover  => 0.9,
    -mutation   => 0.5,
    -terminate  => sub {
        $degen++;
        if ($degen==4) {return 1;}
        my $sc = $_[0]->getFittest->score;
        if ($last_gen==$sc) {
            $counter_sames++;
            if ($counter_sames<3) {
                say "Konec podminene generace. Nejvic fit je ".$sc;
                return 0;
            } else{
                return 1;
            }
        }
        $counter_sames = 0;
        $last_gen=$sc;
        say "Konec generace. Nejvic fit je ".$sc;
        return 0 },
);

my %did;
my $pokusy=0;

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
    $pokusy++;
    my $to_write = write_out($array, "current_results/feature_took");
    if (exists $did{$to_write}) {return $did{$to_write}}
    
    system("rm current_results/experiment_output");
    system ( "R --no-save --args ".
            $model." ".
            $stype.
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
    
    say "Zatim vysledek $pokusy -  ".(0+$line);
    
    $did{$to_write}=0+$line;
    return 0+$line;
}

use File::Slurp;
my $count = read_file("current_results/feature_count");

$ga->init($count);
$ga->inject(1, [(1)x$count]);
$ga->evolve('rouletteTwoPoint', 4);
my $l = $ga->getFittest->genes();
write_out($l, "current_results/evolution_feature_took_final");
