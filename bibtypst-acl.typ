
// #import "@local/bibtypst:0.1.1": url-title, paper-authors, paper-type, paper-year, highlight, parse-author-names
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


#let format-reference-acl(reference, highlighting) = {
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
  } else {
    [UNKOWN BIB TYPE]
  }

  let labeled = [#formatted]

  highlight(reference, labeled, highlighting)
}


// Regrettably, the form has to be specified as either "auto"
// (a default value) or as a constant function that returns a string.
// This is because we get the form from a "ref" supplement, which can't
// have type "string" (it has to be "content"). 
#let format-citation-acl(reference, form) = {
  let parsed-authors = parse-author-names(reference)
  let year = paper-year(reference)

  let authors-str = if parsed-authors.len() == 1 {
    parsed-authors.at(0).at(1)
  } else if parsed-authors.len() == 2 {
    strfmt("{} and {}", parsed-authors.at(0).at(1), parsed-authors.at(1).at(1))
  } else {
    parsed-authors.at(0).at(1) + " et al."
  }

  if form == auto or form(none) == "p" {
    strfmt("({} {})", authors-str, year)
  } else if form(none) == "t" {
    strfmt("{} ({})", authors-str, year)
  } else {
    strfmt("({} {})", authors-str, year)    
  }
}


#let citep(lbl) = ref(lbl, supplement: it => "p")
#let citet(lbl) = ref(lbl, supplement: it => "t")

