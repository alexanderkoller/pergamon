// Citation-order sorting should be stable when no explicit sorting key is used.
// The bibliography source order is a, b, c; the citation order is c, a, b.
#import "/lib.typ": *

#let bib = ```
@misc{a,
  author = {Alpha, Ann},
  title = {Title A},
  year = {2001},
}

@misc{b,
  author = {Beta, Bob},
  title = {Title B},
  year = {2002},
}

@misc{c,
  author = {Gamma, Gia},
  title = {Title C},
  year = {2003},
}
```.text

#add-bib-resource(bib)

= Bibliography before citations

#refsection(style: numeric-style())[
  #print-bibliography(sorting: none)

  Citations: #cite("c") #cite("a") #cite("b")
]

= Bibliography after citations

#refsection(style: numeric-style())[
  Citations: #cite("c") #cite("a") #cite("b")

  #print-bibliography(sorting: "none")
]

#context {
  let refs = query(selector(metadata))
    .filter(it => {
      let value = it.value
      type(value) == dictionary and value.at("kind", default: none) == "reference-data"
    })
    .map(it => it.value)

  assert.eq(("c", "a", "b", "c", "a", "b"), refs.map(it => it.key))
  assert.eq((0, 1, 2, 0, 1, 2), refs.map(it => it.index))
}
