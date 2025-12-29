// Test for editor field in incollection entries
#import "/lib.typ": *

#let bib = ```
@incollection{hempel1965science,
  author       = {Hempel, Carl G.},
  title        = {Science and Human Values},
  booktitle    = {Aspects of Scientific Explanation},
  publisher    = {The Free Press},
  editor = {Carl Gustav Hempel},
  location     = {New York},
  year         = {1965},
  pages        = {81--96},
}
```.text

#let fcite = format-citation-numeric()
#let fref = format-reference(reference-label: fcite.reference-label)

#add-bib-resource(bib)

#refsection(format-citation: fcite.format-citation)[
  Citation: #cite("hempel1965science")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]
