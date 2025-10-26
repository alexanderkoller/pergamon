#import "lib.typ": *

#show link: set text(fill: blue)


// Author-Year:
#let fcite = format-citation-authoryear()

// Alphabetic:
// #let fcite = format-citation-alphabetic()

// Numeric:
// #let fcite = format-citation-numeric()


#let fref = format-reference(
  print-date-after-authors: true,
  reference-label: fcite.reference-label,
)

#let sorting = "nyt"


#add-bib-resource(read("bibs/biblatex-examples.bib"))

#refsection(format-citation: fcite.format-citation)[
  #print-bibliography(
    format-reference: fref, 
    sorting: sorting,
    show-all: true,
    label-generator: fcite.label-generator,
  )
]
