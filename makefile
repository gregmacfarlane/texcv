## Resume MAKE Compiler ##

# for Mac OSX and Linux

# Josephine D. Kressner
# Georgia Institute of Technology
# josiekressner@gatech.edu

# Edits and annotation by Greg Macfarlane
# gmacfarlane7@gatech.edu

# Enter the name of the final .pdf document here:
MASTER = CV.pdf
# Your principal .rnw or .tex file should have the same stem. If your principal
# file is foo.rnw, set MASTER = foo.pdf


BIBTYPES = j c w
# For every type of bibliography you want in your CV. I currently have journals
# and conference proceedings. These are called by the multibib package.


# This file is designed for UNIX- type operating systems and successfully
# compiles on Mac OS X and Red Hat Linux at least. Compiling on Windows will
# require different LaTeX output suppressors (>/dev/null will not be
# recognized)

all: $(MASTER) detail
	@ make clean

site: $(MASTER)
	@ echo + Copying $< to website folder ~/Sites/website
	@ cp $(MASTER) ~/Sites/website/static/uploads/cv.pdf

$(MASTER): cv.tex
	@ echo + Writing $@ from $< ...
	@ echo + XeLaTex pass 0/2
	@ xelatex "\def\myvar{} \input{$<}">/dev/null
	@ echo + XeLaTeX pass 1/2
	@ xelatex "\def\myvar{} \input{$<}">/dev/null
	@ xelatex "\def\myvar{} \input{$<}">/dev/null
	@ echo + XeLaTeX pass 2/2
	@ xelatex "\def\myvar{} \input{$<}">/dev/null

detail: cv_detail.pdf

cv_detail.pdf: cv.tex
	@ echo + making $@ from $< ...
	@ xelatex -jobname=cv_detail "\def\myvar{\detailtrue} \input{$<}">/dev/null
	@ xelatex -jobname=cv_detail "\def\myvar{\detailtrue} \input{$<}">/dev/null


clean:
	@ echo + Cleaning ...
	@ rm -f *.aux *.lof *.log *.lot *.toc Rplots.pdf
	@ rm -f *.bbl *.blg *.dvi *.fls *.fdb_latexmk
	@ rm -f $(patsubst %.rnw,%.tex,$(RNWFILES))

realclean: clean
	@echo + Really cleaning ...
	rm -f $(MASTER)
	rm -f cv_detail.pdf



menu:
	@ echo + ==============================
	@ echo + .......GNU Make menu..........
	@ echo + all: ......... create document
	@ echo + detail: .. create extended doc
	@ echo + clean: ...... delete aux files
	@ echo + realclean: . delete all output
	@ echo + site ......... copy to website
	@ echo +
	@ echo + Georgia Tech---------
	@ echo + --------Civil Engineering
	@ echo + ==============================
