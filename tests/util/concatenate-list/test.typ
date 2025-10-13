#import "/src/bib-util.typ": *
#import "/src/bibstrings.typ": *


#let default-options = (
    list-middle-delim: ", ",
    list-end-delim-two: " and ",
    list-end-delim-many: ", and ",
    bibstring: default-bibstring
)

#let cld(..names, maxnames: 2, minnames: 1, opt:(:)) = concatenate-names(names.pos(), options: opt, maxnames: maxnames, minnames: minnames)

///// for the bibliography: maxnames=99


// single author
#assert.eq("Koller", cld("Koller", maxnames: 99))

// two authors
#assert.eq("Bender and Koller", cld("Bender", "Koller", maxnames: 99))

// three authors
#assert.eq("Kandra, Demberg, and Koller", cld("Kandra", "Demberg", "Koller", maxnames: 99))

// many authors
#assert.eq("Yao, Du, Zhu, Hahn, and Koller", cld("Yao", "Du", "Zhu", "Hahn", "Koller", maxnames: 99))

// change list-end-delim-two
#assert.eq("BenderxxKoller", cld("Bender", "Koller", opt: (list-end-delim-two: "xx"), maxnames: 99))

// change list-middle-delim
#assert.eq("Kandra :Demberg, and Koller", cld("Kandra", "Demberg", "Koller", opt: (list-middle-delim: " :"), maxnames: 99))

// change list-delim-many
#assert.eq("Kandra, Demberg and:Koller", cld("Kandra", "Demberg", "Koller", opt: (list-end-delim-many: " and:"), maxnames: 99))

// et al.
#assert.eq("Yao et al.", concatenate-names(("Yao", "Du", "Zhu", "Hahn", "Koller")))

// two authors, maxnames=1
#assert.eq("Bender et al.", cld("Bender", "Koller", maxnames: 1))

// minnames=2
#assert.eq("Yao, Du et al.", concatenate-names(("Yao", "Du", "Zhu", "Hahn", "Koller"), maxnames: 2, minnames: 2))

// too many minnames
#assert.eq("Bender and Koller", cld("Bender", "Koller", maxnames: 1, minnames: 10))
