
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

  reference.insert("parsed-author-names", parsed-names) // ((first, last), (first, last), ...)
  reference.insert("lastname-first-authors", lastname-first-authors.join(" ")) // for sorting
  reference.insert("authors", concatenate-authors(firstname-first-authors))
  reference.insert("lastnames", lastnames) // to construct citations

  reference
}



///////// 
///////// Public functions
///////// 


#let reference-collection = state("reference-collection", (:))
#let bibliography = state("bibliography", (:))


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

// Checks whether "it" is a reference (type `ref`) to an item in the bibliography.
// If yes, it retrieves the metadata for that bib item and calls `citation-content`
// on it; citation-content: dictionary => content.
// Otherwise, it evaluates `other-content` on the ref item itself; by default,
// it simply returns the ref item unchanged.
//
// We recognize references to items in the bibliography by the fact
// that they point to a "metadata" element with a dictionary value that
// contains "kind = reference-data". This dictionary value is passed as the
// argument to `citation-content`.

#let if-citation(it, citation-content, other-content: x => x) = {
    let el = it.element
    let cite-key = str(it.target)

    if el != none and el.func() == metadata {
      let target = query(it.target).first()
      if type(target.value) == dictionary and "kind" in target.value and target.value.kind == "reference-data" {
        citation-content(target.value)
      } else {
        other-content(it)
      }
    } else {
      other-content(it)
    }
}

// Defines a section of the document that shares a bibliography.
// You need to load a bibliography with the "add-bibliography" function
// in a place that is earlier than the refsection in rendering order.
// Place the rendered bibliography into the document with the
// "print-bibliography" function.
#let refsection(format-citation: reference => [CITATION], doc) = {
  // reset the keys that are cited in this section
  reference-collection.update((:))

  // check that we have a bibliography loaded
  context {
    if bibliography.get() == none {
      panic("Add a bibliography before starting a refsection.")
    }
  }

  show ref: it => {
    // let el = it.element
    let cite-key = str(it.target)

    // this has to be executed unconditionally, because the ref target
    // only changes into a reference once it is cited
    reference-collection.update( dict => {
     dict.insert(cite-key, "1")
     return dict
    })

    // Format references that are really citations.
    if-citation(it, value => {
      let citation-str = format-citation(value, it.supplement)
      link(it.target)[#citation-str]
    })
  }

  doc
}

#let construct-sorting(sorting-string) = {
  let i = 0
  let ret = ()

  if sorting-string == "none" {
    return none
  }

  while i < sorting-string.len() {
    let sort-key = sorting-string.at(i)
    let sorting-function = if sort-key == "y" or sort-key == "d" {
      // year
      // TODO: currently we ignore the rest of the date if "d" specified, fix that
      if i+1 < sorting-string.len() and sorting-string.at(i+1) == "d" {
        reference => -int(reference.fields.year)
        i += 1
      } else {
        reference => int(reference.fields.year)
      }
    } else if sort-key == "n" {
      // author name
      reference => reference.lastname-first-authors
    } else if sort-key == "t" {
      // paper title
      reference => reference.fields.title.trim()
    } else if sort-key == "v" {
      // volume
      reference => if "volume" in reference.fields { reference.fields.volume } else { "ZZZZZZZZZZ" }
    } else if sort-key == "a" {
      reference => if "label" in reference { reference.label } else { "ZZZZZZZZZ" }
    } else {
      panic(strfmt("Sorting key {} is not implemented yet.", sort-key))
    }

    i += 1
    ret.push(sorting-function)
  }

  it => ret.map(f => f(it))
}

// Prints the bibliography for the current refsection.
#let print-bibliography( 
  format-reference: (index, bib-entry) => ([REFERENCE],),
  add-label: reference => reference,
  sorting: none, 
  grid-style: (:),
  bibliography-title: "References") = context {

  let bib = bibliography.get()

  // construct sorting function if necessary
  let sorting-function = if type(sorting) == str { construct-sorting(sorting) } else { sorting }
  if sorting-function == none {
    sorting-function = it => 0
  }

  // extract references for the cited keys
  let cited-keys = reference-collection.final().keys()
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

  // Format the references, based on format-reference: (index, reference, highlighting) -> array(content).
  // Each call to format-reference returns an array of content, for the columns of one printed reference.
  
  // for styles that have meaningful labels, compute and insert them under the "label" key
  let labeled-bibl-unsorted = bibl-unsorted.map(add-label)
  let sorted = labeled-bibl-unsorted.sorted(key: sorting-function)
  let formatted-references = sorted.enumerate().map(it => format-reference(it.at(0), it.at(1)))  // -> array(array(content))
  let num-columns = if formatted-references.len() == 0 { 0 } else { formatted-references.at(0).len() }
  let cells = ()

  // collect cells
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
      label: reference.at("label", default: none)
    )

    // store the data in "meta" in a metadata element, so it can later be access through the label
    let cell0 = [#metadata(meta)#label(reference.entry_key)#formatted-reference.at(0)]
    cells.push(cell0)

    // add all the other cells, if any
    for cell in formatted-reference.slice(1) {
      cells.push(cell)
    }
  }

  // layout the cells in a grid
  if num-columns > 0 {
    // allow grid-style argument to override default layout parameters
    let final-grid-style = (columns: num-columns, row-gutter: 1.2em, column-gutter: 0.5em)
    for (key, value) in grid-style.pairs() {
      final-grid-style.insert(key, value)
    }

    grid(..final-grid-style, ..cells)
  } else {
    []
  }
}
