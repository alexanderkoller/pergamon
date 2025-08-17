
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


/// Parses Bibtex references and makes them available to Bibtypst.
/// Due to architectural limitations in Typst, Bibtypst cannot read 
/// Bibtex from a file. You will therefore typically call `read` yourself, like this:
/// #import "@preview/zebraw:0.5.5": *
/// #zebraw(lang: false,
/// ```typ
/// #add-bib-resource(read("bibliography.bib"))
/// ```
/// )
/// 
/// You can call `add-bib-resource` multiple times, and this will add
/// the contents of multiple bib files.
/// 
/// -> none
#let add-bib-resource(
    /// A Bibtex string to be parsed.
    /// -> str
    bibtex_string
  ) = {
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

/// Helper function that conditionally renders a reference to a bibliography entry.
/// The first argument is assumed to be a Typst #link("https://typst.app/docs/reference/model/ref/")[ref]
/// element, obtained e.g. as the argument of a show rule. If this `ref` is a citation
/// pointing to a bibliography entry managed by Bibtypst, the function passes the metadata
/// of this bib entry to the `citation-content` function and returns the content this
/// function generated. Otherwise, the `ref` is passed to `other-content` for further processing.
/// 
/// The primary purpose of `if-citation` is to facilitate the definition of show rules.
/// A typical example is the following show rule, which colors references to my own publications
/// green and all others blue.
/// 
/// ```typ
/// #show ref: it => if-citation(it, value => {
///    if "Koller" in value.reference.lastnames {
///      show link: set text(fill: green)
///      it
///    } else {
///      show link: set text(fill: blue)
///      it
///  }})
/// ```
/// 
/// -> content
#let if-citation(
    /// A Typst `ref` element.
    /// -> ref
    it, 

    /// A function that maps the metadata associated with a Bibtypst reference to
    /// a piece of content. The metadata is a dictionary with keys (reference, index,
    /// key, year, label); `reference` is a reference dictionary (see @sec:reference),
    /// `key` and `year` are those fields from the reference for easy access, `index`
    /// is the position in the bibliography, and `label` is the label that was generated
    /// by the add-label function that was passed to @print-bibliography.
    /// -> function
    citation-content, 

    /// A function that maps the `ref` to a piece of content. The default argument
    /// simply leaves the `ref` untouched, permitting other show rules to trigger and
    /// render it appropriately.
    /// -> function
    other-content: x => x
  ) = {
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

/// Defines a section of the document that shares a bibliography.
/// You need to load a bibliography with the "add-bibliography" function
/// in a place that is earlier than the refsection in rendering order.
/// -> none
#let refsection(
  /// A function that generates the citation string for a given #link(<sec:reference>)[reference].
  /// This function will typically be defined in a Bibtypst style, to be
  /// compatible with the `format-reference` function that is passed to
  /// @print-bibliography. Note that `format-citation` can return any content
  /// it wants, but it does not need to generate a hyperlink to the bibliography;
  /// the citation string is automatically wrapped in a `link` by Bibtypst.
  /// -> function
  format-citation: (reference, form) => [CITATION], 

  /// The section of the document that is to be wrapped in this `refsection`.
  /// -> content
  doc) = {

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

/// Prints the bibliography for the current @refsection.
///
/// -> none
#let print-bibliography( 
    /// A function that renders the reference for inclusion in the
    /// printed bibliography. This function will typically be defined
    /// in a Bibtypst style, to be compatible with the `format-citation`
    /// function that is passed to @refsection.
    /// 
    /// `format-reference` is passed the position of the reference in the
    /// bibliography as a zero-based `int` in the first argument.
    /// It is passed the current #link(<sec:reference>)[reference]
    /// in the second argument.
    /// 
    /// It returns an
    /// array of contents. The elements of this array will be laid out as the columns
    /// of a grid, in the same row, permitting e.g. bibliography layouts with one
    /// column for the reference label and one with the reference itself. For this reason,
    /// all calls to `format-reference` should return arrays of the same length.
    /// 
    /// -> function
    format-reference: (index, bib-entry) => ([REFERENCE],),

    /// A function that enriches a #link(<sec:reference>)[reference] with
    /// extra information. The intended use case is to add a `label` field to the
    /// reference dictionary, based on the authors and year. The added fields are 
    /// guaranteed to be available both
    /// from `format-reference` and from `format-citation` (in @refsection).
    /// 
    /// The `add-label` function takes a reference as argument and returns an (enriched)
    /// reference.
    /// 
    /// -> function
    add-label: reference => reference,

    /// A function that defines the order in which references are shown in the bibliography.
    /// `sorting` takes a #link(<sec:reference>)[reference] as input and returns a value that can be 
    /// #link("https://typst.app/docs/reference/foundations/array/#definitions-sorted")[sorted],
    /// e.g. a number, a string, or an array of sortable values.
    /// 
    /// Alternatively, you can specify a Biblatex-style sorting string. The following strings are
    /// supported:
    /// - `n`: author name (lastname firstname)
    /// - `t`: paper title
    /// - `y` or `d`: the year in which the paper was published; write `yd` or `dd` for descending order
    /// - `v`: volume, if defined
    /// - `a`: the contents of the `label` field (if defined); for the `alphabetic` style, this amounts to the alphabetic paper key
    /// 
    /// For instance, `"nydt"` sorts the references first by author name, then by descending year, then by title.   
    /// Note that Bibtypst currently makes no distinction between the year and the full date.
    /// 
    /// If `none` or the string `"none"` is passed as the `sorting` argument, the references
    /// are sorted in an arbitrary order. There is currently no reliable support for sorting
    /// the references in the order in which they were cited in the document.
    /// 
    /// -> function | str | none
    sorting: none,

    /// Determines whether the printed bibliography should contains all references from the loaded bibliographies
    /// (`true`) or only those that were cited in the current refsection (`false`).
    /// -> bool
    show-all: false,

    /// Filters which references should be included in the printed bibliography. This makes sense only if
    /// `show-all` is `true`, otherwise not all your citations will be resolved to bibliography entries.
    /// The parameter should be a function that takes a #link(<sec:reference>)[reference] as argument
    /// and returns a boolean value. The printed bibliography will contain exactly those references
    /// for which the function returned `true`.
    /// -> function
    /// 
    filtering: reference => true,

    /// A dictionary for styling the #link("https://typst.app/docs/reference/layout/grid/")[grid]
    /// in which the bibliography is laid out. By default, the grid is laid out with `row-gutter: 1.2em` and
    /// `column-gutter: 0.5em`. You can overwrite these values and specify new ones with this argument;
    /// the revised style specification will be passed to the `grid` function.
    /// 
    /// -> dict
    grid-style: (:),

    /// The title that will be typeset above the bibliography in the document.
    /// The string given here will be rendered as a first-level heading without numbering.
    /// Pass `none` to suppress the bibliography title.
    /// 
    /// -> str | none
    title: "References"
  ) = context {

  let bib = bibliography.get()

  // construct sorting function if necessary
  let sorting-function = if type(sorting) == str { construct-sorting(sorting) } else { sorting }
  if sorting-function == none {
    sorting-function = it => 0
  }

  // extract references for the cited keys
  let bibl-unsorted = ()

  if show-all {
    for reference in bib.values() {
      bibl-unsorted.push(fix-authors(reference))
    }
  } else {
    let cited-keys = reference-collection.final().keys()
    for lbl in cited-keys {
      let key = str(lbl)

      if key in bib { // skip references to labels that are not bib keys
        let bib-entry = fix-authors(bib.at(key))
        bibl-unsorted.push(bib-entry)
      }
    }
  }

  bibl-unsorted = bibl-unsorted.filter(filtering)

  // "References" heading
  if title != none [
    #heading(title, numbering: none)
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
