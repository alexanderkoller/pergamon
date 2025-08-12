
// Limitations:
// - Can't use the same label for a bib entry and as a standalone label (e.g. section reference),
//   but I guess that doesn't make sense anyway.
// - "add-bibliography" can only load a single bibliography for now.

#import "@preview/oxifmt:0.2.1": strfmt
#import "@preview/citegeist:0.1.0": load-bibliography

///////// 
///////// Helper methods for developing Bibtypst styles
///////// 


// make title a hyperlink if DOI or URL are defined
#let url-title(reference) = {
  if "doi" in reference.fields {
    link("https://doi.org/" + reference.fields.doi)[#reference.fields.title.trim()]
  } else if "url" in reference.fields {
    link(reference.fields.url)[#reference.fields.title.trim()]
  } else {
    reference.fields.title.trim()
  }
}


#let paper-type(reference) = reference.entry_type

#let paper-authors(reference) = if "authors" in reference { 
  reference.authors 
} else if "author" in reference.fields {
  let parsed-authors = fix-authors(reference)
  parsed-authors.authors
} else {
  "NO AUTHORS"
}

#let paper-year(reference) = int(reference.fields.year)


#let highlight(reference, formatted, highlighting) = {
  if "keywords" in reference.fields and reference.fields.keywords.contains("highlight") {
    highlighting(formatted)
  } else {
    formatted
  }
}


// returns a list of author names, in the form ((first, last), (first, last), ...)
#let parse-author-names(reference) = {
  let ret = ()

  for raw_author in reference.fields.author.split(regex("\s+and\s+")) {
    let match = raw_author.match(regex("(.*)\s*,\s*(.*)"))
    let first = ""
    let last = ""

    if match != none {
      (first, last) = (match.captures.at(1), match.captures.at(0))
    } else {
      match = raw_author.match(regex("(.+)\s+(\S+)"))
      (first, last) = (match.captures.at(0), match.captures.at(1))
    }

    ret.push((first, last))
  }

  return ret
}


///////// 
///////// Internal helper methods
///////// 


// concatenate an array of authors into "A, B, and C"
#let concatenate-authors(authors) = {
  let ret = authors.at(0)

  for i in range(1, authors.len()) {
    if type(authors.at(i)) != dictionary { // no idea how it would be a dictionary
      if authors.len() == 2 {
        ret = ret + " and " + authors.at(i)
      } else if i == authors.len()-1 {
        ret = ret + ", and " + authors.at(i)
      } else {
        ret = ret + ", " + authors.at(i)
      }
    }
  }

  ret
}


// parse author names and add fields with first-last and last-first author names to the reference
#let fix-authors(reference) = {
  let parsed-names = parse-author-names(reference)
  let lastname-first-authors = ()
  let firstname-first-authors = ()
  let lastnames = ()

  for (first, last) in parsed-names {
    lastname-first-authors.push(strfmt("{}, {}", last, first))
    firstname-first-authors.push(strfmt("{} {}", first, last))
    lastnames.push(last)
  }

  reference.insert("lastname-first-authors", lastname-first-authors.join(" ")) // for sorting
  reference.insert("authors", concatenate-authors(firstname-first-authors))
  reference.insert("lastnames", lastnames) // to construct citations

  reference
}



///////// 
///////// Public functions
///////// 


#let bib-count = state("citation-counter", (:))
// #let bibliography = state("bibliography", none)
#let bibliography = state("bibliography", (:))
#let bib-counter = counter("bib-entry-id")


// Unfortunately, we have to `read` the bib file from the Typst document,
// because code in packages can't read files in the working directory.
#let add-bib-resource(bibtex_string) = {
  bibliography.update(old-bib => {
    for (key, value) in load-bibliography(bibtex_string).pairs() {
      old-bib.insert(key, value)
    }

    old-bib
  })
}

// Defines a section of the document that shares a bibliography.
// You need to load a bibliography with the "add-bibliography" function
// in a place that is earlier than the refsection in rendering order.
// Place the rendered bibliography into the document with the
// "print-bibliography" function.
#let refsection(format-citation: reference => [CITATION], doc) = {
  // reset the keys that are cited in this section
  bib-count.update((:))

  // check that we have a bibliography loaded
  context {
    if bibliography.get() == none {
      panic("Add a bibliography before starting a refsection.")
    }
  }

  show ref: it => {
    let el = it.element
    let cite-key = str(it.target)

    // this has to be executed unconditionally, because the ref target
    // only changes into a reference once it is cited
    bib-count.update( dict => {
     dict.insert(cite-key, "1")
     return dict
    })

    if el != none and el.func() == metadata {
      // metadata contains a dict with all the relevant information
      let target = query(it.target).first()
      if target.value.kind == "reference-data" {
        let citation-str = format-citation(target.value, it.supplement)
        link(it.target)[#citation-str]
      } else {
        it
      }
    } else {
      it
    }
  }

  show figure: it => {
    // left-align figures that we abuse for the individual references
    if it.kind == "reference" {
      set align(left)
      set block(width: 100%)
      it
    } else {
      it
    } 
  }

  doc
}

// Generates content depending on whether the reference for a given key
// matches the condition. "condition" is a function (reference => boolean);
// "if-content" and "else-content" are functions (reference => content).
// if-reference looks up the reference for the given key. If one exists
// and the condition returns true for it, it returns the content that
// "if-content" generates for the reference. Otherwise, it returns the
// content that "else-content" generates.
#let if-reference(key, condition, if-content, else-content) = context {
  let bib = bibliography.get()

  if key in bib {
    let ref = bib.at(key)
    // [#ref.fields.author]

    if condition(ref) {
      if-content(ref)
    } else {
      else-content(ref)
    }
  } else {
    return else-content(ref)
  }
}

// TODO: We probably need to let the style-specific formatter return a list of tuples,
// which we will then typeset as a grid. Otherwise we can't do a cleanly formatted
// numeric style.
#let print-bibliography( 
  format-reference: (index, bib-entry, highlighting) => ([REFERENCE],),
  sorting: reference => 0, 
  highlighting: it => it,
  grid-style: (:),
  bibliography-title: "References") = context {

  let bib = bibliography.get()

  // extract references for the cited keys
  let cited-keys = bib-count.final().keys()
  let bibl-unsorted = ()
  for lbl in cited-keys {
    let key = str(lbl)

    if key in bib { // skip references to labels that are not bib keys
      let bib-entry = fix-authors(bib.at(key))
      bibl-unsorted.push(bib-entry)
    }
  }

  // "References" heading
  if bibliography-title != none [
    #heading(bibliography-title, numbering: none)
  ]

  // print formatted references
  // format-reference: (index, reference) -> array(content)
  let sorted = bibl-unsorted.sorted(key: sorting)
  let formatted-references = sorted.enumerate().map(it => format-reference(it.at(0), it.at(1), highlighting))  // -> array(array(content))
  let num-columns = if formatted-references.len() == 0 { 0 } else { formatted-references.at(0).len() }
  let cells = ()

  for index in range(sorted.len()) {
    let reference = sorted.at(index)
    let formatted-reference = formatted-references.at(index)

    // construct first cell of the row, it has to contain the metadata and label
    let meta = (
      kind: "reference-data",
      key: reference.entry_key,
      index: index,
      reference: reference,
      year: paper-year(reference),
      last-names: reference.lastnames 
    )

    let cell0 = [#metadata(meta)#label(reference.entry_key)#formatted-reference.at(0)]
    cells.push(cell0)

    // add all the other cells, if any
    for cell in formatted-reference.slice(1) {
      cells.push(cell)
    }
  }

  if num-columns > 0 {
    // TODO this all looks a little too vertically loose

    let final-grid-style = (columns: num-columns, row-gutter: 1.2em, column-gutter: 0.5em)
    for (key, value) in grid-style.pairs() {
      final-grid-style.insert(key, value)
    }

    grid(..final-grid-style,
      ..cells)
  } else {
    []
  }
}
