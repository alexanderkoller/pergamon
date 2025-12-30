// #import "@preview/layout-ltd:0.1.0": layout-limiter
// #show: layout-limiter.with(max-iterations: 2) // AAA check this


#import "lib.typ": *
#let dev = pergamon-dev

#let darkgreen = green.darken(20%)
#let darkblue = blue.darken(20%)

#show link: set text(fill: darkblue)

#set heading(numbering: "1.1")

// Author-Year:
// #let fcite = format-citation-authoryear()

// Alphabetic:
// #let fcite = format-citation-alphabetic()

// Numeric:
#let fcite = format-citation-numeric(compact: true)

#let marker = text(size: 8pt)[#emoji.star] 

#let fref = format-reference(
  reference-label: fcite.reference-label,
  name-format: "{given} {family}",
  // name-format: (
  //   "author": "{given} {family}",
  //   "editor": "{g}. {family}"
  // ),
  print-date-after-authors: true,
  format-quotes: it => it,
  // print-identifiers: ("doi", "url"),
  // print-doi: true,
  suppress-fields: (
    "*": ("month", "day",),
    "inproceedings": ("editor", "publisher", "pages", "location")
  ),
  eval-scope: ("todo": x => text(fill: red, x)),
  // suppress-fields: ("*": ("pages",), "inproceedings": ("editor", "publisher") ),
  // additional-fields: ("award",),
  //  period: ",",
  // additional-fields: ((reference, options) => ifdef(reference, "award", (:), award => [*#award*]),),
  highlight: (x, reference, index) => {
    if "highlight" in reference.fields.at("keywords", default: ()) {
      place(dx: -1.5em, dy: -0.15em, marker)
    }
    x
  },

  // Override bibstring entries like this:
  bibstring: ("in": "In"),
  bibstring-style: "long",

  format-fields: (
    // highlight my name in all references
    "author": (dffmt, value, reference, field, options, style) => {
      let formatted-names = value.map(d => {
        let highlighted = (d.family == "Koller")
        let name = format-name(d, name-type: "author", format: options.name-format)
        if highlighted { strong(name) } else { name }
      })

      concatenate-names(formatted-names, maxnames: 999)
    },
  )
)




#let sorting = "nyt"


#add-bib-resource(read("bibs/bibliography.bib"))
#add-bib-resource(read("bibs/other.bib"))
#add-bib-resource(read("bibs/physics.bib"))

#refsection(format-citation: fcite.format-citation)[ // id: "hallo", 
  // This show rule has to come inside the refsection, otherwise it is
  // overwritten by the show rule that is defined in refsection's source code.
  // It colors the citation links based on whether the reference is to a PI publication.
  #show link: it => if-citation(it, value => {
    let color = if "Koller" in family-names(value.reference.fields.labelname) { darkgreen } else { darkblue }
    set text(fill: color)
    it
  })
  
  #set par(justify: true)

  = Introduction <sec:intro>
  To reproduce \#78:
  #context {
    let hdr = query(heading).first()
    link(hdr.location())[#hdr.body]
  }

  = Another section

  to test \#129: #cite("bender20:_climb_nlu", "brownschmidt_2018_perspectivetaking", "test_entry2", "clls", "nodate", "xxxxx", "yyyy")

  citet: !#citet("modelizer-24", "modelizer-24")!

  citep: #citep("bender20:_climb_nlu", "knuth1990")

  citeg: #citeg("kandra-bsc-25", "kandra-bsc-25")

  citen: #citen("yang2025goescrosslinguisticstudyimpossible", "yang2025goescrosslinguisticstudyimpossible")

  "citations" of non-references should fail: #cite("sec:intro") // AAA

  #citename("kandra-bsc-25")

  #citeyear("bender20:_climb_nlu")

  #cite("irtg-sgraph-15")

  #cite("wu-etal-2024-reasoning", "knuth1990")
    #cite("yao2025language")
    #cite("hershcovichItMeaningThat2021")
  #cite("abgrallMeasurementsppmKpm2016")
    #cite("kuhlmann2003tiny") #cite("fake-mastersthesis")

  #cite("multi1") #citen("multi2")

  to test trailing punctuation: #cite("tedeschi-etal-2023-whats")

  to test editors: #cite("hempel1965science")

  to test prefix and suffix: #cite("tedeschi-etal-2023-whats", prefix: "e.g. ", suffix: ", page 17")

  to test undefined citations: #cite("DOES-NOT-EXIST", "tedeschi-etal-2023-whats")

  to test journal subtitles: #cite("clls")

  to test nodate: #cite("nodate")

  to test books editor instead of author, \#88: #cite("Dorfles1969")

  to test \#91: #cite("Ruwitch2025AISlop")

  paper with byeditor: #cite("brownschmidt_2018_perspectivetaking")

  to test tracl \#17: #cite("abid2019gradio")

  to test \#131: #citen("abid2019gradio", prefix: "see", suffix: "page 17")

  Multi-citation with prefix and suffix: #cite("wu-etal-2024-reasoning", "knuth1990", prefix: "see", suffix: "and elsewhere")

  // to test \#130: #cite(<irtg-sgraph-15>)

  // #set par(hanging-indent: 1em)
  #print-bibliography(format-reference: fref, sorting: sorting,
    // reversed: true,
    // grid-style: (row-gutter: 2cm),
    label-generator: fcite.label-generator
    // label-generator: fcite.label-generator.with(format-string: "J{:02}") // try this to get numberings J01, J02, ...
  )

  to test tracl \#21 / pergamon \#139: #cite("test_entry2")

]

// #context {
//   let all_meta = query(selector(metadata))
//   for meta in all_meta {
//     [
//       #meta.value.kind (#meta.value.at("key", default: "--"))
//       #if "label" in meta.fields() [: #str(meta.label)]
//       -- page #meta.location().page() -- #meta.location().position()
//     ]
//     linebreak()
//   }
// }
