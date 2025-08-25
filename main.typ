
#import "bibtypst.typ": add-bib-resource, refsection, print-bibliography, if-citation
// #import "bibtypst-acl.typ": format-citation-acl, format-reference-acl, citep, citet, citeg, citen
// #import "bibtypst-numeric.typ": format-citation-numeric, format-reference-numeric
// #import "bibtypst-alphabetic.typ": format-citation-alphabetic, format-reference-alphabetic, add-label-alphabetic
#import "bibtypst-styles.typ": *

#let darkgreen = green.darken(20%)
#let darkblue = blue.darken(20%)

#show link: set text(fill: darkblue)

#set heading(numbering: "1.1")


#let citep(lbl) = ref(lbl, supplement: it => "p")
#let citet(lbl) = ref(lbl, supplement: it => "t")
#let citeg(lbl) = ref(lbl, supplement: it => "g")
#let citen(lbl) = ref(lbl, supplement: it => "n")


#let fcite = format-citation-acl()
#let fref = format-reference(
  // additional-fields: ("award",)
  additional-fields: ((reference, options) => ifdef(reference, "award", (:), award => [*#award*]),),
  suppress-fields: ("issn",),
  print-isbn: true,
  highlight: (x, reference, index) => {
   if "highlight" in reference.fields.at("keywords", default: ()) {
      [#text(size: 8pt)[#emoji.star.box] #x]
      // strong(x)
   } else {
      x
   }
}
)
#let fadd = x => x
#let sorting = "nyt"


// #let fcite = format-citation-numeric()
// #let fref = format-reference-numeric()
// #let fadd = x => x
// #let sorting = "nyt"


// #let fcite = format-citation-alphabetic()
// #let fref = format-reference-alphabetic() 
// #let fadd = add-label-alphabetic()
// #let sorting = "a"

// #let fcite = format-citation-acl()
// #let fref = format-reference-acl()
// #let fadd = x => x
// #let sorting = "nyt"

// highlighting: x => [*#x*])
// highlight: (x, reference, index) => {
//    if "highlight" in reference.fields.at("keywords", default: ()) {
//       strong(x)
//    } else {
//       x
//    }
// }


#add-bib-resource(read("bibliography.bib"))
#add-bib-resource(read("other.bib"))
#add-bib-resource(read("physics.bib"))

#refsection(format-citation: fcite)[
  // This show rule has to come inside the refsection, otherwise it is
  // overwritten by the show rule that is defined in refsection's source code.
  // It colors the citation links based on whether the reference is to a PI publication.
  #show ref: it => if-citation(it, value => {
    if "Koller" in value.reference.lastnames {
      show link: set text(fill: darkgreen)
      it
    } else {
      show link: set text(fill: darkblue)
      set text(fill: darkblue)
      it
    }
  })

  
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

  #print-bibliography(format-reference: fref, add-label: fadd, sorting: sorting,
    label-generator: (reference, index) => {
      // this is just a quick & dirty approximation of what it would look like for authoryear
      let final-index = calc.min(2, reference.lastnames.len())
      let names = reference.lastnames.slice(0, final-index)
      if final-index < reference.lastnames.len() {
        names += ("et al",) // in biblatex this is an option
      }

      ((names, reference.fields.year),
      strfmt("{} {}", names, reference.fields.year))
    }
  )
]


