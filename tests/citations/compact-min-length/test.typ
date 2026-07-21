// Test numeric compact citations only collapse runs of at least three.

#import "/lib.typ": *

#let fcite = format-citation-numeric(
  compact: true,
  compact-separator: "--",
  format-brackets: it => it,
)

#let refs(..indices) = {
  indices.pos().map(ix => (
    "ref-" + str(ix),
    (reference: (label: (ix, "{}"))),
  ))
}

#let render(..indices) = {
  content-to-string((fcite.format-citation)(refs(..indices), "n", (:)))
}

#assert.eq("3, 4, 6", render(3, 4, 6))
#assert.eq("1--3", render(1, 2, 3))
#assert.eq("1--3, 5, 6", render(1, 2, 3, 5, 6))
#assert.eq("1, 3, 4", render(1, 3, 4))
#assert.eq("1--4, 6", render(1, 2, 3, 4, 6))
