#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use Readonly;


Readonly my $ADDRESS =>
  'http://downloads.sourceforge.net/project/wordlist/Ispell-EnWL/3.1.20/ispell-enwl-3.1.20.zip?r=&ts=1323069538&use_mirror=puzzle';

if (!-e "ispell.zip") {
    system "wget '$ADDRESS' -O ispell.zip";
}

if (!-e "ispell") {
    system "mkdir ispell; unzip ispell.zip -d ispell";
}

if (-e "ispell/english.0") {
    system "mv ispell/english.0 .";
    system "rm -r ispell";
}
