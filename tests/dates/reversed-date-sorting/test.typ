#import "/lib.typ": *

#let bib = ```
@misc{early,
  author = {Doe, Jane},
  title = {Early},
  date = {2024},
}

@misc{middle,
  author = {Doe, Jane},
  title = {Middle},
  date = {2024-03},
}

@misc{late,
  author = {Doe, Jane},
  title = {Late},
  date = {2024-03-14},
}
```.text

#add-bib-resource(bib)

#let fcite = format-citation-numeric()
#let fref = format-reference(reference-label: fcite.reference-label)

#let y-of(section, key) = query(label(section + "-" + key)).first().location().position().y

#refsection(format-citation: fcite.format-citation)[
  #cite("early", "middle", "late")

  #print-bibliography(
    format-reference: fref,
    label-generator: fcite.label-generator,
    sorting: "d",
    reversed: true,
  )

  #context {
    assert(y-of("ref1", "late") < y-of("ref1", "middle"))
    assert(y-of("ref1", "middle") < y-of("ref1", "early"))
  }
]

#refsection(format-citation: fcite.format-citation)[
  #cite("early", "middle", "late")

  #print-bibliography(
    format-reference: fref,
    label-generator: fcite.label-generator,
    sorting: "dd",
    reversed: true,
  )

  #context {
    assert(y-of("ref2", "early") < y-of("ref2", "middle"))
    assert(y-of("ref2", "middle") < y-of("ref2", "late"))
  }
]
