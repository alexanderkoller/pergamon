// Test 7: Legacy explicit wiring still works (no style bundle).

#import "/lib.typ": *

#let bib = ```
@article{doe2024,
  author = {Jane Doe},
  title = {A Test Article},
  journal = {Test Journal},
  year = {2024},
  pages = {1--10},
  volume = {1},
  doi = {10.1234/test},
}
```.text

#add-bib-resource(bib)

#let fcite = format-citation-numeric()
#let fref = format-reference(reference-label: fcite.reference-label)

#refsection(format-citation: fcite.format-citation)[
  Article: #cite("doe2024")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]
