// Test: issue #140 origdate example through authoryear labels and bibliography dates.

#import "/lib.typ": *

#let dev = pergamon-dev

#let bib = ```
@Misc{LynchTwinPeaks1990,
  author       = {Lynch, David and Frost, Mark},
  date         = {2018},
  title        = {Twin Peaks},
  howpublished = {DVD},
  location     = {Warszawa},
  organization = {Imperial CinePix},
  origdate     = {1991},
}
```.text

#let year-of(reference, field) = {
  let date = reference.parsed_dates.at(field, default: none)
  if date != none and date.start != none {
    str(date.start.year)
  } else {
    none
  }
}

#let citation-date(date-value, reference, field-name, options) = {
  let date = if date-value != none { str(date-value.start.year) } else { none }
  let origdate = year-of(reference, "origdate")

  if origdate != none and date != none {
    origdate + "/" + date
  } else if date != none {
    date
  } else {
    origdate
  }
}

#let bibliography-date(reference, options) = {
  let date = (dev.printfield)(reference, "date", options)
  let origdate = (dev.printfield)(reference, "origdate", options)
  let extradate = (dev.printfield)(reference, "extradate", options)

  let date-part = if origdate != none and date != none {
    [#origdate/#date]
  } else if date != none {
    date
  } else {
    origdate
  }

  epsilons(date-part, extradate)
}

#let fcite = format-citation-authoryear(format-date: citation-date)
#let fref = format-reference(
  reference-label: fcite.reference-label,
  format-functions: (
    "date-with-extradate": bibliography-date,
  ),
)

#add-bib-resource(bib)

#refsection(format-citation: fcite.format-citation)[
  Year form: #cite("LynchTwinPeaks1990", form: "year")

  Parenthetical: #cite("LynchTwinPeaks1990", form: "p")

  Textual: #cite("LynchTwinPeaks1990", form: "t")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]
