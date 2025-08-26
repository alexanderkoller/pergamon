#import "@preview/tidy:0.4.3"
#import "@preview/datify:0.1.4": custom-date-format
#import "@preview/zebraw:0.5.5": *

#let darkblue = blue.darken(20%)
#show link: set text(fill: darkblue)
#show ref: set text(fill: darkblue)
#set text(size: 12pt)
#set par(justify: true)
// #show raw: set block(fill: luma(230), inset: 6pt, width: 100%)

#let todo(x) = text(fill: red, [(#x)])

#let date = custom-date-format(datetime.today(), "DD Month YYYY", "en")
#let version = toml("typst.toml").package.version

#let bibtypst = "Pergamon"
#let biblatex = "BibLaTeX"


#align(center)[
  #text(size: 24pt)[*#bibtypst*]\
  #v(0em)
  #biblatex\-inspired bibliography management for Typst\
  https://github.com/alexanderkoller/bibtypst
  #v(0.5em)
  v#version, #date\
  #link("https://www.coli.uni-saarland.de/~koller/")[Alexander Koller]
]



#show heading: set block(above: 2em, below: 1em)
#show heading.where(level: 1): set heading(numbering: "1.1")
#show heading.where(level: 2): set heading(numbering: "1.1")


= Introduction

#bibtypst is a package for typesetting bibliographies in Typst.
It is inspired by #link("https://ctan.org/pkg/biblatex")[BibLaTeX], in that 
the way in which it typesets bibliographies can be easily customized
through Typst code. Like Typst's regular bibliography management model,
#bibtypst can be configured to use different styles for typesetting
references and citations; unlike it, these styles are all defined through
Typst code, rather than CSL.

#bibtypst has a number of advantages over the builtin Typst bibliographies:

- The document can be easily split into different `refsection`s, each of which can have its own bibliography.
- #bibtypst styles are simply pieces of Typst code and can be easily configured or modified.
- Bibliographies can be filtered, and bibliography entries programmatically highlighted, which is useful e.g. for CVs.
- References retain nonstandard Bibtex fields (#link("https://github.com/typst/hayagriva/issues/240")[unlike in Hayagriva]),
  making it e.g. possible to split bibliographies based on keywords.

At the same time, #bibtypst is very new and has a number of important limitations compared to
the builtin system.

- #bibtypst currently supports only bibliographies in Bibtex format, not the Hayagriva YAML format. 
- Only a handful of styles are supported at this point, in contrast to the large number of available CSL styles. #bibtypst comes with implementations of the #biblatex styles `numeric`, `alphabetic`, and `authoryear`.
- #bibtypst still requires a lot of testing and tweaking.

#link("https://en.wikipedia.org/wiki/Pergamon")[Pergamon] was an ancient Greek city state in Asia Minor.
Its library was second only to the Library of Alexandria around 200 BC.

= Example 

The following piece of code typesets a bibliography using #bibtypst.

#zebraw(lang: false,
  ```typ
#import "bibtypst.typ": add-bib-resource, refsection, print-bibliography
#import "bibtypst-styles.typ": format-citation-numeric, format-reference

#let style = format-citation-numeric()
#add-bib-resource(read("bibliography.bib"))
#refsection(format-citation: style.format-citation)[
  ... some text here ...
  @bender20:_climb_nlu

  #print-bibliography(
       format-reference: 
             format-reference(reference-label: style.reference-label), 
       label-generator: style.label-generator,
       sorting: "nyt")
]
  ```
)

#figure(
  box(stroke: 1pt)[#image("doc-materials/example-output.png", width: 100%)],
  placement: top,
  caption: [Example bibliography typeset with #bibtypst.]
) <fig:example-output>

This will generate the output shown in @fig:example-output. Let's go through the different
parts of this code one by one.

The first relevant function that is called here is `add-bib-resource`. It parses a Bibtex file
and adds all the Bibtex entries to #bibtypst's internal list of references. Notice that you have to
`read` the Bibtex file yourself and pass its contents to `add-bib-resource` as a string. This is
because Typst packages can't access files in your working directory for security reasons.

We then create a `refsection`. A `refsection` is a section of Typst content that shares a bibliography.
#bibtypst tracks the citations within each refsection
separately and prints only those references that were cited within the current refsection when you call 
`print-bibliography`. 

Notice that `refsection` has a parameter `format-citation` to which we passed `style.format-citation` in the example.
This tells the `refsection` how to typeset citations -- in the example, that `@bender20:_climb_nlu` should be
rendered as "[1]". 

The `format-citation` function is typically defined in a _#bibtypst style_, along with
a companion function `format-reference` that specifies how the individual references in the bibliography are rendered.
In the example, the `style` is obtained through a call to `format-citation-numeric()` in line 4.
Observe that it has an opening and closing bracket after the function name.
This is because citation and reference formatters can be configured by passing arguments to this function.
In the example, we just use the default configuration for the numeric style.

Finally, the example calls `print-bibliography` to typeset the bibliography itself. This is where you pass
the `format-reference` function that renders the individual references. You can furthermore specify how the 
references should be ordered in the bibliography through the `sorting` parameter. In the example, the 
references are ordered by ascending author name; then ascending publication year; then ascending title.
Note also that `style.label-generator` is passed as an argument to `print-bibliography`. This function generates 
internal style-specific information that is used to typeset both references and citations.

All of these functions can take additional parameters that you can use to customize the appearance of the bibliography.
See @sec:package-doc for details.



= #bibtypst styles

#bibtypst is highly configurable with respect to the way that references and citations are rendered.
Its defining feature is that the _styles_ that control the rendering process are defined as ordinary
Typst functions, rather than in CSL.

There are two different types of styles in #bibtypst:

- _Reference styles_ define how the individual references are typeset in the bibliography.
- _Citation styles_ define how citations are typeset in the text.

Obviously, the reference and citation style that is used in a refsection should fit together to avoid confusing the reader.

#bibtypst comes with one predefined reference style and three predefined citation styles. We will explain these below,
and then we will sketch how to define your own custom styles.

== Builtin reference style
<sec:builtin-reference>

The builtin reference style is defined by the `format-reference` function in `bibtypst-styles.typ`.
#todo[Figure out how to access it in the released package.] This reference style replicates the
builtin reference style of #biblatex, with some limitations that are described in @sec:limitations.

The builtin reference style can currently render the following #biblatex entry types:

- `@article`
- `@book`
- `@incollection`
- `@misc`
- `@inproceedings`
- `@thesis`

These are explained in more detail in Section 2.1.1 of the #link("https://ctan.org/pkg/biblatex")[#biblatex documentation].
Bibtex entries of a different type are typeset as a references in a dummy style which displays the entry type and Bibtex key.


#figure(
  box(stroke: 1pt)[#image("doc-materials/modified-example-output.png", width: 100%)],
  placement: top,
  caption: [Bibliography with the configuration of @sec:builtin-reference.]
) <fig:modified-example-output>

The builtin `format-reference` function can be customized by passing arguments to it.
These arguments are explained in detail in @sec:package:builtin-reference. As one example,
the following arguments will change the output of the example above to look like in @fig:modified-example-output:

#zebraw(lang: false,
```typ
#print-bibliography(
  format-reference: format-reference(
    reference-label: style.reference-label,
    print-date-after-authors: true, 
    format-quotes: it => it
  ), 
  label-generator: style.label-generator,
  sorting: "nyt")
```)

We passed `true` for the argument `print-date-after-authors`. This moved the year from the end of the 
reference to just after the authors and put it in brackets. 

We also passed the function `it => it` as the 
`format-quotes` argument. The builtin reference style surrounds all papers that are contained in bigger 
collections (in this case, a volume of conference proceedings) in quotes by applying the `format-quotes` function.
By replacing the default `format-quotes` function with the identity function, we can make the quotes disappear
in the output.

#bibtypst exploits Typst's ability to pass functions as arguments quite heavily. This makes it cleaner in some ways 
than #biblatex, which is built on top of LaTeX, whose macros are much less flexible.


== Builtin citation styles

#todo[explain numeric, alphabetic, authoryear with examples]

#todo[explain citation forms, like `n`]

== Implementing custom styles 


= Styling #bibtypst

== Styling the bibliography

sorting 

grids 

== Styling the citations

TODO: conditional coloring of references -- use to explain `if-citation`


= Package documentation
<sec:package-doc>

#v(1em)
#let docs = tidy.parse-module(read("src/bibtypst.typ"))
#tidy.show-module(
  docs, 
  style: tidy.styles.default, 
  show-outline: false, 
  // scope: (:) // (bibtypst: "X")
)

== Reference dictionaries
<sec:reference>

(explain them here)

== The builtin reference style
<sec:package:builtin-reference>

Below, we explain the arguments to the builtin reference style in detail
(see @sec:builtin-reference for the big picture).

#let style-docs = tidy.parse-module(read("src/bibtypst-styles.typ"))
#tidy.show-module(style-docs, style: tidy.styles.default, show-outline: false)



= Limitations <sec:limitations>