#import "lib.typ": *

#show link: set text(fill: blue)
#set heading(numbering: "1.1")

#show heading.where(level: 1): it => block(
  below: 1em,
  it
)

#let sorting = "nyt"
#add-bib-resource(read("bibs/biblatex-examples.bib"))


#let stresstest(citation-style, style-name) = {
  let fcite = citation-style
  let fref = format-reference(
    print-date-after-authors: true,
    reference-label: fcite.reference-label,
  )

  refsection(format-citation: fcite.format-citation)[
    = #style-name

    Here we're typesetting the stress-test examples with the #style-name reference style.

    #print-bibliography(
      format-reference: fref,
      title: none,
      sorting: sorting,
      show-all: true,
      label-generator: fcite.label-generator,
    )
  ]

  pagebreak(weak: true)
}


#stresstest(format-citation-authoryear(), "Author-Year")
#stresstest(format-citation-alphabetic(), "Alphabetic")
#stresstest(format-citation-numeric(), "Numeric")