// #import "modern-acad-cv.typ": *
#import "@preview/modern-acad-cv:0.1.5": *
#import "csl-adapter.typ": csl-to-modern-acad
#import "publication-renderer.typ": cv-refs-flexible

// loading meta data and databases (needs to be ad this directory)
#let metadata = yaml("metadata.yaml")
#let base-multilingual = yaml("dbs/i18n.yaml")
#let work = yaml("dbs/work.yaml")
#let education = yaml("dbs/education.yaml")
#let grants = yaml("dbs/grants.yaml")
#let publication-overrides = yaml("dbs/publication-overrides.yaml")
#let refs = csl-to-modern-acad(
  yaml("dbs/library.yaml"),
  overrides: publication-overrides,
)
#let publication-author = [Macfarlane, G.]
#let conferences = yaml("dbs/conferences.yaml")
#let talks = yaml("dbs/talks.yaml")
#let courses = yaml("dbs/courses.yaml")
#let mentoring = yaml("dbs/mentoring.yaml")
#let awards = yaml("dbs/awards.yaml")
#let citizenship = yaml("dbs/citizenship.yaml")
#let review-data = yaml("dbs/review.yaml")

// set the language of the document
#let language = "en"

// defining variables
#let review-mode = sys.inputs.at("review", default: "false") == "true"
#let short-mode = sys.inputs.at("short", default: "false") == "true"
#let multilingual = {
  let result = base-multilingual
  let languages = result.lang
  let labels = languages.at(language)
  let subtitle = if short-mode {
    labels.at("subtitle-short")
  } else if review-mode {
    labels.at("subtitle-review")
  } else {
    labels.subtitle
  }
  labels.insert("subtitle", subtitle)
  languages.insert(language, labels)
  result.insert("lang", languages)
  result
}
#let headerLabs = create-headers(multilingual, lang: language)
#let review-color = rgb(metadata.colors.review_color)
#let solarized-base01 = rgb("#586e75")
#let solarized-base00 = rgb("#657b83")
#let include-entry(item) = if short-mode {
  type(item) == dictionary and item.at("short", default: false)
} else if type(item) == dictionary {
  review-mode or not item.at("review-only", default: false)
} else {
  true
}
#let selected-array(items) = {
  let selected = ()
  for item in items {
    if include-entry(item) { selected.push(item) }
  }
  selected
}
#let selected-dict(items) = {
  let selected = (:)
  for (key, item) in items {
    if include-entry(item) { selected.insert(key, item) }
  }
  selected
}
#let refs-have-tag(refs, tag) = {
  let found = false
  for reference in refs.values() {
    if include-entry(reference) and reference.tags == tag {
      found = true
    }
  }
  found
}
#let refs-have-student-authors(refs) = {
  let found = false
  for reference in refs.values() {
    if include-entry(reference) and "student-authors" in reference.keys() and reference.student-authors.len() > 0 {
      found = true
    }
  }
  found
}
#let refs-have-visible(refs) = {
  let found = false
  for reference in refs.values() {
    if include-entry(reference) { found = true }
  }
  found
}
#let review-style(item, body) = {
  if review-mode and item.at("review-highlight", default: false) {
    text(fill: review-color, body)
  } else {
    body
  }
}
#let review-note(note) = if review-mode {
  block(above: 0.75em, below: 0.75em, note)
}

// Group appointments and degrees by institution so that the institution,
// rather than the role or degree, anchors each entry.
#let cv-auto-by-institution(what, lang: "de") = {
  let localized(value) = if type(value) == dictionary {
    value.at(lang)
  } else {
    value
  }

  let selected = selected-dict(what)
  let institutions = ()
  for key in selected.keys() {
    let item = selected.at(key)
    let institution = localized(item.at("location"))
    if institution not in institutions {
      institutions.push(institution)
    }
  }

  for (index, institution) in institutions.enumerate() {
    if index > 0 {
      v(0.35em)
    }
    cv-cols("", strong(institution))

    for key in selected.keys() {
      let item = selected.at(key)
      if localized(item.at("location")) == institution {
        let date = localized(item.at("left"))
        let entry = localized(item.at("title"))

        if "subtitle" in item.keys() {
          let subtitle = localized(item.at("subtitle"))
          if subtitle != none and subtitle != "" {
            entry += [, #emph(subtitle)]
          }
        }

        if "description" in item.keys() {
          let description = localized(item.at("description"))
          if description != none and description != "" {
            entry += [, #description]
          }
        }

        cv-cols(date, entry)
      }
    }
  }
}

// Renderers for the CV-specific databases migrated from CV.tex. These keep the
// data independent of the template's example schemas and make future updates
// straightforward YAML edits.
#let cv-funding-entry(item) = {
  let body = [#item.investigators]
  if item.title != "" {
    body += [. #emph(item.title)]
  }
  body += [. #item.amount, #item.sponsor.]
  review-style(item, cv-cols(item.year, body))
}

#let cv-funding-group(group) = {
  let entries = selected-array(group.entries)
  if entries.len() > 0 {
    heading(level: 2)[#group.label #if "summary" in group { [(#group.summary)] }]
    for item in entries { cv-funding-entry(item) }
  }
}

#let cv-funding(funding) = {
  let external-groups = (
    funding.external.at("principal-investigator"),
    funding.external.at("co-principal-investigator"),
    funding.external.unfunded,
  )
  let internal-groups = (funding.internal.funded, funding.internal.unfunded)
  if external-groups.any(group => selected-array(group.entries).len() > 0) {
    heading(level: 2)[External funding]
    for group in external-groups { cv-funding-group(group) }
  }
  if internal-groups.any(group => selected-array(group.entries).len() > 0) {
    heading(level: 2)[Internal competitive funding]
    for group in internal-groups { cv-funding-group(group) }
  }
}

#let cv-courses(courses) = {
  for course in courses.values() {
    if include-entry(course) {
      heading(level: 2)[#course.code: #course.name]
      block(above: 0.75em, below: 0.9em)[
        #set par(leading: 0.35em)
        #course.description
      ]

      let cells = ()
      for offering in course.offerings {
        cells.push(review-style(offering, [#offering.term]))
        cells.push(review-style(offering, [#offering.enrolled]))
        cells.push(review-style(offering, [#offering.rating]))
        cells.push(review-style(offering, [#offering.gpa]))
      }
      if review-mode {
        table(
          columns: (2.4fr, 0.8fr, 1.5fr, 0.8fr),
          inset: (x: 0.35em, y: 0.2em),
          stroke: none,
          align: (left, center, center, center),
          table.hline(stroke: 0.8pt + solarized-base01),
          table.header([*Semester*], [*Enrolled*], [*Student rating*], [*Average GPA*]),
          table.hline(stroke: 0.45pt + solarized-base00),
          ..cells,
          table.hline(stroke: 0.8pt + solarized-base01),
        )
      }
    }
  }
}

#let cv-mentoring-entry(item) = {
  let left = item.at("dates", default: item.at("year", default: ""))
  let body = [#strong(item.name)]
  if "area" in item { body += [, #item.area] }
  if "title" in item { body += [, #emph(item.title)] }
  if "status" in item { body += [. #item.status] }
  if "note" in item { body += [. #item.note] }
  if "outcome" in item { body += [. #item.outcome] }
  review-style(item, cv-cols(left, body))
}

#let cv-mentoring(mentoring) = {
  for key in ("graduate-chair", "graduate-member", "undergraduate-research", "honors", "other") {
    let group = mentoring.at(key)
    let entries = selected-array(group.entries)
    if entries.len() > 0 {
      heading(level: 2)[#group.label #if "summary" in group { [(#group.summary)] }]
      for item in entries { cv-mentoring-entry(item) }
    }
  }

  let capstone = mentoring.capstone
  let capstone-entries = selected-array(capstone.entries)
  if capstone-entries.len() > 0 {
    heading(level: 2)[#capstone.label (#capstone.summary)]
    for item in capstone-entries {
      review-style(
        item,
        cv-cols(item.dates, [#strong(item.project). Sponsored by #item.sponsor. Students: #item.students.]),
      )
    }
  }
}

#let cv-awards(awards) = {
  for award in awards {
    if include-entry(award) {
      review-style(award, cv-cols(award.year, [#strong(award.title). #award.description]))
    }
  }
}

#let cv-service-entry(item) = {
  let body = [#strong(item.organization): #item.role]
  if "description" in item { body += [. #item.description] }
  if "note" in item { body += [. #item.note] }
  cv-cols(item.dates, body)
}

#let cv-citizenship(citizenship) = {
  let external = selected-array(citizenship.external)
  let reviewing = selected-array(citizenship.reviewing)
  let memberships = selected-array(citizenship.memberships)
  let internal = selected-array(citizenship.internal)

  if external.len() > 0 {
    heading(level: 2)[External citizenship]
    for item in external { cv-service-entry(item) }
  }

  if reviewing.len() > 0 {
    heading(level: 3)[Journal reviewer]
    cv-cols("", reviewing.map(item => if type(item) == dictionary { item.journal } else { item }).join(", "))
  }

  if memberships.len() > 0 {
    heading(level: 3)[Professional memberships]
    for item in memberships {
      let body = [#item.organization]
      if "note" in item { body += [. #item.note] }
      cv-cols(item.dates, body)
    }
  }

  if internal.len() > 0 {
    heading(level: 2)[Internal citizenship]
    for item in internal { cv-service-entry(item) }
  }
}

// The package's cv-auto-list uses the default, very small superscript size.
// Keep this renderer local so publication footnotes and other superscripts are
// unaffected.
#let cv-conference-list(conferences, lang: "en") = {
  let localized(value) = if type(value) == dictionary {
    value.at(lang)
  } else {
    value
  }

  for year in conferences.keys() {
    let entries = conferences.at(year)
    let selected = selected-array(entries.values())
    let body = []
    for (index, event) in selected.enumerate() {
      if index > 0 { body += [, ] }
      let rendered-event = [#localized(event.name)#box(
        height: 0.8em,
        baseline: 0pt,
        text(size: 0.85em, weight: "semibold")[#event.action],
      )]
      body += review-style(event, rendered-event)
    }
    if selected.len() > 0 { cv-cols(year, body) }
  }
}

#let funding-has-entries(funding) = {
  let found = false
  let groups = (
    funding.external.at("principal-investigator"),
    funding.external.at("co-principal-investigator"),
    funding.external.unfunded,
    funding.internal.funded,
    funding.internal.unfunded,
  )
  for group in groups {
    if selected-array(group.entries).len() > 0 { found = true }
  }
  found
}

#let mentoring-has-entries(mentoring) = {
  let found = false
  for key in ("graduate-chair", "graduate-member", "undergraduate-research", "honors", "other", "capstone") {
    if selected-array(mentoring.at(key).entries).len() > 0 { found = true }
  }
  found
}

#let conferences-have-entries(conferences) = {
  let found = false
  for entries in conferences.values() {
    if selected-array(entries.values()).len() > 0 { found = true }
  }
  found
}

#let citizenship-has-entries(citizenship) = (
  selected-array(citizenship.external).len() > 0
    or selected-array(citizenship.reviewing).len() > 0
    or selected-array(citizenship.memberships).len() > 0
    or selected-array(citizenship.internal).len() > 0
)

#show: modern-acad-cv.with(
  metadata,
  multilingual,
  lang: language,
  font: "Cochin", 
  show-date: true,
)

// The package indents all non-primary headings into the entry text column.
// Subsection headings instead begin at the document's left text margin.
#show heading.where(level: 2): it => {
  set text(weight: "regular", fill: rgb(metadata.colors.main_color))
  block(above: 0.65em, below: 0.15em, it.body)
}
#show heading.where(level: 3): it => {
  set text(weight: "regular", fill: rgb(metadata.colors.main_color))
  block(above: 0.65em, below: 0.15em, it.body)
}

#if selected-dict(work).len() > 0 {
  heading(level: 1)[#headerLabs.at("work")]
  cv-auto-by-institution(work, lang: language)
}

#if selected-dict(education).len() > 0 {
  heading(level: 1)[#headerLabs.at("education")]
  cv-auto-by-institution(education, lang: language)
}

#if review-mode and not short-mode {
  review-style((review-highlight: true), cv-cols("", strong(review-data.notice)))
}

#if refs-have-visible(refs) or (review-mode and not short-mode) {
  heading(level: 1)[#headerLabs.at("pubs")]
}

#if refs-have-student-authors(refs) {
  cv-cols(
    "",
    [† BYU undergraduate student #h(1em) ‡ BYU graduate student],
  )
}

#if refs-have-tag(refs, "peer") [
    == #headerLabs.at("pubs-peer")
    #review-note(review-data.at("publication-notes").peer)
    #cv-refs-flexible(refs, tag: "peer", me-family: "Macfarlane", review-mode: review-mode, short-mode: short-mode, review-color: review-color)
]

#if refs-have-tag(refs, "conference") [
    == #headerLabs.at("pubs-conference")
    #review-note(review-data.at("publication-notes").conference)
    #cv-refs-flexible(refs, tag: "conference", me-family: "Macfarlane", review-mode: review-mode, short-mode: short-mode, review-color: review-color)
]

#if refs-have-tag(refs, "edited") [
    == #headerLabs.at("pubs-edited")
    #cv-refs-flexible(refs, tag: "edited", me-family: "Macfarlane", review-mode: review-mode, short-mode: short-mode, review-color: review-color)
]

#if refs-have-tag(refs, "book") [
    == #headerLabs.at("pubs-book")
    #cv-refs-flexible(refs, tag: "book", me-family: "Macfarlane", review-mode: review-mode, short-mode: short-mode, review-color: review-color)
]

#if refs-have-tag(refs, "other") [
    == #headerLabs.at("pubs-reports")
    #review-note(review-data.at("publication-notes").reports)
    #cv-refs-flexible(refs, tag: "other", me-family: "Macfarlane", review-mode: review-mode, short-mode: short-mode, review-color: review-color)
]

#if (review-mode or short-mode) and refs-have-tag(refs, "planned") [
    == #headerLabs.at("pubs-upcoming")
    #cv-refs-flexible(refs, tag: "planned", me-family: "Macfarlane", review-mode: review-mode, short-mode: short-mode, review-color: review-color)
]

#if review-mode and not short-mode [
    == Venue notes
    #review-note(review-data.at("venue-notes").intro)
    #let venue-cells = ()
    #for venue in review-data.at("venue-notes").entries {
      let citescore = [#venue.at("citescore", default: "-")]
      if "citescore-ranking" in venue {
        citescore += [#linebreak()#text(size: 0.82em)[#venue.at("citescore-ranking")]]
      }
      venue-cells.push(emph(venue.title))
      venue-cells.push(venue.description)
      venue-cells.push(citescore)
      venue-cells.push(venue.at("impact-factor", default: "-"))
      venue-cells.push(venue.at("scimago-quartile", default: "-"))
      venue-cells.push(venue.at("publisher", default: "-"))
    }
    #text(size: 8.3pt, table(
      columns: (1.45fr, 3.1fr, 1.1fr, 0.8fr, 0.7fr, 1fr),
      inset: (x: 0.28em, y: 0.5em),
      stroke: none,
      align: (left, left, center, center, center, left),
      table.hline(stroke: 0.8pt + solarized-base01),
      table.header(
        [*Journal*],
        [*Description*],
        [*CiteScore*],
        [*Impact Factor*],
        [*Scimago*],
        [*Publisher*],
      ),
      table.hline(stroke: 0.45pt + solarized-base00),
      ..venue-cells,
      table.hline(stroke: 0.8pt + solarized-base01),
    ))
]

#if review-mode and not short-mode { pagebreak(weak: true) }
#let selected-talks = selected-dict(talks)
#if conferences-have-entries(conferences) or selected-talks.len() > 0 {
  heading(level: 1)[#headerLabs.at("confs")]
  if conferences-have-entries(conferences) {
    heading(level: 2)[#headerLabs.at("confs-conf")]
    cv-cols("", headerLabs.at("exp-confs"))
    cv-conference-list(conferences, lang: language)
  }
  if selected-talks.len() > 0 {
    heading(level: 2)[#headerLabs.at("confs-talks")]
    cv-auto(selected-talks, multilingual, lang: language)
  }
}

#if funding-has-entries(grants) {
  heading(level: 1)[#headerLabs.at("grants")]
  cv-funding(grants)
}

#if selected-dict(courses).len() > 0 {
  heading(level: 1)[#headerLabs.at("courses")]
  cv-courses(courses)
}

#if mentoring-has-entries(mentoring) {
  heading(level: 1)[#headerLabs.at("mentoring")]
  cv-mentoring(mentoring)
}

#if selected-array(awards).len() > 0 {
  heading(level: 1)[#headerLabs.at("awards")]
  cv-awards(awards)
}

#if citizenship-has-entries(citizenship) {
  heading(level: 1)[#headerLabs.at("citizenship")]
  cv-citizenship(citizenship)
}
