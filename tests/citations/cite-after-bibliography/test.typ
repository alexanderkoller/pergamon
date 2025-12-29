// Test for citation after bibliography (tracl #21 / pergamon #139)
#import "/lib.typ": *

#let bib = ```
@misc{test_entry2,
      title={Doesnt matter 2.},
      author={Santa Claus},
      year={2025}
}
```.text

#let fcite = format-citation-numeric()
#let fref = format-reference(reference-label: fcite.reference-label)

#add-bib-resource(bib)

#refsection(format-citation: fcite.format-citation)[
  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)

  Citation after bibliography: #cite("test_entry2")
]
