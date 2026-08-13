// Convert a Zotero CSL-YAML export to the schema expected by
// modern-acad-cv 0.1.5's `cv-refs` function.

#let csl-year(item) = {
  if "issued" in item.keys() and item.issued.len() > 0 {
    item.issued.at(0).at("year", default: 0)
  } else {
    0
  }
}

#let csl-name(person, student-authors: (:)) = {
  let family = person.at("family", default: "")
  let given = person.at("given", default: "")
  let plain-name = family + ", " + given
  let student-type = student-authors.at(plain-name, default: none)
  let marker = if student-type == "undergraduate" or student-type == "undergrad" {
    "†"
  } else if student-type == "graduate" or student-type == "grad" {
    "‡"
  } else {
    ""
  }
  marker + family + ", " + given 
}

#let csl-to-modern-acad(data, overrides: (:)) = {
  let items = if type(data) == dictionary and "references" in data.keys() {
    data.references
  } else {
    data
  }

  let converted-refs = (:)

  // `cv-refs` preserves dictionary order rather than sorting by date.
  for item in items.sorted(key: item => -csl-year(item)) {
    let key = item.at("citation-key", default: item.at("id"))
    let item-overrides = overrides.at(key, default: (:))
    let student-authors = item-overrides.at("student-authors", default: (:))
    let csl-type = item.at("type", default: "")
    let output-type = if csl-type == "article-journal" or csl-type == "article" {
      "article"
    } else if csl-type == "paper-conference" or csl-type == "chapter" {
      "chapter"
    } else if csl-type == "book" {
      "book"
    } else {
      csl-type
    }

    let inferred-tag = if csl-type == "article-journal" or csl-type == "article" {
      "peer"
    } else if csl-type == "paper-conference" {
      "conference"
    } else if csl-type == "chapter" {
      "edited"
    } else if csl-type == "book" {
      "book"
    } else {
      "other"
    }

    let converted = (
      type: output-type,
      date: csl-year(item),
      title: item.at("title"),
      tags: inferred-tag,
      author: item.at("author").map(
        person => csl-name(person, student-authors: student-authors),
      ),
    )

    if "page" in item.keys() {
      converted.insert("page-range", item.page)
    }
    if csl-type == "report" and "number" in item.keys() {
      converted.insert("report-number", item.number)
    }

    let parent = (:)
    if "container-title" in item.keys() {
      parent.insert("title", item.at("container-title"))
    } else if csl-type == "paper-conference" {
      // Some Zotero conference-paper records omit their proceedings title.
      // Keep the package formatter from producing a bare "In (pp. ...)".
      parent.insert("title", "Proceedings")
    }
    if "volume" in item.keys() {
      parent.insert("volume", item.volume)
    }
    if "issue" in item.keys() {
      parent.insert("issue", item.issue)
    } else if "number" in item.keys() {
      parent.insert("issue", item.number)
    }
    if "editor" in item.keys() {
      parent.insert("author", item.editor.map(csl-name))
    }
    if "publisher" in item.keys() {
      parent.insert("publisher", item.publisher)
      // The package's book formatter looks for publisher at the top level.
      converted.insert("publisher", item.publisher)
    } else if "institution" in item.keys() {
      parent.insert("publisher", item.institution)
      converted.insert("publisher", item.institution)
    }
    if "publisher-place" in item.keys() {
      parent.insert("location", item.at("publisher-place"))
    }
    if parent.len() > 0 {
      converted.insert("parent", parent)
    }

    if "DOI" in item.keys() {
      converted.insert("serial-number", (doi: item.DOI))
    } else if "URL" in item.keys() {
      let url = item.URL
      converted.insert("url", url)
      converted.insert("archive", link(url)[#url])
    }

    if item-overrides.len() > 0 {
      converted = converted + item-overrides
    }
    converted-refs.insert(key, converted)
  }

  converted-refs
}
