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
```
