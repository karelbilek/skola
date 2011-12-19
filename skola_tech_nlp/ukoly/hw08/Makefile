result.pdf: count countgraph.pdf
	pdflatex acl-hlt2011
	pdflatex acl-hlt2011
	mv acl-hlt2011.pdf result.pdf

count: textcz2.ptg
	perl eval_tagger.pl

countgraph.pdf: count
	gnuplot > $@ <<< 'set term pdf; plot "count" using ($$1):($$2) title "tagger results" with lines'

textcz2.ptg:
	wget 'http://ufal.mff.cuni.cz/~hajic/courses/npfl067/textcz2.ptg'
