
#import "lib.typ": *

#let darkgreen = green.darken(20%)
#let darkblue = blue.darken(20%)

#show link: set text(fill: darkblue)

#set heading(numbering: "1.1")



// Author-Year:
#let fcite = format-citation-authoryear()

// Alphabetic:
// #let fcite = format-citation-alphabetic()

// Numeric:
// #let fcite = format-citation-numeric()

#let fref = format-reference(
  name-format: "{given} {family}",
  reference-label: fcite.reference-label,
  // suppress-fields: ("*": ("pages",), "inproceedings": ("editor",) ),
  // print-date-after-authors: true,
  // additional-fields: ("award",)
  // additional-fields: ((reference, options) => ifdef(reference, "award", (:), award => [*#award*]),),
  highlight: (x, reference, index) => {
   if "highlight" in reference.fields.at("keywords", default: ()) {
      [#text(size: 8pt)[#emoji.star.box] #x]
   } else {
      x
   }
}
)

#let sorting = "nyt"


#add-bib-resource(read("bibs/bibliography.bib"))
#add-bib-resource(read("bibs/other.bib"))
#add-bib-resource(read("bibs/physics.bib"))

#refsection(format-citation: fcite.format-citation)[
  // This show rule has to come inside the refsection, otherwise it is
  // overwritten by the show rule that is defined in refsection's source code.
  // It colors the citation links based on whether the reference is to a PI publication.
  #show link: it => if-citation(it, value => {
    let color = if "Koller" in family-names(value.reference.fields.parsed-author) { darkgreen } else { darkblue }
    set text(fill: color)
    it
  })
  
  #set par(justify: true)

  = Introduction <sec:intro>
  #lorem(100)

  = Another section

  citet: !#citet("modelizer-24", "modelizer-24")!

  citep: #citep("bender20:_climb_nlu")

  citeg: #citeg("kandra-bsc-25", "kandra-bsc-25")

  citen: #citen("yang2025goescrosslinguisticstudyimpossible", "yang2025goescrosslinguisticstudyimpossible")

  #cite("sec:intro")


  #cite("kandra-bsc-25")

  #cite("bender20:_climb_nlu")

  #cite("irtg-sgraph-15")

  #cite("wu-etal-2024-reasoning", "knuth1990") #cite("yao2025language") #cite("hershcovichItMeaningThat2021")
  #cite("abgrallMeasurementsppmKpm2016") #cite("kuhlmann2003tiny") #cite("fake-mastersthesis")

  #cite("multi1") #citen("multi2")

  #print-bibliography(format-reference: fref, sorting: sorting,
    label-generator: fcite.label-generator,
  )
]

#refsection(id: "hallo")[ lkjdf ]

#refsection[
  Another refsection
]

