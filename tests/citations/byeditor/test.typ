// Test for incollection with byeditor
#import "/lib.typ": *

#let bib = ```
@incollection{brownschmidt_2018_perspectivetaking,
    author = {Brown-Schmidt, Sarah and Heller, Daphna},
    editor = {Rueschemeyer, Shirley-Ann and Gaskell, M. Gareth},
    pages = {549-572},
    publisher = {Oxford University Press},
    title = {{Perspective-Taking During Conversation}},
    year = {2018},
    booktitle = {The Oxford Handbook of Psycholinguistics}
}
```.text

#let fcite = format-citation-numeric()
#let fref = format-reference(reference-label: fcite.reference-label)

#add-bib-resource(bib)

#refsection(format-citation: fcite.format-citation)[
  Paper with byeditor: #cite("brownschmidt_2018_perspectivetaking")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]
