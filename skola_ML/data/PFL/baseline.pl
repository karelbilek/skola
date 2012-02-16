use strict;
use warnings;


my $sloveso = $ARGV[0];

system("perl transform.pl $sloveso 3 no no > current_results/all_data");
system("R --no-save < baseline.R");
