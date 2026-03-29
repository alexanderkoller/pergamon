// Test 10: Style bundle with custom citation and reference parameters.
// Citation: compact: true (compact numeric citations).
// Reference: link-titles: false (titles should not be linked).

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

#show link: set text(fill: blue)

#refsection(style: numeric-style(
  citation: (compact: true),
  reference: (link-titles: false)
))[
  Two articles: #cite("doe2024", "smith2023")

  #print-bibliography()
]
