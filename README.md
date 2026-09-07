# texcv

This repository contains my curriculum vitae. The current CV is built with
Typst; the older LaTeX source and its archived outputs are retained in
`latex/`.

The main Typst source is `cv.typ`.

## Build

This repository uses [`just`](https://just.systems/) as the command runner.
On macOS, install it with Homebrew:

```sh
brew install just
```

```sh
just build          # build all three Typst CV variants
just typst          # build the public CV as CV.pdf
just typst-review   # build CV-review.pdf with review notes/highlights
just typst-short    # build CV-short.pdf from entries tagged short: true
just typst-short-withheld  # build CV-short-withheld.pdf without email/social links
just watch          # rebuild the public Typst CV when sources change
just site           # rebuild CV.pdf and copy it to the website repository
```

The short CV includes only database records marked `short: true`. Add the tag
directly to entries in the YAML databases. For publications, add it to the
corresponding citation key in `dbs/publication-overrides.yaml`.

For submissions that request contact and social links to be withheld, use
`just typst-short-withheld`, or pass `--input withhold-socials=true` alongside
`--input short=true` when compiling directly. This removes the email, ORCID,
LinkedIn, and homepage (GitHub Pages) links while leaving other CV variants
unchanged.

## Legacy LaTeX CV

The legacy source and outputs live in `latex/`:

```sh
just latex-build    # build both legacy LaTeX variants
just latex-pdf      # build latex/CV.pdf
just latex-detail   # build latex/cv_detail.pdf
just latex-watch    # watch the legacy public CV
just clean          # remove LaTeX auxiliary files
just realclean      # also remove all generated CV PDFs
```
