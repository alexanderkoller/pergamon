#import "@preview/layout-ltd:0.1.0": layout-limiter
#show: layout-limiter.with(max-iterations: 2)


#import "lib.typ": *
#import "src/bibtypst.typ": *


#add-bib-resource(read("bibs/small1.bib"))

#refsection[
  = Refsection Start

  #add-bib-resource(read("bibs/small2.bib"), local: true)

  Refsection is #context { current-refsection() }

  Global bibliography: #context { bibliography.get().keys() }

  Local bibliography: #context { local-bibliography-at-refsection-end().keys() }
]

#refsection[
  = Refsection Start

  Refsection is #context { current-refsection() }

  Global bibliography: #context { bibliography.get().keys() }

  Local bibliography: #context { local-bibliography-at-refsection-end().keys() }
]


