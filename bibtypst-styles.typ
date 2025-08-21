#import "bibtypst.typ": *
#import "templating.typ": *

#let bibstring = (
  "editor": "Ed.",
  "editors": "Eds.",
  "translator": "translator",
  "translators": "translators",
  "in": "In:",
  "volume": "Volume"
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

#let format-reference(
    highlighting: x => x,
    link-titles: true,
    eval-mode: "markup",
    use-author: true,
    use-translator: true,
    use-editor: true,
    multi-list-delim: ", ",
    final-list-delim: list => if list.len() > 2 { ", and" } else { " and " },
    subtitlepunct: "?", // XXX
    format-journaltitle: it => emph(it),
    format-issuetitle: it => emph(it),
    format-series: it => it,
    format-volume-periodical: it => it, // volume field in journals and other periodicals
    format-volume-other: it => [#bibstring.volume #it], // volume field in other bibtypes
    format-number-periodical: it => it,
    format-number-other: it => it,
    format-parens: it => [(#it)],
    volume-number-separator: ".",
    bibeidpunct: ","
    // name-title-delim: ","
  ) = {
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
      bibeidpunct: bibeidpunct,
      volume-number-separator: volume-number-separator
    )

    let formatter(index, reference, eval-mode) = {
      let bib-type = paper-type(reference)

      if bib-type == "article" {
        // For now, I am mapping both \newunit and \newblock to periods.
        let ret = periods(
          author-translator-others(reference, options),
          url-title-x(reference, options),
          join-list(fd(reference, "language"), options), // TODO: parse language field
          // TODO: \usebibmacro{byauthor}
          // TODO: \usebibmacro{bytranslator+others}
          fd(reference, "version"),
          spaces(bibstring.in, journal-issue-title(reference, options)),
        )

        (ret + ".",)
        // ([#reference],)
      } else {
        ([HALLO],)
      }
  }

  formatter
}
/*

  \printfield{version}%
  \newunit\newblock
  \usebibmacro{in:}%
  \usebibmacro{journal+issuetitle}%
  \newunit
  \usebibmacro{byeditor+others}%
  \newunit
  \usebibmacro{note+pages}%
  \newunit\newblock
  \iftoggle{bbx:isbn}
    {\printfield{issn}}
    {}%
  \newunit\newblock
  \usebibmacro{doi+eprint+url}%
  \newunit\newblock
  \usebibmacro{addendum+pubstate}%
  \setunit{\bibpagerefpunct}\newblock
  \usebibmacro{pageref}%
  \newunit\newblock
  \iftoggle{bbx:related}
    {\usebibmacro{related:init}%
     \usebibmacro{related}}
    {}%
  \usebibmacro{finentry}}
  */




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