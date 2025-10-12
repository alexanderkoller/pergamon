#import "/src/bib-util.typ": *

// #let concatenate-list(names, options) = {


#let default-options = (
    list-middle-delim: ", ",
    list-end-delim-two: " and ",
    list-end-delim-many: ", and ",
)

#let cld(..names, opt:(:)) = concatenate-list(names.pos(), default-options + opt)

// single author
#assert.eq("Koller", cld("Koller"))

// two authors
#assert.eq("Bender and Koller", cld("Bender", "Koller"))

// three authors
#assert.eq("Kandra, Demberg, and Koller", cld("Kandra", "Demberg", "Koller"))

// many authors
#assert.eq("Yao, Du, Zhu, Hahn, and Koller", cld("Yao", "Du", "Zhu", "Hahn", "Koller"))

// change list-end-delim-two
#assert.eq("BenderxxKoller", cld("Bender", "Koller", opt: (list-end-delim-two: "xx")))

// change list-middle-delim
#assert.eq("Kandra :Demberg, and Koller", cld("Kandra", "Demberg", "Koller", opt: (list-middle-delim: " :")))

// change list-delim-many
#assert.eq("Kandra, Demberg and:Koller", cld("Kandra", "Demberg", "Koller", opt: (list-end-delim-many: " and:")))


