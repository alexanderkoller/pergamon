// Persistent coverage for #178: inbook pages should not be duplicated.
#import "/lib.typ": *

#set page(width: 7in, height: 8in, margin: 0.4in)
#set text(size: 8pt)

#let bib = ```
@inbook{inbook-pages-only,
  author = {Pages Only},
  title = {Chapter With Pages},
  booktitle = {Container Book},
  publisher = {Publisher},
  location = {Place},
  pages = {10-20},
  date = {2024},
}

@inbook{inbook-note-pages,
  author = {Note Pages},
  title = {Chapter With Note And Pages},
  booktitle = {Container Book},
  note = {Important note},
  publisher = {Publisher},
  location = {Place},
  pages = {30-40},
  date = {2024},
}
```.text

#add-bib-resource(bib)

#refsection(style: authoryear-style(reference: (link-titles: false)))[
  #cite("inbook-pages-only", "inbook-note-pages")

  #print-bibliography()
]
