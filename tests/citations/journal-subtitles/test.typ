// Test for journal subtitles
#import "/lib.typ": *

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
```.text

#let fcite = format-citation-numeric()
#let fref = format-reference(reference-label: fcite.reference-label)

#add-bib-resource(bib)

#refsection(format-citation: fcite.format-citation)[
  Citation: #cite("clls")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]
