


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

#let name-part-placeholder = regex("\\{(given|prefix|family|suffix|given-initials|prefix-initials|g|p|f|s)\\}")

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
  let format-str = if type(format) == dictionary {
    format.at(name-type, default: "{given} {prefix} {family} {suffix}")
  } else {
    format
  }

  let replacements = (
    "given": name-part(name-parts-dict, "given"),
    "prefix": name-part(name-parts-dict, "prefix"),
    "family": name-part(name-parts-dict, "family"),
    "suffix": name-part(name-parts-dict, "suffix"),
    "given-initials": name-part(name-parts-dict, "given-initials"),
    "prefix-initials": name-part(name-parts-dict, "prefix-initials"),
    "g": name-initial(name-parts-dict, "given", initials-key: "given-initials"),
    "p": name-initial(name-parts-dict, "prefix", initials-key: "prefix-initials"),
    "f": name-initial(name-parts-dict, "family"),
    "s": name-initial(name-parts-dict, "suffix"),
  )

  format-str
    .replace(name-part-placeholder, m => replacements.at(m.captures.at(0)))
    .replace(regex("\s+"), " ")
    .trim()
}
