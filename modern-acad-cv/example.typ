// #import "modern-acad-cv.typ": *
#import "@preview/modern-acad-cv:0.1.5": *
#import "csl-adapter.typ": csl-to-modern-acad
#import "publication-renderer.typ": cv-refs-flexible

// loading meta data and databases (needs to be ad this directory)
#let metadata = yaml("metadata.yaml")
#let multilingual = yaml("dbs/i18n.yaml")
#let work = yaml("dbs/work.yaml")
#let education = yaml("dbs/education.yaml")
#let grants = yaml("dbs/grants.yaml")
#let publication-overrides = yaml("dbs/publication-overrides.yaml")
#let refs = csl-to-modern-acad(
  yaml("dbs/library.yaml"),
  overrides: publication-overrides,
)
#let publication-author = [Macfarlane, G.]
#let refs-have-tag(refs, tag) = {
  let found = false
  for reference in refs.values() {
    if reference.tags == tag {
      found = true
    }
  }
  found
}
#let refs-have-student-authors(refs) = {
  let found = false
  for reference in refs.values() {
    if "student-authors" in reference.keys() and reference.student-authors.len() > 0 {
      found = true
    }
  }
  found
}
#let conferences = yaml("dbs/conferences.yaml")
#let talks = yaml("dbs/talks.yaml")
#let courses = yaml("dbs/courses.yaml")
#let mentoring = yaml("dbs/mentoring.yaml")
#let awards = yaml("dbs/awards.yaml")
#let citizenship = yaml("dbs/citizenship.yaml")

// set the language of the document
#let language = "en"

// defining variables
#let headerLabs = create-headers(multilingual, lang: language)
#let show-detail = false // Mirrors the commented-out \detailtrue in CV.tex.
#let include-entry(item) = show-detail or not item.at("detail", default: false)

// Group appointments and degrees by institution so that the institution,
// rather than the role or degree, anchors each entry.
#let cv-auto-by-institution(what, lang: "de") = {
  let localized(value) = if type(value) == dictionary {
    value.at(lang)
  } else {
    value
  }

  let institutions = ()
  for key in what.keys() {
    let item = what.at(key)
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

    for key in what.keys() {
      let item = what.at(key)
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
  cv-cols(item.year, body)
}

#let cv-funding-group(group) = {
  if include-entry(group) {
    heading(level: 2)[#group.label #if "summary" in group { [(#group.summary)] }]
    for item in group.entries {
      if include-entry(item) { cv-funding-entry(item) }
    }
  }
}

#let cv-funding(funding) = {
  heading(level: 2)[External funding]
  cv-funding-group(funding.external.at("principal-investigator"))
  cv-funding-group(funding.external.at("co-principal-investigator"))
  cv-funding-group(funding.external.unfunded)
  heading(level: 2)[Internal competitive funding]
  cv-funding-group(funding.internal.funded)
  cv-funding-group(funding.internal.unfunded)
}

#let cv-courses(courses) = {
  for course in courses.values() {
    heading(level: 2)[#course.code: #course.name]
    course.description
    v(0.35em)

    let cells = ()
    for offering in course.offerings {
      cells.push([#offering.term])
      cells.push([#offering.enrolled])
      cells.push([#offering.rating])
      cells.push([#offering.gpa])
    }
    if show-detail {
      table(
        columns: (2.4fr, 0.8fr, 1.5fr, 0.8fr),
        inset: (x: 0.35em, y: 0.2em),
        stroke: (x: none, y: 0.4pt + luma(75%)),
        align: (left, center, center, center),
        table.header([*Semester*], [*Enrolled*], [*Student rating*], [*Average GPA*]),
        ..cells,
      )
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
  cv-cols(left, body)
}

#let cv-mentoring(mentoring) = {
  for key in ("graduate-chair", "graduate-member", "undergraduate-research", "honors", "other") {
    let group = mentoring.at(key)
    heading(level: 2)[#group.label #if "summary" in group { [(#group.summary)] }]
    for item in group.entries {
      if include-entry(item) { cv-mentoring-entry(item) }
    }
  }

  let capstone = mentoring.capstone
  heading(level: 2)[#capstone.label (#capstone.summary)]
  for item in capstone.entries {
    if include-entry(item) {
      cv-cols(item.dates, [#strong(item.project). Sponsored by #item.sponsor. Students: #item.students.])
    }
  }
}

#let cv-awards(awards) = {
  for award in awards {
    if include-entry(award) {
      cv-cols(award.year, [#strong(award.title). #award.description])
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
  heading(level: 2)[External citizenship]
  for item in citizenship.external { cv-service-entry(item) }

  heading(level: 3)[Journal reviewer]
  cv-cols("", citizenship.reviewing.join(", "))

  heading(level: 3)[Professional memberships]
  for item in citizenship.memberships {
    let body = [#item.organization]
    if "note" in item { body += [. #item.note] }
    cv-cols(item.dates, body)
  }

  heading(level: 2)[Internal citizenship]
  for item in citizenship.internal { cv-service-entry(item) }
}

#show: modern-acad-cv.with(
  metadata,
  multilingual,
  lang: language,
  font: "Cochin", 
  show-date: true,
)

= #headerLabs.at("work")

#cv-auto-by-institution(work, lang: language)

= #headerLabs.at("education")

#cv-auto-by-institution(education, lang: language)


= #headerLabs.at("pubs")


#if refs-have-student-authors(refs) {
  cv-cols(
    "",
    [† BYU undergraduate student #h(1em) ‡ BYU graduate student],
  )
}

== #headerLabs.at("pubs-peer")
#cv-refs(refs, multilingual, tag: "peer", me: publication-author, lang: language)

== #headerLabs.at("pubs-conference")
#cv-refs(refs, multilingual, tag: "conference", me: publication-author, lang: language)

#if refs-have-tag(refs, "edited") [
  == #headerLabs.at("pubs-edited")
  #cv-refs(refs, multilingual, tag: "edited", me: publication-author, lang: language)
]

#if refs-have-tag(refs, "book") [
  == #headerLabs.at("pubs-book")
  #cv-refs(refs, multilingual, tag: "book", me: publication-author, lang: language)
]

#if refs-have-tag(refs, "other") [
  == #headerLabs.at("pubs-reports")
  #cv-refs-flexible(refs, tag: "other", me-family: "Macfarlane")
]

#if refs-have-tag(refs, "planned") [
  == #headerLabs.at("pubs-upcoming")
  #cv-refs(refs, multilingual, tag: "planned", me: publication-author, lang: language)
]

= #headerLabs.at("confs")
== #headerLabs.at("confs-conf")
#cv-cols(
  "",
  headerLabs.at("exp-confs"),
)

#cv-auto-list(conferences, multilingual, lang: language)

== #headerLabs.at("confs-talks")
#cv-auto(talks, multilingual, lang: language)

= #headerLabs.at("grants")

#cv-funding(grants)

= #headerLabs.at("courses")

#cv-courses(courses)

= #headerLabs.at("mentoring")

#cv-mentoring(mentoring)

= #headerLabs.at("awards")

#cv-awards(awards)

= #headerLabs.at("citizenship")

#cv-citizenship(citizenship)
