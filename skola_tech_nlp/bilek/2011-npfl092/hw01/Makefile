J = skakalpes-utf8.txt

LINECOUNT =  wc -l | cut -f1 -d' '
FREQ = sort | uniq -c | sort -nr

skakalpes-il2.txt:
	wget 'http://ufal.mff.cuni.cz/~zabokrtsky/courses/npfl092/html/data/skakalpes-il2.txt'


$(J): skakalpes-il2.txt
	iconv -f iso-8859-2 -t utf8 skakalpes-il2.txt > $(J)

t2: skakalpes-il2.txt
	
t3: skakalpes-il2.txt
	cat skakalpes-il2.txt | less

t4: $(J)

t5: $(J)
	less $(J)

t6: $(J) 
	cat $(J) | $(LINECOUNT)


t7: $(J)
	head -15 $(J); tail -15 $(J); head -20 $(J) | tail -10 

t8: $(J)
	cut -f1,2 -d' ' $(J)
#neni idealni (vice mezer na zacatku vadi apod), ale maximalni, co se da udelat s cutem

t9: $(J)
	grep '[[:digit:]]' $(J)

t10: $(J)
	sed 's/[ [:punct:]]\+/\n/g' $(J)

FILTER_WORDS = sed 's/[ [:punct:]]\+/\n/g' | grep -v '^[[:space:]]*$$'
FILTER_CAPS = grep '^[[:upper:]]\+$$'


	         #beru i zaviraci     newliny, co NEJSOU udelane tagy, nechci   a vyberu jenom tagy
FILTER_TAGS = sed 's/<\/\?/\nTAG:/g'|grep  'TAG:'                            | sed -r 's/^TAG:([[:alpha:]]*).*$$/\1/'| grep -v '^[[:space:]]*$$'

#je to ponekud silene reseni, ale opet, jedine, co me napadlo jen s pouzitim sedu a grepu
		#(asi by se dalo vynechat to oznacovani pomoci TAG:)


NONEMPTY_WORDS = cat $(J) | $(FILTER_WORDS)
SORTED_WORDS = $(NONEMPTY_WORDS) | sort
UNIQ_WORDS = $(SORTED_WORDS) | uniq 
LETTERS = sed -r 's/(.)/\1\n/g' $(J)


t11: $(J)
	$(NONEMPTY_WORDS)

t12: $(J)
	$(SORTED_WORDS)

t13: $(J)
	$(SORTED_WORDS) | $(LINECOUNT) 

t14: $(J) 
	$(UNIQ_WORDS) | $(LINECOUNT)

t15: $(J)
	$(NONEMPTY_WORDS) | $(FREQ)

t16: $(J)
	$(LETTERS) | $(FREQ)

words.txt: $(J)
	$(NONEMPTY_WORDS) > words.txt

shifted.txt: words.txt
	tail -n +2 words.txt > shifted.txt

t17: shifted.txt words.txt
	paste shifted.txt words.txt | $(FREQ)

idnes.html:
	wget 'http://www.idnes.cz' -O idnes.html


idnes_words.txt: idnes.html
	cat idnes.html | $(FILTER_WORDS) | $(FILTER_CAPS) > idnes_words.txt

idnes_shifted.txt: idnes_words.txt
	tail -n +2 idnes_words.txt > idnes_shifted.txt

t18_words: idnes_words.txt idnes_shifted.txt
	paste idnes_words.txt idnes_shifted.txt 


t18_tags: idnes.html
	LC_CTYPE=C; cat idnes.html | $(FILTER_TAGS) |  $(FREQ)

