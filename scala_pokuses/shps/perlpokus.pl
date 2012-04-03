use warnings; use strict;

my $w = 30;
my $sub = sub {print($w."\n")};
$w = 5;
$sub->();
