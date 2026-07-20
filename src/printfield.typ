#import "@preview/nth:1.0.1": *
#import "bib-util.typ": fd, ifdef, concatenate-names
#import "templating.typ": *
#import "names.typ": format-name, is-andothers-name
#import "bib-util.typ": is-integer
#import "dates.typ": date-field-name, get-date, format-date-field, is-year-defined

#let make-eprint-url(eprint, eprint-type) = {
  if eprint-type == none {
    return none
  } else if lower(eprint-type) == "hdl" {
    "http://hdl.handle.net/" + eprint
  } else if lower(eprint-type) == "arxiv" {
      "https://arxiv.org/abs/" + eprint
  } else if lower(eprint-type) == "jstor" {
      "http://www.jstor.org/stable/" + eprint
  } else if lower(eprint-type) == "pubmed" {
      "http://www.ncbi.nlm.nih.gov/pubmed/" + eprint
  } else if (lower(eprint-type) == "googlebooks" or lower(eprint-type) == "google books") {
      "http://books.google.com/books?id=" + eprint
  } else {
    none
  }
}

#let eprint(reference, options) = {
  let eprint-type = fd(reference, "eprinttype", options)

  ifdef(reference, "eprint", options, eprint => {
    let url = make-eprint-url(eprint, eprint-type)

    if eprint-type != none and lower(eprint-type) == "hdl" {
      [HDL: #link(url, eprint)]
    } else if eprint-type != none and lower(eprint-type) == "arxiv" {
      let suffix = ifdef(reference, "eprintclass", options, eprintclass => options.at("format-brackets")(eprintclass))
      [arXiv: #link(url, spaces(eprint, suffix))]
    } else if eprint-type != none and lower(eprint-type) == "jstor" {
      [JSTOR: #link(url, eprint)]
    } else if eprint-type != none and lower(eprint-type) == "pubmed" {
      [PMID: #link(url, eprint)]
    } else if eprint-type != none and (lower(eprint-type) == "googlebooks" or lower(eprint-type) == "google books") {
      [Google Books: #link(url, eprint)]
    } else {
      let suffix = ifdef(reference, "eprintclass", options, eprintclass => options.at("format-brackets")(eprintclass))
      let eprint-type = if eprint-type == none { "eprint" } else { eprint-type }
      [#eprint-type: #link(eprint, spaces(eprint, suffix))]
    }
  })
}

// Normalizes and optionally links a caller-provided title string.
// If options.eval-mode is not `none`, the title string is first evaluated.
// Then, if the reference defines a URL or DOI, the title is wrapped in
// a `link`.
#let link-title(reference, options, title) = {
  if options.eval-mode != none and type(title) == str {
    title = eval(title.trim(), mode: options.eval-mode, scope: options.eval-scope)
  } else if type(title) == str {
    title = title.trim()
  }

  if not options.link-titles {
    title
  } else if "doi" in reference.fields {
    link("https://doi.org/" + reference.fields.doi)[#title]
  } else if "url" in reference.fields {
    link(reference.fields.url)[#title]
  } else {
    let eprint-url = make-eprint-url(fd(reference, "eprint", options), fd(reference, "eprinttype", options))
    if eprint-url != none {
      link(eprint-url)[#title]
    } else {
      title
    }
  }
}

// Prints a list of author names. Names are formatted and concatenated
// as specified in the options. `name-parts-array` is an array of name-parts dictionaries.
// "name-type" is the Bibtex field name, e.g. "author" or "editor".
#let print-name(name-parts-array, name-type, options) = {
  let andothers = name-parts-array.len() > 0 and is-andothers-name(name-parts-array.last())
  if andothers {
    name-parts-array = name-parts-array.slice(0, name-parts-array.len() - 1)
  }

  let names = name-parts-array.map(d => format-name(d, name-type: name-type, format: options.name-format))
  concatenate-names(names, options: options, minnames: options.minnames, maxnames: options.maxnames, andothers: andothers)
}

#let default-field-formats = (
  // Used in the bibliography and bibliography lists

  "doi": (value, reference, field, options, style) => {
    [DOI: #link("https://doi.org/" + value, value)]
  },

  "edition": (value, reference, field, options, style) => {
    if is-integer(value) {
      spaces(nth(int(value)), options.bibstring.edition)
    } else {
      value
    }
  },

  "eprint": (value, reference, field, options, style) => {
    eprint(reference, options)
  },

  "issn": (value, reference, field, options, style) => {
    spaces("ISSN:", value)
  },

  "isbn": (value, reference, field, options, style) => {
    spaces("ISBN:", value)
  },

  "isrn": (value, reference, field, options, style) => {
    spaces("ISRN:", value)
  },

  "pages": (value, reference, field, options, style) => {
    if value.contains("-") or value.contains(sym.dash.en) {
      // Typst biblatex library converts "--" into an endash "–"
      spaces(options.bibstring.pages, value)
    } else {
      spaces(options.bibstring.page, value)
    }
  },

  "volume": (value, reference, field, options, style) => {
    if reference.entry_type in ("article", "periodical") {
      value
    } else {
      spaces(options.bibstring.volume, value)
    }
  },

  "file": (value, reference, field, options, style) => {
    raw(value)
  },

  "chapter": (value, reference, field, options, style) => {
    spaces(options.bibstring.chapter, value)
  },

  "part": (value, reference, field, options, style) => {
    // physical part of a logical volume
    "." + value
  },

  "series": (value, reference, field, options, style) => {
    if reference.entry_type in ("article", "periodical") {
      // series of a journal
      if is-integer(value) {
        spaces(nth(int(value)), options.bibstring.jourser)
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

  "title": (value, reference, field, options, style) => value,

  "type": (value, reference, field, options, style) => {
    options.bibstring.at(value, default: value)
  },

  "url": (value, reference, field, options, style) => {
    [URL: #link(value, value)]
  },

  "urldate": (value, reference, field, options, style) => {
    spaces(options.bibstring.urlseen, format-date-field(value, reference, field, options))
  },

  "version": (value, reference, field, options, style) => {
    spaces(options.bibstring.version, value)
  },

  "volumes": (value, reference, field, options, style) => {
    spaces(value, options.bibstring.volumes)
  },

  "date": (value, reference, field, options, style) => {
    format-date-field(value, reference, field, options)
  },

  "eventdate": (value, reference, field, options, style) => {
    format-date-field(value, reference, field, options)
  },

  "origdate": (value, reference, field, options, style) => {
    format-date-field(value, reference, field, options)
  },

  "extradate": (value, reference, field, options, style) => {
    if is-year-defined(reference) {
      numbering("a", value+1)
    } else {
      (options.format-brackets)(numbering("a", value+1))
    }
  },

  "author": "parsed-author",

  "parsed-author": (value, reference, field, options, style) => {
    print-name(value, "author", options)
  },

  "editor": "parsed-editor",

  "parsed-editor": (value, reference, field, options, style) => {
    print-name(value, "editor", options)
  },

  "translator": "parsed-translator",

  "parsed-translator": (value, reference, field, options, style) => {
    print-name(value, "translator", options)
  },

  "language": (value, reference, field, options, style) => {
    if value == none {
      none
    } else {
      let language-list = value.split(regex("\s+and\s+")).map({ id => options.bibstring.at(id, default: id) })

      concatenate-names(language-list, options: options, maxnames: 99)
    }
  },

  "location": (value, reference, field, options, style) => {
    if value == none {
      none
    } else {
      let location-list = value.split(regex("\s+and\s+")).map({ id => options.bibstring.at(id, default: id) })
      concatenate-names(location-list, options: options, maxnames: 99)
    }
  }

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
  let field-formats = options.at("field-formatters")
  let date-field = date-field-name(field)
  let value = if date-field == none {
    fd(reference, field, options)
  } else {
    get-date(reference, date-field, options: options)
  }

  if value == none {
    none
  } else {
    field = if date-field == none { lower(field) } else { date-field }

    let printed = if field in field-formats {
      let format = field-formats.at(field)

      // resolve format aliases, e.g. "editor" to "parsed-editor"
      while type(format) == str {
        field = format
        format = field-formats.at(field)
        value = fd(reference, field, options)
      }

      format(value, reference, field, options, style)
    } else {
      value
    }

    if options.eval-mode != none and type(printed) == str {
      printed = eval(printed, mode: options.eval-mode, scope: options.eval-scope)
    }

    printed
  }
}
