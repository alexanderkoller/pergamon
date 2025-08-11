
#import "bibtypst.typ": add-bibliography, refsection, print-bibliography, if-reference
#import "bibtypst-acl.typ": format-citation-acl, format-reference-acl, citep, citet

#let darkgreen = green.darken(20%)
#let darkblue = blue.darken(20%)

#show link: set text(fill: darkblue)
  

#set heading(numbering: "1.1")



#let bibtex-string = read("bibliography.bib")
#add-bibliography(bibtex-string)

#refsection(format-citation: format-citation-acl)[
  // This show rule has to come inside the refsection, otherwise it is
  // overwritten by the show rule that is defined in refsection's source code.
  #show ref: it => [
    #if-reference(str(it.target), 
      reference => reference.fields.author.contains("Koller"),
      ref => [
        #show link: set text(fill: darkgreen)
        #it
      ], 
      ref => [
        #show link: set text(fill: darkblue)
        #set text(fill: darkblue)
        #it
      ]
    )
  ]


  = Introduction <sec:intro>
  sadfsdf

  = Another section

  citet: #citet(<modelizer-24>)

  citep: #citep(<bender20:_climb_nlu>)

  @sec:intro

  @modelizer-24

  @yang2025goescrosslinguisticstudyimpossible

  @kandra-bsc-25

  @bender20:_climb_nlu

  @irtg-sgraph-15

  #print-bibliography(format-reference: format-reference-acl, sorting: it => (it.lastname-first-authors, -int(it.fields.year)),)
]


