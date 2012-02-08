use warnings;
use strict;

my $wantword = $ARGV[0];

for my $result_filename (<results/*.result.*>) {
    my ($way, $word) = $result_filename =~ m{results/(.*)\.result\.(.*)};
    use File::Slurp;
    my $res = 0+read_file("$result_filename");
    print $way."\t".$word."\t".$res."\n" if ($word eq $wantword);
}
