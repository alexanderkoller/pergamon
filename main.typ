
#import "bibtypst.typ": add-bib-resource, refsection, print-bibliography, if-reference
#import "bibtypst-acl.typ": format-citation-acl, format-reference-acl, citep, citet, citeg, citen
#import "bibtypst-numeric.typ": format-citation-numeric, format-reference-numeric

#let darkgreen = green.darken(20%)
#let darkblue = blue.darken(20%)

#show link: set text(fill: darkblue)

#set heading(numbering: "1.1")

#let fcite = format-citation-numeric
#let fref = format-reference-numeric



#add-bib-resource(read("bibliography.bib"))
#add-bib-resource(read("other.bib"))

#refsection(format-citation: fcite)[
  // This show rule has to come inside the refsection, otherwise it is
  // overwritten by the show rule that is defined in refsection's source code.
  #show ref: it => if-reference(str(it.target), 
    reference => reference.fields.author.contains("Koller"),
    ref => {
      show link: set text(fill: darkgreen)
      it
    }, 
    ref => {
      show link: set text(fill: darkblue)
      set text(fill: darkblue)
      it
    }
  )
  
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

  @wu-etal-2024-reasoning


  #print-bibliography(format-reference: fref, sorting: it => (it.lastname-first-authors, -int(it.fields.year)),)
]


