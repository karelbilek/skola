system("mv ga.properties ga.orig");
for my $i (1..15) {

	my $d=<<EOF;
	#pocet bitu v jedinci
	dimension = 25

	#velikost populace
	population_size = POP
	#maximalni pocet generaci
	max_generations = 50

	#kolikrat se ma experiment opakovat
	repeats = 10
	#prefix jmena souboru jednotlivych experimentu
	log_filename_prefix = stat.log
	#jmeno souboru s konecnymi vysledky (minima, maxima a prumery jednotlivych experimentu)
	results_filename = results_POP.log
EOF

	my $h = $i*10;
	$d=~s/POP/$h/g;

	open $o, ">ga.properties";
	print $o $d;

	system("java -cp './knihovna/jgap.jar:./knihovna/lib/*:./build/' eva2010.cv1.BitGA");

	system("rm stat.log.*");
	if (defined $s) {$s.=","}
	$s .= '"results_'.$h.'.log" using 2 w l';

}

system("gnuplot -e '
set terminal png;
set output \"graf.png\";
plot $s'");

system("mkdir vysledky/cv1_2; mv graf.png vysledky/cv1_2; mv results_* vysledky/cv1_2");
system("mv ga.orig ga.properties");
