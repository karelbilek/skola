use warnings;
use strict;

my $wantword = $ARGV[0];

for my $result_filename (<results/*.result.*>) {
    my ($way, $word) = $result_filename =~ m{results/(.*)\.result\.(.*)};
    use File::Slurp;
    my $res = read_file("$result_filename");
    chomp $res;
    my ($size, $error) = $res =~ /^(\S+)\s+(\S+)$/;
    if (length($way) < 6) {$way.=" "x(6-length($way))}
    print $way."\t".$word."\t".$size."\t".$error."\t".($size +
    $error)."\t".($size - $error)."\n" if ($word eq $wantword);
}
