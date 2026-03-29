// Test: authoryear citations with same author are merged.
// e.g. "Freitag et al. (2023, 2024)" instead of "Freitag et al. (2023); Freitag et al. (2024)"

#import "/lib.typ": *

#let bib = ```
@article{doe2023,
  author = {Jane Doe},
  title = {First Article},
  journal = {Test Journal},
  year = {2023},
  volume = {1},
}

@article{doe2024a,
  author = {Jane Doe},
  title = {Second Article},
  journal = {Test Journal},
  year = {2024},
  volume = {2},
}

@article{doe2024b,
  author = {Jane Doe},
  title = {Third Article},
  journal = {Test Journal},
  year = {2024},
  volume = {3},
}

@article{smith2023,
  author = {John Smith},
  title = {Smith Article},
  journal = {Other Journal},
  year = {2023},
  volume = {1},
}

@article{smith2024,
  author = {John Smith},
  title = {Another Smith Article},
  journal = {Other Journal},
  year = {2024},
  volume = {2},
}
```.text

#let fcite = format-citation-authoryear()
#let fref = format-reference(reference-label: fcite.reference-label)

#add-bib-resource(bib)

#refsection(format-citation: fcite.format-citation)[
  // Same author, different years -> merged
  Same author merged: #cite("doe2023", "doe2024a")

  // Same author with extradate -> merged with extradate letters
  Same author extradate: #cite("doe2024a", "doe2024b")

  // Three by same author -> all merged
  Three merged: #cite("doe2023", "doe2024a", "doe2024b")

  // Different authors -> not merged
  Different authors: #cite("doe2023", "smith2023")

  // Mixed: same author group + different author
  Mixed: #cite("doe2023", "doe2024a", "smith2023")

  // Mixed: different then same
  Mixed reverse: #cite("smith2023", "doe2023", "doe2024a")

  // Same author non-adjacent -> NOT merged (different author in between)
  Non-adjacent: #cite("doe2023", "smith2023", "doe2024a")

  // Textual form (citet)
  Textual: #cite("doe2023", "doe2024a", form: "t")

  // Parenthetical form (explicit)
  Parenthetical: #cite("doe2023", "doe2024a", form: "p")

  // Naked form
  Naked: #cite("doe2023", "doe2024a", form: "n")

  // With prefix and suffix
  With affixes: #cite("doe2023", "doe2024a", prefix: "see", suffix: "for details")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]

// Test with merge-citations: false — should NOT merge same-author citations
= No merging

#let fcite-nomerge = format-citation-authoryear(merge-citations: false)
#let fref-nomerge = format-reference(reference-label: fcite-nomerge.reference-label)

#refsection(format-citation: fcite-nomerge.format-citation)[
  // Same author, different years -> NOT merged
  No merge: #cite("doe2023", "doe2024a")

  // Textual form, not merged
  Textual no merge: #cite("doe2023", "doe2024a", form: "t")

  #print-bibliography(format-reference: fref-nomerge, label-generator: fcite-nomerge.label-generator)
]
