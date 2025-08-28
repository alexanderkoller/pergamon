#import "lib.typ": *


// In this example document, we are putting the whole bibliography source
// into one string to make the example self-contained. In practice, you would read
// this from a BibTeX file using Typst's `read` function.
#let bibliography = "
@book{knuth1990,
  author = {Knuth, Donald E.},
  year   = {1990},
  publisher = {Addison-Wesley Professional},
  title  = {The {\TeX} Book},
}


@InProceedings{bender20:_climb_nlu,
  author = 	 {Emily M. Bender and Alexander Koller},
  keywords = {highlighted, pi},  
  title = 	 {Climbing towards {NLU}:
 On Meaning, Form, and Understanding in the Age of Data},
  award = {Best theme paper},
  booktitle = {Proceedings of the 58th Annual Meeting of the
                  Association for Computational Linguistics (ACL)},
  doi={10.18653/v1/2020.acl-main.463},
  year = 	 2020}


@article{modelizer-24,
  author = {Tural Mammadov and Dietrich Klakow and Alexander Koller and Andreas
 Zeller},
 title = {Learning Program Behavioral Models from Synthesized Input-Output Pairs},
 journal = {ACM Transactions on Software Engineering and Methodology (TOSEM)},
 url = {https://arxiv.org/abs/2407.08597},
 year = {2025}
}
"

// Here we're making the bibliography available to Pergamon.
#add-bib-resource(bibliography)



// Select a citation style by uncommenting the line you like:
#let style = format-citation-authoryear()
// #let style = format-citation-alphabetic()
// #let style = format-citation-numeric()

// Pick options for the reference style:
#let fref = format-reference(
  reference-label: style.reference-label,

  // Try out different formats, e.g. "{family}, {given}" and "{g}. {family}":
  // name-format: "{family}, {given}",
  
  // Try rendering additional fields, either as strings or as functions:
  // additional-fields: ("award",)
  // additional-fields: ((reference, options) => ifdef(reference, "award", (:), award => [*#award*]),),
  
  // Try highlighting references, e.g. based on keywords:
  // highlight: (x, reference, index) => {
  //  if "highlight" in reference.fields.at("keywords", default: ()) {
  //     [#text(size: 8pt)[#emoji.star.box] #x]
  //  } else {
  //     x
  //  }
  // }
)

// These show rule typeset references to my own papers in green
// and all other links in blue.
#show link: set text(fill: blue) // for links that are not citations
#show link: it => if-citation(it, value => {
  if "Koller" in family-names(value.reference.fields.parsed-author) {
    // links that are citations to my own papers
    set text(fill: green.darken(20%))
    it
  } else {
    // links to other citations
    set text(fill: blue)
    it
}})




#refsection(format-citation: style.format-citation)[
  = Pergamon example
  Here is some text.

  We can cite a paper like this: #cite("bender20:_climb_nlu").

  In the _authoryear_ style, we have some nice citation forms to play with:
  #citet("knuth1990") said that he really liked #citeg("modelizer-24") paper.
  (This is not actually true.)

  #print-bibliography(
    format-reference: fref,
    label-generator: style.label-generator,
  )
]




#refsection()[
  #v(2em)
  = Second refsection

  Here is another refsection. If you cite different papers than in the first 
  refsection, the bibliography will contain different papers: #cite("bender20:_climb_nlu").

  #print-bibliography(
    format-reference: fref,
    label-generator: style.label-generator,
  )
]




#let style2 = format-citation-numeric()
#refsection(format-citation: style2.format-citation)[
  #v(2em)
  = Third refsection

  Here is a third refsection. It uses a different citation style than the first two, and
  therefore both the citations and the bibliography look different
  [#citen("knuth1990"), #citen("modelizer-24")].

  #print-bibliography(
    format-reference: format-reference(reference-label: style2.reference-label),
    label-generator: style2.label-generator
  )
]