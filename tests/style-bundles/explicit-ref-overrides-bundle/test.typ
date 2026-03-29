// Test 5: Explicit format-reference overrides style bundle.
// The style bundle has link-titles enabled (default), but the explicit
// format-reference disables it. The title should NOT be a link.

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
#let fref = format-reference(reference-label: fcite.reference-label, link-titles: false)

#show link: set text(fill: blue)

#refsection(style: numeric-style())[
  Article: #cite("doe2024")

  #print-bibliography(format-reference: fref)
]
