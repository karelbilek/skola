use warnings;
use strict;
use 5.010;

my %diffs;
my %texts;

mkdir "without_whitespace";
mkdir "without_whitespace/data";
for my $file (<data/*>) {
    system("cat $file | tr '\\n' ' '|".q(sed 's/\s//g' ).' > without_whitespace/'.$file);
    use File::Slurp;
    
}

for my $first (<without_whitespace/data/*>) {
    for my $second (<without_whitespace/data/*>) {
       
        if ($first lt $second) {
            
            use File::Slurp;
            my $first_text = read_file($first);
            my $second_text = read_file($second);
            
            use Text::LevenshteinXS  qw(distance);;

            my $diff = distance($first_text, $second_text);
            $diff = 0+$diff;
            
            my $first_copy = $first;
            my $second_copy = $second;
            $second_copy =~ s/without_whitespace\/data\///;
            $first_copy =~ s/without_whitespace\/data\///;
            $diffs{$first_copy."\t".$second_copy} = $diff;
        }
    }
}

for my $files (sort {$diffs{$a} <=> $diffs{$b}} keys %diffs) {
    say $files."\t".$diffs{$files};
}
