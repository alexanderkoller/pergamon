#import "citation-styles.typ": format-citation-alphabetic, format-citation-authoryear, format-citation-numeric
#import "reference-styles.typ": format-reference

// Style bundles for the builtin styles.


/// #unfinished[TODO]
#let build-style(
  citation-factory, 
  reference-factory,
  citation-parameters: (:),
  reference-parameters: (:)
) = {
  let fcite = citation-factory(..citation-parameters)

  let fref = reference-factory(
    reference-label: fcite.reference-label,
    ..reference-parameters
  )

  (
    citation-style: fcite.format-citation,
    reference-style: fref,
    label-generator: fcite.label-generator
  )
}

/// #unfinished[TODO]
#let numeric-style(
  citation: (:),
  reference: (:)
) = {
  build-style(
    format-citation-numeric,
    format-reference,
    citation-parameters: citation,
    reference-parameters: reference
  )
}

/// #unfinished[TODO]
#let alphabetic-style(
  citation: (:),
  reference: (:)
) = {
  build-style(
    format-citation-alphabetic,
    format-reference,
    citation-parameters: citation,
    reference-parameters: reference
  )
}

/// #unfinished[TODO]
#let authoryear-style(
  citation: (:),
  reference: (:)
) = {
  build-style(
    format-citation-authoryear,
    format-reference,
    citation-parameters: citation,
    reference-parameters: reference
  )
}




