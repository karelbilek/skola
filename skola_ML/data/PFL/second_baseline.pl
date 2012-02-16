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

my $sloveso = $ARGV[0];
   
   say $sloveso;
       run_sys("perl transform.pl $sloveso 3 yes no > current_results/all_data");
       run_sys("R --no-save < second_baseline.R");
#

