// Test 6: First refsection with neither style nor format-citation.
// Should fall back to dummy formatters (prints "CITATION" and "REFERENCE").

#import "/lib.typ": *

#let bib = ```
@article{doe2024,
  author = {Jane Doe},
  title = {A Test Article},
  journal = {Test Journal},
  year = {2024},
  pages = {1--10},
  volume = {1},
}
```.text

#add-bib-resource(bib)

#refsection[
  Article: #cite("doe2024")

  #print-bibliography()
]
