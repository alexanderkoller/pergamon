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

The builtin reference style is defined by the `format-reference` function. This reference style replicates the
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

#bibtypst comes with three builtin citation styles: _alphabetic_, _numeric_, and _authoryear_.
These replicate the #biblatex styles of the same names (see e.g. the #link("https://www.overleaf.com/learn/latex/Biblatex_bibliography_styles")[examples on Overleaf]).

Like in Typst's regular bibliography mechanism, you can write `@key` to insert a citation to the
bib entry with the entry-key `key` into your document. The exact string that is inserted depends on 
the citation style you use. Note that unlike in regular Typst, `@key` does not resolve to the #link("https://typst.app/docs/reference/model/cite/")[cite] function in #bibtypst, but to the #link("https://typst.app/docs/reference/model/ref/")[ref] function.
This is because `cite` can only be used with a standard Typst #link("https://typst.app/docs/reference/model/bibliography/")[bibliography].
This should not make a big difference to you in practice, but it matters when you want to style
citations; see @sec:styling-citations for details. 




Whenever you write `@key`, #bibtypst replaces this command with a citation to the reference generated
by `format-reference`. Note that unlike in the regular Typst bibliography mechanism, `@key` is not a
`cite` command, but a `ref` command. 

The difference between the three builtin citation styles is illustrated in @fig:example-output (numeric), @fig:example-alphabetic (alphabetic), and @fig:example-authoryear (authoryear). _Numeric_ and _alphabetic_ both create a label for each bibliography entry;
in the case of _numeric_, the label is the position in the bibliography, and in the case of _alphabetic_, it is a unique string consisting of the first characters of the author names and the year. In both cases, these labels are displayed next to the references and also used as the string to which `@key` expands. By contrast, _authoryear_ does not display any labels next to the references; it expands `@key` to a string consisting of the last names of the authors and the year.

Some of the citation styles have options that will let you control the appearance of the citations in detail.
These are documented in @sec:package:builtin-reference. For instance, to enclose the year in the _authoryear_ style
in square brackets rather than round ones, you can replace line 4 in the above example with

#zebraw(lang: false,
```typ
#let style = format-citation-authoryear(format-parens: nn(it => [(#it)]))
```
)

#figure(
  box(stroke: 1pt)[#image("doc-materials/example-alphabetic.png", width: 100%)],
  placement: top,
  caption: [Bibliography with the `alphabetic` citation style.]
) <fig:example-alphabetic>


#figure(
  box(stroke: 1pt)[#image("doc-materials/example-authoryear.png", width: 100%)],
  placement: top,
  caption: [Bibliography with the `authoryear` citation style.]
) <fig:example-authoryear>


=== Citation forms

Each citation style offers you different _citation forms_ for presenting your citation.
These are documented in @fig:citation-forms. Citation forms are selected using 
the `supplement` argument to the `ref` function:

#zebraw(lang: false,
```typ
#let citet(lbl) = ref(lbl, supplement: it => "t")
#citet(<bender20:_climb_nlu>)
```
)

Observe that you have to cannot simply pass `"t"` as the supplement; it has to be a one-parameter
function that returns `"t"`. This is a regrettable consequence of the fact that `ref` supplements 
can be `auto`, functions, and content, but not strings. If you do not specify a citation form (`ref(<key>)` or `@key`), the `auto` citation forms will be used.

Note that the `n` citation form has special value for combining multiple citations. Unlike the
builtin Typst `cite` function, #bibtypst is currently not able to aggregate multiple citations into 
a single string (e.g. `@key1 @key2` into "(Author, 2020; Person, 2021)"; see #link("https://github.com/alexanderkoller/bibtypst/issues/11")[issue \#11]). You can approximate this by using citations of form `n` and surrounding 
them with brackets and semicolons manually.


#figure(
  table(columns: 4,
    align: left + horizon,
    // column-gutter: 1em,
    inset: (x: 1em, y: 0.7em),
    // stroke: none,
    fill: (_, y) => if calc.odd(y) { rgb("EAF2F5") },

    [], [*authoryear*], [*alphabetic*], [*numeric*],
    [`auto`], [(Bender and Koller 2020)], [[BK20]], [[1]],
    [p], [(Bender and Koller 2020)], [--], [--],
    [t], [Bender and Koller (2020)], [--], [--],
    [g], [Bender and Koller's (2020)], [--], [--],
    [n], [Bender and Koller 2020], [BK20], [1]
  ),
  placement: top,
  caption: [Citation forms.]
) <fig:citation-forms>


== Implementing custom styles 

Instead of using the builtin styles, you can also define your own #bibtypst style
-- either a reference style or a citation style or both. 

Implementing a reference style amounts to defining a Typst function that can be passed 
as the `format-reference` argument to `print-bibliography`. Such a function receives 
arguments `(index, reference, eval-mode)` containing the zero-based position of the 
reference in the bibliography; a reference dictionary; and the mode in which `eval` should
evaluate the paper titles. A call to your function should return some `content`, which
will be displayed in the bibliography.

Reference dictionaries are a central data structure of #bibtypst. They represent the information 
contained in a single bibliography entry and are explained in detail in @sec:reference.

Implementing a citation style is a little more involved, because a citation style consists of three different
functions:

- The _label generator_ is passed as an argument to `print-bibliography`. It is a function that receives
  a reference dictionary and the bibliography position as arguments and is expected to return an array of 
  length two. Its first element is the bib entry's _label_; it is stored under the `label` field of the
  reference dictionary and can contain any information that your style finds useful. The second element 
  is a string summarizing the contents of the label. It is used to recognize when two bib entries have the 
  same label and therefore need an "extradate" to make it unique, e.g. the letter "a" in a citation string like
  "Smith et al. (2025a)". It is up to your style to ensure that entries with the same label also have the same
  string summary.

- The _reference labeler_ is passed as an argument to `format-reference`. It receives a reference 
  dictionary and the bibliography position as arguments and returns content. If this content is not `none`,
  it will be typeset as the first column in the bibliography, next to the reference itself. Of the builtin
  citation styles, the reference labeler of `authoryear` always returns `none` (indicating a one-column
  bibliography layout), and the other two return their respective labels in square brackets. #bibtypst assumes
  that the reference labeler of a citation style either always returns `none` or never returns `none`,
  making for a consistent number of columns.

- The _citation formatter_ is passed as an argument to `refsection`. It receives a reference dictionary
  and a citation form (see above) as arguments and returns content. This function generates the actual citation 
  that is typeset into the document.

Note that the label information that the label generator produces will be stored in the `label` field of the 
reference dictionary. When the reference labeler and the citation formatter are called, the `label` information 
will still be available, allowing you to precompute any information you find useful.


= Styling #bibtypst

== Styling the bibliography

sorting 

grids 

== Styling the citations
<sec:styling-citations>

TODO: show ref 

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

== The builtin styles
<sec:package:builtin-reference>

Below, we explain the arguments to the builtin reference style in detail
(see @sec:builtin-reference for the big picture).

#let style-docs = tidy.parse-module(read("src/bibtypst-styles.typ"))
#tidy.show-module(style-docs, style: tidy.styles.default, show-outline: false)



= Limitations <sec:limitations>