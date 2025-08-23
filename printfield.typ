#import "@preview/nth:1.0.1": *
#import "bib-util.typ": join-list, fd, ifdef
#import "templating.typ": *


#let matches-completely(s, re) = {
  let result = s.match(re)

  if result == none {
    return false
  } else {
    [#result]
    [#{result.start == 0 and result.end == s.len()}]
  }
}

#let is-integer(s) = matches-completely(s, "\d+")


#let eprint(reference, options) = {
  let eprint-type = fd(reference, "eprinttype")

  ifdef(reference, "eprint", eprint => {
    if eprint-type != none and lower(eprint-type) == "hdl" {
      [HDL: #link("http://hdl.handle.net/" + eprint, eprint)]
    } else if eprint-type != none and lower(eprint-type) == "arxiv" {
      let suffix = ifdef(reference, "eprintclass", eprintclass => options.at("format-brackets")(eprintclass))
      [arXiv: #link("https://arxiv.org/abs/" + eprint, spaces(eprint, suffix))]
    } else if eprint-type != none and lower(eprint-type) == "jstor" {
      [JSTOR: #link("http://www.jstor.org/stable/" + eprint, eprint)]
    } else if eprint-type != none and lower(eprint-type) == "pubmed" {
      [PMID: #link("http://www.ncbi.nlm.nih.gov/pubmed/" + eprint, eprint)]
    } else if eprint-type != none and (lower(eprint-type) == "googlebooks" or lower(eprint-type) == "google books") {
      [Google Books: #link("http://books.google.com/books?id=" + eprint, eprint)]
    } else {
      let suffix = ifdef(reference, "eprintclass", eprintclass => options.at("format-brackets")(eprintclass))
      if eprint-type == none { eprint-type = "eprint" }
      [#eprint-type: #link(eprint, spaces(eprint, suffix))]
    }
  })
}

// make title a hyperlink if DOI or URL are defined
#let link-title(reference, options) = {
  let title = if options.eval-mode == none { reference.fields.title.trim() } else { eval(reference.fields.title.trim(), mode: options.eval-mode) }

  if not options.link-titles {
    title 
  } else if "doi" in reference.fields {
    link("https://doi.org/" + reference.fields.doi)[#title]
  } else if "url" in reference.fields {
    link(reference.fields.url)[#title]
  } else {
    title
  }
}

#let field-formats = (

  // Used in the bibliography and bibliography lists

  "doi": (value, reference, field, options, style) => {
    [DOI: #link("https://doi.org/" + value)]
  },

  "edition": (value, reference, field, options, style) => {
    if is-integer(value) {
      [#nth(int(value)) #options.bibstring.edition]
    } else {
      value
    }
  },

  "eprint": (value, reference, field, options, style) => {
    eprint(reference, options)
  },

  "issn": (value, reference, field, options, style) => {
    [ISSN #value]
  },

  "isbn": (value, reference, field, options, style) => {
    [ISBN #value]
  },

  "isrn": (value, reference, field, options, style) => {
    [ISRN #value]
  },

  "pages": (value, reference, field, options, style) => {
    if value.contains("-") or value.contains(sym.dash.en) {
      // Typst biblatex library converts "--" into an endash "–"
      [pp. #value]
    } else {
      [p. #value]
    }
  },

  "volume": (value, reference, field, options, style) => {
    if reference.entry_type in ("article", "periodical") {
      value
    } else {
      [#options.bibstring.volume #value]
    }
  },

  "file": (value, reference, field, options, style) => {
    raw(value)
  },

  "journaltitle": (value, reference, field, options, style) => {
    emph(value)
  },

  "issuetitle": (value, reference, field, options, style) => {
    emph(value)
  },

  "maintitle": (value, reference, field, options, style) => {
    emph(value)
  },

  "booktitle": (value, reference, field, options, style) => {
    emph(value)
  },

  "chapter": (value, reference, field, options, style) => {
    [#options.bibstring.chapter #value]
  },

  "part": (value, reference, field, options, style) => {
    // physical part of a logical volume
    [.#value]
  },

  "series": (value, reference, field, options, style) => {
    if reference.entry_type in ("article", "periodical") {
      // series of a journal
      if is-integer(value) {
        [#nth(int(value)) #options.bibstring.jourser]
      } else {
        options.bibstring.at(value, default: value)
      }
    } else {
      // publication series
      value
    }
  },

  "pubstate": (value, reference, field, options, style) => {
    options.bibstring.at(value, default: value)
  },

  "title": (value, reference, field, options, style) => {
    let bib-type = reference.entry_type
    let title = link-title(reference, options)

    if bib-type in ("article", "inbook", "incollection", "inproceedings", "patent", "thesis", "unpublished") {
      options.at("format-quotes")(title)
    } else if bib-type in ("suppbook", "suppcollection", "suppperiodical") {
      title
    } else {
      emph(title)
    }
  },

  "type": (value, reference, field, options, style) => {
    options.bibstring.at(value, default: value)
  },

  "url": (value, reference, field, options, style) => {
    [URL: #link(value, value)]
  },

  "urldate": (value, reference, field, options, style) => {
    options.at("format-parens")([#options.bibstring.urlseen #value])
  },

  "version": (value, reference, field, options, style) => {
    [#options.bibstring.version #value]
  },

  "volumes": (value, reference, field, options, style) => {
    [#value #options.bibstring.volumes]
  },

  /*
  TODO currently unsupported:

  \DeclareFieldFormat{month}{\mkbibmonth{#1}}
  \DeclareFieldFormat{pagetotal}{\mkpagetotal[bookpagination]{#1}}
  \DeclareFieldFormat{related}{#1}
  \DeclareFieldFormat{related:multivolume}{#1}
  \DeclareFieldFormat{related:origpubin}{\mkbibparens{#1}}
  \DeclareFieldFormat{related:origpubas}{\mkbibparens{#1}}
  \DeclareFieldFormat{relatedstring:default}{#1\printunit{\relatedpunct}}
  \DeclareFieldFormat{relatedstring:reprintfrom}{#1\addspace}
  */
)



#let printfield(reference, field, options, style: none) = {
  let value = fd(reference, field)
  
  if value == none {
    none
  } else {
    field = lower(field)

    if field in field-formats {
      field-formats.at(field)(value, reference, field, options, style)
    } else {
      value
    }
  }
}

