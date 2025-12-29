// Test for misc entry with howpublished field (#91)
#import "/lib.typ": *

#let bib = ```
@misc{Ruwitch2025AISlop,
  author       = {Ruwitch, John},
  title        = {'AI slop' videos may be annoying, but they're racking up views},
  date         = {2025-08-28},
  howpublished = {NPR, All Things Considered},
  note         = {Accessed on 15 October 2025}
}
```.text

#let fcite = format-citation-numeric()
#let fref = format-reference(reference-label: fcite.reference-label)

#add-bib-resource(bib)

#refsection(format-citation: fcite.format-citation)[
  Misc with howpublished: #cite("Ruwitch2025AISlop")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]
