// Test that leading/trailing whitespace in bib fields is trimmed at load time.

#import "/lib.typ": *

#let darkblue = blue.darken(20%)
#show link: set text(fill: darkblue)

#let bib = ```
@article{trimtest,
  author = { Jane Doe },
  title = { A Title with Spaces },
  journal = { Some Journal },
  year = { 2024 },
  doi = { 10.1234/test },
  pages = { 10--20 },
  volume = { 5 },
  number = { 3 },
}
```.text

#let fcite = format-citation-numeric()
#let fref = format-reference(reference-label: fcite.reference-label)

#add-bib-resource(bib)

#refsection(format-citation: fcite.format-citation)[
  Article: #cite("trimtest")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]
