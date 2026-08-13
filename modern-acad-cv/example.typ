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
#let committee = yaml("dbs/committee.yaml")
#let teaching = yaml("dbs/teaching.yaml")
#let training = yaml("dbs/training.yaml")
#let skills = yaml("dbs/skills.yaml")

// set the language of the document
#let language = "en"

// defining variables
#let headerLabs = create-headers(multilingual, lang: language)

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

= #headerLabs.at("grants")

#cv-auto-stp(grants, multilingual, lang: language)

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

= #headerLabs.at("committee")

#cv-auto(committee, multilingual, lang: language)

= #headerLabs.at("teaching")

== #headerLabs.at("teaching-thesis")
#if language == "de" [
  #cv-three-items[Bachelor][7][Master][5][Lehramt][8]
] else if language == "en" [
  #cv-three-items[Bachelor][7][Master][5][Teacher program][8]
] else if language == "pt" [
  #cv-three-items[Graduação][7][Pós-Graduação][5][Licenciatura][8]
] else [
  #cv-three-items[Bachelor][7][Master][5][Teacher program][8]
]

== #headerLabs.at("teaching-courses")

#cv-table-teaching(teaching, multilingual, lang: language)

= #headerLabs.at("training")

#cv-auto-cats(training, multilingual, headerLabs, lang: language)

= #headerLabs.at("others")

#cv-auto-skills(skills, multilingual, metadata, lang: language)
