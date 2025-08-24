#import "@preview/tidy:0.4.3"
#import "@preview/datify:0.1.4": custom-date-format
#import "@preview/zebraw:0.5.5": *

#let darkblue = blue.darken(20%)
#show link: set text(fill: darkblue)
#show ref: set text(fill: darkblue)
#set text(size: 12pt)
// #show raw: set block(fill: luma(230), inset: 6pt, width: 100%)

#let date = custom-date-format(datetime.today(), "DD Month YYYY", "en")
#let version = toml("typst.toml").package.version

#let bibtypst = "Bibtypst"
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



#show heading: set block(above: 2em)
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
- Only a handful of styles are supported at this point, in contrast to the large number of available CSL styles.
- #bibtypst still requires a lot of testing and tweaking.


= Example 

The following piece of code will typeset a bibliography using #bibtypst.

#zebraw(lang: false,
  ```typ
#import "bibtypst.typ": add-bib-resource, refsection, print-bibliography
#import "bibtypst-numeric.typ": format-citation-numeric, format-reference-numeric

#add-bib-resource(read("bibliography.bib"))
#refsection(format-citation: format-citation-numeric())[
  ... some text here ...
  @bender20:_climb_nlu

  #print-bibliography(format-reference: format-reference-numeric(), 
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
A document must contain one of more `refsection`s. #biblatex tracks the citations within each refsection
separately and prints only those references that were cited within the current refsection when you call 
`print-bibliography`. 

Notice that `refsection` has a parameter `format-citation` to which we passed `format-citation-numeric()` in the example.
This tells the `refsection` how to typeset citations -- in the example, that `@bender20:_climb_nlu` should be
rendered as "[1]". The `format-citation` function is typically defined in a _#bibtypst style_, along with
a companion function `format-reference` that specifies how the individual references in the bibliography are rendered.
Observe also that `format-citation-numeric()` has an opening and closing bracket after the function name.
This is because many citation and reference formatters can be configured by passing arguments to this function.
In the example, we just use the default configuration for the numeric style.

Finally, the example calls `print-bibliography` to typeset the bibliography itself. This is where you pass
the `format-reference` function that renders the individual references. You can furthermore specify how the 
references should be ordered in the bibliography through the `sorting` parameter. In the example, the 
references are ordered by ascending author name; then ascending publication year; then ascending title.

All of these functions take additional parameters that you can use to customize the appearance of the bibliography.
See @sec:package-doc for details.


= #bibtypst styles 

== Predefined styles 

TODO: explain citation forms 

== Implementing custom styles 


= Useful tips 

TODO: conditional coloring of references -- use to explain `if-citation`


= Package documentation
<sec:package-doc>

#v(1em)
#let docs = tidy.parse-module(read("bibtypst.typ"))
#tidy.show-module(docs, style: tidy.styles.default, show-outline: false)

== Reference dictionaries
<sec:reference>

(explain them here)

== The default reference style

#let style-docs = tidy.parse-module(read("bibtypst-styles.typ"))
#tidy.show-module(style-docs, style: tidy.styles.default, show-outline: false)
