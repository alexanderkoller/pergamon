#import "@preview/bullseye:0.1.0": *
#import "@preview/oxifmt:1.0.0": strfmt
#import "@local/citegeist:0.4.0": load-bibliography
#import "bib-util.typ": collect-deduplicate, fd, expand-parent-references
#import "names.typ": parse-reference-names
#import "dates.typ": get-date, date-year, date-sort-key

#let REFSECTION-END-MARKER = "refsection-end"

#let reference-collection = state("reference-collection", ())
#let bibliography = state("bibliography", (:))
#let local-bibliographies = state("local-bibliographies", ())
#let rendered-citation-count = state("rendered-citation-count", 0)
#let categories = state("categories", (:))


#let current-citation-formatter = state("format-citation", (reference, form, options) => [CITATION], )
#let current-style-bundle = state("style", none) // TODOD: replace none with good default

/// Parses #bibtex references and makes them available to #bibtypst.
/// Due to architectural limitations in Typst, #bibtypst cannot read
/// #bibtex from a file. You will therefore typically call `read` yourself, like this:
/// #import "@preview/zebraw:0.5.5": *
/// #zebraw(lang: false,
/// ```typ
/// #add-bib-resource(read("bibliography.bib"))
/// ```
/// )
///
/// You can call `add-bib-resource` multiple times, and this will add
/// the contents of multiple bib files. By default, duplicate bibliography
/// keys are an error, even if they occur in different source files.
///
/// -> none
#let add-bib-resource(
    /// A #bibtex string to be parsed.
    /// -> str
    bibtex-string,

    /// If `source-id` is not `none`, it is added to all references loaded from
    /// this #bibtex source under the `source-id` field. This can e.g. be used
    /// to filter bibliographies by source id.
    ///
    /// For instance, this value of `filter` for @print-bibliography will only
    /// show the references that were assigned the source id `other.bib`:
    ///
    /// ```
    /// filter: reference => reference.fields.at("source-id", default: none) == "other.bib"
    /// ```
    ///
    /// -> str | none
    source-id: none,

    /// Marks this bibliography resource as _local_. Local bibliographies are
    /// only available within the `refsection` in which they are defined; papers
    /// in these bibliographies cannot be referenced from outside this refsection.
    ///
    /// Pergamon allows you to define the same entry key in both the global
    /// and a local bibliography. In case of such collisions, the entry in the
    /// local bibliography wins.
    ///
    /// Calls to `add-bib-resource` with `local: true` from outside of a
    /// refsection are not allowed and will cause an error message.
    ///
    /// -> bool
    local: false,

    /// Controls whether #pergamon should convert the titles of all
    /// references to #link("https://apastyle.apa.org/style-grammar-guidelines/capitalization/sentence-case")[sentence case].
    ///
    /// If `true`, titles will be converted to sentence case.
    /// If `false`, titles will be typeset with the verbatim capitalization
    /// specified in the #bibtex entries.
    ///
    /// -> bool
    sentence-case-titles: false,

    /// Controls how duplicate bibliography keys are handled. The value
    /// `"error"` aborts with an error, `"keep-first"` keeps the first entry
    /// with a duplicate key, and `"keep-last"` keeps the last entry.
    ///
    /// This policy applies both to duplicates within this #bibtex source and
    /// to duplicates across multiple calls to `add-bib-resource`.
    ///
    /// -> str
    on-duplicate: "error",
  ) = {
    if not on-duplicate in ("error", "keep-first", "keep-last") {
      panic("Unknown on-duplicate policy '" + on-duplicate + "'.")
    }

    let update-bib-dict(old-bib) = {
      for (key, value) in load-bibliography(bibtex-string, sentence-case-titles: sentence-case-titles, on-duplicate: on-duplicate).pairs() {
        if key in old-bib and on-duplicate == "error" {
          panic("Duplicate definition of bibliography key '" + key + "'.")
        } else if key in old-bib and on-duplicate == "keep-first" {
          continue
        }

        // Trim whitespace from all string field values, since citegeist
        // does not guarantee trimmed output.
        for (field-key, field-value) in value.fields.pairs() {
          if type(field-value) == str {
            value.fields.insert(field-key, field-value.trim())
          }
        }

        if source-id != none {
          value.fields.insert("source-id", source-id)
        }

        old-bib.insert(key, value)
      }

      old-bib
    }

    if local  {
      local-bibliographies.update(old-bib-list => {
        if old-bib-list.len() == 0 {
          panic("add-bib-resource(local: true) is only allowed inside a refsection!")
        } else {
          let old-bib = old-bib-list.pop()
          old-bib = update-bib-dict(old-bib)
          old-bib-list.push(old-bib)
          old-bib-list
        }
      })
    } else {
      bibliography.update(old-bib => {
        update-bib-dict(old-bib)
      })
    }
  }
}


/// Adds a category to the given bibliography entries.
/// The primary use of a category is in splitting bibliographies;
/// you could e.g. have one bibliography with highlighted references
/// and another one with the other references by adding some
/// references to a `"highlighted"` category. See the `has-category`
/// function for looking up categories.
///
/// Like in #biblatex, a category is defined globally for the
/// entire document, not per refsection. Calls to `add-category`
/// should come after the call to `add-bib-resource` that loaded
/// the references to which a category is assigned.
#let add-category(
  /// The category to which the keys should be assigned.
  /// -> str
  category,

  /// The entry keys in the bibliography that should be assigned
  /// to the bibliography.
  /// -> arguments
  ..keys
) = {
  for key in keys.pos() {
    categories.update(cat-dict => {
      let cats = cat-dict.at(key, default: ())
      cats.push(category)
      cat-dict.insert(key, cats)
      cat-dict
    })
  }
}

/// Checks whether a bibliography entry has been assigned to the
/// given category. The primary purpose of this function is to be
/// used as a `filter` in `print-bibliography`.
///
/// The `key` argument can be a string; in this case it is interpreted
/// as the Bibtex key of a bibliography entry, and the function checks
/// whether this key has been assigned to the given `category`.
///
/// Alternatively, you can pass a reference dictionary as the `key`
/// argument. In this case, the function will check whether `key.entry_key`
/// has been assigned to the given category.
///
/// -> bool
#let has-category(
  /// The key that should be looked up.
  /// -> str | dict
  key,

  /// The category that should be checked.
  /// -> str
  category
) = {
  let kkey = if type(key) == dictionary and "entry_key" in key {
    key.entry_key
  } else {
    key
  }

  category in categories.get().at(kkey, default: ())
}

// Returns the current refsection identifier.
//
// -> str
#let current-refsection() = {
  let refsection-count = reference-collection.get().len()
  "ref" + str(refsection-count)
}

// Prepends x with the current refsection identifier.
// Can be used to generate globally unique labels for references,
// even when they appear in multiple refsections.
//
// -> str
#let refsectionize(x) = current-refsection() + "-" + x


/// Helper function for rendering the links to a bibliography entry.
/// The first argument is assumed to be a Typst #link("https://typst.app/docs/reference/model/link/")[link]
/// element, obtained e.g. as the argument of a show rule. If this `link` is a citation
/// pointing to a bibliography entry managed by Pergamon, e.g. generated by Pergamon's `cite` function,
/// the function passes the metadata
/// of this bib entry to the `citation-content` function and returns the content this
/// function generated. Otherwise, the `link` is passed to `other-content` for further processing.
///
/// The primary purpose of `if-citation` is to facilitate the definition of show rules.
/// A typical example is the following show rule, which colors references to my own publications
/// green and all others blue.
///
/// #zebraw(lang: false,
/// ```typ
/// #show link: it => if-citation(it, value => {
///    if "Koller" in family-names(value.reference.fields.parsed-author) {
///      set text(fill: green)
///      it
///    } else {
///      set text(fill: blue)
///      it
///  }})
/// ```)
///
/// -> content
#let if-citation(
    /// A Typst `link` element.
    /// -> link
    it,

    /// A function that maps the metadata associated with a Pergamon reference to
    /// a piece of content. The metadata is a dictionary with keys `reference`, `index`, and
    /// `key`. `reference` is a reference dictionary (see @sec:reference),
    /// `key` is the key of the bib entry, and `index`
    /// is the position in the bibliography.
    ///
    /// -> function
    citation-content,

    /// A function that maps the `link` to a piece of content. The default argument
    /// simply leaves the `link` untouched, permitting other show rules to trigger and
    /// render it appropriately.
    /// -> function
    other-content: x => x
  ) = {
    if type(it.dest) == str or type(it.dest) == label {
      let lbl-name = str(it.dest)
      let targets = query(label(lbl-name))

      if targets != none and targets.len() > 0 {
        let meta = targets.first() // reference metadata
        if "value" in meta.fields() and type(meta.value) == dictionary and meta.value.at("kind", default: none) == "reference-data" {
          return citation-content(meta.value)
        }
      }
    }

    return other-content(it)
  }

/// Defines a section of the document with its own bibliography.
/// You need to load a bibliography with the @add-bib-resource function
/// in a place that is earlier than the refsection in rendering order.
///
/// Each refsection is automatically assigned a unique identifier that distinguishes
/// it from all other refsections in the document. These refsection identifiers are
/// used to generate unique Typst labels for all references in the document, even
/// when they represent the same Bibtex key. Users should make no assumptions about
/// the form of these identifiers beyond their uniqueness. Note that unlike in
/// #pergamon 0.6.0 and earlier, it is no longer possible to specify the refsection
/// identifier explicitly.
///
/// -> none
#let refsection(
  /// The citation formatter that should be used to generate citation strings
  /// within this refsection. It typically comes from a citation style.
  ///
  /// A citation formatter is a function that
  /// receives an array of _citation specifications_ as its first
  /// argument, a `form` string as its second argument, and an `options` dictionary
  /// as its third argument. It returns
  /// the content that is displayed in place of a @cite call.
  ///
  /// A citation specification is an array `(lbl, reference)`, where `lbl`
  /// is a citation label and `reference` is a reference dictionary.
  /// The citation formatter is expected to use the information in the reference
  /// dictionary to generate the citation and then embed it in a #link("https://typst.app/docs/reference/model/link/")[link]
  /// to the given label (which is anchored by the reference in the bibliography).
  /// This might look like this:
  /// ```
  /// #link(label(lbl), format(reference))
  /// ```
  ///
  /// In addition to `(lbl, reference)` pairs, the citation specification array
  /// can also contain elements that are strings (i.e. Typst objects of type `str`).
  /// This happens in cases where the
  /// user cites a paper that does not exist in the bibliography. In this case,
  /// the string is the key of the cited paper, and the citation formatter is
  /// expected to render an appropriate error message. The builtin styles
  /// render the key as "*?key?*"".
  ///
  /// The `form` string specifies the exact form in which the citation is rendered;
  /// see @sec:builtin-citation-styles for details. This makes the difference e.g.
  /// between "Smith et al. (2025)" and "(Smith et al. 2025)".
  ///
  /// The `options` dictionary specifies options that control the rendering of the
  /// citation in detail. For instance, the _authoryear_ style accepts
  /// `prefix` and `suffix` arguments. Not every citation style is required to
  /// interpret the same options; see the documentation of the citation style
  /// for details.
  ///
  /// You can pass `auto` in this argument to indicate that you want to use the
  /// same citation formatter as in the previous `refsection`. If you pass `auto`
  /// to the first refsection in the document, #bibtypst will use the dummy
  /// citation formatter `(references, form) => [CITATION]`.
  ///
  /// See the documentation of the `style` parameter for an alternative way
  /// to specify citation formatters.
  ///
  /// -> function | auto
  format-citation: auto,

  /// The style bundle that should be used to typeset citations and
  /// bibliographies within this refsection.
  ///
  /// A style bundle combines citation style and a reference style
  /// in a single dictionary,
  /// as explained in@sec:style-bundles. The citation style will be used
  /// to format citations within the refsection, and the reference style
  /// will be used to typeset the references in all calls to
  /// @print-bibliography within the refsection.
  ///
  /// You will typically specify how to format citations by passing _either_
  /// a `format-citation` _or_ a `style` argument. The `style` argument is
  /// much more convenient, so there is a good chance that this is how most
  /// users will do it. However, you are allowed to specify both `format-citation`
  /// and `style` arguments; in this case, `format-citation` takes precedence.
  /// The `style` will still provide a reference style and label generator
  /// to the `print-bibliography` calls.
  ///
  /// If you pass `auto` as the `style` argument, the refsection will use the
  /// same style as the previous refsection in the document.
  ///
  /// -> dictionary | auto
  style: auto,

  /// The section of the document that is to be wrapped in this `refsection`.
  /// -> content
  doc) = {

  // Reset the keys that are cited in this section. Note that reference-collection
  // is an array of dictionaries, with one element per refsection in the document.
  // The last element of the array collects the references for the current refsection.
  reference-collection.update(rc => {
    rc.push((:))
    rc
  })

  // Append a new element to the list of local bibliographies. Each refsection has
  // its own local bibliography, which is not accessible from the other refsections
  // and shadows any bib entries with the same key from the global bibliographies.
  local-bibliographies.update(lb => {
    lb.push((:))
    lb
  })

  // reset the count of rendered citations to zero
  rendered-citation-count.update(0)

  // Update either the style bundle or the citation formatter.
  // Priority is as follows:
  // 1. If an explicit citation formatter was given, we use it.
  //    Any previous style bundle stays intact, but the citation formatter
  //    takes precedence within this refsection.
  // 2. If an explicit style bundle was given, we use it and
  //    delete any previous citation formatter.
  // 3. If both are `auto`, we reuse the state from the previous refsection.
  if format-citation != auto {
    current-citation-formatter.update(it => format-citation)

    if style != auto {
      // set the style bundle for the reference style,
      // but citation style still takes precedence in get-citation-formatter()
      current-style-bundle.update(it => style)
    }
  } else if style != auto {
    current-style-bundle.update(it => style)
    current-citation-formatter.update(it => none)
  }

  context {
    // check that we have a bibliography loaded
    if bibliography.get() == none {
      panic("Add a bibliography before starting a refsection.")
    }
  }

  doc

  // Add a label at the end of the refsection, so that print-bibliography
  // can access the state of reference-collection at the end of the refsection.
  metadata((kind: REFSECTION-END-MARKER))
}

// Returns the metadata element at the end of the current refsection.
// The location() of this element can be used to retrieve the full set
// of references cited in the refsection, including ones that were only
// cited after the print-bibliography call.
//
// -> metadata
#let find-refsection-end() = {
  let upcoming = query(selector(metadata).after(here()))
  let matching = upcoming.filter(m => {
    let v = m.value
    type(v) == dictionary and v.at("kind", default: none) == REFSECTION-END-MARKER
  })

  if matching.len() > 0 {
    matching.first()
  } else {
    none
  }
}

// Returns the set of all reference keys that were cited in the
// current refsection.
//
// -> array
#let references-at-refsection-end() = {
  let ref-end = find-refsection-end()

  if ref-end != none {
    let loc = ref-end.location()
    reference-collection.at(loc).last().keys()
  } else {
    return ()
  }
}

// Returns the local bibliography for the current refsection.
//
// -> dictionary
#let local-bibliography-at-refsection-end() = {
  let ref-end = find-refsection-end()

  if ref-end != none {
    let loc = ref-end.location()
    local-bibliographies.at(loc).last()
  } else {
    return (:)
  }
}

// Returns the citation formatter for the current refsection.
// If the refsection is controlled by a style bundle, return its
// citation style; otherwise return the current citation style.
#let get-citation-formatter() = {
  if current-citation-formatter.get() == none {
    current-style-bundle.get().at("citation-style")
  } else {
    current-citation-formatter.get()
  }
}

/// Typesets a citation to the bibliography entry with the given keys.
/// The `cite` function keeps track of what `refsection` we are in and
/// uses that refsection's citation formatter to typeset the
/// citation.
///
/// You can pass a single key, `cite(key)`, to typeset a citation of a
/// single reference. Alternatively, you can pass multiple keys,
/// `cite(key1, key2, key3)`, to generate a sequence of citations. Depending
/// on the citation style, this may give you a compact and neat citation,
/// such as "[1, 5]" or "(Author 2020; Other 2021)".
///
/// Note that bib keys are always given as strings in #bibtypst,
/// e.g. `cite("paper1")`. This is in contrast to Typst's builtin cite function,
/// which expects labels.
///
/// You can pass a `form` for finer control over the citation string,
/// depending on what your citation style supports (see   @sec:builtin-citation-styles). If you do not specify
/// the `form`, its default value of `auto` will generate a default form
/// that depends on the citation style.
///
/// You can optionally pass a `prefix` or `suffix` argument to the `cite` call.
/// The authoryear style will place these before or after the main citation,
/// separated by its `prefix-separator` and `suffix-separator` parameters.
///
/// -> content
#let cite(
  /// The keys of the #bibtex entries you want to cite.
  ///
  /// -> arguments
  ..keys,

  /// The citation form.
  ///
  /// -> str | auto
  form: auto,
) = context {
  let format-citation = get-citation-formatter()
  let to-format = ()

  let xkeys = keys.pos()
  let local-bibs = local-bibliographies.get()
  let current-local-bib = if local-bibs.len() == 0 { (:) } else { local-bibs.last() }
  let current-bib = bibliography.get() + current-local-bib

  for key in xkeys {
    if type(key) != str {
      panic("Pergamon's cite function wants strings, but you passed " + str(type(key)) + ": " + str(key))
    }

    // collect individual citations
    reference-collection.update(rc => {
      rc.last().insert(key, 1)
      rc
    })

    // Render the citation.
    let lbl = refsectionize(key)
    let targets = query(label(lbl)) // find metadata object generated by print-bibliography
    if targets.len() == 0 {
      if key in current-bib {
        // On early layout passes, the bibliography label does not exist yet.
        // This is distinct from an actually missing bibliography key.
        to-format.push((kind: "pending-citation", key: key))
      } else {
        to-format.push(key)
      }
    } else if "value" in targets.first().fields() { // not sure why I need this
      // on second pass, we can generate the real citation
      let value = targets.first().value
      // [|#value|]
      to-format.push((lbl, value))
    }
  }

  // call the citation formatter to typeset the citations
  format-citation(to-format, form, keys.named()) // XXX
  // [#format-citation]
}

/// Typesets a citation with the form `"t"`, e.g. "Smith et al. (2020)".
/// See @cite for details.
#let citet(
  /// The keys of the #bibtex entries you want to cite.
  /// -> arguments
  ..keys
) = cite(..keys, form: "t")

/// Typesets a citation with the form `"p"`, e.g. "(Smith et al. 2020)".
/// See @cite for details.
#let citep(
  /// The keys of the #bibtex entries you want to cite.
  /// -> arguments
  ..keys
) = cite(..keys, form: "p")

/// Typesets a citation with the form `"g"`, e.g. "Smith et al.'s (2020)".
/// See @cite for details.
#let citeg(
  /// The keys of the #bibtex entries you want to cite.
  /// -> arguments
  ..keys
) = cite(..keys, form: "g")

/// Typesets a citation with the form `"n"`, e.g. "Smith et al. 2020".
/// See @cite for details.
#let citen(
  /// The keys of the #bibtex entries you want to cite.
  /// -> arguments
  ..keys
) = cite(..keys, form: "n")

/// Typesets a citation with the form `"name"`, e.g. "Smith et al.".
/// See @cite for details.
#let citename(
  /// The keys of the #bibtex entries you want to cite.
  /// -> arguments
  ..keys
) = cite(..keys, form: "name")

/// Typesets a citation with the form `"year"`, e.g. "2020a".
/// See @cite for details.
#let citeyear(
  /// The keys of the #bibtex entries you want to cite.
  /// -> arguments
  ..keys
) = cite(..keys, form: "year")


#let construct-sorting(sorting-string) = {
  let i = 0
  let ret = ()

  if sorting-string == "none" {
    return none
  }

  while i < sorting-string.len() {
    let sort-key = sorting-string.at(i)
    let sorting-function = if sort-key == "y" {
      // year
      let extract-date(reference) = {
        let date = get-date(reference, "date")
        let year = if date != none { date-year(date) } else { none }
        if year != none {
          year
        } else {
          0
        }
      }

      if i+1 < sorting-string.len() and sorting-string.at(i+1) == "d" {
        reference => -extract-date(reference)
        i += 1
      } else {
        reference => extract-date(reference)
      }
    } else if sort-key == "d" {
      // date
      let extract-date(reference, negate-year) = {
        date-sort-key(reference, reversed: negate-year)
      }

      if i+1 < sorting-string.len() and sorting-string.at(i+1) == "d" {
        reference => extract-date(reference, true)
        i += 1
      } else {
        reference => extract-date(reference, false)
      }
    } else if sort-key == "n" {
      // author name
      reference => reference.fields.at("sortstr", default: reference.entry_key)
    } else if sort-key == "t" {
      // paper title
      reference => {
        for fieldname in ("sorttitle", "labeltitle", "title") {
          let value = fd(reference, fieldname, (:))
          if value != none {
            return value.trim()
          }
        }
        reference.entry_key
      }
    } else if sort-key == "v" {
      // volume
      reference => if "volume" in reference.fields { reference.fields.volume } else { "ZZZZZZZZZZ" }
    } else if sort-key == "a" {
      reference => if "label-repr" in reference { reference.label-repr } else if "label" in reference { str(reference.label) } else { "ZZZZZZZZZ" }
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
#let label-sort-deduplicate(bibl-unsorted, label-generator, sorting-function, start-index) = {
  // Generate preliminary labels; note that the indices we pass to label-generator
  // are meaningless at this point, but they are guaranteed to be all different.
  let preliminary-index = start-index
  for (index, reference) in bibl-unsorted.enumerate() {
    let (lbl, lbl-repr) = label-generator(preliminary-index, reference)
    bibl-unsorted.at(index).insert("label", lbl)
    bibl-unsorted.at(index).insert("label-repr", lbl-repr)
    if fd(reference, "shorthand", (:)) == none {
      preliminary-index += 1
    }
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
  let final-index = start-index
  for (index, reference) in sorted.enumerate() {
    let (lbl, lbl-repr) = label-generator(final-index, reference)
    sorted.at(index).insert("label", lbl)
    sorted.at(index).insert("label-repr", lbl-repr)
    if fd(reference, "shorthand", (:)) == none {
      final-index += 1
    }
  }

  return sorted
}

// order in which sortstr fields are used for "n" sorting
#let namefield-sort-order = ("sortstr-sortname", "sortstr-author", "sortstr-editor", "sortstr-translator")

#let populate-labelname(ref, labelname-fields) = {
  let labelname-field = fd(ref, "labelnamefield", (:))
  if labelname-field != none {
    // if labelnamefield specified, try to populate labelname from it
    let parsed-fieldname = "parsed-" + labelname-field
    let value = fd(ref, parsed-fieldname, (:))
    if value != none {
      ref.fields.insert("labelname", value)
      ref.fields.insert("labelnamesource", labelname-field)
    }
  }

  if fd(ref, "labelname", (:)) == none {
    // if populating from labelnamefield didn't work, try the labelname-fields
    for fieldname in labelname-fields {
      let parsed-fieldname = "parsed-" + fieldname
      let value = fd(ref, parsed-fieldname, (:))
      if value != none {
        ref.fields.insert("labelname", value)
        ref.fields.insert("labelnamesource", fieldname)
        break
      }
    }
  }

  ref
}

#let populate-labeltitle(ref, labeltitle-fields) = {
  let labeltitle-field = fd(ref, "labeltitlefield", (:))
  if labeltitle-field != none {
    let value = fd(ref, labeltitle-field, (:))
    if value != none {
      ref.fields.insert("labeltitle", value)
      ref.fields.insert("labeltitlesource", labeltitle-field)
    }
  }

  if fd(ref, "labeltitle", (:)) == none {
    for fieldname in labeltitle-fields {
      let value = fd(ref, fieldname, (:))
      if value != none {
        ref.fields.insert("labeltitle", value)
        ref.fields.insert("labeltitlesource", fieldname)
        break
      }
    }
  }

  ref
}

#let populate-sortstr(ref) = {
  for fieldname in namefield-sort-order {
    let value = fd(ref, fieldname, (:))
    if value != none {
      ref.fields.insert("sortstr", value)
      break
    }
  }

  if fd(ref, "sortstr", (:)) == none {
    for fieldname in ("sorttitle", "labeltitle", "title", "label", "shorthand") {
      let value = fd(ref, fieldname, (:))
      if value != none {
        ref.fields.insert("sortstr", value)
        break
      }
    }
  }

  if fd(ref, "sortstr", (:)) == none {
    ref.fields.insert("sortstr", ref.entry_key)
  }

  ref
}

#let preprocess-reference(reference, name-fields, labelname-fields, labeltitle-fields: ("shorttitle", "title", "maintitle"), use-prefix-in-sorting: false) = {
  let ref = parse-reference-names(reference, name-fields, use-prefix-in-sorting: use-prefix-in-sorting)

  ref = populate-labelname(ref, labelname-fields)
  ref = populate-labeltitle(ref, labeltitle-fields)
  ref = populate-sortstr(ref)

  ref
}


/// Prints the bibliography for the @refsection in which it is contained.
/// This function cannot be used outside of a refsection.
///
/// -> none
#let print-bibliography(
    /// The reference style that should be used to render a reference
    /// into Typst content.
    ///
    /// A reference style is a function that takes two arguments.
    /// It takes the position of the reference in the
    /// bibliography as a zero-based `int` in the first argument.
    /// It takes the #link(<sec:reference>)[reference dictionary]
    /// for the reference
    /// in the second argument.
    ///
    /// The function returns an
    /// array of contents. The elements of this array will be laid out as the columns
    /// of a grid, in the same row, permitting e.g. bibliography layouts with one
    /// column for the reference label and one with the reference itself.
    /// If only one column is needed (e.g. in the authoryear citation style),
    /// `format-reference` should return an array of length one.
    /// All calls to `format-reference` should return arrays of the same length.
    ///
    /// You can pass the value `auto` instead of a function. In this case,
    /// `print-bibliography` will look up the reference formatter from the
    /// style bundle that you passed to the @refsection that surrounds
    /// this call to `print-bibliography`. If you pass `auto` without
    /// specifying a `style` for the refsection, a dummy reference style
    /// will be used.
    ///
    /// -> auto | function
    format-reference: auto,

    /// The label generator that should be used to generate label information
    /// for a reference. This is a function that takes
    /// the reference dictionary and the reference's index in the sorted bibliography as input and returns
    /// an array `(label, label-repr)`, where `label` can be anything the style finds
    /// useful for generating the citations and `label-repr` is a string representation
    /// of the label. These string representations are used to detect label collisions,
    /// which cause the generation of extradates.
    ///
    /// The default implementation simply returns a number that is guaranteed to be
    /// unique to each reference. Styles that want to work with `extradate` will almost
    /// certainly want to pass a different function here.
    ///
    /// The function passed as `label-generator` does not control whether labels
    /// are printed in the bibliography in their own separate column; it only computes information for internal use.
    /// A style can decide whether it wants to print labels through its `format-reference`
    /// function.
    ///
    /// Note that `label-repr` _must_ be a `str`.
    ///
    /// You can pass the value `auto` instead of a function. In this case,
    /// `print-bibliography` will look up the label generator from the
    /// style bundle that you passed to the @refsection that surrounds
    /// this call to `print-bibliography`. If you pass `auto` without
    /// specifying a `style` for the refsection, the default implementation
    /// described above
    /// will be used.
    ///
    /// -> auto | function
    label-generator: auto,

    /// A function that defines the order in which references are shown in the bibliography.
    /// This function takes a #link(<sec:reference>)[reference dictionary] as input and returns a value that can be
    /// #link("https://typst.app/docs/reference/foundations/array/#definitions-sorted")[sorted],
    /// e.g. a number, a string, or an array of sortable values.
    ///
    /// Alternatively, you can specify a #biblatex\-style sorting string. The following strings are
    /// supported:
    /// - `n`: author name (lastname firstname)
    /// - `t`: paper title
    /// - `y`: the year in which the paper was published; write `yd` for descending order
    /// - `d`: the date on which the paper was published; write `dd` for descending order
    /// - `v`: volume, if defined
    /// - `a`: the contents of the `label` field (if defined); for the `alphabetic` style, this amounts to the alphabetic paper key
    ///
    /// For instance, `"nydt"` sorts the references first by author name, then by descending year, then by title.
    ///
    /// See @sec:dates for details on how parsed dates are exposed by Citegeist. If
    /// a field of the publication date (year, month, day) is missing, it is treated
    /// as zero for the purposes of sorting.
    ///
    /// If `none` or the string `"none"` is passed as the `sorting` argument, the references
    /// are sorted in the order in which they are cited in the document.
    ///
    /// -> function | str | none
    sorting: none,

    /// If `true`, name prefixes such as `van` and `de` are included in the
    /// built-in name sorting key `n`. If `false`, names are sorted by family
    /// name without the prefix, e.g. `van Gennep` sorts under `Gennep`.
    ///
    /// -> bool
    use-prefix-in-sorting: false,

    /// Determines whether the printed bibliography should contains all references from the loaded bibliographies
    /// (`true`) or only those that were cited in the current refsection (`false`).
    /// -> bool
    show-all: false,

    /// If a bib entry is specified as the parent of another entry through
    /// `crossref` links, it will be included in the bibliography when enough
    /// of its children have been cited -- even if it wasn't cited itself.
    /// This option specifies how many children must be cited. It
    /// corresponds to `mincrossrefs` in #biblatex.
    ///
    /// -> int
    mincrossrefs: 2,

    /// If a bib entry is specified as the parent of another entry through
    /// `xref` links, it will be included in the bibliography when enough
    /// of its children have been cited -- even if it wasn't cited itself.
    /// This option specifies how many children must be cited. It
    /// corresponds to `minxrefs` in #biblatex.
    ///
    /// -> int
    minxrefs: 2,

    /// Filters which references should be included in the printed bibliography. This makes sense only if
    /// `show-all` is `true`, otherwise not all your citations will be resolved to bibliography entries.
    /// The parameter should be a function that takes a #link(<sec:reference>)[reference dictionary] as argument
    /// and returns a boolean value. The printed bibliography will contain exactly those references
    /// for which the function returned `true`.
    /// -> function
    ///
    filter: reference => true,

    /// A dictionary for styling the #link("https://typst.app/docs/reference/layout/grid/")[grid]
    /// in which the bibliography is laid out. By default, the grid is laid out with `row-gutter: 1.2em` and
    /// `column-gutter: 0.5em`. You can overwrite these values and specify new ones with this argument;
    /// the revised style specification will be passed to the `grid` function.
    ///
    /// -> dictionary
    grid-style: (:),

    /// The title that will be typeset above the bibliography in the document.
    /// The string given here will be rendered as a first-level heading without numbering.
    /// Pass `none` to suppress the bibliography title.
    ///
    /// -> str | content | none
    title: "References",

    /// Whether the title of the bibliography should appear in the document's #link("https://typst.app/docs/reference/model/outline/")[outline].
    ///
    /// -> bool
    outlined: true,

    /// #bibtex fields that contain names and should be parsed as such. For each `X` in this array,
    /// #bibtypst will enrich the reference dictionary with a field `parsed-X` that contains an array of
    /// name-part dictionaries, such as `("family": "Smith", "given": "John")`. See
    /// @sec:reference for an example.
    ///
    /// If the field `X` is not defined in the #bibtex entry, #bibtypst will still insert
    /// a field `parsed-X`; in this case, it will have the value `none`.
    ///
    /// Note that to fully replicate the options `useauthor` / `useeditor` / `usetranslator`
    /// in #biblatex, you will need to both (a) specify the corresponding option in @format-reference
    /// and (b) remove the field from the `name-fields` parameter here. This is because
    /// `name-fields` is used to determine the reference's `labelname`, long before `format-reference`
    /// gets to typeset the reference itself.
    ///
    /// -> array
    name-fields: ("afterword",
        "annotator",
        "author",
        "bookauthor",
        "commentator",
        "editor",
        "editora",
        "editorb",
        "editorc",
        "foreword",
        "holder",
        "introduction",
        "shortauthor",
        "shorteditor",
        "sortname",
        "translator"),

    /// #bibtex fields that will be considered when determining the entry's labelname.
    /// The labelname is the field that will be used when generating the labels for
    /// the _authoryear_ and _alphabetic_ citation styles. Labelnames are computed as follows:
    ///
    /// - If the #bibtex entry specified a field with the name `labelnamefield`, then the
    ///   #bibtex field specified under `labelnamefield` is used.
    /// - Otherwise, the first field name in `labelname-fields` that is defined in the
    ///   #bibtex entry is used.
    /// - If none of these fields is defined, #pergamon will throw an error.
    ///
    /// In either of these cases, the name of the #bibtex field from which the labelname
    /// is taken is stored in the #bibtex field `labelnamesource`.
    ///
    /// #pergamon assumes that the labelname field contains a list of names.
    ///
    /// -> array
    labelname-fields: (
      "shortauthor",
      "author",
      "shorteditor",
      "editor",
      "translator"
    ),

    /// #bibtex fields that will be considered when determining the entry's
    /// labeltitle. The labeltitle is the title-like fallback used by citation
    /// styles when no labelname is available.
    ///
    /// If the #bibtex entry specified a field with the name `labeltitlefield`,
    /// that field is tried before the fields listed here.
    ///
    /// -> array
    labeltitle-fields: (
      "shorttitle",
      "title",
      "maintitle"
    ),

    /// Starts the numbering of entries in this bibliography after the number
    /// specified in this argument. Let's say you typeset two bibliographies in
    /// your document, and the first one has 15 entries. You can pass `15` in
    /// the `resume-after` argument to make the numbering of entries in the second
    /// bibliography start at 16.
    ///
    /// The `index` parameters of functions like `format-reference` and `format-citation`
    /// will receive the sum of resume-after and the actual position in this particular
    /// bibliography as an argument. In the example above, the first reference in the
    /// second bibliography will be called with index=15 (because the count in the
    /// second bibliography is zero-based). The only default citation style that cares
    /// about indices is _numeric_.
    ///
    /// If you have
    /// multiple calls to `print-bibliography` within the same `refsection`,
    /// you can pass `auto` to `resume-after` to seamlessly continue the numbering
    /// across bibliographies within the same refsection. Note that this requires
    /// slightly complex state management, and using the `auto` argument will
    /// require Typst to perform four iterations to make the layout converge
    /// (rather than three for other uses of Pergamon).
    ///
    /// -> int | auto
    resume-after: 0,

    /// Prints the bibliography in reverse order. This does not change the
    /// numbering of the references -- e.g. in the numeric style, the first
    /// reference in the order of the `sorting` order is still called "[1]".
    /// However, if `reversed` is set to `true`, the reference [1] will be
    /// the final reference in the bibliography.
    ///
    /// -> bool
    reversed: false
  ) = context {
  // look up format-reference and label-generator
  let style = current-style-bundle.get()

  let format-reference = if format-reference == auto {
    if style != none {
      style.at("reference-style")
    } else {
      (index, reference) => ([REFERENCE],)
    }
  } else {
    format-reference
  }

  let label-generator = if label-generator == auto {
    if style != none {
      style.at("label-generator")
    } else {
      (index, reference) => (index + 1, str(index + 1))
    }
  } else {
    label-generator
  }


  let start-index = if resume-after == auto { rendered-citation-count.get() } else { resume-after }

  // Combine the local bibliography for this refsection with the global bibliography.
  // In case of duplicate keys, the definition in the local bibliography wins.
  let bib = bibliography.get() + local-bibliography-at-refsection-end()

  // construct sorting function if necessary
  let sorting-function = if type(sorting) == str { construct-sorting(sorting) } else { sorting }
  if sorting-function == none {
    sorting-function = it => 0
  }

  // extract references for the cited keys
  let bibl-unsorted = ()
  let count-references = 0

  if show-all {
    for reference in bib.values() {
      if lower(reference.entry_type) != "xdata" {
        let ref = preprocess-reference(reference, name-fields, labelname-fields, labeltitle-fields: labeltitle-fields, use-prefix-in-sorting: use-prefix-in-sorting)
        bibl-unsorted.push(ref)
      }
    }
  } else {
    let cited-keys = references-at-refsection-end()
    let selected-keys = expand-parent-references(cited-keys, bib, mincrossrefs: mincrossrefs, minxrefs: minxrefs)
    for key in selected-keys {
      if key in bib { // skip references to labels that are not bib keys
        let bib-entry = bib.at(key)
        if lower(bib-entry.entry_type) != "xdata" {
          bib-entry = preprocess-reference(bib-entry, name-fields, labelname-fields, labeltitle-fields: labeltitle-fields, use-prefix-in-sorting: use-prefix-in-sorting)
          bibl-unsorted.push(bib-entry)
        }
      }
    }
  }

  bibl-unsorted = bibl-unsorted.filter(filter)
  let sorted = label-sort-deduplicate(bibl-unsorted, label-generator, sorting-function, start-index)
  let n = sorted.len()
  let formatted-references-original = sorted.enumerate(start: start-index).map(it => format-reference(it.at(0), it.at(1)))
  // -> array(array(content))

  let displayed-indices = if reversed {
    range(sorted.len()).rev()
  } else {
    range(sorted.len())
  }

  let num-columns = if formatted-references-original.len() == 0 { 0 } else { formatted-references-original.at(0).len() }
  let cells = ()

  rendered-citation-count.update(x => x + n)

  // collect cells
  for index in displayed-indices {
    let reference = sorted.at(index)
    let formatted-reference = formatted-references-original.at(index)

    // construct first cell of the row, it has to contain the metadata and label
    let meta = (
      kind: "reference-data",
      key: reference.entry_key,
      index: start-index + index,
      reference: reference,
    )

    // store the data in "meta" in a metadata element, so it can later be access through the label
    let lbl = refsectionize(reference.entry_key)
    let cell0 = [
      #metadata(meta)#label(lbl)#formatted-reference.at(0)
      // Use this to debug #95
      // #linebreak()#repr(formatted-reference)
    ]
    cells.push(cell0)

    // add all the other cells, if any
    for cell in formatted-reference.slice(1) {
      cells.push(cell)
    }
  }

  // "References" heading
  if title != none {
    match-target(
      paged: heading(title, numbering: none, outlined: outlined),
      html: html.elem("h2", attrs: (class: "reference-heading"), title)
    )
  }

  // layout the cells in a grid
  let alignment = if num-columns > 1 { (right, left) } else { (left,) }
  if num-columns > 0 {
    // allow grid-style argument to override default layout parameters
    let final-grid-style = (columns: num-columns, align: alignment, row-gutter: 1.2em, column-gutter: 0.8em, stroke: none)
    for (key, value) in grid-style.pairs() {
      final-grid-style.insert(key, value)
    }

    match-target(
      paged: grid(..final-grid-style, ..cells),
      html: table(columns: num-columns, ..cells)
    )
  } else {
    []
  }
}
