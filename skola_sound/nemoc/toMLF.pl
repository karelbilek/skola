#!/usr/bin/perl
use utf8;
use open qw(:std :utf8);
$j=1;
print "#!MLF!#\n";
while(<>)
{
 s/[:;,.?!|-]/ /g;  		#zbaveni se interpunkce
 s/ {1,}/ /g; 			#s/  */ /g; #dlouhe mezery srazi na minimum
 s/\s/\n/g;      		#odradkuje mezi kazdym slovem
 s/\n+$//g;
 s/^\n+//g;
 s/^/\"*\/S$j.lab\"\n/g;	#vlozi na zacatek radky identifikator vety
 print uc($_),"\n.\n"; 		#upravenou vetu vytiskne
 $j=$j+1;
}
