
#import "@preview/tracl:0.6.1": acl

#import "lib.typ": *
#let dev = pergamon-dev

// #let darkblue = blue.darken(20%)

// #show link: set text(fill: darkblue)

// #set heading(numbering: "1.1")



#let acl-cite = format-citation-authoryear()


#let acl-ref = format-reference(
  name-format: "{given} {family}",
  reference-label: acl-cite.reference-label,
  format-quotes: it => it,
  suppress-fields: ("*": ("month",)), // TODO: this needs to stay configurable, perhaps with default dictionary overriding
  format-functions: (
    "authors-with-year": (reference, options) => {
      periods(
        (dev.labelname)(reference, options),
        (dev.date)(reference, options)
      )
    }
  ),

  // Override bibstring entries like this:
  bibstring: ("in": "In"),
)

#let print-acl-bibliography() = {
  print-bibliography(
    format-reference: acl-ref, 
    sorting: "nyt",
    label-generator: acl-cite.label-generator,
    )
}


#show: doc => acl(
  refsection(format-citation: acl-cite.format-citation, doc),
  anonymous: false,
  title: [ACL-Pergamon test paper],
  authors: (
    (
      name: "Alexander Koller",
      affiliation: [Saarland University],
      email: "koller@coli.uni-saarland.de"
    ),
  ),
)

#add-bib-resource(read("bibs/bibliography.bib"))



= Introduction

#citet("bender20:_climb_nlu")


#print-acl-bibliography()