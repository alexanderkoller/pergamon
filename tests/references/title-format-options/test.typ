// Persistent coverage for title composition with formatting options.
#import "/lib.typ": *

#set page(width: 7in, height: 9in, margin: 0.4in)
#set text(size: 8pt)

#let bib = ```
@article{article-full,
  author = {Article Full},
  title = {Custom Article},
  subtitle = {Custom Subtitle},
  titleaddon = {Custom Addon},
  journaltitle = {Journal},
  date = {2024},
}

@article{article-title,
  author = {Article Title},
  title = {Custom Article Only},
  journaltitle = {Journal},
  date = {2024},
}

@book{book-full,
  author = {Book Full},
  title = {Custom Book},
  subtitle = {Custom Subtitle},
  titleaddon = {Custom Addon},
  publisher = {Publisher},
  date = {2024},
}

@book{book-title,
  author = {Book Title},
  title = {Custom Book Only},
  publisher = {Publisher},
  date = {2024},
}

@misc{misc-full,
  author = {Misc Full},
  title = {Custom Misc},
  subtitle = {Custom Subtitle},
  titleaddon = {Custom Addon},
  date = {2024},
}

@misc{misc-title,
  author = {Misc Title},
  title = {Custom Misc Only},
  date = {2024},
}
```.text

#let fcite = format-citation-authoryear()
#let fref = format-reference(
  reference-label: fcite.reference-label,
  link-titles: false,
  subtitlepunct: ":",
  format-quotes: it => strong([<#it>]),
  format-title: (reference, title, options) => {
    if reference.entry_type == "article" {
      (options.format-quotes)(title)
    } else if reference.entry_type == "misc" {
      [<#title>]
    } else {
      emph(underline(title))
    }
  },
)

#add-bib-resource(bib)

#refsection(format-citation: fcite.format-citation)[
  #cite("article-full", "article-title", "book-full", "book-title", "misc-full", "misc-title")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]
