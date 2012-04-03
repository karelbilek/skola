#!/usr/bin/env perl
use strict;
use warnings;

use XML::Twig;
my $skipped = 0;
my $page_number = 0;
#$|=1;
binmode(STDOUT, ":utf8");
my $wikitwig = XML::Twig->new( twig_handlers => {page=>\&handle_page} );

$wikitwig->parsefile($ARGV[0]);


#Smaze vsechny templaty, tj vse v {}
#(uz neslo regexem, protoze templaty muzou byt - a casto jsou - vnorene)
sub delete_all_templates {
    my $text = shift;
   
    my $length = length $text;
    my $beginning;
    my $state = 0;
    
    for my $position (0..$length-1) {
        my $letter = substr ($text, $position, 1);
        if ($letter eq '{') {
            if ($state == 0) {
                $beginning = $position;
            }
            $state++;
        }
        if ($letter eq '}') {
            $state--;
            if ($state==0) {
                my $substr_length = $position-$beginning+1;
                #trik - nejdriv cely template nahradim {{{{, pak ho smazu o
                #kousek niz
                substr($text, $beginning, $substr_length, "{"x$substr_length);
            }
        }
    }
    if ($state > 0) {
        my $position_end = $length-1;
        my $substr_length = $position_end-$beginning+1;
        substr($text, $beginning, $substr_length, "{"x$substr_length);
    }
    $text =~ s/\{+//sg;

    return $text;
}



sub handle_page {
    my ($wikitwig, $section) = @_;
    actually_handle_page(@_);
    $section->purge();
}



sub actually_handle_page {
    my ($wikitwig, $page) = @_;
    #first two pages are never regular contents
    $page_number++;
    if ($page_number <= 2) {
        return;
    }
    
    #if there is : in title, it's usually something "internal", I dont care
    my $title = $page->first_child("title")->text;
    if ($title =~ /:/) {
        return;
    }

    
    my $text = $page->first_child("revision")->first_child("text")->text;
    

    $text = "\n".$text;
    
    #substituting all the newlines
    $text =~ s/<br\s*\/?\s*>/\n/sg;
    
    #deleting all the templates
    $text = delete_all_templates($text);
    
    #Substituting all the links without : to their words
    $text =~ s/\[\[([^:|\]]*)\]\]/$1/sg;
    $text =~ s/\[\[([^:\]]*)\|([^:\]]*)\]\]/$2/sg;

    #deleting "internal" links and images, too
    $text =~ s/\[\[[^\]]*\:[^\]]*\]\]//sg;
 

    #all "xml like tags" from wikipedia documentation
    my $XML_like_tags =
        "ref|categorytree|charinsert|dynamicpagelist|gallery|hiero|imagemap|inputbox|math|nowiki|poem|pre|references|section|source|syntaxhighlight|timeline";
    
    #deleting headers
    $text =~ s/\n=+[^=]+=+//g;
    #deleting anything in XML like tags
    $text =~ s/<\s*($XML_like_tags)[^>]*>[^<]*?<\/\s*(\1)\s*>//sg;
    
    #deleting non-pair XMLlike tags
    $text =~ s/<\s*($XML_like_tags)[^>]*\s*\/>//sg;
    
    #deleting <li> list
    $text =~ s/<li>.*?<\/li>//sg;

    #deleting ALL the lists
    $text =~ s/\n;+\s*[^\n]*/\n/g while ($text =~ /\n;/);
    $text =~ s/\n:+\s*[^\n]*/\n/g while ($text =~ /\n:/);
    $text =~ s/\n#+\s*[^\n]*/\n/g while ($text =~ /\n#/);
    #deleting "wild" tables (which were not deleted in delete_all_templates)
    $text =~ s/\n\s*!\s*[^\n]*/\n/g while ($text =~ /\n\s*!/);
    $text =~ s/\n\s*\|\s*[^\n]*/\n/g while ($text =~ /\n\s*\|/);
    $text =~ s/\n\*+\s*[^\n]*/\n/g while ($text =~ /\n\*/);

    #replace links for words
    $text =~ s/\[http:\/\/\S* ([^\]]*)\]/$1/sg;
    
    #delete bold/italic formating
    $text =~ s/'//g;
   
    #spaces
    $text =~ s/&nbsp;/ /sg;

    #comments deleting
    $text =~ s/<!--.*([^-][^-][^>])-->//g;
    
    #deletigng other "wild" tags
    $text =~ s/<[^>]*>//g;

    #deleting empty parenthesis (<- were created thanks to template deletion)
    $text =~ s/\(\s*\)//g;

    #deleting repetitive lines
    $text =~ s/\n+/\n/sg;
   

    #take only texts that have something after all that deleting :) 
    if (length $text > 50) {
        print $text;
        print "\n";
    }
}
