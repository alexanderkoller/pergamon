#import "/src/bibtypst.typ": add-bib-resource, bibliography, preprocess-reference, label-sort-deduplicate
#import "/src/citation-styles.typ": format-citation-authoryear
#import "/src/dates.typ": get-date, date-year

#let bib = ```
@misc{year-only,
  author = {Doe, Jane},
  title = {Year Only},
  date = {2020},
}

@misc{year-month,
  author = {Month, Mary},
  title = {Year Month},
  date = {2020-03},
}

@misc{no-date,
  author = {Nodate, Nora},
  title = {No Date},
}

@misc{approx-date,
  author = {Approx, Annie},
  title = {Approx Date},
  date = {2024~},
}

@misc{bce-date,
  author = {Before, Bea},
  title = {BCE Date},
  date = {-0031-07%},
}

@misc{smith-pub,
  author = {Smith, Sam},
  title = {Publication Date Only},
  date = {2020},
}

@misc{smith-orig,
  author = {Smith, Sam},
  title = {Original Date},
  date = {2020},
  origdate = {1920},
}

@misc{smith-orig-copy,
  author = {Smith, Sam},
  title = {Original Date Copy},
  date = {2020},
  origdate = {1920},
}
```.text

#add-bib-resource(bib)

#let pad2(value) = {
  if value < 10 {
    "0" + str(value)
  } else {
    str(value)
  }
}

#let year-month-label-date(date, reference, field-name, options) = {
  if date == none or date.start == none {
    none
  } else {
    let start = date.start
    if start.at("month", default: none) != none {
      str(start.year) + "-" + pad2(start.month)
    } else {
      str(start.year)
    }
  }
}

#let origdate-label-date(date, reference, field-name, options) = {
  let origdate = get-date(reference, "origdate")
  let year(date) = {
    if date != none and date-year(date) != none {
      str(date-year(date))
    } else {
      none
    }
  }

  let publication-year = year(date)
  let original-year = year(origdate)

  if original-year != none and publication-year != none {
    original-year + "/" + publication-year
  } else if publication-year != none {
    publication-year
  } else {
    original-year
  }
}

#context {
  let refs = bibliography.get()
  let ref = key => preprocess-reference(refs.at(key), ("author",), ("author",))

  let default-style = format-citation-authoryear()
  let default-label = key => (default-style.label-generator)(0, ref(key)).first()

  assert.eq(("Doe", "2020", none), default-label("year-only"))
  assert.eq(("Month", "Mar. 2020", none), default-label("year-month"))
  assert.eq(("Nodate", "n.d.", none), default-label("no-date"))
  assert.eq(("Approx", "ca. 2024", none), default-label("approx-date"))
  assert.eq(("Before", "ca. July 32 BCE?", none), default-label("bce-date"))

  let year-month-style = format-citation-authoryear(format-date: year-month-label-date)
  let year-month-label = key => (year-month-style.label-generator)(0, ref(key)).first()

  assert.eq(("Doe", "2020", none), year-month-label("year-only"))
  assert.eq(("Month", "2020-03", none), year-month-label("year-month"))
  assert.eq(("Nodate", "n.d.", none), year-month-label("no-date"))

  let origdate-style = format-citation-authoryear(format-date: origdate-label-date)
  let origdate-label = key => (origdate-style.label-generator)(0, ref(key)).first()

  assert.eq(("Smith", "2020", none), origdate-label("smith-pub"))
  assert.eq(("Smith", "1920/2020", none), origdate-label("smith-orig"))

  let by-key(entries, key) = entries.find(entry => entry.entry_key == key)
  let sort-by-key = entry => entry.entry_key

  let default-deduped = label-sort-deduplicate(
    ("smith-orig", "smith-pub").map(ref),
    default-style.label-generator,
    sort-by-key,
    0,
  )

  assert.eq(("Smith", "2020", "a"), by-key(default-deduped, "smith-orig").label)
  assert.eq(("Smith", "2020", "b"), by-key(default-deduped, "smith-pub").label)

  let origdate-deduped = label-sort-deduplicate(
    ("smith-orig", "smith-orig-copy", "smith-pub").map(ref),
    origdate-style.label-generator,
    sort-by-key,
    0,
  )

  assert.eq(("Smith", "1920/2020", "a"), by-key(origdate-deduped, "smith-orig").label)
  assert.eq(("Smith", "1920/2020", "b"), by-key(origdate-deduped, "smith-orig-copy").label)
  assert.eq(("Smith", "2020", none), by-key(origdate-deduped, "smith-pub").label)
}
