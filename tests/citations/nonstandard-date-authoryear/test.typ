// Test: authoryear citations and references agree on nonstandard parsed dates.

#import "/lib.typ": *

#let bib = ```
@misc{approx-date,
  author = {Approx, Ada},
  title = {Approximate Work},
  date = {2024~},
}

@misc{uncertain-date,
  author = {Uncertain, Uma},
  title = {Uncertain Work},
  date = {2024?},
}

@misc{bce-date,
  author = {Before, Bea},
  title = {BCE Work},
  date = {-0031%},
}

@misc{after-date,
  author = {After, Alan},
  title = {After Work},
  date = {2024/..},
}

@misc{range-date,
  author = {Range, Riley},
  title = {Range Work},
  date = {2020/2024},
}
```.text

#add-bib-resource(bib)

#let style = authoryear-style(reference: (print-date-after-authors: true))

#refsection(style: style)[
  Approx: #cite("approx-date")

  Uncertain: #cite("uncertain-date")

  BCE: #cite("bce-date")

  After: #cite("after-date")

  Range: #cite("range-date")

  #print-bibliography()
]
