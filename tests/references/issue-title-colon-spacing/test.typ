// Regression test for issue #186: no extra space before issuetitle colon.
#import "/lib.typ": *

#set page(width: 6in, height: 3in, margin: 0.35in)
#set text(size: 9pt)

#let bib = ```
@periodical{jcg-periodical,
  editor = {Doe, Jane},
  title = {Computers and Graphics},
  year = {2011},
  issuetitle = {Semantic 3D Media and Content},
  volume = {35},
  number = {4}
}

@article{jcg-article,
  author = {Roe, Richard},
  title = {Sample Article},
  journaltitle = {Computers and Graphics},
  date = {2011},
  issuetitle = {Semantic 3D Media and Content},
  volume = {35},
  number = {4}
}
```.text

#add-bib-resource(bib)

#refsection(style: authoryear-style(reference: (link-titles: false)))[
  #cite("jcg-periodical", "jcg-article")
  #print-bibliography(sorting: "n")
]
