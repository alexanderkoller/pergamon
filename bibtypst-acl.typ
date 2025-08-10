#import "@preview/oxifmt:0.2.1": strfmt


// make title a hyperlink if DOI or URL are defined
#let url-title(reference) = {
  if "doi" in reference.fields {
    link("https://doi.org/" + reference.fields.doi)[#reference.fields.title.trim()]
  } else if "url" in reference.fields {
    link(reference.fields.url)[#reference.fields.title.trim()]
  } else {
    reference.fields.title.trim()
  }
}


#let paper-type(reference) = reference.entry_type

#let paper-authors(reference) = if "authors" in reference { 
  reference.authors 
} else if "author" in reference.fields {
  let parsed-authors = fix-authors(reference)
  parsed-authors.authors
} else {
  "NO AUTHORS"
}

#let paper-year(reference) = int(reference.fields.year)

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

#let highlight(reference, formatted, highlighting) = {
  if "keywords" in reference.fields and reference.fields.keywords.contains("highlight") {
    highlighting(formatted)
  } else {
    formatted
  }
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


// returns a list of author names, in the form ((first, last), (first, last), ...)
#let parse-author-names(reference) = {
  let ret = ()

  for raw_author in reference.fields.author.split(regex("\s+and\s+")) {
    let match = raw_author.match(regex("(.*)\s*,\s*(.*)"))
    let first = ""
    let last = ""

    if match != none {
      (first, last) = (match.captures.at(1), match.captures.at(0))
    } else {
      match = raw_author.match(regex("(.+)\s+(\S+)"))
      (first, last) = (match.captures.at(0), match.captures.at(1))
    }

    ret.push((first, last))
  }

  return ret
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




