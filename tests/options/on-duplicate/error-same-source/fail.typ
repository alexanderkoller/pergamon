#import "/lib.typ": *

#let bib = ```
@article{duplicate,
  author = {Doe, Jane},
  title = {First},
  journal = {Journal},
  year = {2024},
}

@article{duplicate,
  author = {Doe, Jane},
  title = {Second},
  journal = {Journal},
  year = {2025},
}
```.text

#add-bib-resource(bib, on-duplicate: "error")
