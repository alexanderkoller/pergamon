
// Limitations:
// - Can't use the same label for a bib entry and as a standalone label (e.g. section reference),
//   but I guess that doesn't make sense anyway.
// - "add-bibliography" can only load a single bibliography for now.

#import "@preview/oxifmt:0.2.1": strfmt
#import "@preview/citegeist:0.1.0": load-bibliography



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

  for (first, last) in parsed-names {
    lastname-first-authors.push(strfmt("{}, {}", last, first))
    firstname-first-authors.push(strfmt("{} {}", first, last))
  }

  reference.insert("lastname-first-authors", lastname-first-authors.join(" ")) // for sorting
  reference.insert("authors", concatenate-authors(firstname-first-authors))

  reference
}



#let bib-count = state("citation-counter", (:))
#let bibliography = state("bibliography", none)

// Unfortunately, we have to `read` the bib file from the Typst document,
// because code in packages can't read files in the working directory.
#let add-bibliography(bibtex_string) = {
  bibliography.update(load-bibliography(bibtex_string))
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
    // this has to be executed unconditionally, because the ref target
    // only changes into a reference once it is cited
    let el = it.element
    let cite-key = str(it.target)

    // collect key of citation
    bib-count.update( dict => {
     dict.insert(cite-key, "1")
     return dict
    })

    if el != none and  el.func() == figure and el.kind == "reference" {
      let bib = bibliography.get()
      let citation = format-citation(bib.at(cite-key))
      link(it.target)[#citation]
    } else {
      it
    }
  }

  show figure: set align(left)

  doc
}

#let print-bibliography( 
  format-reference: (bib-entry, highlighting) => [REFERENCE],
  sorting: reference => 0, 
  highlighting: it => it, 
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
  [#heading(bibliography-title, numbering: none)]

  // print formatted references
  let sorted = bibl-unsorted.sorted(key: sorting)
  for bib-entry in sorted {    
    [#figure( kind: "reference", supplement: none, numbering: n => numbering("[1]", n), [
      #format-reference(bib-entry, highlighting)
    ])
    #label(bib-entry.entry_key)
    ]
  }
}
