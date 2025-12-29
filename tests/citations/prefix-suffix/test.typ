// Test for prefix and suffix in citations
#import "/lib.typ": *

#let bib = ```
@inproceedings{tedeschi-etal-2023-whats,
    title = "What's the Meaning of Superhuman Performance?",
    author = "Tedeschi, Simone and Bos, Johan",
    booktitle = "Proceedings of ACL",
    year = "2023",
}
```.text

#let fcite = format-citation-authoryear()
#let fref = format-reference(reference-label: fcite.reference-label)

#add-bib-resource(bib)

#refsection(format-citation: fcite.format-citation)[
  With prefix and suffix: #cite("tedeschi-etal-2023-whats", prefix: "e.g.", suffix: "page 17")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]
