#import "@preview/tidy:0.4.3"
#import "@preview/datify:0.1.4": custom-date-format
#import "@preview/zebraw:0.5.5": *
#import "lib.typ": * // current version of Pergamon
#let dev = pergamon-dev

#let darkblue = blue.darken(20%)
#show link: set text(fill: darkblue)
#show ref: set text(fill: darkblue)
#set text(size: 12pt)
#set par(justify: true)
// #show raw: set block(fill: luma(230), inset: 6pt, width: 100%)

#let todo(x) = text(fill: red, [*(#x)*])
#let issue(id) = link("https://github.com/alexanderkoller/pergamon/issues/" + str(id))[issue \##id]

#let date = custom-date-format(datetime.today(), "DD Month YYYY", "en")
#let version = toml("typst.toml").package.version

#let bibtypst = "Pergamon"
#let pergamon = bibtypst
#let biblatex = "BibLaTeX"
#let bibtex = "BibTeX"

#let unfinished-color = red.transparentize(80%)
#let unfinished(x) = box(inset: 6pt, stroke: black, fill: unfinished-color)[
  #place(top+right, dy: -6pt - 1em - 4pt, dx: 6pt)[#box(stroke: black, fill: unfinished-color, inset: 4pt, [*FINISH ME!*])]
  #x
]

#let scope = (
  "bibtypst": bibtypst,
  "bibtex": bibtex,
  "biblatex": biblatex,
  "pergamon": bibtypst,
  "zebraw": zebraw,
  "issue": issue,
  "todo": todo,
  "unfinished": unfinished
)

// for the examples
#add-bib-resource(read("bibs/bibliography.bib"))

#align(center)[
  #text(size: 24pt)[*#bibtypst*]\
  #v(0em)
  #biblatex\-inspired bibliography management for Typst\
  https://github.com/alexanderkoller/pergamon
  #v(0.5em)
  v#version, #date\
  #link("https://www.coli.uni-saarland.de/~koller/")[Alexander Koller]
]



#show heading: set block(above: 2em, below: 1em)

#outline(depth: 2)

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

- #bibtypst styles are simply pieces of Typst code and can be easily configured or modified.
- The document can be easily split into different `refsection`s, each of which can have its own bibliography
  (similar to #link("https://typst.app/universe/package/alexandria/")[Alexandria]). Unlike in Alexandria,
  you do not have to manually add bibliography prefixes to your citations.
- Paper titles can be automatically made into hyperlinks -- as in #link("https://typst.app/universe/package/blinky/")[blinky], but much more flexibly and correctly.  
- Bibliographies can be filtered, and bibliography entries programmatically highlighted, which is useful e.g. for CVs.
- References retain nonstandard #bibtex fields (#link("https://github.com/typst/hayagriva/issues/240")[unlike in Hayagriva]),
  making it e.g. possible to split bibliographies based on keywords.

I have used #pergamon for a number of nontrivial bibliographic scenarios, but I
welcome your comments so that I can make it work more generally. #biblatex is a
very complex library to replicate, and I would like to prioritize features that
people actually care about.

#link("https://en.wikipedia.org/wiki/Pergamon")[Pergamon] was an ancient Greek city state in Asia Minor.
Its library was second only to the Library of Alexandria around 200 BC.

= Example 

The following piece of code typesets a bibliography using #bibtypst.
(You can try out a more complex example yourself: download #link("https://github.com/alexanderkoller/pergamon/blob/main/example.typ")[example.typ from Github]\;
see also #link("https://github.com/alexanderkoller/pergamon/blob/main/example.pdf")[the generated PDF].)


// construct code example, with the right Pergamon version interpolated in
#let example-raw = "#import \"@preview/pergamon:VERSION\": *

#let style = format-citation-numeric()
#add-bib-resource(read(\"bibliography.bib\"))

#refsection(format-citation: style.format-citation)[
  ... some text here ...
  #cite(\"bender20:_climb_nlu\")

  #print-bibliography(
       format-reference: 
             format-reference(reference-label: style.reference-label), 
       label-generator: style.label-generator,
       sorting: \"nyt\")
]".replace("VERSION", version)

#zebraw(lang: false, raw(example-raw, lang: "typ", block: true))




#figure(
  box(stroke: 1pt, inset: 6pt)[
    #set align(left)
    #let style = format-citation-numeric()

    #refsection(format-citation: style.format-citation)[
      ... some text here ... #cite("bender20:_climb_nlu")
      #v(-1em)

      #print-bibliography(
       outlined: false,
       format-reference: format-reference(reference-label: style.reference-label), 
       label-generator: style.label-generator
      )
    ]
  ],
  placement: top,
  caption: [Example bibliography typeset with #bibtypst (`numeric` citation style).]
) <fig:example-output>

This will generate the output shown in @fig:example-output. Let's go through the different
parts of this code one by one.

The first relevant function that is called here is `add-bib-resource`. It parses a #bibtex file
and adds all the #bibtex entries to #bibtypst's internal list of references. Notice that you have to
`read` the #bibtex file yourself and pass its contents to `add-bib-resource` as a string. This is
because Typst packages can't access files in your working directory for security reasons.

We then create a `refsection`. A `refsection` is a section of Typst content that shares a bibliography.
#bibtypst tracks the citations within each refsection
separately and prints only those references that were cited within the current refsection when you call 
`print-bibliography`. 

The actual citation is generated by the call `cite("bender20:_climb_nlu")`. #bibtypst currently does not use the 
regular Typst citation syntax `@bender20:_climb_nlu` for a number of reasons (see #issue(40)). Instead you call 
#bibtypst's `cite` function, with the key of the #bibtex entry as a string (not a Typst label). 
Note that this is not the same as Typst's builtin #link("https://typst.app/docs/reference/model/cite/")[cite] function, which is overwritten 
by #bibtypst.

Notice that `refsection` has a parameter `format-citation` to which we passed `style.format-citation` in the example.
This tells the `refsection` how to typeset citations -- in the example, that `#cite("bender20:_climb_nlu")` should be
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

The builtin reference style is defined by the `format-reference` function. This reference style aims to replicate
the default style of #biblatex.

The builtin reference style can currently render all #biblatex entry types (article, inproceedings, etc.) except for `set`.
These are explained in more detail in Section 2.1.1 of the #link("https://ctan.org/pkg/biblatex")[#biblatex documentation].
Entry type aliases are resolved as in #biblatex (e.g. `software` to `misc`).


#figure(
  box(stroke: 1pt, inset: 6pt)[
    #set align(left)
    #let style = format-citation-numeric()

    #refsection(format-citation: style.format-citation)[
      ... some text here ... #cite("bender20:_climb_nlu")
      #v(-1em)

      #print-bibliography(
       format-reference: format-reference(
          reference-label: style.reference-label,
          print-date-after-authors: true, 
          format-quotes: it => it
       ), 
       outlined: false,
       label-generator: style.label-generator
      )
    ]
  ],
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
<sec:builtin-citation-styles>

#bibtypst comes with three builtin citation styles: _alphabetic_, _numeric_, and _authoryear_.
These replicate the #biblatex styles of the same names (see e.g. the #link("https://www.overleaf.com/learn/latex/Biblatex_bibliography_styles")[examples on Overleaf]).

Unlike in Typst's regular bibliography mechanism, you write `#cite("key")` to insert a citation into your document
when you use #bibtypst. The exact string that is inserted depends on 
the citation style you use. 

The difference between the three builtin citation styles is illustrated in @fig:example-output (numeric), @fig:example-alphabetic (alphabetic), and @fig:example-authoryear (authoryear). _Numeric_ and _alphabetic_ both create a label for each bibliography entry;
in the case of _numeric_, the label is the position in the bibliography, and in the case of _alphabetic_, it is a unique string consisting of the first characters of the author names and the year. In both cases, these labels are displayed next to the references and also used as the string to which `#cite(key)` expands. By contrast, _authoryear_ does not display any labels next to the references; it expands `#cite(key)` to a string consisting of the last names of the authors and the year.

Some of the citation styles have options that will let you control the appearance of the citations in detail.
These are documented in @sec:package:builtin-citation. For instance, to enclose the year in the _authoryear_ style
in square brackets rather than round ones, you can replace line 4 in the above example with

#zebraw(lang: false,
```typ
#let style = format-citation-authoryear(format-parens: nn(it => [[#it]]))
```
)

#figure(
  box(stroke: 1pt, inset: 6pt)[
    #set align(left)
    #let style = format-citation-alphabetic()

    #refsection(format-citation: style.format-citation)[
      ... some text here ... #cite("bender20:_climb_nlu")
      #v(-1em)

      #print-bibliography(
       format-reference: format-reference(
          reference-label: style.reference-label,
       ), 
       outlined: false,
       label-generator: style.label-generator
      )
    ]
  ],
  placement: top,
  caption: [Bibliography with the `alphabetic` citation style.]
) <fig:example-alphabetic>


#figure(
  box(stroke: 1pt, inset: 6pt)[
    #set align(left)
    #let style = format-citation-authoryear()

    #refsection(format-citation: style.format-citation)[
      ... some text here ... #cite("bender20:_climb_nlu")
      #v(-1em)

      #print-bibliography(
       format-reference: format-reference(
          reference-label: style.reference-label,
       ), 
       outlined: false,
       label-generator: style.label-generator
      )
    ]
  ],
  placement: top,
  caption: [Bibliography with the `authoryear` citation style.]
) <fig:example-authoryear>


=== Citation forms

Each citation style offers you different _citation forms_ for presenting your citation.
These are documented in @fig:citation-forms. Citation forms are selected using 
the optional `form` argument to the `cite` function: 

#zebraw(lang: false,
```typ
#cite("bender20:_climb_nlu", form: "t")
```
)

If you do not specify a citation form, the `auto` citation forms will be used. For your 
convenience, #biblatex defines the functions `citet`, `citep`, `citen`, and `citeg`, which all 
just call `cite` with the respective citation form.


=== Citation options

You can pass extra named arguments to the Pergamon citation commands
`cite`, `citet`, etc. These arguments will be passed as _options_ to the
citation formatter. For instance, the following citation will render as
"(see Bender et al. 2020, p. 3)":

#zebraw(lang: false,
```typ
#cite("bender20:_climb_nlu", prefix: "see", suffix: "p. 3")
```
)

Currently, the only builtin citation style that supports such arguments
is the _authoryear_ style. It accepts the `prefix` and `suffix` options,
as in the example. You can still pass options 
to the other citation styles; they will simply ignore them.




== Customizing the reference style
<sec:customizing-style>

You can deeply customize how the default reference style in #pergamon typesets the individual references.
The default style defines a variety of functions in #link("https://github.com/alexanderkoller/pergamon/blob/main/src/reference-styles.typ")[reference-styles.typ]
 that typeset pieces of the reference; for instance,
the function `journal-issue-title` displays the title and issue of a journal and connects them correctly with
commas and periods. At the extreme end of the spectrum, the function `driver-X` renders a complete
#bibtex entry of type `X` (e.g. `driver-article` renders journal article references).
You can use the parameter `format-functions` in `format-reference` (see @sec:package:builtin-reference) to override 
these formatting functions.



#figure(
  box(stroke: 1pt, inset: 6pt)[
    #set align(left)
    #let style = format-citation-authoryear()

    #refsection(format-citation: style.format-citation)[
      ... some text here ... #cite("bender20:_climb_nlu")
      #v(-1em)

      #print-bibliography(
       format-reference: format-reference(
          reference-label: style.reference-label,
          print-date-after-authors: true,
          format-functions: (
            "maybe-with-date": (reference, options) => {
              name => {
                periods(
                  name,
                  (dev.date-with-extradate)(reference, options)
                )
              }
            },
          )
       ), 
       outlined: false,
       label-generator: style.label-generator
      )
    ]
  ],
  placement: top,
  caption: [Bibliography with modified format-functions.]
) <fig:example-acl>


An example is shown in @fig:example-acl; this reference style replicates that of the #link("https://www.aclweb.org/portal/acl")[ACL conferences],
which typesets the year after the author, separated by periods. To achieve this format, you can override the formatting function `maybe-with-date`
as shown below:

#zebraw(lang: false,
```typ
#import "@preview/pergamon:0.5.0": *
#let dev = pergamon-dev

#print-bibliography(
  format-reference: format-reference(
    reference-label: style.reference-label,
    print-date-after-authors: true,
    format-functions: (
      "maybe-with-date": (reference, options) => {
        name => {
          periods(
            name,
            (dev.date-with-extradate)(reference, options)
      )}},
  )), 
  label-generator: style.label-generator
)
```)

This is actually one of the more complex formatting functions. Like all formatting functions, it takes the `reference` and the usual 
`options` as argument. However, most other formatting functions just return some Typst content. By contrast, the drivers for the
entry types call `maybe-with-date` as a function that takes the rendered author name as input and returns content. By default,
`maybe-with-date` attaches the year and extradate to the author name, separated by parentheses, if the option `print-date-after-authors` 
is specified. The code above replaces this default implementation of `maybe-with-date` with a function that takes the author name as 
argument and attaches the date and extradate with a period. The drivers for the entry types will now call this function instead of 
the default one.

The formatting functions that can be overridden are exactly those that start with `with-default` in #link("https://github.com/alexanderkoller/pergamon/blob/main/src/reference-styles.typ")[reference-styles.typ]. That file will also give you hints on which formatting function you have to override for the effect you want.
You can access the other formatting functions through the dictionary `pergamon-dev`, which you can access after importing #pergamon
(see the code above). 



== Implementing your own styles from scratch 
<sec:custom-styles>

If the customization options of the `format-functions` parameter are not enough for you,
you can also define your own #bibtypst style
-- either a reference style or a citation style or both. It is recommended to look at the
default styles in #link("https://github.com/alexanderkoller/pergamon/blob/main/src/citation-styles.typ")[citation-styles.typ]
and #link("https://github.com/alexanderkoller/pergamon/blob/main/src/reference-styles.typ")[reference-styles.typ]
 to get a clearer picture.

Implementing a reference style amounts to defining a Typst function that can be passed 
as the `format-reference` argument to `print-bibliography`. Such a function receives 
arguments `(index, reference)` containing the zero-based position of the 
reference in the bibliography and a reference dictionary. A call to your function should
 return some `content`, which
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

- The _citation formatter_ is passed as an argument to `refsection`. It is responsible for
  formatting the actual citations into content that is inserted into the document text.
  The citation formatter receives three arguments: an array of citation specifications, a citation 
  form (cf. "Citation forms" in @sec:builtin-citation-styles), and an options
  dictionary (cf. "Citation options" in @sec:builtin-citation-styles). See the `format-citation` argument 
  of the `refsection` function in @sec:package:main for details on the citation specifications.

Note that the label information that the label generator produces will be stored in the `label` field of the 
reference dictionary. When the reference labeler and the citation formatter are called, the `label` information 
will still be available, allowing you to precompute any information you find useful.



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
    [name], [Bender and Koller], [--], [--],
    [year], [2020], [--], [--],
    [n], [Bender and Koller 2020], [BK20], [1]
  ),
  placement: top,
  caption: [Citation forms.]
) <fig:citation-forms>




= Advanced usage 

#v(-1em)
== Multiple refsections

A #bibtypst document consists of one or more `refsection`s. Each refsection is a segment of the document 
that shares a bibliography: #bibtypst collects all citations within each refsection and prints them in the
refsection's bibliography. This allows you to have multiple bibliographies per document, as in the well-known
#link("https://typst.app/universe/package/alexandria/")[Alexandria] package.

Every refsection in a document has a unique identifier that distinguishes it from the other refsections.
These identifiers are prepended to the keys of the bibliography entries in every citation. You still write
`#cite("key")` in your document, with the same key that you also use in your #bibtex file; in a refsection with 
identifier `id`, #bibtypst automatically converts this into a reference to `id-key`. The only situation where 
you will notice that the keys were 
modified is when a citation is undefined; in this case, Typst will warn you that the reference `id-key`
couldn't be resolved, rather than `key`.

You can specify the refsection identifier yourself by passing it as the `id` argument to the `refsection`
function. But typical usage will be to not specify an explicit `id` argument and let #bibtypst assign 
a unique identifier automatically. In this case, the first refsection in the document will have the identifier 
`none`, and the subsequent ones will be names `"ref1"`, `"ref2"`, and so on. When the identifier is `none`,
#bibtypst simply uses the `key` itself as the label, rather than prepending it with an identifier string.
For the frequent use case where the document has only one refsection, this will make error messages 
easier to read.

You may use `print-bibliography` only in the context of a `refsection`. If your document has only a single 
refsection, you can configure it through a document show rule, like this:

#zebraw(lang: false,
```typ
#let style = format-citation-numeric()
#show: doc => refsection(format-citation: style.format-citation, doc)

#add-bib-resource(read("bibs/bibliography.bib"))
#cite("bender20:_climb_nlu")
```)



== Styling the bibliography

A #bibtypst bibliography is displayed as a #link("https://typst.app/docs/reference/layout/grid/")[grid],
with one row per bibliography entry. The grid has one or two columns, depending on whether a first column 
is needed to display a label or not.

You can style this grid by passing a dictionary in the `grid-style` argument of `print-bibliography`.
The values in this dictionary will be used to overwrite the default values. 

In addition, the individual entries in the bibliography are typeset as paragraphs,
one per bib entry. You can style these paragraphs through `set par` rules, e.g. 
to give the entries a hanging indentation.


== Styling individual references
<sec:styling-individual-references>

The default reference style of #pergamon gives you fine-grained control over the way the
individual fields of a reference are rendered. A _field formatter_ is a function with parameters 
`(value, reference, field, options, style)`, where `field` is the name and `value` is the value
of a field in the reference; `reference` is the entire reference dictionary; `options` are the 
options that were passed to the reference style; and `style` is an optional style specification 
for the field. The field formatter is expected to return content representing the field's value.

You can override the formatters for specific fields by using the `format-fields` parameter 
of `format-reference`. The argument should be a dictionary that maps field names to field formatters.
One use of this mechanism is to highlight specific authors in a reference. For instance, to 
highlight my name in a reference, I could use the following call:

#zebraw(lang: false,
```typ
#format-reference(
  format-fields: (
    "author": (dffmt, value, reference, field, options, style) => {
      let formatted-names = value.map(d => {
        let highlighted = (d.family == "Koller")
        let name = format-name(d, format: "{given} {family}")
        if highlighted { strong(name) } else { name }
      })

      concatenate-names(formatted-names, maxnames: 999)
    }
  )
)
```)

#figure(
  box(stroke: 1pt, inset: 6pt)[
    #set align(left)
    #let style = format-citation-authoryear()

    #refsection(format-citation: style.format-citation)[
      #hide[
      ... some text here ... #cite("bender20:_climb_nlu")
      ]
      #v(-2em)

      #print-bibliography(
      title: none,
       format-reference: format-reference(
          reference-label: style.reference-label,
          format-fields: (
            // highlight my name in all references
            "author": (dffmt, value, reference, field, options, style) => {
              let formatted-names = value.map(d => {
                let highlighted = (d.family == "Koller")
                let name = format-name(d, format: "{given} {family}")
                if highlighted { strong(name) } else { name }
              })

              concatenate-names(formatted-names, maxnames: 999)
            },
          )
       ), 
       label-generator: style.label-generator
      )
    ]
  ],
  // box(stroke: 1pt)[#image("docs/materials/highlighted-author.png", width: 100%)],
  placement: top,
  caption: [Reference with highlighted author.]
) <fig:highlighted-author>

This will produce output as in @fig:highlighted-author.

Another effect that can be achieved by overriding field formatters is to change the 
presentation of the volume and number of the journal in which an article appears. Here's how
the default presentation "VOL.NUM" can be replaced with "vol. VOL, no. NUM":

#zebraw(lang: false,
```typ
#format-reference(
  volume-number-separator: ", ",
  format-fields: (
    "volume": (dffmt, value, reference, field, options, style) => {
      if reference.entry_type == "article" {
        [vol. #value]
      } else {
        dffmt(value, reference, field, options, style)
      }
    },

    "number": (dffmt, value, reference, field, options, style) => {
      if reference.entry_type == "article" {
        [no. #value]
      } else {
        dffmt(value, reference, field, options, style)
      }
    },
  )
)
```)

Note that this implementation makes use of the `dffmt` argument, which receives the
default implementation of the field formatters for volume and number, respectively, so 
that we can delegate the formatting of the field for references that are not journal articles.

One special case that is not covered by field formatters arises in the case of subtitles.
In #biblatex, the titles of journals, books, special issues, and multi-volume books can have
optional subtitles. If both are specified, #pergamon concatenates the title and subtitle
with the `subtitlepunct` argument, e.g. to "Title: Subtitle". It then applies a formatting function
to the entire concatenated title and subtitle; for instance, `format-journaltitle` defaults to
setting the title and subtitle in italics. You can override the default behavior by passing 
your own functions in these arguments. 

== Sorting the bibliography

You can furthermore control the order in which references are presented in the bibliography.
To this end, you can pass a sorting string in the `sorting` argument of `print-bibliography`.
See the documentation of this argument in @sec:package-doc for details.

== Styling the citations
<sec:styling-citations>

Citations in #bibtypst are #link("https://typst.app/docs/reference/model/link/")[link] elements, 
and can be styled using show rules. However, it is 
not entirely trivial to distinguish a `link` element that represents a #bibtypst citation from 
any other `link` element (referring e.g. to a website). #bibtypst therefore provides a function 
 `if-citation` which will make this distinction for you. The following piece of code
typesets all #bibtypst citations in blue:

#zebraw(lang: false,
```typ
  #show link: it => if-citation(it, value => {
    set text(fill: blue)
    it
  })
```)

The `value` argument contains metadata about the citation; `value.reference` is the
reference dictionary (see @sec:reference). You can use this information to style citations conditionally.
For instance, in order to typeset all citations to my own papers in green and all other
citations in blue, I could write:

#zebraw(lang: false,
```typ
#show link: it => if-citation(it, value => {
  if "Koller" in family-names(value.reference.fields.parsed-author) {
    set text(fill: green)
    it
  } else {
    set text(fill: blue)
    it
}})
 ```)


== Showing the entire bibliography

It is sometimes convenient to display the entire bibliography, and not just those 
references that were actually cited in the current refsection. You can instruct
`print-bibliography` to do this using the `show-all` argument:

#zebraw(lang: false,
```typ
#print-bibliography(
  format-reference: format-reference(),
  show-all: true
)
```)

To obtain finer control over the bibliography entries that are shown, you can 
use the `filter` argument. This function receives a #link(<sec:reference>)[reference dictionary] as 
its argument and returns `true` if this reference should be included in the bibliography
and `false` otherwise. For instance, the following call shows all journal articles
and nothing else:

#zebraw(lang: false,
```typ
#print-bibliography(
  format-reference: format-reference(),
  show-all: true,
  filter: reference => reference.entry_type == "article"
)
```)

== Continuous numbering
<sec:continuous-numbering>

When you typeset a CV, it is sometimes useful to have separate bibliographies for
journal articles, papers in conference proceedings, and so on. In this case, you might want to 
use the _numeric_ citation style to number all your references, and you might want to continue 
counting the papers across the different bibliographies; if you have seven journal papers, you
want the first conference paper to be "[8]".

You can achieve this using the `resume-after` parameter of `print-bibliography`. If you pass the 
number `7` for this parameter, the first entry in the bibliography will be labeled "[8]".

You can automatically continue numbering across multiple bibliographies by passing the `auto`
argument to the `resume-after` parameter. If you use `resume-after: auto` for the first bibliography
in a refsection, the numbering will start at 1. Each subsequent bibliography in the refsection then
determines how many references have already been displayed in this refsection and then starts numbering
at this reference count plus 1.

Note that the use of `resume-after: auto` requires an additional iteration of the Typst layout algorithm
to converge. It might therefore slow down compilation a little and invite layout convergence issues.


== Highlighting references
<sec:highlighting>

The builtin `format-reference` function accepts a parameter `highlight`, which you 
can use to highlight individual references in the bibliography. The
`highlight` function takes a `rendered-reference` as argument; this is a piece of content 
representing the entire rendered bibliography entry, just before it is printed.
It also receives the corresponding reference dictionary and the position in the bibliography.

Let's say that you use the `keywords` field in your #bibtex entries to contain the keyword `highlight`
if you want to highlight the paper. You can then selectively highlight references like this:

#zebraw(lang: false,
```typ
#let f-r = format-reference(
  highlight: (rendered, reference, index) => {
   if "highlight" in reference.fields.at("keywords", default: ()) {
      [#text(size: 8pt)[#emoji.star.box] #rendered]
   } else {
      rendered
}})
```)

This will place a marker before each reference with the "highlight" keyword, and will leave 
all other references unchanged.

#figure(
  box(stroke: 1pt, inset: 6pt)[
    #set align(left)
    #let style = format-citation-authoryear()

    #refsection(format-citation: style.format-citation)[
      #hide[
        ... some text here ... #cite("bender20:_climb_nlu")
      ]
      #v(-2em)

      #print-bibliography(
       title: none,
       format-reference: format-reference(
          reference-label: style.reference-label,
          highlight: (rendered, reference, index) => {
            if "highlight" in reference.fields.at("keywords", default: ()) {
              [#text(size: 8pt)[#emoji.star.box] #rendered]
            } else {
              rendered
            }
          }
       ), 
       label-generator: style.label-generator
      )
    ]
  ],
  placement: top,
  caption: [Highlighting a reference.]
) <fig:highlighting>



#show heading.where(level: 3): it => {
  set text(fill: darkblue)
  block({
    place(dx: -1.5em)[>>]
    it
  })
}


= Caveats

#v(-1em)
== Layout iterations

In the simplest case, #pergamon requires three iterations of the Typst layout algorithm
to converge. First, the cited references in each refsection are collected in a state; second,
the bibliography for the refsection is rendered and citation labels are assigned to each
reference; third, the citations in the running text are rendered correctly based on these labels.

The number of layout iterations is increased to four if you use the `resume-after: auto` feature 
in the numeric citation style. This feature requires an accurate count of the
references in the first bibliography in order to determine the numbering of the second bibliography.
Thus, the labels in the second bibliography only stabilize in layout iteration 3, and the citations
to these references only stabilize in iteration 4. Be aware that the use of this feature increases
the iteration count by one.

Furthermore, the number of layout iterations can occasionally grow to four if a reference in the
bibliography occurs close to a page break. Because the exact rendering of a citation into a string changes
across layout iterations 1--3, the bibliography itself may shift up or down by a few lines. When this
pushes the reference across a page break, Typst needs another layout iteration to stabilize the page
number for its label. This increase in iterations should not be cumulative with the resume-after increase;
both together should still be done in four iterations.


= Data model

#bibtypst makes a number of assumptions on the contents of the #bibtex entries.
These are typically consistent with those that #biblatex makes (see Chapter 2 "Database Guide"
in the #biblatex documentation), but some of them are worth discussing.

== Dates
<sec:dates>

Dates can occur in a number of places in the #bibtex entry. The most important one
is the publication date of the reference. It can be specified in one of two ways:

- In the `date` field, using the ISO 8601-2 format: "YYYY-MM-DD" or "YYYY-MM" or "YYYY".
  In this format, years, months, and days must all be positive integers.
- In the `year` and `month` fields. In this format, the value of `year` should be a positive integer.
  The `month` field should contain a positive integer (1--12), full English month names like 
  `january`, or three-letter abbreviations of English month names like `feb`. 
  Dates specified in this way will be potentially localized using `bibstring`
  (see @sec:package:utility). As a fallback option, you can also specify some other string
  for the month, which will be printed in the reference verbatim.

All other #bibtex fields whose name ends in `date` (e.g. `urldate`) will also be parsed
as in the `date` option described above.

The parsed dates will be stored in the #link(<sec:reference>)[reference dictionary] `reference`
under `reference.fields.parsed-X`, where `X` is the name of the `date` field. (If the publication 
date is specified with a `year` field, its value will still be stored in `reference.fields.parsed-date`.)
This makes them available for other functions and styles. A parsed date is represented as a dictionary 
with keys `year`, `month`, and `day`, all of which may be missing. The values under these fields are 
all positive integers. If a date specification in the #bibtex entry cannot be parsed, it will be
represented as an empty dictionary.

In addition to these basic date specifications, #biblatex allows for date ranges (#issue(55),
approximate dates (#issue(56)), and years before the Common Era (#issue(57)). These features 
are not yet supported in #bibtypst.


= Detailed documentation
<sec:package-doc>

Let's now go through the detailed documentation of all the functions and data structures
that #bibtypst exposes to you.

== Reference dictionaries
<sec:reference>

The central data structure that #bibtypst manages is the _reference dictionary_. This is a dictionary
as shown in @fig:reference-dict; its purpose is to represent all information about a single bib entry.
It is obtained by parsing a #bibtex file using #link("https://typst.app/universe/package/citegeist/")[citegeist] 
and then enriching it with some extra information from within #bibtypst.

From the perspective of a style developer, the most important part of the reference dictionary is
the `fields` part, which contains the fields of the #bibtex entry. In the example, the #bibtex entry defined 
a number of standard #bibtex fields, such as `author` and `title`; it also defines some lesser-known
fields that are standard in #bibtex, such as `keywords`; and it also has extra fields, such as `award`.
The reference dictionary makes all of these #bibtex fields available to you.

The keys `entry_type` and `entry_key` at the top of @fig:reference-dict also come from the #bibtex file;
they represent the key and entry type of the #bibtex entry. In addition, #bibtypst preprocesses the reference
dictionary and adds some fields of its own.

- The `label` and `label-repr` fields store the output of the `label-generator` call.

- The `parsed-X` fields contain parsed name information. For instance, `parsed-author` represents the outcome of
  parsing the names in the `author` field. It consists of an array of _name-part dictionaries_, which map the keys
  `given` and `family` (aka "first" and "last" names) to the parts of that author's name.

- The `sortstr-author` field concatenates the author names, family-name first. It is used when sorting references
  in a bibliography using the `n` identifier.

The preprocessing happens relatively early, so the code in a reference or citation style can rely on the presence
of these fields in the reference dictionary.


#figure(
zebraw(lang: false,
```
(
  entry_type: "inproceedings",
  entry_key: "bender20:_climb_nlu",
  fields: (
    author: "Emily M. Bender and Alexander Koller",
    award: "Best theme paper",
    booktitle: "Proceedings of the 58th Annual Meeting of the Association
                for Computational Linguistics (ACL)",
    doi: "10.18653/v1/2020.acl-main.463",
    keywords: "highlight",
    title: "Climbing towards NLU: On Meaning, Form, and Understanding 
            in the Age of Data",
    year: "2020",
    parsed-author: (
      (given: "Emily M.", family: "Bender"),
      (given: "Alexander", family: "Koller"),
    ),
    sortstr-author: "Bender,Emily M. Koller,Alexander",
    parsed-editor: none,
    parsed-translator: none,
    parsed-date: (year: 2020)
  ),
  label: ("Bender and Koller", "2020"),
  label-repr: "Bender and Koller 2020",
)
```),
placement: top,
caption: [Example of a reference dictionary.])
 <fig:reference-dict>



== Main functions
<sec:package:main>

These are functions implementing the base functionality of #bibtypst, such as `cite` and `print-bibliography`.

#v(1em)
#let docs = tidy.parse-module(read("src/bibtypst.typ"), scope: scope)
#tidy.show-module(
  docs, 
  break-param-descriptions: true,
  style: tidy.styles.default, 
  show-outline: false, 
  // scope: (:) // (bibtypst: "X")
)


== Builtin reference style
<sec:package:builtin-reference>

Here we explain the builtin reference style.
#v(1em)

#let style-docs = tidy.parse-module(read("src/reference-styles.typ"), scope: scope)
#tidy.show-module(style-docs, style: tidy.styles.default, show-outline: false, break-param-descriptions: true)


== Builtin citation styles 
<sec:package:builtin-citation>

Here we explain the builtin citation styles.
#v(1em)

#let style-docs = tidy.parse-module(read("src/citation-styles.typ"), scope: scope)
#tidy.show-module(style-docs, style: tidy.styles.default, show-outline: false, break-param-descriptions: true)


== Utility functions 
<sec:package:utility>

The following functions may be helpful in the advanced usage and customization of #bibtypst.

#let x = tidy.parse-module(read("src/bib-util.typ"), scope: scope)
#tidy.show-module(x, style: tidy.styles.default, show-outline: false)

#let x = tidy.parse-module(read("src/names.typ"), scope: scope)
#tidy.show-module(x, style: tidy.styles.default, show-outline: false)

#let x = tidy.parse-module(read("src/bibstrings.typ"), scope: scope)
#tidy.show-module(x, style: tidy.styles.default, show-outline: false)


= Differences from #biblatex

I call #pergamon "#biblatex _inspired_" because #biblatex is a huge library, and I will probably never
manage to achieve full feature parity with #biblatex. Nonetheless, #pergamon covers a large part of the 
functionality and configurability of #biblatex, and the feature gap closes with each release.

To get a sense of where we stand with respect to supporting #biblatex features, you can have a look
at #link("https://github.com/alexanderkoller/pergamon/blob/main/examples/biblatex-stresstest.typ")[biblatex-stresstest.typ].
It renders the #link("https://github.com/plk/biblatex/blob/dev/bibtex/bib/biblatex/biblatex-examples.bib")[biblatex-examples.bib]
from the official #biblatex Github repository, augmented with examples for a few additional entry types.
You can compare:

- #link("https://github.com/alexanderkoller/pergamon/blob/main/examples/biblatex-stresstest.pdf")[biblatex-stresstest.pdf], the
  result of compiling biblatex-stresstest.typ with Typst (i.e. the bibliography as rendered by #pergamon);
- #link("https://github.com/alexanderkoller/pergamon/blob/main/examples/stresstest-compiled-with-biblatex.pdf")[stresstest-compiled-with-biblatex.pdf],
  the result of rendering the same bibliography with #biblatex (using #link("https://github.com/alexanderkoller/pergamon/blob/main/biblatex-playground/stresstest-compiled-with-biblatex.tex")[this tex file]).

Note that a handful of bib entries cause #pergamon to crash; these are in #link("https://github.com/alexanderkoller/pergamon/blob/main/bibs/unsupported-biblatex-examples.bib")[unsupported-biblatex-examples]. These all involve the use of `crossref`, `set`, or `label` in bib entries without authors or editors.


// #v(-1em)
== String declarations in #bibtex files 

#pergamon supports `@string` declarations in #bibtex files, but it requires that you use
a slightly different syntax than in standard #biblatex. 

In #biblatex, you declare strings as follows:

#zebraw(lang: false,
```bibtex
@string{anch-ie = {Angew.~Chem. Int.~Ed.}}
@string{cup     = {Cambridge University Press}}
@string{dtv     = {Deutscher Taschenbuch-Verlag}}
```
)

By contrast, declare them as follows in #pergamon:

#zebraw(lang: false,
```bibtex
@string{
  anch-ie = {Angew.~Chem. Int.~Ed.},
  cup     = {Cambridge University Press},
  dtv     = {Deutscher Taschenbuch-Verlag},
}
```)

This is because #pergamon uses the #link("https://github.com/typst/biblatex")[Typst Biblatex crate]
to parse #bibtex files, and that crate requires the syntax variant.



== Known limitations

- #pergamon supports `year` and `date` declarations. However, it currently does not support
  approximate dates (#issue(56)), negative years (#issue(57)), date ranges (#issue(55)),
  or non-numeric years (#issue(111)).
- #pergamon supports the `author`, `editor`, and `translator` fields, but there is currently
  no support for `editora` and similar fields (#issue(104)). Furthermore, when the same
  person has multiple roles, these are printed separately and not aggregated (#issue(103)).
- #pergamon currently requires all #bibtex entries to specify an author, editor, or
  translator; there is no support for the `label` or `shorthand` fields (#issue(115)).
- It is a known bug that #pergamon does not automatically uppercase words at the beginning
  of a sentence (#issue(95)).
- `set`, `crossref`, `related`, and `pageref` are not yet supported.


= Changelog

==== Changes in 0.7.2 (2026-01-26)
- Added support for refsection-local bibliographies.
- Improved robustness in Bibtex processing.

==== Changes in 0.7.1 (2026-01-22)
- Added elementary support for HTML export.
- Bumped to citegeist 0.2.1, which parses Bibtex more robustly and has improved error reporting (thanks to Y.D.X. for the pull request).
- Added the ability to define categories (thanks to maxnoe for the suggestion).
- Added minalphanames option to the _alphabetic_ citation style (thanks to DorianRudolph for the pull request).

==== Changes in 0.7.0 (2025-12-31)
- Revamped the way in which references are collected in each refsection (thanks to bluss and SillyFreak for technical advice).
- Dropped support for `count-bib-entries`, which is no longer needed.
- The _numeric_ style now supports custom citation labels (thanks to andreas-bulling for the suggestion).
- The _numeric_ style now supports a compact form (thanks to thvdburgt for the suggestion).
- The `print-bibliography` function can now print the references in reverse order (thanks to andreas-bulling for the suggestion).
- Fixed a number of bugs (thanks to ironupiwada, zouharvi).
- Fixed some bugs in the documentation (thanks to thvdburgt).

==== Changes in 0.6.0 (2025-12-06)
- Reduced the number of iterations until layout convergence from five to three.
- Added the `resume-after: auto` parameter to support continuous numbering of references across bibliographies.
- Fixed a number of bugs.

==== Changes in 0.5.0 (2025-10-31)
- Implemented the complete set of entry types in Biblatex.
- Languages and countries are now rendered correctly through bibstrings.
- Introduced the `format-function` argument, which allows flexible control
  over how #pergamon formats larger blocks of references. This permits
  far-reaching modifications of the standard reference style, without
  having to reimplement the style from scratch.
- Greatly improved support for contributors who are not the author. 
  For instance, books that have only an editor and not an author are now
  rendered correctly.
- Added an option to choose between long and short bibstrings.
- Fixed a number of bugs.

==== Changes in 0.4.0 (2025-10-13)
- Introduced the `format-field` argument, which allows flexible control 
  over how #pergamon formats individual #bibtex fields in the reference.
- Added the `minnames` and `maxnames` arguments to `format-reference`
  and `format-citation-authoryear`, replicating the #biblatex options.
- More flexible control over the bibstring table.
- Cleaned up the formatting of titles that permit subtitles.

==== Changes in v0.3.2 (2025-10-02)

- Fixed a number of bugs.
- Added the `print-identifiers` parameter to `format-reference`.

==== Changes in v0.3.1 (2025-09-22)

- Fixed a number of bugs.
- Can now specify different name formats for authors, editors, etc.
- Can now specify prefixes and suffixes in authoryear citations.
- Citing a nonexistent reference key now displays a warning.

==== Changes in v0.3.0

- Author names are now parsed as in #biblatex, using the parser of the #link("https://crates.io/crates/biblatex")[biblatex crate].
- Added an `eval-scope` argument to `format-reference` and dropped the `eval-mode`
  parameter from `print-bibliography`. It is now specified directly on `format-reference`.
- Added `name` and `year` citation forms.
- `print-bibliography` now has a `resume-after` parameter.
- More correct date handling: months can now be suppressed in the bibliography, and the `d` sorting specifier works correctly.

==== Changes in v0.2.0

- Aggregated citation commands: `#cite("key1", "key2", ...)`.
- Support for `date` and `month` fields (thanks to ironupiwada for contributing code).
- Added `source-id` parameter to `add-bib-resource`.
- The `suppress-fields` option in `format-reference` can now be defined per entry type.
- Default style avoids printing two punctuation symbols in a row.
- Defining multiple references with the same key is now an error.