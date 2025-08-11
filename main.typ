
#import "bibtypst.typ": add-bib-resource, refsection, print-bibliography, if-reference
#import "bibtypst-acl.typ": format-citation-acl, format-reference-acl, citep, citet, citeg, citen

#let darkgreen = green.darken(20%)
#let darkblue = blue.darken(20%)

#show link: set text(fill: darkblue)
  

#set heading(numbering: "1.1")


#add-bib-resource(read("bibliography.bib"))
#add-bib-resource(read("other.bib"))

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

  citeg: #citeg(<kandra-bsc-25>)

  citen: #citen(<yang2025goescrosslinguisticstudyimpossible>)

  @sec:intro


  @kandra-bsc-25

  @bender20:_climb_nlu

  @irtg-sgraph-15

  @wu-etal-2024-reasoning

  #set par(justify: true)
  #print-bibliography(format-reference: format-reference-acl, sorting: it => (it.lastname-first-authors, -int(it.fields.year)),)
]


