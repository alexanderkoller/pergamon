
#let join-list(list, options) = {
  if list == none or list.len() == 0 {
    none
  } else if list.len() == 1 {
    list.at(0)
  } else {
    let ret = list.at(0)
    for i in range(1, list.len()) {
        if i == list.len() - 1 {
          ret += (options.final-list-delim)(list)
        }
        ret += list.at(i)
    }
    return ret
  }
}


// concatenate an array of authors into "A, B, and C"
// TODO - unify with join-list
#let concatenate-authors(authors) = {
  let ret = authors.at(0)

  for i in range(1, authors.len()) {
    if type(authors.at(i)) != dictionary { // no idea how it would be a dictionary
      if authors.len() == 2 {
        ret = ret + " and " + authors.at(i)
      } else if i == authors.len()-1 {
        ret = ret + ", and " + authors.at(i)
      } else {
        ret = ret + ", " + authors.at(i)
      }
    }
  }

  ret
}



// Map "modern" Biblatex field names to legacy field names as they
// might appear in the bib file. Should be complete, as per biblatex.def
#let field-aliases = (
  "journaltitle": "journal",
  "langid": "hyphenation",
  "location": "address",
  "institution": "school",
  "annotation": "annote",
  "eprinttype": "archiveprefix",
  "eprintclass": "primaryclass",
  "sortkey": "key",
  "file": "pdf"
)


// Map legacy Bibtex entry types to their "modern" Biblatex names.
#let type-aliases = (
  "conference": reference => { reference.insert("entry_type", "inproceedings"); return reference },
  "electronic": reference => { reference.insert("entry_type", "online"); return reference },
  "www": reference => { reference.insert("entry_type", "online"); return reference },
  "mastersthesis": reference => { 
    reference.insert("entry_type", "thesis")
    if not "type" in reference.fields {
      reference.fields.insert("type", "mathesis")
    }
    return reference
  },
  "phdthesis": reference => { 
    reference.insert("entry_type", "thesis")
    if not "type" in reference.fields {
      reference.fields.insert("type", "phdthesis")
    }
    return reference
  },
  "techreport": reference => { 
    reference.insert("entry_type", "report")
    reference.fields.insert("type", "techreport")
    return reference
  },
)



#let fd(reference, field, options, format: x => x) = {
  let legacy-field = field-aliases.at(field, default: "dummy-field-name")
  
  if field in options.at("suppressed-fields", default: ()) {
    return none
  } else if field in reference.fields {
    return format(reference.fields.at(field))
  } else if legacy-field in reference.fields {
    return format(reference.fields.at(legacy-field))
  } else {
    return none
  }
}


#let ifdef(reference, field, options, fn) = {
  let value = fd(reference, field, options)

  if value == none { none } else { fn(value) }
}

// Convert an array of (key, value) pairs into a "multimap":
// a dictionary in which each key is assigned to an array of all
// the values with which it appeared.
// 
// Example: (("a", 1), ("a", 2), ("b", 3)) -> (a: (1, 2), b: (3,))
#let collect-deduplicate(pairs) = {
  let ret = (:)

  for (key, value) in pairs {
    if key in ret {
      ret.at(key).push(value)
    } else {
      ret.insert(key, (value,))
    }
  }

  return ret
}


// Wraps a function in `none`-handling code. `nn(func)`
// behaves like `func` on arguments that are not `none`,
// and it returns `none` if the argument is `none`.
// Only works for functions `func` that have a single argument.
// -> function
#let nn(func) = {
  it => if it == none { none } else { func(it) }
}

