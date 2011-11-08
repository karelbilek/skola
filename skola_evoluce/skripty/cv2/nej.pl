use warnings;
use strict;

sub forall {
	my $wat = shift;
	my $endung = shift;
	for my $fname (<vysledky/cv2/progress_2*>) {
		open my $if, "<", $fname;
		my @arr = <$if>;
		my $last = $arr[-1];
		my $first = 0+((split(/ /, $last))[0]);
		$wat->($first, $fname);
	}
	$endung->();
	
}


my $min = 999999;
my $infmin;
my $max = -999999;
my $infmax;
forall (sub {
	my $first = shift;
	my $fname = shift;
	if ($first < $min) {$min = $first;$infmin=$fname}
	if ($first > $max) {$max = $first;$infmax=$fname}
}, sub {

print "MIN = $min, NAME=$infmin\n";
print "MAX = $max, NAME=$infmax\n";
});

sub partsub {
	my $w = shift;
	return otherpartsub($w, sub{return $_[$w]});
}

sub otherpartsub {
	my $wat = shift;
	my $s = shift;
	my %sums;
	my %sizes;
	return (sub {
		my $first = shift;
		my $fname = shift;
		my @arr = split(/_/,$fname);
		shift @arr;
		my $w = $s->(@arr);
		if (defined $w) {
			$sizes{$w}++;
			$sums{$w}+=$first;
		}
	}, sub {
		use 5.010;
		say "$wat\n<table>";
		for (sort {($sums{$a}/$sizes{$a})<=>($sums{$b}/$sizes{$b})} keys %sums) {
			use 5.010;
			say "<tr><td>".$_."</td><td>".($sums{$_}/$sizes{$_})."</td></tr>";
		}
		say"</table>";
	});

}





forall(partsub(1));
forall(partsub(2));
forall(otherpartsub("3_2_prvni", sub{if ($_[2]!="2") {return undef;} my @k=split(/-/, $_[3]); return ($k[0]/($_[1]));}));
forall(otherpartsub("3_2_druhy", sub{if ($_[2]!="2") {return undef;} my @k=split(/-/, $_[3]); return $k[1];}));
forall(otherpartsub("3_3",  sub{if ($_[2]!="3") {return undef;}  return $_[3];}));
forall(partsub(4));
forall(otherpartsub("5_2_prvni", sub{if ($_[4]!="2") {return undef;} my @k=split(/-/, $_[5]); return ($k[0]/($_[1]));}));
forall(otherpartsub("5_2_druhy", sub{if ($_[4]!="2") {return undef;} my @k=split(/-/, $_[5]); return $k[1];}));
forall(otherpartsub("5_3",  sub{if ($_[4]!="3") {return undef;}  return $_[5];}));
forall(partsub(6));
forall(partsub(7));
