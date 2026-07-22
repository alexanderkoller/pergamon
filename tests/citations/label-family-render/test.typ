#import "/lib.typ": *

#let bib = ```
@manual{cms,
  title = {The Chicago Manual of Style},
  date = {2003},
  subtitle = {The Essential Guide for Writers, Editors, and Publishers},
  edition = {15},
  publisher = {University of Chicago Press},
  location = {Chicago},
  label = {CMS},
  shorttitle = {Chicago Manual of Style}
}

@online{ctan,
  title = {CTAN},
  subtitle = {The Comprehensive TeX Archive Network},
  date = {2006},
  url = {http://www.ctan.org},
  label = {CTAN}
}

@periodical{jcg,
  title = {Computers and Graphics},
  year = {2011},
  issuetitle = {Semantic 3D Media and Content},
  volume = {35},
  number = {4}
}

@book{kant-kpv,
  author = {Kant, Immanuel},
  title = {Kritik der praktischen Vernunft},
  date = {1788},
  shorthand = {KpV}
}
```.text

#add-bib-resource(bib)

= Author-year
#refsection(style: authoryear-style(reference: (link-titles: false)))[
  #cite("cms")
  #cite("ctan")
  #cite("jcg")
  #cite("kant-kpv")

  #print-bibliography(sorting: "nyt")
]

= Alphabetic
#refsection(style: alphabetic-style(reference: (link-titles: false)))[
  #cite("cms")
  #cite("ctan")
  #cite("jcg")
  #cite("kant-kpv")

  #print-bibliography(sorting: "anyt")
]

= Numeric
#refsection(style: numeric-style(reference: (link-titles: false), citation: (compact: true)))[
  #cite("cms", "kant-kpv", "ctan", "jcg")

  #print-bibliography(sorting: "none")
]
