#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;
use utf8;

#script for testing the module's functionality
#(for more advanced Perl programmers: use Test::More)

use MyTagger;


	
	#priradi seznam tagu.

#example of using my library.
my $sentence_ref = ["I","am","a","We","human","and","my","old","school","is","my","close","."];

my $sentence = "To help you figure out what was undefined , perl will try to tell you the name of the variable ( if any ) that was undefined . In some cases it cannot do this , so it also tells you what operation you used the undefined value in .  Note , however , that perl optimizes your program and the operation displayed in the warning may not necessarily appear literally in your program .  For example , \" that foo \" is usually optimized into \"that \" . foo , and the warning will refer to the concatenation (.) operator , even though there is no . in your program . ";


my @sentence = split " ", $sentence;

print join "\n", posTagger(@sentence);
#posTagger($sentence_ref);

#REVIEW: First, it is not a "real" test, just a visual one,
#and not good one at that (because you don't see which word has
#which tag)
#Also, sentence_ref is not used anywhere
#Also, there could be qw instead of splitting by space