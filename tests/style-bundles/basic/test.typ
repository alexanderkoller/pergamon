// Test 1: Style bundle with defaults — basic happy path.

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

#refsection(style: numeric-style())[
  Article: #cite("doe2024")

  #print-bibliography()
]
