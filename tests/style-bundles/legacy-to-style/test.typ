// Test 8: Legacy explicit citation (alphabetic), then switch to style bundle (numeric).
// First refsection should show alphabetic labels [Doe24].
// Second refsection should show numeric labels [1].

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

= Legacy alphabetic
#let fcite = format-citation-alphabetic()
#let fref = format-reference(reference-label: fcite.reference-label)

#refsection(format-citation: fcite.format-citation)[
  Article: #cite("doe2024")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]

= Style bundle numeric
#refsection(style: numeric-style())[
  Article: #cite("doe2024")

  #print-bibliography()
]
