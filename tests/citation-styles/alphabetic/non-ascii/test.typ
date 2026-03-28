#import "/lib.typ": *

#add-bib-resource(
  "
@article{https://doi.org/10.1002/qua.560020505,
author = {Fröhlich, H.},
title = {Long-range coherence and energy storage in biological systems},
journal = {International Journal of Quantum Chemistry},
volume = {2},
number = {5},
pages = {641-649},
doi = {https://doi.org/10.1002/qua.560020505},
url = {https://onlinelibrary.wiley.com/doi/abs/10.1002/qua.560020505},
year = {1968}
}
",
)

#let style = format-citation-alphabetic()
#refsection(format-citation: style.format-citation)[
  = UTF-8 Bug

  #cite("https://doi.org/10.1002/qua.560020505")

  #print-bibliography(
    show-all: true,
    title: none,
    format-reference: format-reference(reference-label: style.reference-label),
    label-generator: style.label-generator,
  )
]