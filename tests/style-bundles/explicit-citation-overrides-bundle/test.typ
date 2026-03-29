// Test 4: Explicit format-citation overrides the style bundle's citation style.
// The citation should use compact formatting, but print-bibliography should
// still use the bundle's reference style and label generator.

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

@article{smith2023,
  author = {John Smith},
  title = {Another Article},
  journal = {Other Journal},
  year = {2023},
  volume = {2},
}
```.text

#add-bib-resource(bib)

#let fcite = format-citation-numeric(compact: true)

#refsection(style: numeric-style(), format-citation: fcite.format-citation)[
  Two articles: #cite("doe2024", "smith2023")

  #print-bibliography()
]
