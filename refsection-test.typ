#import "lib.typ": *

#let fcite = format-citation-authoryear()
#let format-citation = fcite.format-citation

#let fref = format-reference(
  name-format: "{given} {family}",
  reference-label: fcite.reference-label,
)


#show link: set text(fill: blue)

#add-bib-resource(read("bibs/bibliography.bib"))


#refsection(format-citation: fcite.format-citation)[
  = First refsection
  #cite("bender20:_climb_nlu")
  #cite("generalized-2025")
  // @bender20:_climb_nlu
    #print-bibliography(format-reference: fref, label-generator: fcite.label-generator,
  )
]


#refsection[ 
  = Second refsection

  #cite("knuth1990")
  // @knuth1990
#print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
// refsection-id: "hallo", 
]

// #refsection(id: "third")[
//   Another refsection
// ]


#refsection(format-citation: fcite.format-citation)[ 
  = Third refsection
  #cite("ehop-2025") #cite("yao2025language", form: it => "t")
  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]