
#import "src/bibtypst.typ": add-bib-resource, refsection, print-bibliography, if-citation, cite, citet, citep, citen, citeg, citename, citeyear, count-bib-entries
#import "src/bibtypst-styles.typ": format-citation-authoryear, format-citation-alphabetic, format-citation-numeric, format-reference
#import "src/names.typ": family-names, format-name
#import "src/bib-util.typ": fd, ifdef, nn, concatenate-names
#import "src/bibstrings.typ": default-bibstring
#import "src/content-to-string.typ": content-to-string
#import "src/templating.typ": commas, periods, spaces, epsilons

#let pergamon-dev = {
  import "src/bibtypst-styles.typ": *
  import "src/printfield.typ": printfield, print-name

  (
    printfield: printfield,
    print-name: print-name,
    authorstrg: authorstrg,
    language: language,
    date: date, 
    labelname: labelname,
    authors-with-year: authors-with-year,
    author: author,
    editor-others: editor-others,
    translator-others: translator-others,
    author-translator-others: author-translator-others,
    volume-number-eid: volume-number-eid,
    issue-date: issue-date,
    issue: issue,
    journal-issue-title: journal-issue-title,
    withothers: withothers,
    bytranslator-others: bytranslator-others,
    byeditor-others: byeditor-others,
    note-pages: note-pages,
    doi-eprint-url: doi-eprint-url,
    addendum-pubstate: addendum-pubstate,
    maintitle: maintitle,
    booktitle: booktitle,
    maintitle-booktitle: maintitle-booktitle,
    maintitle-title: maintitle-title,
    print-event-date: print-event-date,
    event-venue-date: event-venue-date,
    volume-part-if-maintitle-undef: volume-part-if-maintitle-undef,
    series-number: series-number,
    publisher-location-date: publisher-location-date,
    organization-location-date: organization-location-date,
    institution-location-date: institution-location-date,
    chapter-pages: chapter-pages,
    author-editor-others-translator-others: author-editor-others-translator-others,
    require-fields: require-fields,
    driver-article: driver-article,
    driver-inproceedings: driver-inproceedings,
    driver-incollection: driver-incollection,
    driver-book: driver-book,
    driver-misc: driver-misc,
    driver-thesis: driver-thesis,
  )
}
