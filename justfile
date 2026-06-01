source := "CV.tex"
main_pdf := "CV.pdf"
detail_pdf := "cv_detail.pdf"
site_pdf := "~/3_resources/gregmacfarlane.github.io/static/cv.pdf"

default: build

build: pdf detail
    latexmk -c {{source}}
    latexmk -c -jobname=cv_detail {{source}}
    rm -f *.xdv

pdf:
    latexmk -xelatex -halt-on-error -interaction=nonstopmode {{source}}

detail:
    latexmk -xelatex -halt-on-error -interaction=nonstopmode -jobname=cv_detail -usepretex='\def\myvar{\detailtrue}' {{source}}

watch:
    latexmk -pvc -xelatex -halt-on-error -interaction=nonstopmode {{source}}

site: pdf
    cp {{main_pdf}} {{site_pdf}}

clean:
    latexmk -c {{source}}
    latexmk -c -jobname=cv_detail {{source}}
    rm -f *.aux *.lof *.log *.lot *.toc Rplots.pdf
    rm -f *.bbl *.blg *.dvi *.fls *.fdb_latexmk *.xdv

realclean: clean
    rm -f {{main_pdf}} {{detail_pdf}}
