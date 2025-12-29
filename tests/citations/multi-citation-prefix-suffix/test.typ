// Test for multi-citation with prefix and suffix
#import "/lib.typ": *

#let bib = ```
@inproceedings{wu-etal-2024-reasoning,
    title = "Reasoning or Reciting?",
    author = {Wu, Zhaofeng and Kim, Yoon},
    booktitle = "Proceedings of NAACL",
    year = "2024",
}

@book{knuth1990,
  author = {Knuth, Donald E.},
  title = {The Art of Computer Programming},
  publisher = {Addison-Wesley},
  year = {1990}
}
```.text

#let fcite = format-citation-authoryear()
#let fref = format-reference(reference-label: fcite.reference-label)

#add-bib-resource(bib)

#refsection(format-citation: fcite.format-citation)[
  Multi-citation with prefix and suffix: #cite("wu-etal-2024-reasoning", "knuth1990", prefix: "see", suffix: "and elsewhere")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]
