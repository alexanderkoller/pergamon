
#import "bibtypst.typ": add-bibliography, refsection, print-bibliography
#import "bibtypst-acl.typ": format-citation-acl, format-reference-acl

#set heading(numbering: "1.1")

#show ref: set text(fill: blue)
#show link: set text(fill: blue)

#let bibtex-string = read("bibliography.bib")
#add-bibliography(bibtex-string)

#refsection(format-citation: format-citation-acl)[
  = Introduction <sec:intro>
  sadfsdf

  = Another section

  @sec:intro

  @modelizer-24

  @yang2025goescrosslinguisticstudyimpossible

  @kandra-bsc-25

  @bender20:_climb_nlu

  @irtg-sgraph-15


  #print-bibliography(format-reference: format-reference-acl, sorting: it => (it.lastname-first-authors, -int(it.fields.year)),)
]


