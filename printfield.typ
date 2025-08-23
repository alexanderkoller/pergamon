

#let format-for-printfield(value, reference, field, options, style: none) = {
  if value == none {
    none
  } else {
    field = lower(field)

    if field == "issn" {
      [ISSN #value]
    } else if field == "pages" {
      if value.contains("-") or value.contains("–") { // the second one is an emdash
        [pp. #value]
      } else {
        [p. #value]
      }
    } else if field == "volume" {
      if reference.entry_type in ("article", "periodical") {
        value
      } else {
        [#options.bibstring.volume #value]
      }
    } else {
      value
    }
  }
}
