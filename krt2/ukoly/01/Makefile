archive.xml.bz2:
	wget 'http://dumps.wikimedia.org/$(LAN)wiki/latest/$(LAN)wiki-latest-pages-articles.xml.bz2' -O archive.xml.bz2

archive.xml: archive.xml.bz2
	bunzip2 archive.xml.bz2

text: archive.xml
	./rozeber.pl archive.xml > text

text.words: text
	cat text | sed -r 's/([[:punct:]])/\n\1\n/g;s/\s+/\n/g;' | grep -v '^\s*$$' > text.words

text.sorted: text.words
	sort text.words > text.sorted

text.uniq: text.sorted
	uniq -c text.sorted > text.uniq

text.final: text.uniq
	sort -nr text.uniq > text.final


all: text.final
