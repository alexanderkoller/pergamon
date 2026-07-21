// Test: the same format-date hook can format origdate/date labels and references.

#import "/lib.typ": *

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

#let year(reference, field) = {
  str(reference.parsed_dates.at(field).start.year)
}

#let orig-and-pub-date(date, reference, field-name, options) = {
  if field-name == "date" and "origdate" in reference.parsed_dates {
    year(reference, "origdate") + "/" + year(reference, "date")
  } else {
    default-format-date(date, reference, field-name, options)
  }
}

#let style = authoryear-style(
  citation: (format-date: orig-and-pub-date),
  reference: (format-date: orig-and-pub-date),
)

#add-bib-resource(bib)

#refsection(style: style)[
  Year form: #cite("LynchTwinPeaks1990", form: "year")

  Parenthetical: #cite("LynchTwinPeaks1990", form: "p")

  Textual: #cite("LynchTwinPeaks1990", form: "t")

  #print-bibliography()
]
