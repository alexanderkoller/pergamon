#import "/src/bibtypst.typ": add-bib-resource, bibliography, cite, preprocess-reference, print-bibliography, refsection
#import "/src/bibstrings.typ": default-long-bibstring
#import "/src/citation-styles.typ": format-citation-authoryear
#import "/src/names.typ": family-names, format-name
#import "/src/printfield.typ": print-name
#import "/src/reference-styles.typ": format-reference

#assert.eq(
  "Arnold van Gennep",
  format-name((given: "Arnold", prefix: "van", family: "Gennep", suffix: "")),
)

#assert.eq(
  "Doe",
  format-name((given: "", prefix: "", family: "Doe", suffix: "")),
)

#assert.eq(
  "JPS d Rousse",
  format-name(
    (
      given: "Jean Pierre Simon",
      prefix: "de la",
      family: "Rousse",
      suffix: "",
      given-initials: "JPS",
      prefix-initials: "d",
    ),
    format: "{g} {p} {family}",
  ),
)

#assert.eq(
  "Jean Pierre Simon de la Rousse",
  format-name(
    (
      given: "Jean Pierre Simon",
      prefix: "de la",
      family: "Rousse",
      suffix: "",
      given-initials: "JPS",
      prefix-initials: "d",
    ),
    format: "{given} {prefix} {family} {suffix}",
  ),
)

#assert.eq(
  ("Gennep", "van Gennep"),
  family-names((
    (given: "Arnold", prefix: "van", family: "Gennep", suffix: ""),
    (given: "Arnold", prefix: "van", family: "Gennep", suffix: "", use-prefix: true),
  )),
)

#let print-options = (
  name-format: "{given} {prefix} {family} {suffix}",
  bibstring: default-long-bibstring,
  list-middle-delim: ", ",
  list-end-delim-two: " and ",
  list-end-delim-many: ", and ",
  minnames: 9999,
  maxnames: 9999,
)

#assert.eq(
  "Maximilian Linhoff et al.",
  print-name((
    (given: "Maximilian", prefix: "", family: "Linhoff", suffix: ""),
    (given: "", prefix: "", family: "others", suffix: ""),
  ), "author", print-options),
)

#let bib = ```
@book{sort-a,
  author = {given=Arnold, prefix=van, family=Gennep},
  title = {A},
  year = {2020},
}

@book{sort-b,
  author = {given=Arnold, prefix=van, family=Gennep, useprefix=true},
  title = {B},
  year = {2020},
}
```.text

#add-bib-resource(bib)

#context {
  let bib = bibliography.get()
  let ref-a-default = preprocess-reference(bib.at("sort-a"), ("author",), ("author",))
  let ref-b-default = preprocess-reference(bib.at("sort-b"), ("author",), ("author",))
  let ref-a-prefix-sort = preprocess-reference(bib.at("sort-a"), ("author",), ("author",), use-prefix-in-sorting: true)

  assert.eq("Gennep,Arnold", ref-a-default.fields.sortstr-author)
  assert.eq("Gennep,Arnold", ref-b-default.fields.sortstr-author)
  assert.eq("van Gennep,Arnold", ref-a-prefix-sort.fields.sortstr-author)
  assert.eq(("Gennep",), family-names(ref-a-default.fields.labelname))
  assert.eq(("van Gennep",), family-names(ref-b-default.fields.labelname))
}

#let fcite = format-citation-authoryear()
#refsection(format-citation: fcite.format-citation)[
  #cite("sort-a", "sort-b")
  #print-bibliography(
    format-reference: format-reference(reference-label: fcite.reference-label),
    label-generator: fcite.label-generator,
    sorting: "n",
    use-prefix-in-sorting: true,
  )
]
