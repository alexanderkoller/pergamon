
// #import "@local/bibtypst:0.1.2": url-title, paper-authors, paper-type, paper-year, highlight, parse-author-names
#import "bibtypst.typ": url-title, paper-authors, paper-type, paper-year, highlight, parse-author-names
#import "@preview/oxifmt:0.2.1": strfmt



// under the assumption that this is an @article reference, format the journal name + volume + number
#let journal-suffix(reference) = {
  let suffix = [#emph(reference.fields.journal)]

  if "volume" in reference.fields {
    if "number" in reference.fields {
      // number + volume

      suffix += [ *#reference.fields.volume*(#reference.fields.number)]
    } else {
      // number only
      suffix += [ #reference.fields.volume]
    }
  }

  suffix += [ (#paper-year(reference))]

  if "pages" in reference.fields {
    suffix += [, pp. #reference.fields.pages]
  } 

  return suffix 
}


#let format-reference-numeric(highlighting: x => x) = {
  let formatter(index, reference) = {
    let bib-type = paper-type(reference)
    let authors =  paper-authors(reference)
    let award = if "award" in reference.fields { [ #strong(reference.fields.award).] } else { [] }
    let key = reference.entry_key

    let formatted = if bib-type == "misc" {
        // Author/Org. *Title* or “Title”. [Howpublished/Note.] [Year.] [URL]
        [#authors. "#url-title(reference)". #reference.fields.howpublished. #paper-year(reference).]
    } else if bib-type == "article" {
        // Author(s). “Title.” Journal Name 〈volume〉[〈number〉] (〈year〉), pp. 〈pages〉[. DOI/URL]
        [#authors. "#url-title(reference)". #journal-suffix(reference).]
    } else if bib-type == "inproceedings" or bib-type == "incollection" {
        // Author(s). “Chapter Title.” In: *Collection Title*. Ed. by Editor(s). Place: Publisher, Year, pp. 〈pages〉. [DOI/URL]
        [#authors. "#url-title(reference)." In: _#{reference.fields.booktitle}_, #paper-year(reference).]
    } else if bib-type == "book" {
        // Author(s)/Editor(s). *Title*. [Edition.] Place: Publisher, Year. [DOI/URL]
        [#authors. _#url-title(reference)_. #reference.fields.publisher, #paper-year(reference).]
        // TODO - distinguish authors and editor(s), cf. https://apastyle.apa.org/style-grammar-guidelines/references/examples/book-references
        // TODO - include edition if specified
    } else {
      [UNKOWN BIB TYPE]
    }

    let labeled = [#formatted]

    (
      [[#{index+1}]],
      highlight(reference, labeled, highlighting)
    )
  }

  return formatter
}

#let format-citation-numeric() = {
  let formatter(reference-dict, form) = {
    // keys of reference-dict: key, index, reference, last-names, year
    let fform = if form == auto { auto } else { form(none) } // str or auto

    if fform == "n" {
      [#{reference-dict.index+1}]
    } else {
      return [[#{reference-dict.index+1}]]
    }
  }
  formatter
}
