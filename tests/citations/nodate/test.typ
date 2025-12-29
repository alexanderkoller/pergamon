// Test for entries without a date
#import "/lib.typ": *

#let bib = ```
@article{nodate,
  author       = {Hempel, Carl G.},
  title        = {Science and Human Values},
  journal = {Journal of Negative Results},
}
```.text

#let fcite = format-citation-authoryear()
#let fref = format-reference(reference-label: fcite.reference-label)

#add-bib-resource(bib)

#refsection(format-citation: fcite.format-citation)[
  Citation with no date: #cite("nodate")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]
