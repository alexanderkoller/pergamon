
// #import "@local/bibtypst:0.1.2": url-title, paper-authors, paper-type, paper-year, highlight, parse-author-names
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


#let format-reference-acl(highlighting: x => x) = {
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

    let labeled = [#formatted]

    (highlight(reference, labeled, highlighting),) // return length-1 tuple
  }
  return formatter
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


#let citep(lbl) = ref(lbl, supplement: it => "p")
#let citet(lbl) = ref(lbl, supplement: it => "t")
#let citeg(lbl) = ref(lbl, supplement: it => "g")
#let citen(lbl) = ref(lbl, supplement: it => "n")