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

#let field-formats = (
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


/*
\DeclareFieldFormat{title}{\mkbibemph{#1}}
\DeclareFieldFormat
  [article,inbook,incollection,inproceedings,patent,thesis,unpublished]
  {title}{\mkbibquote{#1\isdot}}
\DeclareFieldFormat
  [suppbook,suppcollection,suppperiodical]
  {title}{#1}

\DeclareFieldFormat{type}{\ifbibstring{#1}{\bibstring{#1}}{#1}}
\DeclareFieldFormat{url}{\mkbibacro{URL}\addcolon\space\url{#1}}
\DeclareFieldFormat{urldate}{\mkbibparens{\bibstring{urlseen}\space#1}}
\DeclareFieldFormat{version}{\bibstring{version}~#1}
\DeclareFieldFormat{volume}{\bibstring{volume}~#1}% volume of a book
\DeclareFieldFormat[article,periodical]{volume}{#1}% volume of a journal
\DeclareFieldFormat{volumes}{#1~\bibstring{volumes}}


% Generic formats for \printtext and \printfield

\DeclareFieldFormat{emph}{\mkbibemph{#1}}
\DeclareFieldFormat{bold}{\mkbibbold{#1}}
\DeclareFieldFormat{smallcaps}{\textsc{#1}}
\DeclareFieldFormat{parens}{\mkbibparens{#1}}
\DeclareFieldFormat{brackets}{\mkbibbrackets{#1}}
\DeclareFieldFormat{bibhyperref}{\bibhyperref{#1}}
\DeclareFieldFormat{bibhyperlink}{\bibhyperlink{\thefield{entrykey}}{#1}}
\DeclareFieldFormat{bibhypertarget}{\bibhypertarget{\thefield{entrykey}}{#1}}
\DeclareFieldFormat{titlecase}{#1}
\DeclareFieldFormat{noformat}{#1}
*/


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

