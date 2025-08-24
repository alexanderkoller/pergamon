
#let join-list(list, options) = {
  if list == none or list.len() == 0 {
    none
  } else if list.len() == 1 {
    list.at(0)
  } else {
    let ret = list.at(0)
    for i in range(1, list.len()) {
        if i == list.len() - 1 {
          ret += options.final-list-delim(list)
        }
        ret += list.at(i)
    }
    return ret
  }
}


// Map "modern" Biblatex field names to legacy field names as they
// might appear in the bib file. Should be complete, as per biblatex.def
#let field-aliases = (
  "journaltitle": ("journal",),
  "langid": ("hyphenation",),
  "location": ("address",),
  "institution": ("school",),
  "annotation": ("annote",),
  "eprinttype": ("archiveprefix",),
  "eprintclass": ("primaryclass",),
  "sortkey": ("key",),
  "file": ("pdf",)
)

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
  if field in options.at("suppressed-fields", default: ()) {
    return none
  } else if field in reference.fields {
    return format(reference.fields.at(field).trim())
  } else if field in field-aliases {
    for alias in field-aliases.at(field) {
      if alias in reference.fields {
        return format(reference.fields.at(alias).trim())
      }
    }
  } else {
    return none
  }
}


#let ifdef(reference, field, options, fn) = {
  let value = fd(reference, field, options)

  if value == none { none } else { fn(value) }
}
