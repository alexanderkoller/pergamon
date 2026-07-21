#let month-bibstring-keys = (
  "january", "february", "march", "april", "may", "june",
  "july", "august", "september", "october", "november", "december"
)

// Returns the canonical parsed-date field name for date-like bibliography fields.
#let date-field-name(field) = {
  let field = lower(field)
  if field in ("date", "eventdate", "origdate", "urldate") {
    field
  } else {
    none
  }
}

// Looks up a parsed date on a reference, respecting field suppression.
#let get-date(reference, field, options: (:)) = {
  if field in options.at("suppressed-fields", default: ()) {
    none
  } else {
    reference.at("parsed_dates", default: (:)).at(field, default: none)
  }
}

// Returns the start date-time dictionary of a parsed date, if it has one.
#let date-start(date) = {
  date.at("start", default: none)
}

// Returns the end date-time dictionary of a parsed date, if it has one.
#let date-end(date) = {
  date.at("end", default: none)
}

// Returns the first available year from a parsed date's start or end date-time.
#let date-year(date) = {
  let start = date-start(date)
  if start != none {
    start.year
  } else {
    let end = date-end(date)
    if end != none {
      end.year
    } else {
      none
    }
  }
}

// Checks whether the publication date is defined in this reference dict.
#let is-year-defined(reference) = {
  let date = get-date(reference, "date")
  date != none and date-year(date) != none
}

// Builds a sortable publication-date key from year, month, and day.
#let date-sort-key(reference, reversed: false) = {
  let date = get-date(reference, "date")
  let start = if date != none { date-start(date) } else { none }

  let parts = ("year", "month", "day").map(field => {
    let value = if start != none { start.at(field, default: 0) } else { 0 }
    if value == none {
      value = 0
    }
    if reversed {
      -value
    } else {
      value
    }
  })

  parts
}

// Pads small positive integers to two digits for numeric date/time output.
#let pad2(value) = {
  if value < 10 {
    "0" + str(value)
  } else {
    str(value)
  }
}

// Formats a numeric year in signed four-digit ISO-style form.
#let format-signed-year(year) = {
  let sign = if year < 0 { "-" } else { "" }
  let abs-year = calc.abs(year)
  sign + str(abs-year).pad(4, fill: "0")
}

// Formats a year for human-readable output, converting years before 1 CE to BCE.
#let default-format-date-era(year, field-name, options) = {
  if year < 1 {
    str(1 - year) + " BCE"
  } else {
    str(year)
  }
}

// Formats a year using either ISO signed-year output or the default era formatter.
#let format-year(year, field-name, options, style) = {
  if style == "iso" {
    format-signed-year(year)
  } else {
    default-format-date-era(year, field-name, options)
  }
}

// Formats only the calendar-date part of a date-time dictionary.
#let default-format-calendar-date(datetime, field-name, options, style) = {
  let year = format-year(datetime.year, field-name, options, style)
  let month = datetime.at("month", default: none)
  let day = datetime.at("day", default: none)
  if "month" in options.suppressed-fields {
    month = none
    day = none
  } else if "day" in options.suppressed-fields {
    day = none
  }

  if style == "iso" {
    if month != none and day != none {
      format-signed-year(datetime.year) + "-" + pad2(month) + "-" + pad2(day)
    } else if month != none {
      format-signed-year(datetime.year) + "-" + pad2(month)
    } else {
      format-signed-year(datetime.year)
    }
  } else if style == "short" {
    if month != none and day != none {
      str(datetime.year) + "-" + pad2(month) + "-" + pad2(day)
    } else if month != none {
      str(datetime.year) + "-" + pad2(month)
    } else {
      year
    }
  } else {
    let month-str = if month != none {
      options.bibstring.at(month-bibstring-keys.at(month - 1))
    } else {
      none
    }

    if day != none and month-str != none {
      str(day) + " " + month-str + " " + year
    } else if month-str != none {
      month-str + " " + year
    } else {
      year
    }
  }
}

// Formats a nested time-of-day dictionary.
#let default-format-time(time, options) = {
  let ret = pad2(time.hour) + ":" + pad2(time.minute)

  if options.at("show-date-seconds", default: false) {
    ret += ":" + pad2(time.second)
  }

  if options.at("show-date-timezones", default: false) {
    let offset = time.at("offset", default: none)
    if offset != none and offset.kind == "utc" {
      ret += "Z"
    } else if offset != none and offset.kind == "offset" {
      let sign = if offset.positive { "+" } else { "-" }
      ret += sign + pad2(offset.hours) + ":" + pad2(offset.minutes)
    }
  }

  ret
}

// Formats a date-time dictionary, adding its nested time-of-day when requested.
#let default-format-datetime(datetime, field-name, options) = {
  let style = if field-name == "urldate" { "short" } else { "long" }
  let ret = default-format-calendar-date(datetime, field-name, options, style)
  let time = datetime.at("time", default: none)

  if time != none and options.at("show-date-times", default: false) {
    ret + " " + default-format-time(time, options)
  } else {
    ret
  }
}

// Formats a parsed date range, including open-ended ranges.
#let default-format-date-range(start, end, field-name, options) = {
  let sep = "–"
  let fmt = datetime => default-format-datetime(datetime, field-name, options)

  if start != none and end != none {
    fmt(start) + sep + fmt(end)
  } else if start != none {
    fmt(start) + sep
  } else if end != none {
    sep + fmt(end)
  } else {
    options.bibstring.nodate
  }
}

// Marks an already-rendered date as uncertain.
#let default-format-date-uncertain(rendered, field-name, options) = {
  rendered + "?"
}

// Marks an already-rendered date as approximate.
#let default-format-date-approximate(rendered, field-name, options) = {
  "ca. " + rendered
}

// Formats a parsed date value, including kind, range, and approximate/uncertain markers.
#let default-format-date(date, reference, field-name, options) = {
  if date == none {
    return none
  }

  let kind = date.kind
  let start = date-start(date)
  let end = date-end(date)
  let rendered = if kind == "at" {
    if start == none {
      options.bibstring.nodate
    } else {
      default-format-datetime(start, field-name, options)
    }
  } else if kind == "after" {
    if start == none {
      options.bibstring.nodate
    } else {
      "after " + default-format-datetime(start, field-name, options)
    }
  } else if kind == "before" {
    if end == none {
      options.bibstring.nodate
    } else {
      "before " + default-format-datetime(end, field-name, options)
    }
  } else if kind == "between" {
    default-format-date-range(start, end, field-name, options)
  } else {
    options.bibstring.nodate
  }

  if date.approximate {
    rendered = default-format-date-approximate(rendered, field-name, options)
  }
  if date.uncertain {
    rendered = default-format-date-uncertain(rendered, field-name, options)
  }

  rendered
}

// Dispatches a parsed date field through the active public date formatter.
#let format-date-field(date, reference, field, options) = {
  options.at("format-date")(date, reference, field, options)
}
