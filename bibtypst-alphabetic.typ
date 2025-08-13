




#import "bibtypst.typ": url-title, paper-authors, paper-type, paper-year, highlight, parse-author-names
#import "@preview/oxifmt:0.2.1": strfmt



// under the assumption that this is an @article reference, format the journal name + volume + number
#let journal-suffix(reference) = {
  let suffix = ([#emph(reference.fields.journal)],)

  if "volume" in reference.fields {
    if "number" in reference.fields {
      // number + volume
      suffix.push([ ])
      suffix.push(reference.fields.volume)
      suffix.push([(])
      suffix.push(reference.fields.number)
      suffix.push([)])
    } else {
      // number only
      suffix.push([ ])
      suffix.push(reference.fields.volume)
    }
  }

  if "pages" in reference.fields {
    suffix.push([, ])
    suffix.push(reference.fields.pages)
  } 

  suffix.join("")
}


#let add-label-alphabetic(maxalphanames: 3, labelalpha: 3, labelalphaothers: "+") = {
  let labeler(reference) = {
    // TODO - handle the case with no authors
    // TODO - handle the case where reference.fields.label is already defined (then just keep it)
    
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

    reference.insert("label", strfmt("{}{:02}", abbreviation, calc.rem(paper-year(reference), 100)))
    reference
  }

  labeler
}


#let format-reference-alphabetic(highlighting: x => x) = {
  let formatter(index, reference) = {
    let bib-type = paper-type(reference)
    let authors =  paper-authors(reference)
    let award = if "award" in reference.fields { [ #strong(reference.fields.award).] } else { [] }
    let key = reference.entry_key

    let formatted = if bib-type == "misc" {
        [#authors (#paper-year(reference)). #url-title(reference). #reference.fields.howpublished.#award]
    } else if bib-type == "article" {
        [#authors (#paper-year(reference)). #url-title(reference). #journal-suffix(reference).#award]
    } else if bib-type == "inproceedings" {
        [#authors (#paper-year(reference)). #url-title(reference). In _#{reference.fields.booktitle}_.#award]
    } else if bib-type == "incollection" {
        [#authors (#paper-year(reference)). #url-title(reference). In _#{reference.fields.booktitle}_.#award]
    } else if bib-type == "book" {
        [#authors (#paper-year(reference)). _#url-title(reference)_. #reference.fields.publisher.]
        // TODO - distinguish authors and editor(s), cf. https://apastyle.apa.org/style-grammar-guidelines/references/examples/book-references
        // TODO - include edition if specified
    } else {
      [UNKOWN BIB TYPE]
    }

    // let labeled = [#formatted]
    ([[#reference.label]], highlight(reference, formatted, highlighting),) // return length-1 tuple
  }

  return formatter
}


#let format-citation-alphabetic() = {
  let formatter(reference-dict, form) = {
    // keys of reference-dict: key, index, reference, last-names, year
    let fform = if form == auto { auto } else { form(none) } // str or auto

    if fform == "n" {
      [#{reference-dict.label}]
    } else {
      return [[#{reference-dict.label}]]
    }
  }
  formatter
}


#let citep(lbl) = ref(lbl, supplement: it => "p")
#let citet(lbl) = ref(lbl, supplement: it => "t")
#let citeg(lbl) = ref(lbl, supplement: it => "g")
#let citen(lbl) = ref(lbl, supplement: it => "n")