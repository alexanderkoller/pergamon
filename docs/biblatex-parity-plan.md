# Pergamon Biblatex Parity Plan

This plan summarizes the remaining work for bringing Pergamon closer to
Biblatex parity. It is grounded in the current Pergamon source and in the
installed Biblatex 2024 source:

- Pergamon source:
  - `src/bibtypst.typ`
  - `src/reference-styles.typ`
  - `src/printfield.typ`
  - `src/bib-util.typ`
  - `src/dates.typ`
  - `src/names.typ`
  - `src/bibstrings.typ`
  - `bibs/unsupported-biblatex-examples.bib`
- Biblatex source:
  - `/usr/local/texlive/2024/texmf-dist/tex/latex/biblatex/blx-dm.def`
  - `/usr/local/texlive/2024/texmf-dist/tex/latex/biblatex/biblatex.def`
  - `/usr/local/texlive/2024/texmf-dist/tex/latex/biblatex/bbx/standard.bbx`

The issue links below point to existing Pergamon issues when they already
cover the gap. Items marked "needs issue" were not clearly covered by an
existing open issue at the time of this audit.

## Executive Summary

Pergamon is now close to Biblatex's `standard.bbx` for ordinary, flat entries
in the supported entry types. The biggest remaining gaps are not isolated
punctuation fixes in bibliography drivers. They are mostly Biblatex's
preprocessing, data model, inheritance, label fallback, role aggregation,
sorting, date normalization, localization, and citation-state machinery.

The recommended order is:

1. Finish the 0.8.1 visible-rendering fixes:
   [#171 Subtitle printing behavior](https://github.com/alexanderkoller/pergamon/issues/171)
   and
   [#178 InBook entry type pages duplication](https://github.com/alexanderkoller/pergamon/issues/178).
2. Implement Biblatex-compatible parent/inheritance processing:
   [#90 Implement crossref](https://github.com/alexanderkoller/pergamon/issues/90),
   plus new issues for `xref`, `xdata`, and `@set`.
3. Fix nameless-entry label fallback:
   [#115 Add support for the label field](https://github.com/alexanderkoller/pergamon/issues/115)
   and
   [#117 Should labelnames be local to the citation styles?](https://github.com/alexanderkoller/pergamon/issues/117).
4. Implement related-entry printing and related field formats.
5. Complete role-string and secondary-name macro parity:
   [#102 Implement "strg" roles](https://github.com/alexanderkoller/pergamon/issues/102),
   [#103 Implement "+others"](https://github.com/alexanderkoller/pergamon/issues/103),
   and
   [#104 Support for editora, editorb, editorc](https://github.com/alexanderkoller/pergamon/issues/104).
6. Broaden sorting/date/name/citation parity after the core data model is
   reliable.

## P0: Core Data Model And Preprocessing

### 1. Crossref, Xref, And Xdata Inheritance

Existing issue:
[#90 Implement crossref](https://github.com/alexanderkoller/pergamon/issues/90)

Current Pergamon evidence:

- `bibs/unsupported-biblatex-examples.bib` marks `westfahl:space` unsupported
  because it requires `crossref`.
- `src/bib-util.typ` has only a small set of field and type aliases; it does
  not implement Biblatex inheritance rules.
- `src/bibtypst.typ` preprocesses individual references, but does not resolve
  parent-child entries before label generation, sorting, and rendering.

Biblatex evidence:

- `blx-dm.def` declares `crossref` and `xref` as entry-key fields.
- `blx-dm.def` declares `xdata` as a skip-output entry type and as an
  inheritance field.
- Biblatex inheritance is type-sensitive. For example, a parent `@collection`
  title may be inherited into an `@incollection` child as `booktitle`, not just
  copied field-for-field.

Plan:

1. Broaden issue #90 from "crossref" alone to "crossref/xref/xdata
   preprocessing."
2. Add an inheritance preprocessing stage before `preprocess-reference`.
3. Implement Biblatex's default inheritance table, including type-sensitive
   field mappings.
4. Preserve enough metadata to know whether a value was explicit or inherited.
5. Add tests from `biblatex-examples.bib` that currently live in
   `unsupported-biblatex-examples.bib`.

Acceptance criteria:

- Cross-referenced `incollection`, `inbook`, and `inproceedings` examples from
  Biblatex compile without manual duplication.
- `xref` establishes the relation without data inheritance.
- `xdata` inherits data without making the xdata entry printable/citable.
- Parent inclusion behavior is either Biblatex-compatible or explicitly
  documented if Typst constraints require a difference.

### 2. Entry Sets

Needs issue: support `@set` and `entryset`.

Current Pergamon evidence:

- `bibs/unsupported-biblatex-examples.bib` marks `@set{set}` and
  `@set{stdmodel}` as unsupported.
- `src/reference-styles.typ` implements drivers for the main `standard.bbx`
  entry types, but not a `set` driver.

Biblatex evidence:

- `standard.bbx` defines a `set` bibliography driver.
- `blx-dm.def` declares `set` as an entry type and `entryset` as a key-list
  field.

Plan:

1. Add a dedicated issue for `@set` and `entryset`.
2. Decide whether set expansion belongs in bibliography preprocessing or in a
   `driver-set` implementation. Prefer preprocessing for label/sorting parity.
3. Implement the `set` driver after the entryset data is resolved.
4. Add tests for citing the set itself and, if supported, citing set members.

Acceptance criteria:

- Biblatex example sets compile.
- Set labels and bibliography output match Biblatex's standard style for common
  cases.
- Set members do not accidentally render as ordinary standalone entries unless
  explicitly requested.

### 3. Related Entries

Needs issue: support `related`, `relatedtype`, `relatedstring`, and
`relatedoptions`.

Current Pergamon evidence:

- `src/printfield.typ` lists unsupported field formats for `related`,
  `related:multivolume`, `related:origpubin`, `related:origpubas`,
  `relatedstring:default`, and `relatedstring:reprintfrom`.

Biblatex evidence:

- `standard.bbx` contains `related:init` and `related` macros.
- `biblatex.def` contains related-entry macros including `related:default`,
  `related:bytranslator`, `related:multivolume`, `related:origpubin`,
  `related:origpubas`, and `related:reprintfrom`.
- `blx-dm.def` declares `related`, `relatedtype`, `relatedstring`, and
  `relatedoptions`.

Plan:

1. Add a dedicated issue for related entries.
2. Resolve `related` key lists during preprocessing, after inheritance.
3. Implement `related:init`/`related` behavior at the end of drivers.
4. Implement the known related-type format variants.
5. Add tests covering `default`, `multivolume`, `origpubin`, `origpubas`, and
   `reprintfrom`.

Acceptance criteria:

- Related entries print with Biblatex-compatible labels, separators, and
  nesting behavior.
- Related entries do not disturb the main bibliography's sorting and label
  generation.

## P0/P1: Labels And Nameless Entries

### 4. Label Field And Label Fallback Chain

Existing issues:

- [#115 Add support for the label field](https://github.com/alexanderkoller/pergamon/issues/115)
- [#117 Should labelnames be local to the citation styles?](https://github.com/alexanderkoller/pergamon/issues/117)

Current Pergamon evidence:

- `src/bibtypst.typ` currently panics if no `labelname` can be determined.
- `bibs/unsupported-biblatex-examples.bib` lists `cms`, `ctan`, and `jcg` as
  failures caused by missing author/editor names despite available title or
  label-like fields.

Biblatex evidence:

- `blx-dm.def` marks `label`, `shorthand`, `shorttitle`, `shortjournal`, and
  `shortseries` as label-relevant fields.
- Biblatex citation styles can fall back through names, labels, shorthand,
  labeltitle/title-like fields, and dates depending on style.

Plan:

1. Implement `label` support for issue #115.
2. Use issue #117 to move labelname computation closer to citation-style label
   generation where possible.
3. Add a broader fallback chain beyond `label`:
   `label`, `shorthand`, `shorttitle`, title-derived label, and possibly
   entry-key fallback for placeholder/error modes.
4. Add tests for authorless `manual`, `online`, and `periodical` entries from
   `unsupported-biblatex-examples.bib`.

Acceptance criteria:

- Nameless entries do not crash numeric styles.
- Authoryear and alphabetic styles match Biblatex behavior for explicit
  `label` fields.
- Unsupported examples `cms`, `ctan`, and `jcg` can move into the main
  Biblatex stress test corpus.

## P1: Standard Style Macro Parity

### 5. Title, Subtitle, Titleaddon, And Inbook Pages

Existing issues:

- [#171 Subtitle printing behavior](https://github.com/alexanderkoller/pergamon/issues/171)
- [#178 Bug: "InBook" entry type pages duplication](https://github.com/alexanderkoller/pergamon/issues/178)

Current status:

- These are the two remaining 0.8.1 parity issues.
- The implemented direction should remain Biblatex-shaped:
  `title + subtitle` formatted as a single title unit, with `titleaddon` after
  that unit.
- `inbook` should print `pages` only through the chapter/pages block, not again
  through `note+pages`.

Plan:

1. Keep broad persistent visual tests for title rendering across all drivers
   because the `title` macro is deep.
2. Keep focused `inbook` tests for `pages` alone and `note + pages`.
3. Compare reference outputs against Biblatex PDFs where separator questions
   arise.

Acceptance criteria:

- Article-like titles quote the composed title/subtitle together.
- Book-like titles emphasize the composed title/subtitle together.
- Plain/special branches do not gain stray punctuation.
- `inbook` page ranges appear exactly once.

### 6. Role Strings, +others, And Secondary Contributors

Existing issues:

- [#102 Implement "strg" roles](https://github.com/alexanderkoller/pergamon/issues/102)
- [#103 Implement "+others"](https://github.com/alexanderkoller/pergamon/issues/103)
- [#104 Support for editora, editorb, editorc](https://github.com/alexanderkoller/pergamon/issues/104)
- [#101 Name formats: byeditor instead of editor?](https://github.com/alexanderkoller/pergamon/issues/101)

Current Pergamon evidence:

- `src/reference-styles.typ` marks `authorstrg` as incomplete.
- `byeditor-others`, `byauthor`, and related macros contain TODOs for
  `byeditorx`, `bytypestrg`, and role-string expansion.
- `src/bibtypst.typ` already parses `editora`, `editorb`, and `editorc` as name
  fields, but the reference style does not fully render them.

Biblatex evidence:

- `biblatex.def` contains `authorstrg`, `byeditor`, `byeditorx`,
  `byeditor+others`, and `byeditor+othersstrg`.
- Biblatex role handling combines roles such as editor, translator,
  commentator, annotator, introduction, foreword, and afterword with localized
  strings.

Plan:

1. Implement `authorstrg` and `bytypestrg` before touching all drivers.
2. Implement `byeditorx` for `editora`, `editorb`, and `editorc`.
3. Implement `+others` grouping so identical names with multiple roles are
   grouped rather than duplicated.
4. Add tests for editors, translators, editors plus translators, and
   `editora/b/c` roles.

Acceptance criteria:

- Edited and translated works match Biblatex for common `standard.bbx` cases.
- Secondary contributors are not duplicated.
- Role strings use the selected long/short bibstring table.

### 7. Pagination And Page Totals

Needs issue: pagination and `pagetotal` parity.

Current Pergamon evidence:

- `src/printfield.typ` lists `pagetotal` as unsupported.
- `src/reference-styles.typ` has `note-pages` and `chapter-pages`, but broader
  Biblatex pagination behavior is not complete.

Biblatex evidence:

- `blx-dm.def` distinguishes `pages`, `pagination`, `bookpagination`, and
  `pagetotal`.
- `biblatex.def` formats `pagetotal` through `bookpagination`.

Plan:

1. Add an issue for `pagetotal`, `pagination`, and `bookpagination`.
2. Implement field formatting for `pagetotal`.
3. Audit every driver that prints `pages`, `pagetotal`, or locators.
4. Add tests for page, column, verse, section, and total-page cases if those
   bibstrings are available.

Acceptance criteria:

- `pages` and `pagetotal` are not conflated.
- Page prefixes and pluralization match Biblatex for common cases.

## P1/P2: Sorting And Disambiguation

### 8. Presort, Sortkey, And Sorting Templates

Existing issue:
[#100 Implement presort and sortkey](https://github.com/alexanderkoller/pergamon/issues/100)

Current Pergamon evidence:

- `src/bibtypst.typ` supports a compact sorting string with keys `n`, `t`,
  `y`, `yd`, `d`, `dd`, `v`, `a`, and `none`.
- `print-bibliography` documents that citation-order sorting is not reliably
  supported.

Biblatex evidence:

- Biblatex sorting templates include `presort`, `sortkey`, `sortname`,
  `sorttitle`, `sortyear`, `sortshorthand`, date parts, label parts, and
  locale-aware collation behavior.

Plan:

1. Broaden issue #100 from `presort`/`sortkey` to "Biblatex sorting template
   parity."
2. Implement `presort` and `sortkey` first because they are explicit fields and
   least ambiguous.
3. Add `sorttitle`, `sortyear`, `sortname`, and `sortshorthand`.
4. Decide whether to expose a Biblatex-template-like API or keep Pergamon's
   current compact sorting string and document the differences.
5. Investigate stable citation-order sorting after Typst context limitations are
   clear.

Acceptance criteria:

- Explicit `presort` and `sortkey` fields affect bibliography order.
- Common Biblatex sort schemes such as `nty`, `nyt`, `ynt`, and no-sort
  behavior can be approximated or documented precisely.

### 9. Extradate, Uniquename, And Uniquelist

Related issue:
[ #52 Print extradate with brackets depending on context ](https://github.com/alexanderkoller/pergamon/issues/52)

Current Pergamon evidence:

- `src/bibtypst.typ` detects label collisions and adds `extradate`.
- Full Biblatex-style name/list disambiguation is not present.

Biblatex evidence:

- Biblatex has `extradate`, `extratitle`, `extratitleyear`, `uniquename`,
  `uniquelist`, and style-dependent disambiguation behavior.

Plan:

1. Keep #52 for context-sensitive rendering of `extradate`.
2. Add an issue for `uniquename` and `uniquelist` if this becomes part of the
   parity target.
3. Add tests with same author/year/title collisions and ambiguous shortened
   name lists.

Acceptance criteria:

- Authoryear citations disambiguate like Biblatex for common same-author/year
  cases.
- Name-list expansion for ambiguous citations is either supported or documented
  as intentionally out of scope.

## P2: Dates

### 10. Date Model Expansion

Existing issues:

- [#55 Permit date ranges](https://github.com/alexanderkoller/pergamon/issues/55)
- [#56 Permit approximate dates](https://github.com/alexanderkoller/pergamon/issues/56)
- [#57 Permit dates with negative years](https://github.com/alexanderkoller/pergamon/issues/57)
- [#111 Handle dates that are strings](https://github.com/alexanderkoller/pergamon/issues/111)
- [#140 Consider supporting the origdate field](https://github.com/alexanderkoller/pergamon/issues/140)

Current Pergamon evidence:

- `src/dates.typ` explicitly lists TODOs for date ranges, approximate dates,
  and negative years.
- `src/bibtypst.typ` parses any field ending in `date`, but rendering support is
  still field/style dependent.

Biblatex evidence:

- `blx-dm.def` declares `date`, `eventdate`, `origdate`, and `urldate`.
- Biblatex supports ranges, uncertain dates, approximate dates, open-ended
  dates, seasons, and negative years.

Plan:

1. Implement date ranges first because issue #111's `1885/1888` case is a
   common Biblatex example shape.
2. Implement approximate/uncertain markers.
3. Implement negative years.
4. Implement `origdate` rendering in both bibliography entries and citation
   labels where relevant.
5. Add tests for each date field: `date`, `eventdate`, `origdate`, and
   `urldate`.

Acceptance criteria:

- Unsupported date examples no longer render as `n.d.`.
- `origdate` can be used without custom user style wrappers.
- Date formatting remains configurable through field formatters.

## P2: Names

### 11. Name Parsing, Formatting, And Scope

Existing or related issues:

- [#101 Name formats: byeditor instead of editor?](https://github.com/alexanderkoller/pergamon/issues/101)
- [#117 Should labelnames be local to the citation styles?](https://github.com/alexanderkoller/pergamon/issues/117)
- Closed background issue:
  [#179 Pick up prefix name parts from Biblatex 0.12](https://github.com/alexanderkoller/pergamon/issues/179)

Current Pergamon evidence:

- `src/names.typ` supports name-part dictionaries with family, given, prefix,
  suffix, and initials.
- `src/bibtypst.typ` parses many Biblatex name fields, including secondary
  contributor fields.

Biblatex evidence:

- Biblatex has a larger name system with name aliases, per-context formats,
  particles, name hashes, initials, uniqueness, and role-specific formatting.

Plan:

1. Finish secondary-role rendering through issues #101, #102, #103, and #104.
2. After label fallback is fixed, audit name disambiguation separately.
3. Add parity tests for prefixes, suffixes, particles, initials, `and others`,
   and role-specific formats.

Acceptance criteria:

- Common Biblatex names render correctly in bibliography and citation contexts.
- Label generation no longer forces name parsing where a citation style does
  not need it.

## P2/P3: Citation API And Citation State

### 12. Biblatex Citation Command Family

Existing or related issues:

- [#40 Support for `@key` citations](https://github.com/alexanderkoller/pergamon/issues/40)
- Closed:
  [#154 Support biblatex-style fullcite](https://github.com/alexanderkoller/pergamon/issues/154)
- Closed:
  [#69 Allow prefix and suffix in #cite](https://github.com/alexanderkoller/pergamon/issues/69)
- Closed:
  [#146 Support merging of citations](https://github.com/alexanderkoller/pergamon/issues/146)

Needs issue: Biblatex citation tracker parity.

Current Pergamon evidence:

- `src/bibtypst.typ` exposes `cite`, `citet`, `citep`, `citeg`, `citen`,
  `citename`, and `citeyear`.

Biblatex evidence:

- `biblatex.def` declares many more citation commands, including `fullcite`,
  `footfullcite`, `citeauthor`, `citetitle`, `citeyear`, `citedate`,
  `citeurl`, and note variants.
- Biblatex styles use stateful trackers such as `ibid`, `idem`, `opcit`, and
  `loccit`.

Plan:

1. Decide whether Pergamon aims for Biblatex command-name parity or only
   behavior parity through Typst-native functions.
2. Add a citation tracker issue for `ibid`, `idem`, `opcit`, `loccit`, and
   reset behavior.
3. Add command/function parity for `citeauthor`, `citetitle`, `citedate`,
   `citeurl`, `fullcite`, and footnote variants if feasible in Typst.
4. Add multicite and locator tests after the tracker model exists.

Acceptance criteria:

- Users can express common Biblatex citation idioms without custom formatter
  rewrites.
- Tracker behavior is predictable across paragraphs, footnotes, and
  refsections, or documented if Typst constraints make exact parity impossible.

## P3: Entry Type Coverage

### 13. Additional Biblatex Entry Types

Needs issue: additional Biblatex entry types.

Current Pergamon evidence:

- `src/reference-styles.typ` implements drivers for the core `standard.bbx`
  types and aliases some multivolume/supplemental types.
- `src/bib-util.typ` aliases only `conference`, `electronic`, `www`,
  `mastersthesis`, `phdthesis`, and `techreport`.

Biblatex evidence:

- `blx-dm.def` declares additional entry types such as `artwork`, `audio`,
  `bibnote`, `commentary`, `customa` through `customf`, `image`,
  `jurisdiction`, `legal`, `legislation`, `letter`, `movie`, `music`,
  `performance`, `reference`, `software`, `standard`, `video`, `xdata`, and
  `set`.

Plan:

1. Add a tracking issue for non-standard-driver Biblatex entry types.
2. Classify each type as:
   - aliasable to an existing driver,
   - needing a small dedicated driver,
   - requiring a larger legal/media/custom-data model decision,
   - or intentionally unsupported.
3. Add tests for `software`, `standard`, `audio/video/image/movie`, and legal
   types if they are in scope.

Acceptance criteria:

- Unsupported entry types either render Biblatex-compatible output or produce a
  clear, documented fallback.
- The dummy driver is no longer the silent behavior for common Biblatex types.

## P3: Localization And Option System

### 14. Localization

Needs issue: Biblatex `.lbx` localization parity.

Current Pergamon evidence:

- `src/bibstrings.typ` has an explicit TODO to internationalize beyond English.
- The current bibstring table can be overridden manually, but this is not the
  same as Biblatex's localization system.

Biblatex evidence:

- Biblatex ships localization files with long/short strings, pluralization,
  gender-sensitive terms, role strings, date strings, and language-specific
  conventions.

Plan:

1. Add a localization issue.
2. Decide whether to import a subset of Biblatex `.lbx` data or provide a
   Typst-native localization table format.
3. Wire `langid`, `language`, and `origlanguage` behavior into localization
   rather than treating them as mostly printable fields.
4. Add tests for English plus at least one non-English language.

Acceptance criteria:

- Users can select a bibliography language without overriding dozens of strings.
- Role strings and date strings localize consistently.

### 15. Option Scoping And Customization

Existing or related issues:

- [#118 Refactor format-journaltitle etc. so they can be customized with format-functions](https://github.com/alexanderkoller/pergamon/issues/118)
- [#94 Rename "periods" and "commas" to "block-separator" and "unit-separator"?](https://github.com/alexanderkoller/pergamon/issues/94)
- Closed:
  [#3 Implement Biblatex options](https://github.com/alexanderkoller/pergamon/issues/3)
- Closed:
  [#143 Feature request: Category system](https://github.com/alexanderkoller/pergamon/issues/143)

Current Pergamon evidence:

- `src/reference-styles.typ` has many Typst-native customization options:
  `format-fields`, `format-functions`, `suppress-fields`,
  `additional-fields`, identifier-printing options, `maxnames`, `minnames`,
  and separator settings.

Biblatex evidence:

- Biblatex supports global/type/entry/refcontext scoping, sourcemaps,
  datamodel extension, categories, keywords, filters, backrefs, indexing, and
  style inheritance.

Plan:

1. Keep Pergamon's Typst-native customization API, but document where it maps to
   Biblatex options and where it intentionally differs.
2. Use #118 to remove remaining hard-coded title-format customization gaps.
3. Add follow-up issues only for parity features that users need in practice:
   per-entry options, refcontext options, keyword filters, and sourcemap-like
   preprocessing.

Acceptance criteria:

- Common Biblatex style customization tasks can be expressed in Pergamon.
- Intentional API differences are documented rather than discovered by failure.

## Testing Strategy

The current Tytanic persistent tests should remain the regression gate for
visible output. For parity work, add three layers of tests:

1. Focused persistent tests for each fixed behavior.
2. Biblatex comparison PDFs for separator-sensitive changes.
3. Stress-test migration: move examples from
   `bibs/unsupported-biblatex-examples.bib` into the supported Biblatex corpus
   whenever a parity feature lands.

Priority test groups:

- Crossref/xdata/xref inheritance.
- `@set` and `entryset`.
- `related` entries.
- Nameless entries using `label`, `shorttitle`, `shorthand`, and title
  fallback.
- Role strings and secondary contributor aggregation.
- Date ranges, approximate dates, negative years, string dates, and `origdate`.
- Sorting with `presort`, `sortkey`, `sorttitle`, `sortyear`, and `sortname`.
- Citation tracker state, if implemented.

Reference-output rule:

- For bibliography-driver punctuation and separator behavior, generate a small
  Biblatex PDF for comparison before committing persistent Pergamon references.
- For preprocessing features such as inheritance and label fallback, compare
  both rendered output and the effective resolved fields where practical.

## Issue Gaps To Create

The following issues appear to be missing and should be created if full
Biblatex parity remains the goal:

1. Support `xref` and `xdata` inheritance, or broaden #90 to include them.
2. Support `@set` and `entryset`.
3. Support `related` entries and related-type formatting.
4. Implement full Biblatex label fallback beyond the `label` field.
5. Implement `pagetotal`, `pagination`, and `bookpagination` parity.
6. Implement Biblatex citation trackers: `ibid`, `idem`, `opcit`, and
   `loccit`.
7. Track additional Biblatex entry types beyond the current standard-driver
   set.
8. Add Biblatex localization / `.lbx` parity.
9. Track `uniquename` and `uniquelist` disambiguation if exact authoryear
   parity is required.
