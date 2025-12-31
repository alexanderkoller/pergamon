// Test reversed bibliographies

#import "/lib.typ": *

#let darkgreen = green.darken(20%)
#let darkblue = blue.darken(20%)

#show link: set text(fill: darkblue)

#let bib = ```
@article{clls,
  Author = {Markus Egg and Alexander Koller and Joachim Niehren},
  Journal = {Journal of Logic, Language, and Information},
  journalsubtitle = {A journal with subtitles},
  Volume = 10,
  Number = 4,
  Pages = {457--485},
  Title = {The Constraint Language for Lambda Structures},
  Year = 2001
}


@InProceedings{bender20:_climb_nlu,
  author = 	 {Emily M. Bender and Alexander Koller},
  keywords = {highlighted, pi},  
  title = 	 {Climbing towards {NLU}:
 On Meaning, Form, and Understanding in the Age of Data},
  award = {Best theme paper},
  booktitle = {Proceedings of the 58th Annual Meeting of the
                  Association for Computational Linguistics (ACL)},
  doi={10.18653/v1/2020.acl-main.463},
  year = 	 2020}

  
@incollection{brownschmidt_2018_perspectivetaking,
    author = {Brown-Schmidt, Sarah and Heller, Daphna},
    editor = {Rueschemeyer, Shirley-Ann and Gaskell, M. Gareth},
    month = {08},
    pages = {549-572},
    publisher = {Oxford University Press},
    title = {{Perspective-Taking During Conversation}},
    doi = {10.1093/oxfordhb/9780198786825.013.23},
    year = {2018},
    organization = {The Oxford Handbook of Psycholinguistics},
    booktitle = {The Oxford Handbook of Psycholinguistics}
}

@misc{test_entry2,
      title={Doesnt matter 2.}, 
      author={Santa Claus},
      year={2025}
}


@book{Dorfles1969,
  editor    = {Dorfles, Gillo},
  title     = {Kitsch: The World of Bad Taste},
  publisher = {Universe Books},
  address   = {New York},
  year      = {1969}
}

@article{nodate,
  author       = {Hempel, Carl G.},
  title        = {Science and Human Values},
  journal = {Journal of Negative Results},
}
```.text

#add-bib-resource(bib)


#let fcite = format-citation-numeric(compact: true)
#let fref = format-reference(reference-label: fcite.reference-label)

#refsection(format-citation: fcite.format-citation)[
  create a gap: #cite("Dorfles1969")

  to test \#129: #cite("bender20:_climb_nlu", "brownschmidt_2018_perspectivetaking", "test_entry2", "clls", "nodate", "xxxxx", "yyyy")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator, sorting: "n", reversed: true)
]
