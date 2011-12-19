use strict;
use warnings;

#my $sloveso=$ARGV[0];
for my $sloveso (qw(ally arrive cry halt plough submit)) {
#first I have to process the files into all_data
system("perl transform.pl $sloveso > all_data_unshuffled");

system("tail -250 all_data_unshuffled|sort -R > all_data_shuffled");
system("head -1 all_data_unshuffled>header");
system("cat header all_data_shuffled>all_data");

system("R --no-save <baseline.R");


mkdir "results";
system("mv baseline_result results/baseline_$sloveso");
}
