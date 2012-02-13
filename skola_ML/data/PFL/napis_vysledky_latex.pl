use warnings;
use strict;

my $wantword = $ARGV[0];

my %all;
for my $result_filename (<results/*.result.*>) {
    my ($way, $word) = $result_filename =~ m{results/(.*)\.result\.(.*)};
    use File::Slurp;
    my $res = 0+read_file("$result_filename");
    if ($word eq $wantword){
        my ($type, $feat, $par) = split (/\./, $way);
        $feat =~ s/_/ /;
        my $se=sqrt($res*(1-$res)/30);
        my $low_int= sprintf("%.7f", ($res-1.96*$se));
        my $high_int= sprintf("%.7f", ($res+1.96*$se));
        $all{ $type." & ".$feat." & ".$par." & ".$res." & $low_int & $high_int ".'\\\\ \hline'} = $res;
    }
}

for (sort {$all{$b} <=> $all{$a}} keys %all) {
    print $_."\n";
}
