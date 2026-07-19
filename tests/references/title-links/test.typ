// Persistent coverage for linked title rendering with and without subtitles.
#import "/lib.typ": *

#set page(width: 7in, height: 8in, margin: 0.4in)
#set text(size: 8pt)
#show link: set text(fill: blue)

#let bib = ```
@article{article-doi-full,
  author = {Article Doi Full},
  title = {Linked Article},
  subtitle = {Linked Subtitle},
  journaltitle = {Journal},
  doi = {10.1000/example-full},
  date = {2024},
}

@article{article-doi-title,
  author = {Article Doi Title},
  title = {Linked Article Only},
  journaltitle = {Journal},
  doi = {10.1000/example-title},
  date = {2024},
}

@online{online-url-full,
  author = {Online Url Full},
  title = {Linked Online},
  subtitle = {Linked Subtitle},
  url = {https://example.com/full},
  date = {2024},
}

@online{online-url-title,
  author = {Online Url Title},
  title = {Linked Online Only},
  url = {https://example.com/title},
  date = {2024},
}
```.text

#add-bib-resource(bib)

#refsection(style: authoryear-style(reference: (print-url: false)))[
  #cite("article-doi-full", "article-doi-title", "online-url-full", "online-url-title")

  #print-bibliography()
]
