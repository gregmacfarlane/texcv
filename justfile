typst_source := "cv.typ"
main_pdf := "CV.pdf"
review_pdf := "CV-review.pdf"
short_pdf := "CV-short.pdf"
site_pdf := "../gregmacfarlane.github.io/static/cv.pdf"

latex_dir := "latex"
latex_source := "CV.tex"
latex_main_pdf := "CV.pdf"
latex_detail_pdf := "cv_detail.pdf"

default: build

# Build all Typst CV variants.
build: typst-build

typst:
    typst compile {{typst_source}} {{main_pdf}}

typst-review:
    typst compile --input review=true {{typst_source}} {{review_pdf}}

typst-short:
    typst compile --input short=true {{typst_source}} {{short_pdf}}

typst-build: typst typst-review typst-short

# Rebuild the public Typst CV whenever its source or data changes.
watch:
    typst watch {{typst_source}} {{main_pdf}}

# Build and export the public Typst CV to the website repository.
site: typst
    cp {{main_pdf}} {{site_pdf}}

# Legacy LaTeX builds retained for reference.
latex-pdf:
    cd {{latex_dir}} && latexmk -xelatex -halt-on-error -interaction=nonstopmode {{latex_source}}

latex-detail:
    cd {{latex_dir}} && latexmk -xelatex -halt-on-error -interaction=nonstopmode -jobname=cv_detail -usepretex='\def\myvar{\detailtrue}' {{latex_source}}

latex-build: latex-pdf latex-detail
    cd {{latex_dir}} && latexmk -c {{latex_source}}
    cd {{latex_dir}} && latexmk -c -jobname=cv_detail {{latex_source}}
    rm -f {{latex_dir}}/*.xdv

latex-watch:
    cd {{latex_dir}} && latexmk -pvc -xelatex -halt-on-error -interaction=nonstopmode {{latex_source}}

clean:
    cd {{latex_dir}} && latexmk -c {{latex_source}}
    cd {{latex_dir}} && latexmk -c -jobname=cv_detail {{latex_source}}
    rm -f {{latex_dir}}/*.aux {{latex_dir}}/*.lof {{latex_dir}}/*.log {{latex_dir}}/*.lot {{latex_dir}}/*.toc {{latex_dir}}/Rplots.pdf
    rm -f {{latex_dir}}/*.bbl {{latex_dir}}/*.blg {{latex_dir}}/*.dvi {{latex_dir}}/*.fls {{latex_dir}}/*.fdb_latexmk {{latex_dir}}/*.xdv

realclean: clean
    rm -f {{main_pdf}} {{review_pdf}} {{short_pdf}}
    rm -f {{latex_dir}}/{{latex_main_pdf}} {{latex_dir}}/{{latex_detail_pdf}}
