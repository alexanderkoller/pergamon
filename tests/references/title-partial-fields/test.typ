// Persistent coverage for absent subtitle/titleaddon combinations.
#import "/lib.typ": *

#set page(width: 8in, height: 10in, margin: 0.4in)
#set text(size: 8pt)

#let bib = ```
@article{article-title,
  author = {Article Title},
  title = {Article Title Only},
  journaltitle = {Journal},
  date = {2024},
}

@article{article-subtitle,
  author = {Article Subtitle},
  title = {Article Title},
  subtitle = {Article Subtitle},
  journaltitle = {Journal},
  date = {2024},
}

@article{article-addon,
  author = {Article Addon},
  title = {Article Title},
  titleaddon = {Article Addon},
  journaltitle = {Journal},
  date = {2024},
}

@article{article-full,
  author = {Article Full},
  title = {Article Title},
  subtitle = {Article Subtitle},
  titleaddon = {Article Addon},
  journaltitle = {Journal},
  date = {2024},
}

@book{book-title,
  author = {Book Title},
  title = {Book Title Only},
  publisher = {Publisher},
  date = {2024},
}

@book{book-subtitle,
  author = {Book Subtitle},
  title = {Book Title},
  subtitle = {Book Subtitle},
  publisher = {Publisher},
  date = {2024},
}

@book{book-addon,
  author = {Book Addon},
  title = {Book Title},
  titleaddon = {Book Addon},
  publisher = {Publisher},
  date = {2024},
}

@book{book-full,
  author = {Book Full},
  title = {Book Title},
  subtitle = {Book Subtitle},
  titleaddon = {Book Addon},
  publisher = {Publisher},
  date = {2024},
}

@misc{misc-title,
  author = {Misc Title},
  title = {Misc Title Only},
  date = {2024},
}

@misc{misc-subtitle,
  author = {Misc Subtitle},
  title = {Misc Title},
  subtitle = {Misc Subtitle},
  date = {2024},
}

@misc{misc-addon,
  author = {Misc Addon},
  title = {Misc Title},
  titleaddon = {Misc Addon},
  date = {2024},
}

@misc{misc-full,
  author = {Misc Full},
  title = {Misc Title},
  subtitle = {Misc Subtitle},
  titleaddon = {Misc Addon},
  date = {2024},
}
```.text

#add-bib-resource(bib)

#refsection(style: authoryear-style(reference: (link-titles: false)))[
  #cite("article-title", "article-subtitle", "article-addon", "article-full")
  #cite("book-title", "book-subtitle", "book-addon", "book-full")
  #cite("misc-title", "misc-subtitle", "misc-addon", "misc-full")

  #print-bibliography()
]
