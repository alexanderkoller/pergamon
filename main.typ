
#import "lib.typ": *
// #import "@preview/pergamon:0.2.0": *

#let darkgreen = green.darken(20%)
#let darkblue = blue.darken(20%)

#show link: set text(fill: darkblue)

#set heading(numbering: "1.1")



// Author-Year:
#let fcite = format-citation-authoryear()

// Alphabetic:
// #let fcite = format-citation-alphabetic()

// Numeric:
// #let fcite = format-citation-numeric()

#let marker = text(size: 8pt)[#emoji.star] 

#let fref = format-reference(
  // name-format: "{given} {family}",
  name-format: (
    "author": "{given} {family}",
    "editor": "{g}. {family}"
  ),
  reference-label: fcite.reference-label,
  format-quotes: it => it,
  print-identifiers: ("doi", "url"),
  // print-doi: true,
  suppress-fields: ("*": ("month",)),
  eval-scope: ("todo": x => text(fill: red, x)),
  // suppress-fields: ("*": ("pages",), "inproceedings": ("editor", "publisher") ),
  // print-date-after-authors: true,
  // additional-fields: ("award",)
  //  period: ",",
  additional-fields: ((reference, options) => ifdef(reference, "award", (:), award => [*#award*]),),
  highlight: (x, reference, index) => {
    if "highlight" in reference.fields.at("keywords", default: ()) {
      place(dx: -1.5em, dy: -0.15em, marker)
    }
    x
  },

  // Override bibstring entries like this:
  bibstring: ("in": "In"),

  // This (together with the field formatters for volume and number below) addresses #46.
  // volume-number-separator: " ",

  // format-fields: (
  //   // highlight my name in all references
  //   "author": (dffmt, value, reference, field, options, style) => {
  //     let formatted-names = value.map(d => {
  //       let highlighted = (d.family == "Koller")
  //       let name = format-name(d, name-type: "author", format: options.name-format)
  //       if highlighted { strong(name) } else { name }
  //     })

         // TODO: cover the case of two authors, or just use concatenate-list
  //     formatted-names.join(", ", last: ", and ")
  //   },


    // // This (together with the volume-number-separator above) addresses #46.
    // "volume": (dffmt, value, reference, field, options, style) => {
    //   if reference.entry_type == "article" {
    //     [vol. #value]
    //   } else {
    //     dffmt(value, reference, field, options, style)
    //   }
    // },

    // "number": (dffmt, value, reference, field, options, style) => {
    //   if reference.entry_type == "article" {
    //     [no. #value]
    //   } else {
    //     dffmt(value, reference, field, options, style)
    //   }
    // },
  )
)


/*
maintitle - emph
booktitle - emph
*/

#let sorting = "nyt"


#add-bib-resource(read("bibs/bibliography.bib"))
#add-bib-resource(read("bibs/other.bib"))
#add-bib-resource(read("bibs/physics.bib"))

#for i in range(1) { // to test whether multiple refsections cause issues

  refsection(format-citation: fcite.format-citation)[
    // This show rule has to come inside the refsection, otherwise it is
    // overwritten by the show rule that is defined in refsection's source code.
    // It colors the citation links based on whether the reference is to a PI publication.
    #show link: it => if-citation(it, value => {
      let color = if "Koller" in family-names(value.reference.fields.parsed-author) { darkgreen } else { darkblue }
      set text(fill: color)
      it
    })
    
    #set par(justify: true)

    = Introduction <sec:intro>
    #lorem(100)

    To reproduce \#78:
    #context {
      let hdr = query(heading).first()
      link(hdr.location())[#hdr.body]
    }

    = Another section

    citet: !#citet("modelizer-24", "modelizer-24")!

    citep: #citep("bender20:_climb_nlu", "knuth1990")

    citeg: #citeg("kandra-bsc-25", "kandra-bsc-25")

    citen: #citen("yang2025goescrosslinguisticstudyimpossible", "yang2025goescrosslinguisticstudyimpossible")

    #cite("sec:intro")

    // #citename("kandra-bsc-25")

    // #citeyear("bender20:_climb_nlu")

    #cite("irtg-sgraph-15")

    #cite("wu-etal-2024-reasoning", "knuth1990") #cite("yao2025language") #cite("hershcovichItMeaningThat2021")
    #cite("abgrallMeasurementsppmKpm2016") #cite("kuhlmann2003tiny") #cite("fake-mastersthesis")

    #cite("multi1") #citen("multi2")

    to test trailing punctuation: #cite("tedeschi-etal-2023-whats")

    to test editors: #cite("hempel1965science")

    to test prefix and suffix: #cite("tedeschi-etal-2023-whats", prefix: "e.g. ", suffix: ", page 17")

    to test undefined citations: #cite("DOES-NOT-EXIST", "tedeschi-etal-2023-whats")

    to test journal subtitles: #cite("clls")

    #context { count-bib-entries() }

    // #set par(hanging-indent: 1em)
    #print-bibliography(format-reference: fref, sorting: sorting,
      // grid-style: (row-gutter: 0.8em),
      label-generator: fcite.label-generator,
    )
  ]
}

#refsection(id: "hallo")[ lkjdf ]

#refsection[
  Another refsection
]

