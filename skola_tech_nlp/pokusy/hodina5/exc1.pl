use warnings;
use strict;
use utf8;
binmode(STDOUT, ':utf8');

my $sentence = "Tedy abych byl přesný, úvodní otázka by správně měla znít „proč jsme se nedozvěděli nic z českých médií“, neboť ta zahraniční o akci nazvané Global Investigative Journalism Conference, která proběhla v polovině října v Kyjevě, informovala.";

print map {$_." ".length($_)."\n"} sort {length ($b) <=> length ($a)} grep {length($_)>3} split /[\s[:punct:]]/, $sentence;


