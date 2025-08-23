#import "bibtypst.typ": *
#import "templating.typ": *

// TODO - make these configurable
#let bibstring = (
  "editor": "Ed.",
  "editors": "Eds.",
  "translator": "translator",
  "translators": "translators",
  "in": "In:",
  "volume": "Volume",
  "byeditor": "Edited by",
  "bytranslator": "Translated by",
  "withcommentator": "With a commentary by",
  "withannotator": "With annotations by",
  "withintroduction": "With an introduction by",
  "withforeword": "With a foreword by",
  "withafterword": "With an afterword by"
    
)


#let join-list(list, options) = {
  if list == none or list.len() == 0 {
    none
  } else if list.len() == 1 {
    list.at(0)
  } else {
    let ret = list.at(0)
    for i in range(1, list.len()) {
        if i == list.len() - 1 {
          ret += options.final-list-delim(list)
        }
        ret += list.at(i)
    }
    return ret
  }
}

// Map "modern" Biblatex field names to legacy field names as they
// might appear in the bib file. 
#let field-aliases = (
  "journaltitle": ("journal",)
)

#let fd(reference, field, format: x => x) = {
  if field in reference.fields {
    return format(reference.fields.at(field).trim())
  } else if field in field-aliases {
    for alias in field-aliases.at(field) {
      if alias in reference.fields {
        return format(reference.fields.at(alias).trim())
      }
    }
  } else {
    return none
  }
}



#let ifdef(reference, field, fn) = {
  let value = fd(reference, field)

  if value == none { none } else { fn(value) }
}

// biblatex.def editor+others
#let editor-others(reference, options) = {
  if options.use-editor and fd(reference, "editor") != none {
    // TODO - parse and re-concatenate editors like we do with authors
    // TODO - choose between bibstring.editor and bibstring.editors depending on length of editor list
    [#reference.editor, #bibstring.editor]
  } else {
    none
  }
}

// biblatex.def translator+others
#let translator-others(reference, options) = {
  if options.use-translator and fd(reference, "translator") != none {
    // TODO - parse and re-concatenate editors like we do with authors
    // TODO - choose between bibstring.editor and bibstring.editors depending on length of editor list
    [#reference.translator, #bibstring.translator]
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
  let volume = fd(reference, "volume", format: options.format-volume-periodical)
  let number = fd(reference, "number", format: options.format-number-periodical)

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
    ifdef(reference, "commentator", commentator => spaces(bibstring.withcommentator, commentator)),
    ifdef(reference, "annotator", annotator => spaces(bibstring.withannotator, annotator)),
    ifdef(reference, "introduction", introduction => spaces(bibstring.withintroduction, introduction)),
    ifdef(reference, "foreword", foreword => spaces(bibstring.withforeword, foreword)),
    ifdef(reference, "afterword", afterword => spaces(bibstring.withafterword, afterword))
  )
}

// biblatex.def bytranslator+others
#let bytranslator-others(reference, options) = {
  let translator = fd(reference, "translator")

  periods(
    // TODO bibstring.bytranslator should be expanded as in bytranslator+othersstrg
    ifdef(reference, "translator", translator => spaces(bibstring.bytranslator, translator)),
    withothers(reference, options)
  )
}

// biblatex.def byeditor+others
#let byeditor-others(reference, options) = {
  let editor = fd(reference, "editor")

  periods(
    // TODO bibstring.byeditor should be expanded as in byeditor+othersstrg
    ifdef(reference, "editor", reference => spaces(bibstring.byeditor, editor)),

    // TODO: support editora etc.,  \usebibmacro{byeditorx}%

    bytranslator-others(reference, options)
  )
}

// standard.bbx note+pages
#let note-pages(reference, options) = {
  fjoin(options.bibpagespunct, fd(reference, "note"), fd(reference, "pages"))
}

// biblatex.def eprint
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

// standard.bbx doi+eprint+url
#let doi-eprint-url(reference, options) = {
  periods(
    if options.print-doi { fd(reference, "doi") } else { none },
    if options.print-eprint { eprint(reference, options) } else { none },
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
    format-title: bib-type => {
      if bib-type in ("article", "inbook", "incollection", "inproceedings", "patent", "thesis", "unpublished") {
        it => ["#it"]
      } else if bib-type in ("suppbook", "suppcollection", "suppperiodical") {
        it => it
      } else {
        it => emph(it)
      }
    },
    format-volume-periodical: it => it, // volume field in journals and other periodicals
    format-volume-other: it => [#bibstring.volume #it], // volume field in other bibtypes
    format-number-periodical: it => it,
    format-number-other: it => it,
    format-parens: it => [(#it)],
    format-brackets: it => [[#it]],
    volume-number-separator: ".",
    bibeidpunct: ",",
    bibpagespunct: ",",
    print-isbn: false,
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
        format-volume-periodical: format-volume-periodical,
        format-volume-other: format-volume-other,
        format-number-periodical: format-number-periodical,
        format-number-other: format-number-other,
        format-parens: format-parens,
        format-brackets: format-brackets,
        format-title: format-title(bib-type),
        bibeidpunct: bibeidpunct,
        bibpagespunct: bibpagespunct,
        print-isbn: print-isbn,
        print-url: print-url,
        print-doi: print-doi,
        print-eprint: print-eprint,
        volume-number-separator: volume-number-separator
      )


      if bib-type == "article" {
        // For now, I am mapping both \newunit and \newblock to periods.
        let ret = periods(
          author-translator-others(reference, options),
          options.at("format-title")(url-title-x(reference, options)),
          join-list(fd(reference, "language"), options), // TODO: parse language field
          // TODO: \usebibmacro{byauthor}
          // TODO: \usebibmacro{bytranslator+others}
          fd(reference, "version"),
          spaces(bibstring.in, journal-issue-title(reference, options)),
          byeditor-others(reference, options),
          note-pages(reference, options),
          if print-isbn {  ifdef(reference, "issn", issn => [ISSN #issn]) } else { none },
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