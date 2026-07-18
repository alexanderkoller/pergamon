#import "/lib.typ": *
#import "/src/bibtypst.typ": bibliography

#let first = ```
@article{duplicate,
  author = {Doe, Jane},
  title = {First},
  journal = {Journal},
  year = {2024},
}
```.text

#let second = ```
@article{duplicate,
  author = {Doe, Jane},
  title = {Second},
  journal = {Journal},
  year = {2025},
}
```.text

#add-bib-resource(first)
#add-bib-resource(second, on-duplicate: "error")

#context bibliography.get()
