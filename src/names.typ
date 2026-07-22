


// Functions for parsing and formatting names.
// The central data structure of this file is a "name-parts dictionary",
// whose keys are the parts of a name (family, given, ...).

#let name-part(name-parts-dict, key) = {
  name-parts-dict.at(key, default: "")
}

#let name-initial(name-parts-dict, key, initials-key: none) = {
  let initials = if initials-key == none { "" } else { name-part(name-parts-dict, initials-key) }
  let value = name-part(name-parts-dict, key)

  if initials != "" {
    initials
  } else if value != "" {
    value.at(0)
  } else {
    ""
  }
}

#let family-name(name-parts-dict) = {
  let prefix = name-part(name-parts-dict, "prefix")
  let family = name-part(name-parts-dict, "family")

  if name-parts-dict.at("use-prefix", default: false) and prefix != "" {
    prefix + " " + family
  } else {
    family
  }
}

#let prefix-labelalpha(name-parts-dict) = {
  let prefix = name-part(name-parts-dict, "prefix")
  let initials = name-part(name-parts-dict, "prefix-initials")

  if not name-parts-dict.at("use-prefix", default: false) or prefix == "" {
    ""
  } else if initials != "" {
    initials
  } else {
    prefix.split(regex("\s+")).map(part => part.at(0)).join("")
  }
}

#let labelalpha-name(name-parts-dict, family-width: none) = {
  let family = name-part(name-parts-dict, "family")
  let family-part = if family-width == none {
    family
  } else {
    family.codepoints().slice(0, family-width).join()
  }

  prefix-labelalpha(name-parts-dict) + family-part
}

#let sort-name(name-parts-dict, use-prefix-in-sorting: false) = {
  let prefix = name-part(name-parts-dict, "prefix")
  let family = name-part(name-parts-dict, "family")
  let given = name-part(name-parts-dict, "given")
  let sort-family = if use-prefix-in-sorting and prefix != "" { prefix + " " + family } else { family }

  (sort-family, given).filter(x => x != "").join(",")
}

#let is-andothers-name(name-parts-dict) = {
  name-part(name-parts-dict, "family") == "others" and name-part(name-parts-dict, "given") == "" and name-part(name-parts-dict, "prefix") == "" and name-part(name-parts-dict, "suffix") == ""
}

#let name-format-default = "{given} {prefix} {family} {suffix}"
#let name-format-fields = (
  "given": 1,
  "prefix": 1,
  "family": 1,
  "suffix": 1,
  "given-initials": 1,
  "prefix-initials": 1,
  "g": 1,
  "p": 1,
  "f": 1,
  "s": 1,
)

#let parse-name-format(format-str) = {
  let tokens = ()
  let chars = format-str.codepoints()
  let literal = ()
  let i = 0

  while i < chars.len() {
    if chars.at(i) == "{" {
      let j = i + 1
      while j < chars.len() and chars.at(j) != "}" {
        j += 1
      }

      if j < chars.len() {
        let field = chars.slice(i + 1, j).join("")
        if field in name-format-fields {
          tokens.push((field: field, prefix: literal.join("")))
          literal = ()
          i = j + 1
          continue
        }
      }
    }

    literal.push(chars.at(i))
    i += 1
  }

  if literal.len() > 0 {
    tokens.push(literal.join(""))
  }

  tokens
}

#let parse-name-format-option(format) = {
  let parsed = ("*": parse-name-format(name-format-default))
  if type(format) == dictionary {
    for (name-type, format-str) in format {
      parsed.insert(name-type, parse-name-format(format-str))
    }
  } else {
    parsed.insert("*", parse-name-format(format))
  }
  parsed
}

#let parsed-name-format-for(format, name-type) = {
  format.at(name-type, default: format.at("*"))
}

#let render-name-format(format, name-parts-dict) = {
  let buffer = ()
  let emitted = false
  for token in format {
    if type(token) == str {
      if token != "" {
        buffer.push(token)
        emitted = true
      }
    } else {
      let value = if token.field == "g" {
        name-initial(name-parts-dict, "given", initials-key: "given-initials")
      } else if token.field == "p" {
        name-initial(name-parts-dict, "prefix", initials-key: "prefix-initials")
      } else if token.field == "f" {
        name-initial(name-parts-dict, "family")
      } else if token.field == "s" {
        name-initial(name-parts-dict, "suffix")
      } else {
        name-parts-dict.at(token.field, default: "")
      }

      if value != "" {
        if emitted {
          buffer.push(token.prefix)
        } else {
          emitted = true
        }
        buffer.push(value)
      }
    }
  }

  buffer.join("")
}

// Parses the name lists for the given name-fields. Returns a reference dictionary
// that has been enriched with "parsed-X" fields, for all X in name-fields.
#let parse-reference-names(reference, name-fields, use-prefix-in-sorting: false) = {
  for field in name-fields {
    if field in reference.parsed_names {
      let parsed-names = reference.parsed_names.at(field)
      let lastname-first = parsed-names.map(it => sort-name(it, use-prefix-in-sorting: use-prefix-in-sorting)).join(" ")
      reference.fields.insert("parsed-" + field, parsed-names)
      reference.fields.insert("sortstr-" + field, lastname-first)
      // sortstr fields are needed to perform efficient sorting on the "n" key
    } else {
      reference.fields.insert("parsed-" + field, none)
    }
  }

  return reference
}

/// Extracts the list of family names from the list of name-part dictionaries.
/// For instance, the `parsed-author` entry of the example in @fig:reference-dict
/// will be mapped to the array `("Bender", "Koller")`.
///
/// Warning: this is a convenience helper for simple family-name extraction and
/// custom show rules. It flattens parsed name dictionaries, so it is not suitable
/// for BibLaTeX-style label construction such as alphabetic citation labels.
/// 
/// If `parsed-names` is `none`, the function returns `none`.
/// 
/// -> array | none
#let family-names(parsed-names) = {
  if parsed-names == none {
    none
  } else {
    parsed-names.map(family-name)
  }
}

/// Spells out a name-part dictionary into a string.
/// See the documentation of the `name-format` argument of
/// @format-reference for details on the format string.
/// 
/// -> str
#let format-name(
  /// A name-part dictionary
  /// -> dictionary
  name-parts-dict, 
  
  /// The type of name as which the name-part dictionary
  /// should be formatted. If `format` is a dictionary,
  /// `format-name` will look up the format string under this
  /// key in `format`.
  /// -> str
  name-type: "author", 
  
  /// A format string or dictionary which specifies how the
  /// name should be formatted. You can either pass a string,
  /// or you can pass a dictionary that maps name types to
  /// strings.
  /// -> str | dictionary
  format: "{given} {prefix} {family} {suffix}"
  ) = {
  let parsed-format = parse-name-format-option(format)
  render-name-format(parsed-name-format-for(parsed-format, name-type), name-parts-dict)
}

#let format-name-parsed(name-parts-dict, name-type, format) = {
  render-name-format(parsed-name-format-for(format, name-type), name-parts-dict)
}
