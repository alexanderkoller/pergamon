
#import "@preview/layout-ltd:0.1.0": layout-limiter
#show: layout-limiter.with(max-iterations: 3)

#let reference-collection = state("reference-collection", ())
#let REFSECTION-END-MARKER = "refsection-end"

#let refsection(doc) = {
  reference-collection.update(rc => {
    rc.push((:))
    rc
  })

  doc

  metadata((kind: REFSECTION-END-MARKER))
}

#let current-refsection() = {
  let refsection-count = reference-collection.get().len()
  "ref" + str(refsection-count)
}

#let refsectionize(x) = current-refsection() + "-" + x

#let find-refsection-end() = {
  let upcoming = query(selector(metadata).after(here()))
  let matching = upcoming.filter(m => {
    let v = m.value
    type(v) == dictionary and v.at("kind", default: none) == REFSECTION-END-MARKER
  })
  
  if matching.len() > 0 {
    matching.first()
  } else {
    none
  }
}

#let references-at-refsection-end() = {
  let loc = find-refsection-end().location()
  reference-collection.at(loc).last().keys()
}

#let cite(x) = {
  reference-collection.update(rc => {
    rc.last().insert(x, 1)
    rc
  })

  context {
    link(label(refsectionize(x)))[(cite: #x)]
  }
}

#let print-bibliography() = context {
  [
    Bibliography for refsection #current-refsection():
    
    #box(stroke: 1pt, inset: 6pt)[
      #{ 
        for ref in references-at-refsection-end() [
          (reference: #ref)
          #label(refsectionize(ref))

        ]
      }
    ]
  ]
}


= First

#refsection[
  #cite("a")

  #pagebreak()
  #print-bibliography()

  #cite("c")
]


#pagebreak()
= Second 

#refsection[
  #cite("b")

  #pagebreak()
  #print-bibliography()
]