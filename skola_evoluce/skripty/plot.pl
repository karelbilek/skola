$wat = $ARGV[0];
system("gnuplot -e '
set terminal png;
set output \"graf.png\";
plot \"$wat\" using 2 w l'");
