# texcv

This is my curriculum vitae in a latex document. I've been maintaining my CV in this file since 2012, but finally moved it to GitHub in 2021.

## Build

This repository uses [`just`](https://just.systems/) as the command runner and
`latexmk` with XeLaTeX for LaTeX builds.

On macOS, install `just` with Homebrew:

```sh
brew install just
```

```sh
just build      # build CV.pdf and cv_detail.pdf
just pdf        # build CV.pdf
just detail     # build cv_detail.pdf
just watch      # rebuild CV.pdf when files change
just clean      # remove auxiliary files
just realclean  # remove generated PDFs and auxiliary files
just site       # copy CV.pdf to the website repository
just typst      # build modern-acad-cv/CV.pdf
just typst-review # build modern-acad-cv/CV-review.pdf with review notes/highlights
just typst-short  # build modern-acad-cv/CV-short.pdf from entries tagged short: true
just typst-build  # build all three Typst variants
```

The short CV includes only database records marked `short: true`. Add the tag
directly to entries in the YAML databases. For publications, add it to the
corresponding citation key in `modern-acad-cv/dbs/publication-overrides.yaml`.
