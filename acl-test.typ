
#import "@preview/tracl:0.6.1": acl
#import "@preview/oxifmt:1.0.0": strfmt


#import "lib.typ": *
#let dev = pergamon-dev



#let acl-cite = format-citation-authoryear(
  author-year-separator: ", "
)


#let volume-number-pages(reference, options) = {
  let volume = fd(reference, "volume", options)
  let number = fd(reference, "number", options)
  let pages = fd(reference, "pages", options)

  let a = if volume == none and number == none {
    none
  } else if number == none {
    " " + volume
  } else if volume == none {
    panic("Can't use 'number' without 'volume' (in " + reference.entry_key + ")!")
  } else {
    strfmt(" {}({})", volume, number)
  }

  let pp = if pages == none {
    ""
  } else if a != none {
    ":" + pages
  } else {
    ", " + (dev.printfield)(reference, "pages", options)
  }

  a + pp
}


// // standard.bbx volume+number+eid
// #let volume-number-eid = with-default("volume-number-eid", (reference, options) => {
  

//   let a = if volume == none and number == none {
//     none
//   } else if number == none {
//     volume
//   } else if volume == none {
//     panic("Can't use 'number' without 'volume' (in " + reference.entry_key + "!")
//   } else {
//     volume + options.volume-number-separator + number
//   }

//   fjoin(options.bibeidpunct, a, fd(reference, "eid", options))
// })

#let acl-ref = format-reference(
  name-format: "{given} {family}",
  reference-label: acl-cite.reference-label,
  format-quotes: it => it,
  // TODO: this needs to stay configurable, perhaps with default dictionary overriding
  suppress-fields: (
    "*": ("month",),
    "inproceedings": ("editor",),
  ), 
  print-date-after-authors: true,
  format-functions: (
    "authors-with-year": (reference, options) => {
      periods(
        (dev.labelname)(reference, options),
        (dev.date)(reference, options)
      )
    },

    "driver-inproceedings": (reference, options) => {
      (dev.require-fields)(reference, options, "author", "title", "booktitle")

      (options.periods)(
        (dev.author-translator-others)(reference, options), // includes date
        (dev.printfield)(reference, "title", options),
        (options.commas)(
          spaces(options.bibstring.in, (dev.maintitle-booktitle)(reference, options)),
          (dev.printfield)(reference, "pages", options),
          (dev.printfield)(reference, "location", options),
          (dev.printfield)(reference, "organization", options),
        ),
        (dev.doi-eprint-url)(reference, options),
        (dev.addendum-pubstate)(reference, options)
      )
    },

    "driver-article": (reference, options) => {
        (dev.require-fields)(reference, options, "author", "title", "journaltitle")

        (options.periods)(
          (dev.author-translator-others)(reference, options),
          (dev.printfield)(reference, "title", options),
          epsilons(
            emph((dev.printfield)(reference, "journaltitle", options)),
            volume-number-pages(reference, options)
          ),
          (dev.doi-eprint-url)(reference, options),
          (dev.addendum-pubstate)(reference, options)
        )
    }
    ),

  // Override bibstring entries like this:
  bibstring: (
    "in": "In",
    "pages": "pages"
  ),
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

Citep: #cite("bender20:_climb_nlu", "lindemann19:_compos_seman_parsin_acros_graph")

Citet: #citet("hershcovichItMeaningThat2021")

Citeg: #citeg("bonial-etal-2020-dialogue")

Using bloated Bibtex from ACL anthology: #cite("stein-donatelli-2021-representing")




#print-acl-bibliography()