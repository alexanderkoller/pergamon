#import "bibtypst.typ": *
#import "templating.typ": *
#import "bibstrings.typ": default-bibstring
#import "printfield.typ": printfield
#import "bib-util.typ": join-list, fd, ifdef, type-aliases, nn




// If, else none. If the `guard` evaluates to `true`,
// evaluate `value-func` and return the result. Otherwise return `none`.
#let ifen(guard, value-func) = {
  if guard {
    value-func()
  } else {
    none
  }
}

// biblatex.def authorstrg
#let authorstrg(reference, options) = {
  printfield(reference, "authortype", options)
  // TODO - implement all the "strg" stuff correctly
}

#let language(reference, options) = {
  join-list(fd(reference, "language", options), options) // TODO: parse language field
}


#let date(reference, options) = {
  epsilons(
    fd(reference, "year", options), // TODO this is probably incomplete
    printfield(reference, "extradate", options)
  )
}

#let authors-with-year(reference, options) = {
  spaces(
    // TODO - make configurable
    reference.authors, // TODO - was \printnames{author}
    ifen(options.print-date-after-authors, () => (options.format-parens)(date(reference, options)))
  )
}

// biblatex.def author
#let author(reference, options) = {
  fjoin(options.author-type-delim,
    authors-with-year(reference, options),
    authorstrg(reference, options)
  )
}

// biblatex.def editor+others
#let editor-others(reference, options) = {
  if options.use-editor and fd(reference, "editor", options) != none {
    // TODO - parse and re-concatenate editors like we do with authors
    // TODO - choose between bibstring.editor and bibstring.editors depending on length of editor list
    [#printfield(reference, "editor", options), #options.bibstring.editor]
  } else {
    none
  }
}

// biblatex.def translator+others
#let translator-others(reference, options) = {
  if options.use-translator and fd(reference, "translator", options) != none {
    // TODO - parse and re-concatenate editors like we do with authors
    // TODO - choose between bibstring.editor and bibstring.editors depending on length of editor list
    [#printfield(reference, "translator", options), #options.bibstring.translator]
  } else {
    none
  }
}

// biblatex.def author/translator+others
#let author-translator-others(reference, options) = {
  if options.use-author and fd(reference, "author", options) != none {
    authors-with-year(reference, options)
  } else {
    translator-others(reference, options)
  }
}


// standard.bbx volume+number+eid
#let volume-number-eid(reference, options) = {
  let volume = printfield(reference, "volume", options)
  let number = printfield(reference, "number", options)

  let a = if volume == none and number == none {
    none
  } else if number == none {
    volume
  } else if volume == none {
    panic("Can't use 'number' without 'volume' (in " + reference.entry_key + "!")
  } else {
    volume + options.volume-number-separator + number
  }

  fjoin(options.bibeidpunct, a, fd(reference, "eid", options))
}





// standard.bbx issue+date
#let issue-date(reference, options) = {
  spaces(
    printfield(reference, "issue", options),
    ifen(not options.print-date-after-authors, () => date(reference, options)),
    format: options.format-parens
  )
}

// biblatex.def issue
// -- in contrast to the original, we include the preceding colon here
#let issue(reference, options) = {
  let issuetitle = fd(reference, "issuetitle", options)
  let issuesubtitle = fd(reference, "issuesubtitle", options)

  if issuetitle == none and issuesubtitle == none {
    none
  } else {
    [: ]
    periods(
      fjoin(options.subtitlepunct, format: options.format-issuetitle, issuetitle, issuesubtitle),
      printfield(reference, "issuetitleaddon", options)
    )
  }
}

// standard.bbx journal+issuetitle
#let journal-issue-title(reference, options) = {
  let jt = fd(reference, "journaltitle", options)
  let jst = fd(reference, "journalsubtitle", options)

  if jt == none and jst == none {
    none
  } else {
    let journaltitle = periods(
      fjoin(options.subtitlepunct, jt, none, format: options.format-journaltitle),
      printfield(reference, "journaltitleaddon", options)
    )

    spaces(
      journaltitle,
      printfield(reference, "series", options),
      volume-number-eid(reference, options),
      issue-date(reference, options),
      issue(reference, options)
    )
  }
}

// biblatex.def withothers
#let withothers(reference, options) = {
  periods(
    ifdef(reference, "commentator", options, commentator => spaces(options.bibstring.withcommentator, commentator)),
    ifdef(reference, "annotator", options, annotator => spaces(options.bibstring.withannotator, annotator)),
    ifdef(reference, "introduction", options, introduction => spaces(options.bibstring.withintroduction, introduction)),
    ifdef(reference, "foreword", options, foreword => spaces(options.bibstring.withforeword, foreword)),
    ifdef(reference, "afterword", options, afterword => spaces(options.bibstring.withafterword, afterword))
  )
}

// biblatex.def bytranslator+others
#let bytranslator-others(reference, options) = {
  let translator = fd(reference, "translator", options)

  periods(
    // TODO bibstring.bytranslator should be expanded as in bytranslator+othersstrg
    ifdef(reference, "translator", options, translator => spaces(options.bibstring.bytranslator, translator)),
    withothers(reference, options)
  )
}

// biblatex.def byeditor+others
#let byeditor-others(reference, options) = {
  let editor = fd(reference, "editor", options)
  // TODO: parse editor names and recombine as for authors

  periods(
    // TODO bibstring.byeditor should be expanded as in byeditor+othersstrg
    ifdef(reference, "editor", options, reference => spaces(options.bibstring.byeditor, editor)),

    // TODO: support editora etc.,  \usebibmacro{byeditorx}%

    bytranslator-others(reference, options)
  )
}

// standard.bbx note+pages
#let note-pages(reference, options) = {
  fjoin(options.bibpagespunct, printfield(reference, "note", options), printfield(reference, "pages", options))
}

// standard.bbx doi+eprint+url
#let doi-eprint-url(reference, options) = {
  periods(
    if options.print-doi { printfield(reference, "doi", options) } else { none },
    if options.print-eprint { printfield(reference, "eprint", options) } else { none },
    if options.print-url { printfield(reference, "url", options) } else { none },
  )
}

// standard.bbx addendum+pubstate
#let addendum-pubstate(reference, options) = {
  periods(
    printfield(reference, "addendum", options),
    printfield(reference, "pubstate", options)
  )
}

#let maintitle(reference, options) = {
  periods(
    fjoin(options.subtitlepunct, 
      printfield(reference, "maintitle", options, style: "titlecase"), 
      printfield(reference, "mainsubtitle", options, style: "titlecase")),
    printfield(reference, "maintitleaddon", options)
  )

  // missing:  {\printtext[maintitle]{
}

#let booktitle(reference, options) = {
  periods(
    fjoin(options.subtitlepunct, 
      printfield(reference, "booktitle", options, style: "titlecase"), 
      printfield(reference, "booksubtitle", options, style: "titlecase")),
    printfield(reference, "booktitleaddon", options)
  )

  // missing:  {\printtext[booktitle]{
}


// standard.bbx maintitle+booktitle
#let maintitle-booktitle(reference, options) = {
  spaces(
    ifdef(reference, "maintitle", options, maintitle => {
      spaces(
        maintitle,
        ifdef(reference, "volume", options, volume => {
          [#printfield(reference, "volume", options)
           #printfield(reference, "part", options):]           
        })
      )
    }),
    booktitle(reference, options)
  )
}

// standard.bbx maintitle+title
#let maintitle-title(reference, options) = {
  let maintitle = fd(reference, "maintitle", options).trim()
  let title = fd(reference, "title", options).trim()
  let print-maintitle = (maintitle != title)

  let volume-prefix = if print-maintitle { epsilons(printfield(reference, "volume", options), printfield(reference, "part", options)) } else { none }

  periods(
    if print-maintitle {
      periods(
        printfield(reference, "maintitle", options),
        printfield(reference, "mainsubtitle", options)
      )
    } else { none },
    fjoin(":", volume-prefix, printfield(reference, "title", options))
  )
}

// TODO: "printeventdate" is referenced from event+venue+date,
// but I can't figure out where it is defined or what it means.
// It is _not_ the year, that comes later.
#let print-event-date(reference, options) = {
  // printfield(reference, "year", options)
  none
}

// standard.bbx event+venue+date
#let event-venue-date(reference, options) = {
  let format-parens = options.at("format-parens")

  spaces(
    periods(
      printfield(reference, "eventtitle", options),
      printfield(reference, "eventtitleaddon", options),
    ),
    format-parens(
      commas(
        printfield(reference, "venue", options),
        print-event-date(reference, options)
      )
    )
  )
}

#let volume-part-if-maintitle-undef(reference, options) = {
  if fd(reference, "maintitle", options) == none {
    spaces(printfield(reference, "volume", options), printfield(reference, "part", options))
  } else {
    none
  }
}

// standard.bbx series+number
#let series-number(reference, options) = {
  spaces(printfield(reference, "series", options), printfield(reference, "number", options))
}

#let xxx-location-date(reference, options, xxx) = {
  commas(
    fjoin(
      ":",
      printfield(reference, "location", options), // Biblatex: printlist{location}
      printfield(reference, xxx, options)
    ),
    ifen(not options.print-date-after-authors, () => date(reference, options))
  )
}

// standard.bbx publisher+location+date
#let publisher-location-date(reference, options) = xxx-location-date(reference, options, "publisher")

// standard.bbx organization+location+date
#let organization-location-date(reference, options) = xxx-location-date(reference, options, "organization")

// standard.bbx institution+location+date
#let institution-location-date(reference, options) = xxx-location-date(reference, options, "institution")


// chapter+pages
#let chapter-pages(reference, options) = {
  fjoin(options.bibpagespunct,
    printfield(reference, "chapter", options),
    printfield(reference, "eid", options),
    printfield(reference, "pages", options)
  )
}

// biblatex.def author/editor+others/translator+others
#let author-editor-others-translator-others(reference, options) = {
  // TODO: implement the "useauthor" option
  first-of(
    author(reference, options),
    editor-others(reference, options),
    translator-others(reference, options)
  )

// \newbibmacro*{author/editor+others/translator+others}{%
//   \ifboolexpr{
//     test \ifuseauthor
//     and
//     not test {\ifnameundef{author}}
//   }
//     {\usebibmacro{author}}
//     {\ifboolexpr{
//        test \ifuseeditor
//        and
//        not test {\ifnameundef{editor}}
//      }
//        {\usebibmacro{editor+others}}
//        {\usebibmacro{translator+others}}}}
}

#let require-fields(reference, options, ..fields) = {
  for field in fields.pos() {
    assert(fd(reference, field, options) != none, message: strfmt("Required field '{}' is missing in entry '{}'!", field, reference.entry_key))
    }
  }
}


#let driver-article(reference, options) = {
    // TODO - it's okay if either year or date is defined
    // -> revamping dates and years is a major coherent work package that I should look at
    require-fields(reference, options, "author", "title", "journaltitle", "year")

    // For now, I am mapping both \newunit and \newblock to periods.
    periods(
      author-translator-others(reference, options),
      printfield(reference, "title", options),
      language(reference, options),
      // TODO: \usebibmacro{byauthor}
      // TODO: \usebibmacro{bytranslator+others}
      //   - the "others" macros construct bibstring keys like "editorstrfo" to
      //     cover multiple roles of the same person at once
      printfield(reference, "version", options),
      spaces(options.bibstring.in, journal-issue-title(reference, options)),
      byeditor-others(reference, options),
      note-pages(reference, options),
      if options.print-isbn { printfield(reference, "issn", options) } else { none },
      doi-eprint-url(reference, options),
      addendum-pubstate(reference, options)

      // TODO: support this at some point [1]
      //   \setunit{\bibpagerefpunct}\newblock
      // \usebibmacro{pageref}%
      // \newunit\newblock
      // \iftoggle{bbx:related}
      //   {\usebibmacro{related:init}%
      //   \usebibmacro{related}}
    )
}



#let driver-inproceedings(reference, options) = {
  // TODO - it's okay if either year or date is defined
  require-fields(reference, options, "author", "title", "booktitle", "year")

  // LIMITATION: If the date (= year) is followed directly by the pages, Biblatex separates
  // them with a comma rather than a period. I think is works because the \setunit in chapter+pages
  // can retroactively modify the end-of-unit marker from publisher+location+date. Bibtypst
  // can't do this without major changes to the way we concatenate strings, so we have to live 
  // with periods for now. (Same for @articles.)

  periods(
    author-translator-others(reference, options),
    printfield(reference, "title", options),
    language(reference, options),
    // TODO:   \usebibmacro{byauthor}%
    spaces(options.bibstring.in, maintitle-booktitle(reference, options)),
    event-venue-date(reference, options),
    byeditor-others(reference, options),
    volume-part-if-maintitle-undef(reference, options),
    printfield(reference, "volumes", options),
    series-number(reference, options),
    printfield(reference, "note", options),
    printfield(reference, "organization", options),
    publisher-location-date(reference, options),
    chapter-pages(reference, options),
    if options.print-isbn { printfield(reference, "isbn", options) } else { none },
    doi-eprint-url(reference, options),
    addendum-pubstate(reference, options)
    
    // TODO see [1] above
  )
}


#let driver-incollection(reference, options) = {
  // TODO - it's okay if either year or date is defined
  require-fields(reference, options, "author", "title", "editor", "booktitle", "year")

  periods(
    author-translator-others(reference, options),
    printfield(reference, "title", options),
    language(reference, options),
    // TODO:   \usebibmacro{byauthor}%
    spaces(options.bibstring.in, maintitle-booktitle(reference, options)),
    byeditor-others(reference, options),
    printfield(reference, "edition", options),
    volume-part-if-maintitle-undef(reference, options),
    printfield(reference, "volumes", options),
    series-number(reference, options),
    printfield(reference, "note", options),
    publisher-location-date(reference, options),
    chapter-pages(reference, options),
    if options.print-isbn { printfield(reference, "isbn", options) } else { none },
    doi-eprint-url(reference, options),
    addendum-pubstate(reference, options)
    
    // TODO see [1] above
  )
}


#let driver-book(reference, options) = {
  // TODO - it's okay if either year or date is defined
  // TODO - it's probably okay if there is an editor rather than an author
  require-fields(reference, options, "author", "title", "year")

  periods(
    author-editor-others-translator-others(reference, options),
    maintitle-title(reference, options),
    language(reference, options),
    // TODO:  \usebibmacro{byauthor}%
    byeditor-others(reference, options),
    printfield(reference, "edition", options),
    volume-part-if-maintitle-undef(reference, options),
    printfield(reference, "volumes", options),
    series-number(reference, options),
    printfield(reference, "note", options),
    publisher-location-date(reference, options),
    chapter-pages(reference, options),
    printfield(reference, "pagetotal", options),
    if options.print-isbn { printfield(reference, "isbn", options) } else { none },
    doi-eprint-url(reference, options),
    addendum-pubstate(reference, options)
    
    // TODO see [1] above
  )
}

#let driver-misc(reference, options) = {
  // TODO - it's okay if either year or date is defined
  require-fields(reference, options, "author", "title", "year")

  periods(
    author-editor-others-translator-others(reference, options),
    printfield(reference, "title", options),
    language(reference, options),
    // TODO:  \usebibmacro{byauthor}%
    byeditor-others(reference, options),
    printfield(reference, "howpublished", options),
    printfield(reference, "type", options),
    printfield(reference, "version", options),
    printfield(reference, "note", options),
    organization-location-date(reference, options), // XX
    doi-eprint-url(reference, options),
    addendum-pubstate(reference, options)
    
    // TODO see [1] above
  )
}


#let driver-thesis(reference, options) = {
  // TODO - it's okay if either year or date is defined
  require-fields(reference, options, "author", "title", "type", "institution", "year")

  periods(
    author(reference, options),
    printfield(reference, "title", options),
    language(reference, options),
    // TODO:  \usebibmacro{byauthor}%
    printfield(reference, "note", options),
    printfield(reference, "type", options),
    institution-location-date(reference, options),
    chapter-pages(reference, options),
    printfield(reference, "pagetotal", options),
    if options.print-isbn { printfield(reference, "isbn", options) } else { none },
    doi-eprint-url(reference, options),
    addendum-pubstate(reference, options)
    
    // TODO see [1] above
  )

}

#let driver-dummy(reference, options) = {
  [UNSUPPORTED REFERENCE (key=#reference.entry_key, bibtype=#reference.entry_type)]
}

// TODO resolve type aliases (phdthesis -> thesis)

#let bibliography-drivers = (
  "article": driver-article,
  "inproceedings": driver-inproceedings,
  "incollection": driver-incollection,
  "book": driver-book,
  "misc": driver-misc,
  "thesis": driver-thesis
)

/// Generates a reference formatter using the specified options.
/// References are formatted essentially as in the standard BibLaTeX.
#let format-reference(
    /// Generates a label to be printed in the first column of the bibliography.
    /// This is useful e.g. for use with the alphabetic and numeric citation style.
    /// By default, the function returns constant `none`, indicating that there
    /// should be no label.
    /// 
    /// This function typically comes from a predefined style (e.g.
    /// authoryear, numeric, alphabetic), or you can define your own.
    /// 
    /// -> function
    reference-label: (index, reference) => none,

    /// Selectively highlights certain bibliography entries. The parameter
    /// is a function that is applied at the final stage of the rendering process,
    /// where the whole rest of the entry has already been rendered. This is
    /// an opportunity to e.g. mark certain entries in the bibliography by
    /// boldfacing them or prepending them with a marker symbol.
    /// 
    /// The highlighting function accepts arguments `rendered-reference`
    /// (`str` or `content` representing the reference as it is printed),
    /// `index` (position of the reference in the bibliography), and
    /// `reference` (the Bibtex reference dictionary). It returns `content`.
    /// The default implementation simply returns the `rendered-reference`
    /// unmodified.
    /// 
    /// -> function
    highlight: (rendered-reference, index, reference) => rendered-reference,

    /// If `true`, titles are rendered as hyperlinks pointing to the reference's
    /// DOI or URL. When both are defined, the DOI takes precedence.
    /// -> bool
    link-titles: true,

    /// If `true`, prints the reference's URL at the end of the bibliography entry.
    /// -> bool
    print-url: false,

    /// If `true`, prints the reference's DOI at the end of the bibliograph entry.
    /// -> bool
    print-doi: false,

    /// If `true`, prints the reference's eprint information at the end of the
    /// bibliography entry. This could be a reference to arXiv or JSTOR.
    /// -> bool
    print-eprint: true,

    /// If `true`, prints the reference's author if it is defined.
    /// -> bool
    use-author: true,

    /// If `true`, prints the reference's translator if it is defined.
    /// Note that support for "authors" that are not the author is currently
    /// weak. See #link("https://github.com/alexanderkoller/bibtypst/issues/28")[issue 28]
    /// to track progress on this.
    /// -> bool
    use-translator: true,

    /// If `true`, prints the reference's editor if it is defined.
    /// Note that support for "authors" that are not the author is currently
    /// weak. See #link("https://github.com/alexanderkoller/bibtypst/issues/28")[issue 28]
    /// to track progress on this.
    /// -> bool
    use-editor: true,

    /// If `true`, Bibtypst will print the date right after the authors, e.g.
    /// 'Smith (2020). "A cool paper".' If `false`, Bibtypst will follow the
    /// normal behavior of BibLaTeX and place the date towards the end of the
    /// reference.
    /// -> bool
    print-date-after-authors: true,

    /// When Bibtypst renders a reference, the title is processed by Typst's
    /// #link("https://typst.app/docs/reference/foundations/eval/")[eval] function.
    /// The `eval-mode` argument you specify here is passed as the `mode` argument
    /// to `eval`. 
    /// 
    /// The default value of `"markup"` renders the title as if it were ordinary
    /// Typst content, typesetting e.g. mathematical expressions correctly.
    /// 
    /// -> str
    eval-mode: "markup",

    /// String that is used to combine the final author in an author list
    /// with the previous authors.
    /// -> str
    final-list-delim: list => if list.len() > 2 { ", and" } else { " and " },


    /// String that is used to combine the name of an author with the author
    /// type, e.g. "Smith, editor".
    /// -> str
    author-type-delim: ",",

    /// String that is used to combine a title with a subtitle.
    /// -> str
    subtitlepunct: ".",

    /// Renders the title of a journal as content. The default argument
    /// typesets it in italics.
    /// -> function
    format-journaltitle: it => emph(it),

    /// Renders the title of a special issue as content. The default argument
    /// typesets it in italics.
    /// -> function
    format-issuetitle: it => emph(it),
  
    /// Wraps text in round brackets. The argument needs to be a function
    /// that takes one argument (`str` or `content`) and returns `content`.
    /// 
    /// It is essential that if the argument is `none`, the function must
    /// also return `none`. This can be achieved conveniently with the `nn`
    /// function wrapper, defined in `bibtypst-styles.typ`.
    /// 
    /// -> function
    format-parens: nn(it => [(#it)]),

    /// Wraps text in square brackets. The argument needs to be a function
    /// that takes one argument (`str` or `content`) and returns `content`.
    /// 
    /// It is essential that if the argument is `none`, the function must
    /// also return `none`. This can be achieved conveniently with the `nn`
    /// function wrapper, defined in `bibtypst-styles.typ`.
    /// 
    /// -> function    
    format-brackets: nn(it => [[#it]]),

    /// Wraps text in double quotes. The argument needs to be a function
    /// that takes one argument (`str` or `content`) and returns `content`.
    /// 
    /// It is essential that if the argument is `none`, the function must
    /// also return `none`. This can be achieved conveniently with the `nn`
    /// function wrapper, defined in `bibtypst-styles.typ`.
    /// 
    /// -> function    
    format-quotes: nn(it => ["#it"]),

    /// Separator symbol for "volume" and "number" fields, e.g. in `@article`s.
    /// -> str
    volume-number-separator: ".",

    /// Separator symbol that connects the EID (Scopus Electronic Identifier)
    /// from other journal information.
    /// -> str
    bibeidpunct: ",",

    /// Separator symbol that connects the "pages" field with related information.
    /// -> str
    bibpagespunct: ",",

    /// If `true`, prints the ISBN or ISSN of the reference if it is defined.
    /// -> bool
    print-isbn: false,

    /// The bibstring table. This is a dictionary that maps language-independent
    /// IDs of bibliographic constants (such as "In: " or "edited by") to
    /// their language-dependent surface forms. Replace some or all of the values
    /// with your own surface forms to control the way the bibliography is rendered.
    /// -> dict
    bibstring: default-bibstring,

    /// An array of additional fields which will be printed at the end of each
    /// bibliography entry. Fields can be specified either as a string, in which case
    /// the field with that name is printed using `printfield`; or they can be
    /// specified as a function `(reference, options) -> content`, in which case the
    /// returned content will be printed directly. Instead of an array, you can also
    /// pass `none` to indicate that no additional fields need to be printed.
    /// 
    /// For example, both of these will work:
    /// ```
    /// additional-fields: ("award",)
    /// additional-fields: ((reference, options) => ifdef(reference, "award", (:), award => [*#award*]),)
    /// ```
    /// 
    /// -> function | none
    additional-fields: none,

    /// An array of field names that should not be printed. References are treated
    /// as if they do not contain values for these fields, even if the Bibtex file
    /// defines them. Instead of an array, you can also pass `none` to indicate that
    /// no fields should be suppressed.
    /// -> array | none
    suppress-fields: none,
  ) = {
    
    let formatter(index, reference, eval-mode) = {
      let suppressed-fields = (:)
      if suppress-fields != none {
        for field in suppress-fields {
          suppressed-fields.insert(field, 1)
        }
      }

      let options = (
        link-titles: link-titles,
        eval-mode: eval-mode,
        use-author: use-author,
        use-translator: use-translator,
        use-editor: use-editor,
        // multi-list-delim: multi-list-delim,
        final-list-delim: final-list-delim,
        author-type-delim: author-type-delim,
        subtitlepunct: subtitlepunct,
        format-journaltitle: format-journaltitle,
        format-issuetitle: format-issuetitle,
        format-parens: format-parens,
        format-brackets: format-brackets,
        format-quotes: format-quotes,
        bibeidpunct: bibeidpunct,
        bibpagespunct: bibpagespunct,
        print-isbn: print-isbn,
        print-url: print-url,
        print-doi: print-doi,
        print-eprint: print-eprint,
        print-date-after-authors: print-date-after-authors,
        volume-number-separator: volume-number-separator,
        bibstring: bibstring,
        suppressed-fields: suppressed-fields
      )

      // process type aliases
      if reference.entry_type in type-aliases {
        reference = type-aliases.at(reference.entry_type)(reference)
      }

      // typeset reference
      let driver = bibliography-drivers.at(lower(reference.entry_type), default: driver-dummy)
      let ret = driver(reference, options)

      // add additional fields, if specified
      if additional-fields != none {
        for field in additional-fields {
          if type(field) == str {
            let value = printfield(reference, field, options)
            if value != none {
              ret += ". "
              ret += value
            }
          } else if type(field) == function {
            let value = field(reference, options)
            if value != none {
              ret += ". "
              ret += value
            }
          }
        }
      }

      // add label if requested
      let lbl = reference-label(index, reference)
      let highlighted = highlight(ret + ".", reference, index)

      if lbl == none {
        (highlighted,)
      } else {
        (lbl, highlighted)
      }
  }

  formatter
}




//////////////////////////////////////////////////////////////////////////
//
// Builtin citation styles:
// alphabetic, numeric, authoryear
// 
////////////////////////////////////////////////////////////////////////////

#let label-parts-alphabetic(reference) = {
  let extradate = if "extradate" in reference.fields {
    numbering("a", reference.fields.extradate + 1)
  } else {
    ""
  }

  (reference.label, extradate)
}

#let format-citation-alphabetic(maxalphanames: 3, labelalpha: 3, labelalphaothers: "+") = {
  let formatter(reference-dict, form) = {
    let fform = if form == auto { auto } else { form(none) } // str or auto
    let (reference-label, extradate) = label-parts-alphabetic(reference-dict.reference)

    if fform == "n" {
      [#reference-label#extradate]
    } else {
      return [[#reference-label#extradate]]
    }
  }

  let label-generator(index, reference) = {
    // TODO - handle the case with no authors
    
    let abbreviation = if reference.lastnames.len() == 1 {
      reference.lastnames.at(0).slice(0, labelalpha)
    } else {
      let first-letters = reference.lastnames.map(s => s.at(0)).join("")
      if reference.lastnames.len() > maxalphanames {
        first-letters.slice(0, maxalphanames) + labelalphaothers
      } else {
        first-letters
      }
    }

    let lbl = strfmt("{}{:02}", abbreviation, calc.rem(paper-year(reference), 100))
    (lbl, lbl)
  }

  let reference-label(index, reference) = {
    let (reference-label, extradate) = label-parts-alphabetic(reference)
    [[#reference-label#extradate]]
  }

  ("format-citation": formatter, "label-generator": label-generator, "reference-label": reference-label)
}

#let format-citation-authoryear(
  /// Wraps text in round brackets. The argument needs to be a function
  /// that takes one argument (`str` or `content`) and returns `content`.
  /// 
  /// It is essential that if the argument is `none`, the function must
  /// also return `none`. This can be achieved conveniently with the `nn`
  /// function wrapper, defined in `bibtypst-styles.typ`.
  /// 
  /// -> function
  format-parens: nn(it => [(#it)]),
) = {
  let formatter(reference-dict, form) = {
    // access precomputed information that was stored in the label field
    let (authors-str, year) = reference-dict.reference.at("label")
    if "extradate" in reference-dict.reference.fields {
      year += numbering("a", reference-dict.reference.fields.extradate + 1)
    }

    // Regrettably, the form has to be specified as either "auto"
    // (a default value) or as a constant function that returns a string.
    // This is because we get the form from a "ref" supplement, which can't
    // have type "string" (it has to be "content"). 

    let fform = if form == auto { auto } else { form(none) } // str or auto
    if fform == "t" {
      strfmt("{} {}", authors-str, format-parens(year))
    } else if fform == "g" {
      strfmt("{}'s {}", authors-str, format-parens(year))
    } else if fform == "n" {
      strfmt("{} {}", authors-str, year)
    } else { // auto or "p"
      format-parens(strfmt("{} {}", authors-str, year))
    }
  }

  let label-generator(index, reference) = {
    let parsed-authors = reference.lastnames
    let year = str(reference.fields.year) // TODO - get rid of the extra year key

    if "extradate" in reference.fields {
      year += numbering("a", reference.fields.extradate + 1)
    }

    let authors-str = if parsed-authors.len() == 1 {
      parsed-authors.at(0)
    } else if parsed-authors.len() == 2 {
      strfmt("{} and {}", parsed-authors.at(0), parsed-authors.at(1))
    } else {
      parsed-authors.at(0) + " et al."
    }

    let lbl = (authors-str, year)
    let lbl-repr = strfmt("{} {}", authors-str, year)

    (lbl, lbl-repr)
  }

  ("format-citation": formatter, "label-generator": label-generator, "reference-label": (index, reference) => none)
}


#let format-citation-numeric() = {
  let formatter(reference-dict, form) = {
    let fform = if form == auto { auto } else { form(none) } // str or auto
    let lbl = reference-dict.reference.label

    if fform == "n" {
      [#{reference-dict.index+1}]
    } else {
      return [[#{reference-dict.index+1}]]
    }
  }

  let label-generator(index, reference) = {
    (index + 1, str(index + 1))
  }

  let reference-label(index, reference) = {
    [[#reference.label]]
  }

  ("format-citation": formatter, "label-generator": label-generator, "reference-label": reference-label)
}