#import "/lib.typ": *
#import "/src/bibtypst.typ": bibliography

#let entry(key, title, year) = "
@article{" + key + ",
  author = {Doe, Jane},
  title = {" + title + "},
  journal = {Journal},
  year = {" + year + "},
}
"

#let duplicate-source(key, first-title, second-title) = entry(key, first-title, "2024") + entry(key, second-title, "2025")

#add-bib-resource(duplicate-source("same-source-first", "First", "Second"), on-duplicate: "keep-first")
#add-bib-resource(duplicate-source("same-source-last", "First", "Second"), on-duplicate: "keep-last")

#add-bib-resource(entry("cross-source-first", "First", "2024"))
#add-bib-resource(entry("cross-source-first", "Second", "2025"), on-duplicate: "keep-first")

#add-bib-resource(entry("cross-source-last", "First", "2024"))
#add-bib-resource(entry("cross-source-last", "Second", "2025"), on-duplicate: "keep-last")

#context {
  let bib = bibliography.get()
  assert.eq("First", bib.at("same-source-first").fields.title)
  assert.eq("Second", bib.at("same-source-last").fields.title)
  assert.eq("First", bib.at("cross-source-first").fields.title)
  assert.eq("Second", bib.at("cross-source-last").fields.title)
}
