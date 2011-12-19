#XML je dokonce i validni, viz corpus.dtd :)
corpus_to_XML:
	./corp_to_XML.pl > corpus.xml

#vylezle .txt diffnuto se sample0.txt da 0 rozdil
XML_to_corp:
	./XML_to_corp.pl > corpus.txt

#tento ukol
XML_to_HTML:
	xsltproc XML_to_HTML.xsl corpus.xml > corpus.html

#minuly ukol
XML_to_HTML_past:
	xsltproc XML_to_HTML.xsl ../hw06/corpus.xml > corpus.html

