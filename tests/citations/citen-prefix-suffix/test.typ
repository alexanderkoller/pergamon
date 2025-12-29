// Test for citen with prefix and suffix (#131)
#import "/lib.typ": *

#let bib = ```
@article{abid2019gradio,
  title={Gradio: Hassle-free sharing and testing of ML models in the wild},
  author={Abid, Abubakar and Abdalla, Ali and Abid, Ali and Khan, Dawood},
  journal={arXiv preprint arXiv:1906.02569},
  year={2019},
}
```.text

#let fcite = format-citation-authoryear()
#let fref = format-reference(reference-label: fcite.reference-label)

#add-bib-resource(bib)

#refsection(format-citation: fcite.format-citation)[
  citen with prefix and suffix: #citen("abid2019gradio", prefix: "see", suffix: "page 17")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]
