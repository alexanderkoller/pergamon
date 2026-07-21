#import "/src/bibtypst.typ": add-bib-resource, bibliography, preprocess-reference, construct-sorting
#import "/src/bibstrings.typ": default-long-bibstring
#import "/src/content-to-string.typ": content-to-string
#import "/src/printfield.typ": printfield, default-field-formats
#import "/lib.typ": default-format-date, default-format-datetime

#let options = (
  field-formatters: default-field-formats,
  eval-mode: none,
  bibstring: default-long-bibstring,
  suppressed-fields: (:),
  format-date: default-format-date,
  show-date-times: false,
  show-date-seconds: false,
  show-date-timezones: false,
)

#let bib = ```
@misc{year-only,
  author = {Doe, Jane},
  title = {Year Only},
  date = {2024},
}

@misc{year-month,
  author = {Doe, Jane},
  title = {Year Month},
  date = {2024-03},
}

@misc{full-date,
  author = {Doe, Jane},
  title = {Full Date},
  date = {2024-03-14},
  urldate = {2024-03-20},
}

@misc{range-date,
  author = {Doe, Jane},
  title = {Range Date},
  date = {2024-03-14/2024-03-20},
}

@misc{open-after,
  author = {Doe, Jane},
  title = {Open After},
  date = {2024/..},
}

@misc{open-before,
  author = {Doe, Jane},
  title = {Open Before},
  date = {../2024-03},
}

@misc{approx-uncertain,
  author = {Doe, Jane},
  title = {Approx Uncertain},
  date = {2024~},
  origdate = {-0031-07%},
}

@misc{with-time,
  author = {Doe, Jane},
  title = {With Time},
  date = {2024-03-14T12:30:45+02:15},
}
```.text

#add-bib-resource(bib)

#context {
  let refs = bibliography.get()
  let ref = key => preprocess-reference(refs.at(key), ("author",), ("author",))

  let year-only = ref("year-only")
  assert.eq(2024, year-only.parsed_dates.date.start.year)
  assert(not "parsed-date" in year-only.fields)
  assert.eq("2024", printfield(year-only, "date", options))

  assert.eq("March 2024", printfield(ref("year-month"), "date", options))
  assert.eq("14 March 2024", printfield(ref("full-date"), "date", options))
  assert.eq("visited on 2024-03-20", printfield(ref("full-date"), "urldate", options))
  let field-options = options + (
    format-date: (date, reference, field-name, options) => {
      if field-name == "urldate" {
        "url:" + default-format-datetime(date.start, field-name, options)
      } else {
        default-format-date(date, reference, field-name, options)
      }
    },
  )
  assert.eq("visited on url:2024-03-20", printfield(ref("full-date"), "urldate", field-options))
  assert.eq("2024", printfield(ref("full-date"), "date", options + (suppressed-fields: (month: 1, day: 1))))

  assert.eq("14 March 2024–20 March 2024", content-to-string(printfield(ref("range-date"), "date", options)))
  let slash-range-options = options + (
    format-date: (date, reference, field-name, options) => {
      if date.kind == "between" {
        let fmt = datetime => default-format-datetime(datetime, field-name, options)
        fmt(date.start) + " / " + fmt(date.end)
      } else {
        default-format-date(date, reference, field-name, options)
      }
    },
  )
  assert.eq("14 March 2024 / 20 March 2024", printfield(ref("range-date"), "date", slash-range-options))
  assert.eq("after 2024", printfield(ref("open-after"), "date", options))
  assert.eq("before March 2024", printfield(ref("open-before"), "date", options))

  assert.eq("ca. 2024", printfield(ref("approx-uncertain"), "date", options))
  assert.eq("ca. July 32 BCE?", printfield(ref("approx-uncertain"), "origdate", options))

  let time-options = options + (show-date-times: true, show-date-seconds: true, show-date-timezones: true)
  assert.eq("14 March 2024 12:30:45+02:15", printfield(ref("with-time"), "date", time-options))

  let sorted = ("full-date", "year-only", "year-month").map(key => ref(key)).sorted(key: construct-sorting("d"))
  assert.eq(("year-only", "year-month", "full-date"), sorted.map(it => it.entry_key))
}
