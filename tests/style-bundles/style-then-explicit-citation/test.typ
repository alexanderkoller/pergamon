// Test 9: Style bundle, then explicit format-citation inherits bundle's ref style.
// First refsection sets numeric style bundle.
// Second refsection overrides format-citation with compact numeric,
// but does NOT set a style bundle. The inherited bundle's reference-style
// and label-generator should still be used by print-bibliography.

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

= First refsection (numeric bundle)
#refsection(style: numeric-style())[
  Two articles: #cite("doe2024", "smith2023")

  #print-bibliography()
]

= Second refsection (explicit compact citation, inherited bundle ref style)
#let fcite-compact = format-citation-numeric(compact: true)

#refsection(format-citation: fcite-compact.format-citation)[
  Two articles: #cite("doe2024", "smith2023")

  #print-bibliography()
]
