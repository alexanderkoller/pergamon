
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


#let acl-ref = format-reference(
  name-format: "{given} {family}",
  reference-label: acl-cite.reference-label,
  format-quotes: it => it,
  print-isbn: false,
  // TODO: this needs to stay configurable, perhaps with default dictionary overriding
  suppress-fields: (
    "*": ("month",),
    "inproceedings": ("editor",),
  ), 

  print-date-after-authors: true,

  format-fields: (
    // "editor": (dffmt, value, reference, field, options, style) => {
    //   let ed-str = (dev.print-name)(value, "editor", options)
    //   let editorx = if value.len() > 1 { "editors" } else { "editor" }
    //   strfmt("{}, {}", ed-str, editorx)
    // },

    "title": (dffmt, value, reference, field, options, style) => {
      let bib-type = reference.entry_type
      let title = (dev.link-title)(reference, options)

      if bib-type == "misc" {
        title
      } else {
        dffmt(value, reference, field, options, style)
      }
    }
  ),

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
        (dev.author-translator-others)(reference, options),
        (dev.date-with-extradate)(reference, options),
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

    // TODO: include "edited by"
    "driver-incollection": (reference, options) => {
      (dev.require-fields)(reference, options, "author", "title", "editor", "booktitle")

      (options.periods)(
        (dev.author-translator-others)(reference, options),
        (dev.date-with-extradate)(reference, options),
        (dev.printfield)(reference, "title", options),
        spaces(
          options.bibstring.in,
          (options.commas)(
            (dev.printfield)(reference, "editor", options),
            (dev.maintitle-booktitle)(reference, options),
            (dev.printfield)(reference, "pages", options)
          )
        ),
        (dev.publisher-location-date)(reference, options),
      )
    },

    "driver-article": (reference, options) => {
        (dev.require-fields)(reference, options, "author", "title", "journaltitle")

        (options.periods)(
          (dev.author-translator-others)(reference, options),
          (dev.date-with-extradate)(reference, options),
          (dev.printfield)(reference, "title", options),
          epsilons(
            emph((dev.printfield)(reference, "journaltitle", options)),
            volume-number-pages(reference, options)
          ),
          (dev.doi-eprint-url)(reference, options),
          (dev.addendum-pubstate)(reference, options)
        )
    },

    "driver-book": (reference, options) => {
      (dev.require-fields)(reference, options, ("author", "editor", "translator"), "title")

      (options.periods)(
        (dev.author-editor-others-translator-others)(reference, options),
        (dev.date-with-extradate)(reference, options),
        (dev.maintitle-title)(reference, options),
        (dev.byeditor-others)(reference, options),
        (options.commas)(
          (dev.printfield)(reference, "edition", options),
          (dev.volume-part-if-maintitle-undef)(reference, options),
          (dev.printfield)(reference, "volumes", options),
        ),
        (dev.series-number)(reference, options),
        (dev.printfield)(reference, "note", options),
        (dev.publisher-location-date)(reference, options),
        (options.commas)(
          (dev.chapter-pages)(reference, options),
          (dev.printfield)(reference, "pagetotal", options),
        ),
        if options.print-isbn { printfield(reference, "isbn", options) } else { none },
        (dev.doi-eprint-url)(reference, options),
        (dev.addendum-pubstate)(reference, options)
      )
    },


    "driver-misc": (reference, options) => {
      (dev.require-fields)(reference, options, ("author", "editor", "translator"), "title")

      (options.periods)(
        (dev.author-editor-others-translator-others)(reference, options),
        (dev.date-with-extradate)(reference, options),
        (dev.printfield)(reference, "title", options),
        // TODO:  \usebibmacro{byauthor}%
        (dev.byeditor-others)(reference, options),
        (dev.printfield)(reference, "howpublished", options),
        (options.commas)(
          (dev.printfield)(reference, "type", options),
          (dev.printfield)(reference, "version", options),
          (dev.printfield)(reference, "note", options),
        ),
        (dev.organization-location-date)(reference, options),
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



  // TODO: Things like this should be addable by the user:
  eval-scope: (todo: x => x)
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

A book: #cite("Dorfles1969")

An incollection: #cite("brownschmidt_2018_perspectivetaking")

A misc: #cite("hill2020human")

#print-acl-bibliography()