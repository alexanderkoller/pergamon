// Test mincrossrefs/minxrefs parent inclusion.
// Crossref children should see data inherited upstream by citegeist/biblatex;
// xref children should not inherit data from their parent.
#import "/lib.typ": *

#let bib = ```
@collection{cross-parent,
  editor       = {Parent, Paula},
  title        = {Crossref Parent},
  date         = {2020},
  publisher    = {Parent Press},
  location     = {Parent City},
}

@incollection{cross-child-a,
  author       = {Child, Alice},
  title        = {First Crossref Child},
  pages        = {1-10},
  crossref     = {cross-parent},
}

@incollection{cross-child-b,
  author       = {Child, Bob},
  title        = {Second Crossref Child},
  pages        = {11-20},
  crossref     = {cross-parent},
}

@periodical{journal-parent,
  editor       = {Journal, Jenny},
  title        = {Journal of Crossref Data},
  date         = {2024},
  volume       = {12},
  number       = {3},
}

@article{article-child,
  author       = {Article, Ada},
  title        = {Article Crossref Child},
  crossref     = {journal-parent},
}

@book{xref-parent,
  author       = {Reference, Riley},
  title        = {Xref Parent},
  date         = {2021},
  publisher    = {Reference Press},
  location     = {Reference City},
}

@book{xref-child-a,
  author       = {Child, Carol},
  title        = {First Xref Child},
  date         = {2022},
  xref         = {xref-parent},
}

@book{xref-child-b,
  author       = {Child, Dave},
  title        = {Second Xref Child},
  date         = {2023},
  xref         = {xref-parent},
}
```.text

#add-bib-resource(bib)

#refsection(style: authoryear-style(reference: (link-titles: false)))[
  #cite("cross-child-a", "cross-child-b", "article-child", "xref-child-a", "xref-child-b")
  #print-bibliography(sorting: "nyt")
]
