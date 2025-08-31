#import "bib-util.typ": fd, is-integer

#let parse-date(reference, date-field, fallback-year-field: none) = {
  let options = (:) // these are print-reference options, and we are outside of print-reference
  let date-str = fd(reference, date-field, options)
  
  // I would like to return dates as Typst datetime objects, but they require
  // valid dates in which year, month, day are all specified; and Biblatex doesn't require this.

  // TODO: permit date ranges
  // TODO: permit approximate dates
  // TODO: permit negative years

  if date-str != none {
    date-str = date-str.trim()

    if date-str.contains("-") {
      // parse as ISO8601-2 Extended Format, see Biblatex manual, §2.3.8
      let parts = date-str.split("-")

      if parts.len() >= 3 {
        // Format: year-month-date
        if is-integer(parts.at(0)) and is-integer(parts.at(1)) and is-integer(parts.at(2)) {
          ("year": int(parts.at(0)), "month": int(parts.at(1)), "day": int(parts.at(2)))
        } else {
          // unparseable date
          none
        }
      } else if parts.len() == 2 {
        // Format: year-month
         if is-integer(parts.at(0)) and is-integer(parts.at(1)) {          
          ("year": int(parts.at(0)), "month": int(parts.at(1)))
         } else {
          none
         }
      } else if is-integer(parts.at(0)) {
        // Format: year
        ("year": int(parts.at(0)))
      }
    } else {
      // unparsable date -> print as "n.d."
      none
    }
  } else if fallback-year-field != none {
    // no date field, fall back to year field
    let year-str = fd(reference, fallback-year-field, options)
    if year-str != none and is-integer(year-str) {
      ("year": int(year-str.trim()))
    } else {
      // unparseable year -> print as "n.d."
      none
    }
  } else {
    // no date or year field specified -> print as "n.d."
    none
  }
}
