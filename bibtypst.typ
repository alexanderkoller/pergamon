
#import "@preview/oxifmt:0.2.1": strfmt
#import "@preview/citegeist:0.1.0": load-bibliography
#import "bib-util.typ": collect-deduplicate
#import "names.typ": parse-names, parse-reference-names



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
  let parsed-names = parse-names(reference, "author") // parse-author-names(reference)
  let lastname-first-authors = ()
  let firstname-first-authors = ()
  let lastnames = ()

  for d in parsed-names {
    let last = d.family
    let first = d.given
    lastname-first-authors.push(strfmt("{}, {}", last, first))
    firstname-first-authors.push(strfmt("{} {}", first, last))
    lastnames.push(last)
  }

  reference.insert("parsed-author-names", parsed-names) // ((first, last), (first, last), ...)
  reference.insert("lastname-first-authors", lastname-first-authors.join(" ")) // for sorting
  reference.insert("authors", concatenate-authors(firstname-first-authors))
  reference.insert("lastnames", lastnames) // (last, last, last, ...) - to construct citations

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

// Generate labels for the references, add extradates to distinguish them where
// necessary, and return the sorted bibliography.
#let label-sort-deduplicate(bibl-unsorted, label-generator, sorting-function) = {
  // Generate preliminary labels; note that the indices we pass to label-generator
  // are meaningless at this point, but they are guaranteed to be all different.
  for (index, reference) in bibl-unsorted.enumerate() {
    let (lbl, lbl-repr) = label-generator(index, reference)
    bibl-unsorted.at(index).insert("label", lbl)
    bibl-unsorted.at(index).insert("label-repr", lbl-repr)
  }

  // Sort and collect label collisions
  let sorted = bibl-unsorted.sorted(key: sorting-function)
  let sorted-labeled = sorted.enumerate().map(pair => (pair.at(1).at("label-repr"), pair.at(0)))
  let grouped = collect-deduplicate(sorted-labeled) // dict label-repr => list(reference-index)

  // Add extradates where needed
  for (lbl-repr, indices) in grouped {
    if indices.len() > 1 {
      let extradate = 0
      for ix in indices {
        sorted.at(ix).at("fields").insert("extradate", extradate)
        extradate += 1
      }
    }
  }

  // Generate final labels
  for (index, reference) in sorted.enumerate() {
    // call label-generator with meaningless indices, just in case it is needed
    let (lbl, lbl-repr) = label-generator(index, reference)
    sorted.at(index).insert("label", lbl)
    sorted.at(index).insert("label-repr", lbl-repr)
  }

  return sorted
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
    format-reference: (index, reference, eval-mode) => ([REFERENCE],),

    /// Generates label information for the given reference. The function takes
    /// the reference and its index in the sorted bibliography as input and returns
    /// values `(label, label-repr)`, where `label` can be anything the style finds
    /// useful for generating the citations and `label-repr` is a string representation
    /// of the label. These string representations are used to detect label collisions,
    /// which cause the generation of extradates.
    /// 
    /// The default implementation simply returns a number that is guaranteed to be
    /// unique to each reference. Styles that want to work with `extradate` will almost
    /// certainly want to pass a different function here.
    /// 
    /// The function passed as `label-generator` does not control whether labels
    /// are printed in the bibliography; it only computes information for internal use.
    /// A style can decide whether it wants to print labels through its `format-reference`
    /// function.
    /// 
    /// Note that `label-repr` _must_ be a `str`.
    /// 
    /// -> function
    label-generator: (index, reference) => (index + 1, str(index + 1)),

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

    /// The output of `format-reference` can be passed through the Typst #link("https://typst.app/docs/reference/foundations/eval/")[eval]
    /// function
    /// for final rendering. This is useful e.g. to typeset math in a paper title correctly.
    /// Pass the `eval` mode in this argument, or pass `none` if you don't want to call
    /// `eval`.
    /// 
    /// -> str | none
    eval-mode: "markup",

    /// The title that will be typeset above the bibliography in the document.
    /// The string given here will be rendered as a first-level heading without numbering.
    /// Pass `none` to suppress the bibliography title.
    /// 
    /// -> str | none
    title: "References",

    /// Bibtex fields that contain names and should be parsed as such. For each X in this list,
    /// #bibtypst will enrich the reference with a field "parsed-X" that contains a list of
    /// dictionaries of name parts, such as ("family": "Smith", "given": "John").
    name-fields: ("author", "editor", "translator")
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
      let ref = parse-reference-names(fix-authors(reference), name-fields) // TTTT TODO remove fix-authors
      bibl-unsorted.push(ref)
    }
  } else {
    let cited-keys = reference-collection.final().keys()
    for lbl in cited-keys {
      let key = str(lbl)

      if key in bib { // skip references to labels that are not bib keys
        let bib-entry = fix-authors(bib.at(key))
        bib-entry = parse-reference-names(bib-entry, name-fields) // TTTT TODO remove fix-authors
        bibl-unsorted.push(bib-entry)
        // [#bib-entry]
      }
    }
  }

  bibl-unsorted = bibl-unsorted.filter(filtering)
  let sorted = label-sort-deduplicate(bibl-unsorted, label-generator, sorting-function)
  let formatted-references = sorted.enumerate().map(it => format-reference(it.at(0), it.at(1), eval-mode))  // -> array(array(content))
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
      // year: paper-year(reference),
      // label: reference.at("label", default: none)
    )

    // store the data in "meta" in a metadata element, so it can later be access through the label
    let cell0 = [#metadata(meta)#label(reference.entry_key)#formatted-reference.at(0)]
    cells.push(cell0)

    // add all the other cells, if any
    for cell in formatted-reference.slice(1) {
      cells.push(cell)
    }
  }


  // "References" heading
  if title != none [
    #heading(title, numbering: none)
  ]

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
