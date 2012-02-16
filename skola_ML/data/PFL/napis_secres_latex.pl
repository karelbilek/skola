use warnings;
use strict;

my $wantword = $ARGV[0];
my %all;
for my $result_filename (<results/*.secres.*>) {
    my ($way, $word) = $result_filename =~ m{results/(.*)\.secres\.(.*)};
    use File::Slurp;
    my $res = 0+read_file("$result_filename");
    if ($word eq $wantword){
        my ($type, $feat, $par) = split (/\./, $way);
        $feat =~ s/_/ /;
        my $se=sqrt($res*(1-$res)/30);
        $all{ $type." & ".$feat." & ".$par." & ".$res.'\\\\ \hline'} = $res;
    }
}

for (sort {$all{$b} <=> $all{$a}} keys %all) {
    print $_."\n";
}
