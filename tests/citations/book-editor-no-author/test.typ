// Test for book with editor instead of author (#88)
#import "/lib.typ": *

#let bib = ```
@book{Dorfles1969,
  editor    = {Dorfles, Gillo},
  title     = {Kitsch: The World of Bad Taste},
  publisher = {Universe Books},
  address   = {New York},
  year      = {1969}
}
```.text

#let fcite = format-citation-numeric()
#let fref = format-reference(reference-label: fcite.reference-label)

#add-bib-resource(bib)

#refsection(format-citation: fcite.format-citation)[
  Book with editor, no author: #cite("Dorfles1969")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]
