// Test 2: Each builtin style works as a bundle.

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

= Numeric
#refsection(style: numeric-style())[
  Article: #cite("doe2024")

  #print-bibliography()
]

= Alphabetic
#refsection(style: alphabetic-style())[
  Article: #cite("doe2024")

  #print-bibliography()
]

= Author-year
#refsection(style: authoryear-style())[
  Article: #cite("doe2024")

  #print-bibliography()
]
