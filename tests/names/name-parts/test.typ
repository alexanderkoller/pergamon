#import "/src/bibtypst.typ": add-bib-resource, bibliography, cite, preprocess-reference, print-bibliography, refsection
#import "/src/bibstrings.typ": default-long-bibstring
#import "/src/citation-styles.typ": format-citation-alphabetic, format-citation-authoryear
#import "/src/names.typ": family-names, format-name, labelalpha-name
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

#assert.eq(
  "Sau",
  labelalpha-name((given: "Ferdinand", prefix: "de", family: "Saussure", suffix: ""), family-width: 3),
)

#assert.eq(
  "dSau",
  labelalpha-name((given: "Ferdinand", prefix: "de", family: "Saussure", suffix: "", use-prefix: true), family-width: 3),
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

@book{saussure-no-prefix,
  author = {given=Ferdinand, prefix=de, family=Saussure},
  title = {Course},
  year = {1916},
}

@book{saussure-prefix,
  author = {given=Ferdinand, prefix=de, family=Saussure, useprefix=true},
  title = {Course With Prefix},
  year = {1917},
}

@book{multi-prefix,
  author = {given=Ferdinand, prefix=de, family=Saussure, useprefix=true and given=Noam, family=Chomsky},
  title = {Multi},
  year = {2026},
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

  let authoryear = format-citation-authoryear()
  assert.eq(("Gennep", "2020", none), (authoryear.label-generator)(0, ref-a-default).first())
  assert.eq(("van Gennep", "2020", none), (authoryear.label-generator)(0, ref-b-default).first())

  let alphabetic = format-citation-alphabetic()
  let ref-saussure-no-prefix = preprocess-reference(bib.at("saussure-no-prefix"), ("author",), ("author",))
  let ref-saussure-prefix = preprocess-reference(bib.at("saussure-prefix"), ("author",), ("author",))
  let ref-multi-prefix = preprocess-reference(bib.at("multi-prefix"), ("author",), ("author",))
  assert.eq("Sau16", (alphabetic.label-generator)(0, ref-saussure-no-prefix).first())
  assert.eq("dSau17", (alphabetic.label-generator)(0, ref-saussure-prefix).first())
  assert.eq("dSC26", (alphabetic.label-generator)(0, ref-multi-prefix).first())
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
