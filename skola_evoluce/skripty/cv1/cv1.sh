gnuplot -e '
set terminal png;
set output "vysledky/cv1/graf.png";
plot "vysledky/cv1/results.log" using 2 w l'
