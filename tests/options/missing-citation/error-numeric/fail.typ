#import "/lib.typ": *

#let bib = ```
@article{known,
  author = {Doe, Jane},
  title = {Known},
  journal = {Journal},
  year = {2024},
}
```.text

#add-bib-resource(bib)
#let fcite = format-citation-numeric(missing-citation: "error")

#refsection(format-citation: fcite.format-citation)[
  #cite("missing")
]
