#!/usr/bin/perl
use strict;
use warnings;

use XML::DOM;
use 5.010;

my $parser = XML::DOM::Parser->new();

sub gz_to_XML {
   my $filename = shift;
   #the or die part actually does NOT cover the case when gunzip dies
    #I would need eval or something, I am too lazy for that :(
    #also, the string would be empty, so the parsert would probably be empty
    #too and die too (but I haven't tested it)
    open my $filehandle, "gunzip -c $filename |" 
        or die "Can't open $filename";
    binmode($filehandle, ":utf8");    #this binmode is PROBABLY not
                                      #needed, but it's more utf8-woodoo

    my $string = do {local $/;<$filehandle>};
    close $filehandle;

    my $XML_doc = $parser->parse($string) or die "can't parse $filename";
   
    return $XML_doc;
}

for my $a_filename (<sample*.a.gz>) {
    my $m_filename = $a_filename;
    $m_filename =~ s/a\.gz/m.gz/;
    my $am_filename = $a_filename;
    $am_filename =~ s/a\.gz/am.gz/;
    
    my $a_XML_doc = gz_to_XML($a_filename);
    my $m_XML_doc = gz_to_XML($m_filename);

    #the words will all be needed anyway, let's put them all to hash
    #(they don't take too much memory, it's just references anyway)
    my %words;
    for my $m_word ($m_XML_doc->getElementsByTagName('m')) {
        my $id = $m_word->getAttribute('id');
        $words{$id} = $m_word;
    }

    for my $rf ($a_XML_doc->getElementsByTagName('m.rf')) {
        my $number = substr($rf->getFirstChild->getData, 2);
        my $word = $words{$number};
        my $word_clone = $word->cloneNode(1);
        $word_clone->setOwnerDocument($a_XML_doc);
        $rf->getParentNode->replaceChild($word_clone, $rf);
    }

    open my $am_filehandle, "| gzip > $am_filename";
    binmode($am_filehandle, ":utf8");

    print $am_filehandle $a_XML_doc->toString(); 
    close $am_filehandle;
    $m_XML_doc->dispose;
    $a_XML_doc->dispose;
}
