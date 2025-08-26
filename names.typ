


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
      reference.fields.insert("parsed-" + field, parsed-names)
    } else {
      reference.fields.insert("parsed-" + field, none)
    }
  }

  return reference
}

#let family-names(parsed-names) = {
  if parsed-names == none {
    none
  } else {
    parsed-names.map( it => it.at("family", default: none) )
  }
}

// Concatenate an array of names ("A", "B", "C") into "A, B, and C".
// TODO - make configurable with final-list-delim
// TODO - this is the same as join-list in bib-util, skipping it
// #let concatenate-namelist(authors) = {
//   let ret = authors.at(0)

//   for i in range(1, authors.len()) {
//     if type(authors.at(i)) != dictionary { // no idea how it would be a dictionary
//       if authors.len() == 2 {
//         ret = ret + " and " + authors.at(i)
//       } else if i == authors.len()-1 {
//         ret = ret + ", and " + authors.at(i)
//       } else {
//         ret = ret + ", " + authors.at(i)
//       }
//     }
//   }

//   ret
// }


// // parse author names and add fields with first-last and last-first author names to the reference
// #let fix-authors(reference) = {
//   let parsed-names = parse-author-names(reference)
//   let lastname-first-authors = ()
//   let firstname-first-authors = ()
//   let lastnames = ()

//   for (first, last) in parsed-names {
//     lastname-first-authors.push(strfmt("{}, {}", last, first))
//     firstname-first-authors.push(strfmt("{} {}", first, last))
//     lastnames.push(last)
//   }

//   // unused
//   reference.insert("parsed-author-names", parsed-names) // ((first, last), (first, last), ...)

//   // used in "n" sorting
//   reference.insert("lastname-first-authors", lastname-first-authors.join(" ")) // for sorting

//   // used in authors-with-year
//   reference.insert("authors", concatenate-authors(firstname-first-authors))

//   // used quite broadly, but could probably replace uses with parsed-author-names + utility function
//   // - should this be an array of dictionaries of name parts?
//   reference.insert("lastnames", lastnames) // (last, last, last, ...) - to construct citations

//   reference
// }
