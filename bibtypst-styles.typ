#import "bibtypst.typ": *
#import "templating.typ": *
#import "bibstrings.typ": default-bibstring
#import "printfield.typ": printfield
#import "bib-util.typ": join-list, fd, ifdef

// biblatex.def editor+others
#let editor-others(reference, options) = {
  if options.use-editor and fd(reference, "editor") != none {
    // TODO - parse and re-concatenate editors like we do with authors
    // TODO - choose between bibstring.editor and bibstring.editors depending on length of editor list
    [#printfield(reference, "editor", options), #options.bibstring.editor]
  } else {
    none
  }
}

// biblatex.def translator+others
#let translator-others(reference, options) = {
  if options.use-translator and fd(reference, "translator") != none {
    // TODO - parse and re-concatenate editors like we do with authors
    // TODO - choose between bibstring.editor and bibstring.editors depending on length of editor list
    [#printfield(reference, "translator", options), #options.bibstring.translator]
  } else {
    none
  }
}

// biblatex.def author/translator+others
#let author-translator-others(reference, options) = {
  if options.use-author and fd(reference, "author") != none {
    // TODO - make configurable
    reference.authors
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

  fjoin(options.bibeidpunct, a, fd(reference, "eid"))
}



#let date(reference, options) = fd(reference, "year") // TODO this is probably incomplete

// standard.bbx issue+date
#let issue-date(reference, options) = {
  spaces(
    fd(reference, "issue"),
    date(reference, options),
    format: options.format-parens
  )
}

// biblatex.def issue
// -- in contrast to the original, we include the preceding colon here
#let issue(reference, options) = {
  let issuetitle = fd(reference, "issuetitle")
  let issuesubtitle = fd(reference, "issuesubtitle")

  if issuetitle == none and issuesubtitle == none {
    none
  } else {
    [: ]
    periods(
      fjoin(options.subtitlepunct, format: options.format-issuetitle, issuetitle, issuesubtitle),
      fd(reference, "issuetitleaddon")
    )
  }
}

// standard.bbx journal+issuetitle
#let journal-issue-title(reference, options) = {
  let jt = fd(reference, "journaltitle")
  let jst = fd(reference, "journalsubtitle")

  if jt == none and jst == none {
    none
  } else {
    let journaltitle = periods(
      fjoin(options.subtitlepunct, jt, none, format: options.format-journaltitle),
      fd(reference, "journaltitleaddon")
    )

    spaces(
      journaltitle,
      fd(reference, "series", format: options.format-series),
      volume-number-eid(reference, options),
      issue-date(reference, options),
      issue(reference, options)
    )
  }
}

// biblatex.def withothers
#let withothers(reference, options) = {
  periods(
    ifdef(reference, "commentator", commentator => spaces(options.bibstring.withcommentator, commentator)),
    ifdef(reference, "annotator", annotator => spaces(options.bibstring.withannotator, annotator)),
    ifdef(reference, "introduction", introduction => spaces(options.bibstring.withintroduction, introduction)),
    ifdef(reference, "foreword", foreword => spaces(options.bibstring.withforeword, foreword)),
    ifdef(reference, "afterword", afterword => spaces(options.bibstring.withafterword, afterword))
  )
}

// biblatex.def bytranslator+others
#let bytranslator-others(reference, options) = {
  let translator = fd(reference, "translator")

  periods(
    // TODO bibstring.bytranslator should be expanded as in bytranslator+othersstrg
    ifdef(reference, "translator", translator => spaces(options.bibstring.bytranslator, translator)),
    withothers(reference, options)
  )
}

// biblatex.def byeditor+others
#let byeditor-others(reference, options) = {
  let editor = fd(reference, "editor")

  periods(
    // TODO bibstring.byeditor should be expanded as in byeditor+othersstrg
    ifdef(reference, "editor", reference => spaces(options.bibstring.byeditor, editor)),

    // TODO: support editora etc.,  \usebibmacro{byeditorx}%

    bytranslator-others(reference, options)
  )
}

// standard.bbx note+pages
#let note-pages(reference, options) = {
  fjoin(options.bibpagespunct, fd(reference, "note"), printfield(reference, "pages", options))
}

// standard.bbx doi+eprint+url
#let doi-eprint-url(reference, options) = {
  periods(
    if options.print-doi { fd(reference, "doi") } else { none },
    if options.print-eprint { printfield(reference, "eprint", options) } else { none },
    if options.print-url { fd(reference, "url") } else { none },
  )
}

// GLOBAL TODO: check DeclareFieldFormat for all printfield commands
/*

\DeclareFieldFormat{eprint}{%
  
\DeclareFieldFormat{eprint:hdl}{%
  
\DeclareFieldAlias{eprint:HDL}{eprint:hdl}
\DeclareFieldFormat{eprint:arxiv}{%
  
\DeclareFieldAlias{eprint:arXiv}{eprint:arxiv}
\DeclareFieldFormat{eprint:jstor}{%

\DeclareFieldAlias{eprint:JSTOR}{eprint:jstor}
\DeclareFieldFormat{eprint:pubmed}{%
  
\DeclareFieldAlias{eprint:PubMed}{eprint:pubmed}
\DeclareFieldFormat{eprint:googlebooks}{%
  
\DeclareFieldAlias{eprint:Google Books}{eprint:googlebooks}
*/

#let format-reference(
    highlighting: x => x,
    link-titles: true,
    print-url: false,
    print-doi: false,
    print-eprint: true,
    eval-mode: "markup",
    use-author: true,
    use-translator: true,
    use-editor: true,
    multi-list-delim: ", ",
    final-list-delim: list => if list.len() > 2 { ", and" } else { " and " },
    subtitlepunct: ".",
    format-journaltitle: it => emph(it),
    format-issuetitle: it => emph(it),
    format-series: it => it,
    format-parens: it => [(#it)],
    format-brackets: it => [[#it]],
    format-quotes: it => ["#it"],
    volume-number-separator: ".",
    bibeidpunct: ",",
    bibpagespunct: ",",
    print-isbn: false,
    bibstring: default-bibstring
    // name-title-delim: ","
  ) = {
    
    let formatter(index, reference, eval-mode) = {
      let bib-type = paper-type(reference)
      let options = (
        link-titles: link-titles,
        eval-mode: eval-mode,
        use-author: use-author,
        use-translator: use-translator,
        use-editor: use-editor,
        multi-list-delim: multi-list-delim,
        final-list-delim: final-list-delim,
        subtitlepunct: subtitlepunct,
        format-journaltitle: format-journaltitle,
        format-series: format-series,
        format-parens: format-parens,
        format-brackets: format-brackets,
        format-quotes: format-quotes,
        bibeidpunct: bibeidpunct,
        bibpagespunct: bibpagespunct,
        print-isbn: print-isbn,
        print-url: print-url,
        print-doi: print-doi,
        print-eprint: print-eprint,
        volume-number-separator: volume-number-separator,
        bibstring: bibstring
      )


      if bib-type == "article" {
        // For now, I am mapping both \newunit and \newblock to periods.
        let ret = periods(
          author-translator-others(reference, options),
          printfield(reference, "title", options),
          join-list(fd(reference, "language"), options), // TODO: parse language field
          // TODO: \usebibmacro{byauthor}
          // TODO: \usebibmacro{bytranslator+others}
          printfield(reference, "version", options),
          spaces(options.bibstring.in, journal-issue-title(reference, options)),
          byeditor-others(reference, options),
          note-pages(reference, options),
          if print-isbn { printfield(reference, "issn", options) } else { none },
          doi-eprint-url(reference, options),
          // addendum-pubstate(reference, options)

          // \usebibmacro{addendum+pubstate}%
          // 
          // 
          // 
          // TODO: support this at some point
          //   \setunit{\bibpagerefpunct}\newblock
          // \usebibmacro{pageref}%
          // \newunit\newblock
          // \iftoggle{bbx:related}
          //   {\usebibmacro{related:init}%
          //   \usebibmacro{related}}
        )

        (ret + ".",)
        // ([#reference],)
      } else {
        ([HALLO],)
      }
  }

  formatter
}



// Regrettably, the form has to be specified as either "auto"
// (a default value) or as a constant function that returns a string.
// This is because we get the form from a "ref" supplement, which can't
// have type "string" (it has to be "content"). 
#let format-citation-acl() = {
  let formatter(reference-dict, form) = {
    // keys of reference-dict: key, index, reference, year

    let parsed-authors = reference-dict.reference.lastnames
    let year = reference-dict.year

    let authors-str = if parsed-authors.len() == 1 {
      parsed-authors.at(0)
    } else if parsed-authors.len() == 2 {
      strfmt("{} and {}", parsed-authors.at(0), parsed-authors.at(1))
    } else {
      parsed-authors.at(0) + " et al."
    }

    let fform = if form == auto { auto } else { form(none) } // str or auto

    if fform == "t" {
      strfmt("{} ({})", authors-str, year)
    } else if fform == "g" {
      strfmt("{}'s ({})", authors-str, year)
    } else if fform == "n" {
      strfmt("{} {}", authors-str, year)
    } else { // auto or "p"
      strfmt("({} {})", authors-str, year)    
    }
  }
  formatter
}