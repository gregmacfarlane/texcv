// Publication renderer with structured personal/institutional authors.

#let initials(given) = {
  given
    .split(" ")
    .filter(part => part != "")
    .map(part => if part.last() == "." { part } else { part.first() + "." })
    .join(" ")
}

#let author-marker(student-type) = {
  if student-type == "undergraduate" or student-type == "undergrad" {
    "†"
  } else if student-type == "graduate" or student-type == "grad" {
    "‡"
  } else {
    ""
  }
}

#let render-author(author, me-family: none, corresponding: false) = {
  if type(author) == dictionary and "literal" in author.keys() {
    // CSL literal names are institutions and must remain verbatim.
    return [#author.literal]
  }

  let family = if type(author) == dictionary {
    author.family
  } else {
    author.split(", ").first()
  }
  let given = if type(author) == dictionary {
    author.given
  } else {
    let parts = author.split(", ")
    if parts.len() > 1 { parts.at(1) } else { "" }
  }
  let student-type = if type(author) == dictionary {
    author.at("student-type", default: none)
  } else {
    none
  }
  let marker = author-marker(student-type)
  let given-initials = initials(given)
  let rendered = [#marker#family, #given-initials]

  if me-family != none and family == me-family {
    if corresponding {
      strong([#rendered#super[C]])
    } else {
      strong(rendered)
    }
  } else {
    rendered
  }
}

#let join-names(names) = {
  if names.len() == 0 {
    []
  } else if names.len() == 1 {
    names.first()
  } else {
    names.slice(0, names.len() - 1).join(", ") + [ & ] + names.last()
  }
}

#let render-authors(authors, me-family: none, corresponding: false) = join-names(
  authors.map(author => render-author(
    author,
    me-family: me-family,
    corresponding: corresponding,
  )),
)

#let render-editors(editors) = join-names(editors.map(editor => {
  if type(editor) == dictionary and "literal" in editor.keys() {
    [#editor.literal]
  } else {
    let family = editor.family
    let given-initials = initials(editor.given)
    [#given-initials #family]
  }
}))

#let append-link(reference, fields) = {
  if "serial-number" in fields.keys() and "doi" in fields.serial-number.keys() {
    let url = "https://doi.org/" + fields.serial-number.doi
    reference + [ #link(url)[#url]]
  } else if "url" in fields.keys() {
    reference + [ #link(fields.url)[#fields.url]]
  } else {
    reference
  }
}

#let render-publication(fields, me-family: none) = {
  let reference = render-authors(
    fields.author,
    me-family: me-family,
    corresponding: fields.at("corresponding", default: false),
  )
  if "date" in fields.keys() and fields.date != 0 {
    reference += [ (#fields.date).]
  }
  if fields.type == "report" {
    reference += [ #emph(fields.title).]
  } else {
    reference += [ #fields.title.]
  }

  if fields.type == "article" {
    if "parent" in fields.keys() and "title" in fields.parent.keys() {
      reference += [ #emph(fields.parent.title)]
    }
    if "parent" in fields.keys() and "volume" in fields.parent.keys() {
      reference += [, #emph(str(fields.parent.volume))]
    }
    if "parent" in fields.keys() and "issue" in fields.parent.keys() {
      reference += [(#str(fields.parent.issue))]
    }
    if "page-range" in fields.keys() {
      reference += [, #fields.page-range.]
    } else {
      reference += [.]
    }
  } else if fields.type == "chapter" {
    reference += [ In ]
    if "parent" in fields.keys() and "author" in fields.parent.keys() {
      reference += [#render-editors(fields.parent.author) (Eds.), ]
    }
    if "parent" in fields.keys() and "title" in fields.parent.keys() {
      reference += emph(fields.parent.title)
    }
    if "page-range" in fields.keys() {
      reference += [ (pp. #fields.page-range).]
    } else {
      reference += [.]
    }
    if "parent" in fields.keys() and "publisher" in fields.parent.keys() {
      reference += [ #fields.parent.publisher.]
    }
  } else if fields.type == "report" {
    if "report-number" in fields.keys() {
      reference += [ #fields.at("report-number")]
      if "publisher" in fields.keys() {
        reference += [, #fields.publisher.]
      } else {
        reference += [.]
      }
    } else if "publisher" in fields.keys() {
      reference += [ #fields.publisher.]
    }
  } else {
    if "publisher" in fields.keys() {
      reference += [ #fields.publisher.]
    }
  }

  append-link(reference, fields)
}

#let cv-refs-flexible(what, tag: none, me-family: none) = {
  set par(hanging-indent: 2em, justify: true, linebreaks: auto)
  set block(above: 0.65em)

  let selected = ()
  for (_, fields) in what {
    if tag == none or ("tags" in fields.keys() and fields.tags == tag) {
      selected.push(fields)
    }
  }

  let total = selected.len()
  for (index, fields) in selected.enumerate() {
    [\[#(total - index)\] ]
    render-publication(fields, me-family: me-family)
    parbreak()
  }
}
