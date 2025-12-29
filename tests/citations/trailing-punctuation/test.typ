// Test for trailing punctuation in titles (title ends with "?")
#import "/lib.typ": *

#let bib = ```
@inproceedings{tedeschi-etal-2023-whats,
    title = "What{'}s the Meaning of Superhuman Performance in Today{'}s {NLU}?",
    author = "Tedeschi, Simone and Bos, Johan and Koller, Alexander",
    booktitle = "Proceedings of the 61st Annual Meeting of the ACL",
    year = "2023",
}
```.text

#let fcite = format-citation-numeric()
#let fref = format-reference(
  reference-label: fcite.reference-label,
  format-quotes: it => it,
)

#add-bib-resource(bib)

#refsection(format-citation: fcite.format-citation)[
  Citation: #cite("tedeschi-etal-2023-whats")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]
