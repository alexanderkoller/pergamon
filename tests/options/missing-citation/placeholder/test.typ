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

#let numeric = format-citation-numeric()
#let alphabetic = format-citation-alphabetic()
#let authoryear = format-citation-authoryear()

#refsection(format-citation: numeric.format-citation)[
  Default numeric placeholder: #cite("missing-numeric")
]

#refsection(format-citation: alphabetic.format-citation)[
  Default alphabetic placeholder: #cite("missing-alphabetic")
]

#refsection(format-citation: authoryear.format-citation)[
  Default authoryear placeholder: #cite("missing-authoryear")
]

#let custom = format-citation-numeric(
  missing-citation: "placeholder",
  missing-citation-placeholder: key => [MISSING #key],
)

#refsection(format-citation: custom.format-citation)[
  Custom placeholder: #cite("missing-custom")
]
