
#import "bibtypst.typ": add-bib-resource, refsection, print-bibliography, if-citation
// #import "bibtypst-acl.typ": format-citation-acl, format-reference-acl, citep, citet, citeg, citen
// #import "bibtypst-numeric.typ": format-citation-numeric, format-reference-numeric
// #import "bibtypst-alphabetic.typ": format-citation-alphabetic, format-reference-alphabetic, add-label-alphabetic
#import "bibtypst-styles.typ": *
#import "names.typ": family-names

#let darkgreen = green.darken(20%)
#let darkblue = blue.darken(20%)

#show link: set text(fill: darkblue)

#set heading(numbering: "1.1")


#let citep(lbl) = ref(lbl, supplement: it => "p")
#let citet(lbl) = ref(lbl, supplement: it => "t")
#let citeg(lbl) = ref(lbl, supplement: it => "g")
#let citen(lbl) = ref(lbl, supplement: it => "n")


// Author-Year:
// #let fcite = format-citation-authoryear() // format-parens: nn(it => [[#it]]))

// Alphabetic:
#let fcite = format-citation-alphabetic()

// Numeric:
// #let fcite = format-citation-numeric()

#let fref = format-reference(
  reference-label: fcite.reference-label,
  // additional-fields: ("award",)
  additional-fields: ((reference, options) => ifdef(reference, "award", (:), award => [*#award*]),),
  highlight: (x, reference, index) => {
   if "highlight" in reference.fields.at("keywords", default: ()) {
      [#text(size: 8pt)[#emoji.star.box] #x]
   } else {
      x
   }
}
)

#let sorting = "nyt"


#add-bib-resource(read("bibliography.bib"))
#add-bib-resource(read("other.bib"))
#add-bib-resource(read("physics.bib"))

#refsection(format-citation: fcite.format-citation)[
  // This show rule has to come inside the refsection, otherwise it is
  // overwritten by the show rule that is defined in refsection's source code.
  // It colors the citation links based on whether the reference is to a PI publication.
  #show ref: it => if-citation(it, value => {
    if "Koller" in family-names(value.reference.fields.parsed-author) {
      show link: set text(fill: darkgreen)
      it
    } else {
      show link: set text(fill: darkblue)
      set text(fill: darkblue)
      it
    }
  })
  // TTTT

  
  #set par(justify: true)

  = Introduction <sec:intro>
  #lorem(100)

  = Another section

  citet: !#citet(<modelizer-24>)!

  citep: #citep(<bender20:_climb_nlu>)

  citeg: #citeg(<kandra-bsc-25>)

  citen: #citen(<yang2025goescrosslinguisticstudyimpossible>)

  #citen(<yang2025goescrosslinguisticstudyimpossible>)\; #citen(<yang2025goescrosslinguisticstudyimpossible>)

  @sec:intro


  @kandra-bsc-25

  @bender20:_climb_nlu

  @irtg-sgraph-15

  @wu-etal-2024-reasoning @knuth1990 @yao2025language @hershcovichItMeaningThat2021
  @abgrallMeasurementsppmKpm2016 @kuhlmann2003tiny @fake-mastersthesis

  @multi1 @multi2

  #print-bibliography(format-reference: fref, sorting: sorting,
    label-generator: fcite.label-generator,
  )
]


