// Test that xdata entries are not printed with show-all.
#import "/lib.typ": *

#let bib = ```
@xdata{shared-data,
  author       = {Shared, Dana},
  publisher    = {Shared Press},
  location     = {Shared City},
  date         = {2020},
}

@book{uses-xdata,
  title        = {Uses Xdata},
  xdata        = {shared-data},
}
```.text

#add-bib-resource(bib)

#refsection(style: authoryear-style(reference: (link-titles: false)))[
  #print-bibliography(show-all: true)
]
