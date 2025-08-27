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

  #pcite("bender20:_climb_nlu", none)
  // @bender20:_climb_nlu
    #print-bibliography(format-reference: fref, label-generator: fcite.label-generator,
  )
]


#refsection(id: "hallo", format-citation: fcite.format-citation)[ 
  = Second 

  #pcite("knuth1990", "hallo")
  // @knuth1990
#print-bibliography(refsection-id: "hallo", format-reference: fref, label-generator: fcite.label-generator)
]

// #refsection(id: "third")[
//   Another refsection
// ]
