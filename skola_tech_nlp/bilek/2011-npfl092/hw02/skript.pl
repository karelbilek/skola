#!/usr/bin/env perl 

#Ukolu rozumim tak, ze vsechny provadene ukoly maji byt udelany v perlu a ne pomoci externich programu
#(tj. nepouzivam wget, cut, paste, nic podobneho)

use warnings;
use strict;
use 5.010;

binmode(STDOUT, ":utf8");

#Otevirani skakalpes delam tolikrat, ze se mi to nechce psat pokazde znovu
sub all_skakalpes(&) {
	my $subref = shift;
	open my $if, "<:utf8", "skakalpes-utf8.txt" or die "neotevrel skakalpes-utf8.txt pro cteni";
	
	while (<$if>) {
		$subref->($_);
	}
}

sub t2 {
	if (!-e "skakalpes-il2.txt") {
		require LWP::UserAgent;
		LWP::UserAgent->new->get('http://ufal.mff.cuni.cz/~zabokrtsky/courses/npfl092/html/data/skakalpes-il2.txt', ':content_file'   => "skakalpes-il2.txt");
	}
}

sub t4 {
	t2;

#	use Encoding;
	
	if (!-e "skakalpes-utf8.txt") {
		open my $if, "<:encoding(iso-8859-2)", "skakalpes-il2.txt" or die "neotevrel skakalpes-il2.txt pro cteni";
		open my $of, ">:utf8", "skakalpes-utf8.txt" or die "neotevrel skakalpes-utf8.txt pro psani";
		while (<$if>) {
			print $of $_;
		}
	}
}


sub t6 {
	my $shutup=shift;
	t4;
	my $c=0;
	all_skakalpes{$c++};
	say $c unless $shutup;
	return $c;
}

sub t7 {
	#problem s poslednimi 15 radky nejde vyresit idealne. 
	#Bud se vsechny budou muset nacist do pameti, nebo se bude muset cist soubor nacist dvakrat, poprve pocitat radky.
	#Ja jsem zvolil druhou moznost.
	my $c = t6(1);
	my $i = 1;
	all_skakalpes{
		no warnings 'exiting';	#kvuli mirne silenemu skakani ze subrutiny pres last :)
		if ($i<=15){print (shift)}
		if ($i==15){last}
		$i++;
	};
	$i=1;
	all_skakalpes {
		no warnings 'exiting';	
		if ($i>=10 and $i<=20){print (shift)}
		if ($i==20){last}
		$i++;
	};

	$i=1;
	all_skakalpes {
		if ($i>$c-15){print (shift)}
		$i++;
	};
}

sub t8 {
	t4;
	all_skakalpes {
		no warnings 'uninitialized';
		say(join " ", (split(/\s+/,shift))[0,1]);
	};
}

sub t9 {
	t4;
	all_skakalpes {
		my $l=shift;
		if ($l=~/\d/){print$l}
	}
}

sub arr {
	t4;
	my @arr;
	all_skakalpes{
		push(@arr, split(/[\s[:punct:]]+/,shift));
	};
	return @arr;
}

sub cleaned_arr{
	return grep{$_ ne ""} arr;
}

sub t10 {
	for (arr){say $_}
}

sub t11 {
	for (cleaned_arr){say $_}
}


sub t12 {
	use locale;
	use POSIX qw(locale_h); 
	setlocale(LC_ALL, "cs_CZ.utf8");
	for my $w(sort {$a cmp $b} cleaned_arr) {say $w} 
}

sub t13 {
	print scalar cleaned_arr();
}

sub frequency {
	my %freq;
	for (cleaned_arr){$freq{$_}++}
	return %freq; 
}

sub t14 {
	my %freq = frequency;
	print scalar keys %freq;
}

sub sort_freq{
	#tohle predavani by mohlo zpomalovat, ale nechce se mi premyslet nad (de)referencovanim a je toho stejne malo
	my %freq = @_;
	for(sort{$freq{$b}<=>$freq{$a}} keys %freq) {say $freq{$_}."\t".$_}
}

sub t15 {
	sort_freq(frequency);
}

#"letters" beru pismena pouze ze slov
sub t16 {
	my %freq;
	for (cleaned_arr){
		#tento trik se splitem funguje jen v perlu
		for (split(//,$_)){
			$freq{$_}++;
		}
	}
	sort_freq(%freq);
}

sub count_bigrams {
	my $subref = shift;
	my @what = @_;
	my %freq;
	my $previous_word;
	for my $word (@what) {
		if (defined $previous_word) {
			if ($subref->($previous_word) and $subref->($word)) {
				$freq{$previous_word." ".$word}++;
			}
		}
		$previous_word=$word;
	}
	sort_freq(%freq);
}

sub t17 {
	count_bigrams(sub{1}, cleaned_arr);
}

sub download_idnes {
	if (!-e "idnes.html") {
		require LWP::UserAgent;
		open my $of, ">:utf8", "idnes.html" or die "neotevrel idnes.html pro cteni";
		print $of LWP::UserAgent->new->get('http://idnes.cz')->decoded_content(charset => 'windows-1250');  
	}
}


sub t18_bigrams {
	download_idnes;
	open my $if, "<:utf8", "idnes.html" or die "neotevrel idnes.html pro cteni";
	my @arr;
	while (<$if>) {
		push(@arr, split(/[\s[:punct:]]+/,$_));
	}
	count_bigrams(sub{	
		my $w = shift;
		use locale;
		use POSIX qw(locale_h); 
		setlocale(LC_ALL, "cs_CZ.utf8");
			#kdyby nahodou bylo prvni velke pismeno s diakritikou
		return ($w =~ /^[[:upper:]]/)
	}, @arr);
}

sub t18_tags {
	download_idnes;
	open my $if, "<:utf8", "idnes.html" or die "neotevrel idnes.html pro cteni";
	my %freq;
	while (<$if>) {
		while (/<(\w+)/g) {
			$freq{$1}++;
		}
	}
	sort_freq(%freq);
}


use Switch 'fallthrough';

switch ($ARGV[0]) {
	case ["t2", undef] {t2}
	case ["t4", undef] {t4}
	case ["t6", undef] {t6}
	case ["t7", undef] {t7}
	case ["t8", undef] {t8}
	case ["t9", undef] {t9}
	case ["t10", undef] {t10}
	case ["t11", undef] {t11}
	case ["t12", undef] {t12}
	case ["t13", undef] {t13}
	case ["t14", undef] {t14}
	case ["t15", undef] {t15}
	case ["t16", undef] {t16}
	case ["t17", undef] {t17}
	case ["t18_bigrams", undef] {t18_bigrams}
	case ["t18_tags", undef] {t18_tags}
}

