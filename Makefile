tables = results-entropy-words.table results-entropy-chars.table results-model-CZ.table results-model-EN.table results-randomlanguage.table results-stats.table
images = results-entropy-CZ.pdf results-entropy-EN.pdf results-model.pdf results-randomlanguage.pdf results-zipf.pdf

all: paper.pdf

results-zipf-%.raw : TEXT%1.txt
	cat $< | ./countOfCounts.pl > $@

results-entropy-%.raw : results-entropy-%-CZ.raw results-entropy-%-EN.raw
	paste results-entropy-$*-CZ.raw results-entropy-$*-EN.raw | cut -f1,2,3,4,6,7,8 > $@

results-stats.raw : TEXTEN1.txt TEXTCZ1.txt
	cat TEXTCZ1.txt | ./stats.pl > CZ.tmp; \
	cat TEXTEN1.txt | ./stats.pl > EN.tmp; \
	paste CZ.tmp EN.tmp | cut -f1,2,4 > $@

results-model-%.raw : TEXT%1.txt
	cat $< | ./language-model-experiment.pl > $@ 2> languagemodel.$*.log

results-entropy-words-%.raw : TEXT%1.txt
	cat $< | ./entropy-experiment.pl words > $@

results-entropy-chars-%.raw : TEXT%1.txt
	cat $< | ./entropy-experiment.pl chars > $@

results-randomlanguage.raw :
	./random-language-experiment.pl > $@

results-model.pdf : results-model-CZ.raw results-model-EN.raw
	gnuplot > $@ <<< 'set term pdf; \
	set ylabel "Cross Entropy on test data"; \
	set xlabel "Tweaked lambda3"; \
	set rmargin 4; \
	plot "results-model-CZ.raw" title "Czech" with lp, \
		 "results-model-EN.raw" title "English" with lp;'

results-randomlanguage.pdf : results-randomlanguage.raw
	gnuplot > $@ <<< 'set term pdf; \
	set xlabel "Length of random language"; \
	set ylabel "Conditional Entropy"; \
	set logscale x; \
	set rmargin 4; \
	plot "$<" title "Random Language" with lp'

results-entropy-%.pdf : results-entropy-words-%.raw results-entropy-chars-%.raw
	gnuplot > $@ <<< 'set term pdf; \
	set xlabel "Percent of changed items"; \
	set ylabel "Conditional Entropy"; \
	set logscale x; \
	set rmargin 4; \
	set key left bottom; \
	plot "results-entropy-words-$*.raw" title "Changing words" with lp, \
	     "results-entropy-chars-$*.raw" title "Changing chars" with lp'

results-zipf.pdf : results-zipf-CZ.raw results-zipf-EN.raw
	gnuplot > $@ <<< 'set term pdf; \
    set xlabel "frequency"; \
    set ylabel "rank"; \
	set logscale x; \
	set logscale y; \
	set xrange [1:1000]; \
	set yrange [1:10000]; \
    set rmargin 4; \
    plot "results-zipf-CZ.raw" title "Czech"  with dots, \
	     "results-zipf-EN.raw" title "English" with dots'


results-%.table : results-%.raw
	cat $< | ./tabular.pl > $@

paper.pdf : $(images) $(tables)
	pdflatex paper.tex

clean :
	rm -rf results* *.aux *.log *.pdf *.tmp

.PHONY : paper.pdf clean
