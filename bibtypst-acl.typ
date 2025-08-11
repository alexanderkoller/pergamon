
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



#let format-citation-acl(reference) = {
  let parsed-authors = parse-author-names(reference)
  let year = paper-year(reference)

  if parsed-authors.len() == 1 {
    return strfmt("{} ({})", parsed-authors.at(0).at(1), year)
  } else if parsed-authors.len() == 2 {
    return strfmt("{} and {} ({})", parsed-authors.at(0).at(1), parsed-authors.at(1).at(1), year)
  } else {
    return strfmt("{} et al. ({})", parsed-authors.at(0).at(1), year)
  }
}




