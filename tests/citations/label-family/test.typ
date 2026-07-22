#import "/src/bibtypst.typ": add-bib-resource, bibliography, preprocess-reference, label-sort-deduplicate
#import "/src/citation-styles.typ": format-citation-authoryear, format-citation-alphabetic, format-citation-numeric
#import "/src/content-to-string.typ": content-to-string

#let bib = ```
@manual{cms,
  title = {The Chicago Manual of Style},
  date = {2003},
  label = {CMS},
  shorttitle = {Chicago Manual of Style}
}

@online{ctan,
  title = {CTAN},
  url = {http://www.ctan.org},
  label = {CTAN}
}

@periodical{jcg,
  title = {Computers and Graphics},
  year = {2011}
}

@book{kant-kpv,
  author = {Kant, Immanuel},
  title = {Kritik der praktischen Vernunft},
  date = {1788},
  shorthand = {KpV}
}

@misc{named-label,
  author = {Doe, Jane},
  title = {Named Explicit Label},
  date = {2024},
  label = {DX}
}

@misc{same-title-a,
  title = {Same Title},
  date = {2020},
  label = {STA}
}

@misc{same-title-b,
  title = {Same Title},
  date = {2020},
  label = {STB}
}

@misc{same-title-title-a,
  title = {Same Title Only},
  date = {2020}
}

@misc{same-title-title-b,
  title = {Same Title Only},
  date = {2020}
}

@misc{numeric-extra,
  title = {Numeric Extra},
  date = {2021}
}

@book{maintitle-only,
  maintitle = {Collected Works}
}

@misc{source-override,
  author = {Author, Alice},
  editor = {Editor, Eve},
  title = {Main Title},
  titleaddon = {Addon Title},
  labelnamefield = {editor},
  labeltitlefield = {titleaddon}
}
```.text

#add-bib-resource(bib)

#context {
  let refs = bibliography.get()
  let ref = key => preprocess-reference(
    refs.at(key),
    ("author", "editor", "shortauthor", "shorteditor", "translator"),
    ("shortauthor", "author", "shorteditor", "editor", "translator"),
  )

  let cms = ref("cms")
  assert(not ("labelname" in cms.fields))
  assert.eq("Chicago Manual of Style", cms.fields.labeltitle)
  assert.eq("shorttitle", cms.fields.labeltitlesource)
  assert.eq("Chicago Manual of Style", cms.fields.sortstr)

  let jcg = ref("jcg")
  assert(not ("labelname" in jcg.fields))
  assert.eq("Computers and Graphics", jcg.fields.labeltitle)
  assert.eq("title", jcg.fields.labeltitlesource)

  let maintitle-default = ref("maintitle-only")
  assert.eq("Collected Works", maintitle-default.fields.labeltitle)
  assert.eq("maintitle", maintitle-default.fields.labeltitlesource)

  let source-override = ref("source-override")
  assert.eq("editor", source-override.fields.labelnamesource)
  assert.eq("Addon Title", source-override.fields.labeltitle)
  assert.eq("titleaddon", source-override.fields.labeltitlesource)

  let ay = format-citation-authoryear()
  let ay-label = key => (ay.label-generator)(0, ref(key)).first()

  assert.eq(("CMS", "2003", none), ay-label("cms"))
  assert.eq(("CTAN", "n.d.", none), ay-label("ctan"))
  assert.eq(("Computers and Graphics", "2011", none), ay-label("jcg"))
  assert.eq(("KpV", "1788", none), ay-label("kant-kpv"))
  assert.eq(("Doe", "2024", none), ay-label("named-label"))

  let by-key(entries, key) = entries.find(entry => entry.entry_key == key)
  let deduped = label-sort-deduplicate(
    ("same-title-a", "same-title-b").map(ref),
    ay.label-generator,
    entry => entry.entry_key,
    0,
  )

  assert.eq(("STA", "2020", none), by-key(deduped, "same-title-a").label)
  assert.eq(("STB", "2020", none), by-key(deduped, "same-title-b").label)

  let title-deduped = label-sort-deduplicate(
    ("same-title-title-a", "same-title-title-b").map(ref),
    ay.label-generator,
    entry => entry.entry_key,
    0,
  )

  assert.eq(("Same Title Only", "2020", "a"), by-key(title-deduped, "same-title-title-a").label)
  assert.eq(("Same Title Only", "2020", "b"), by-key(title-deduped, "same-title-title-b").label)

  let alpha = format-citation-alphabetic()
  let alpha-label = key => (alpha.label-generator)(0, ref(key)).first()

  assert.eq(("CMS03", "CMS03"), (alpha.label-generator)(0, ref("cms")))
  assert.eq(("CTAN", "CTAN"), (alpha.label-generator)(0, ref("ctan")))
  assert.eq(("Com11", "Com11"), (alpha.label-generator)(0, ref("jcg")))
  assert.eq(("KpV", "KpV"), (alpha.label-generator)(0, ref("kant-kpv")))
  assert.eq(("DX24", "DX24"), (alpha.label-generator)(0, ref("named-label")))

  let numeric = format-citation-numeric()
  assert.eq((kind: "shorthand", value: "KpV"), (numeric.label-generator)(0, ref("kant-kpv")).first())
  assert.eq((kind: "number", index: 1, format-string: "{}"), (numeric.label-generator)(0, ref("cms")).first())

  let numeric-order = ("cms": 0, "kant-kpv": 1, "ctan": 2, "jcg": 3, "numeric-extra": 4)
  let numeric-deduped = label-sort-deduplicate(
    ("cms", "kant-kpv", "ctan", "jcg", "numeric-extra").map(ref),
    numeric.label-generator,
    entry => numeric-order.at(entry.entry_key),
    0,
  )
  assert.eq((kind: "number", index: 1, format-string: "{}"), by-key(numeric-deduped, "cms").label)
  assert.eq((kind: "shorthand", value: "KpV"), by-key(numeric-deduped, "kant-kpv").label)
  assert.eq((kind: "number", index: 2, format-string: "{}"), by-key(numeric-deduped, "ctan").label)
  assert.eq((kind: "number", index: 3, format-string: "{}"), by-key(numeric-deduped, "jcg").label)
  assert.eq((kind: "number", index: 4, format-string: "{}"), by-key(numeric-deduped, "numeric-extra").label)

  let numeric-compact = format-citation-numeric(compact: true, compact-separator: "-")
  let numeric-compact-deduped = label-sort-deduplicate(
    ("cms", "kant-kpv", "ctan", "jcg", "numeric-extra").map(ref),
    numeric-compact.label-generator,
    entry => numeric-order.at(entry.entry_key),
    0,
  )
  let compact-entry = reference => (
    "ref-" + reference.entry_key,
    (kind: "reference-data", key: reference.entry_key, index: numeric-order.at(reference.entry_key), reference: reference),
  )
  assert.eq(
    "1, KpV, 2-4",
    content-to-string((numeric-compact.format-citation)(numeric-compact-deduped.map(compact-entry), "n", (:))),
  )

  let with-label(style, key, reference) = {
    let (label, label-repr) = (style.label-generator)(0, reference)
    reference.insert("label", label)
    reference.insert("label-repr", label-repr)
    ("ref-" + key, (kind: "reference-data", key: key, index: 0, reference: reference))
  }

  assert.eq("KpV", content-to-string((ay.format-citation)((with-label(ay, "kant-kpv", ref("kant-kpv")),), "n", (:))))
  assert.eq("KpV", content-to-string((numeric.format-citation)((with-label(numeric, "kant-kpv", ref("kant-kpv")),), "n", (:))))
}
