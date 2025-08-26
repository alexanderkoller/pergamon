


// Parses the specified author list in the reference and returns a list of parsed authors.
// A parsed author is a dictionary of name parts: (family: ..., given: ...).
#let parse-names(reference, author-field) = {
  let ret = ()

  for raw_author in reference.fields.at(author-field).split(regex("\s+and\s+")) {
    let match = raw_author.match(regex("(.*)\s*,\s*(.*)"))
    let given = ""
    let family = ""

    if match != none {
      (given, family) = (match.captures.at(1), match.captures.at(0))
    } else {
      match = raw_author.match(regex("(.+)\s+(\S+)"))
      (given, family) = (match.captures.at(0), match.captures.at(1))
    }

    ret.push( ("given": given, "family": family) )
  }

  return ret
}

// Parses the name lists for the given name-fields. Returns a reference dictionary
// that has been enriched with "parsed-X" fields, for all X in name-fields.
#let parse-reference-names(reference, name-fields) = {
  for field in name-fields {
    if field in reference.fields {
      let parsed-names = parse-names(reference, field)
      let lastname-first = parsed-names.map(it => it.family + "," + it.given).join(" ")

      reference.fields.insert("parsed-" + field, parsed-names)
      reference.fields.insert("sortstr-" + field, lastname-first)
      // sortstr fields are needed to perform efficient sorting on the "n" key
    } else {
      reference.fields.insert("parsed-" + field, none)
    }
  }

  return reference
}

// Extracts the list of family names from the list of name-part dictionaries.
#let family-names(parsed-names) = {
  if parsed-names == none {
    none
  } else {
    parsed-names.map( it => it.at("family", default: none) )
  }
}
