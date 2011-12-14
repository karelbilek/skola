use strict;
use warnings;
use 5.010;

use AI::Genetic;
my $ga = new AI::Genetic(
    -fitness    =>  \&do_experiment ,
    -type       => 'bitvector',
    -population => 50,
    -crossover  => 0.9,
    -mutation   => 0.01,
    -terminate  => sub { say "Wow. Konec. Nejvic fit je".
        $_[0]->getFittest->score;return 0 },
);

my $pokusy=0;
sub do_experiment {
    my $array = shift;
    $pokusy++;
    my $to_write;
    for (@$array) {
        if ($_) {
            $to_write.="1 ";        
        } else {
            $to_write.="0 ";
        }
    }
    open my $outf, ">", "feature_took";
    print $outf $to_write."\n";
    close $outf;
    say "Dalsi pokus.";
    system" R --no-save <skript.R >/dev/null";
    open my $inf, "<", "experiment_output";
    my $line = <$inf>;
    close $inf;
    chomp $line;
    say "Zatim vysledek ".(0+$line);
    mkdir "pokusy";
    system "cp feature_took pokusy/$pokusy";
    say "Platilo u $pokusy";
    $pokusy++;
    return 0+$line;
}

#my @w;
#for (1..283){push @w, int(rand(2))}
#print do_experiment(\@w);
$ga->init(283);
$ga->evolve('rouletteTwoPoint', 10);

