// Test for Arxiv references that are @articles.
// These used to not compile correctly (tracl #17).

#import "/lib.typ": *

#let darkblue = blue.darken(20%)

#show link: set text(fill: darkblue)

#let bib = ```
@article{abid2019gradio,
  title={Gradio: Hassle-free sharing and testing of ML models in the wild},
  author={Abid, Abubakar and Abdalla, Ali and Abid, Ali and Khan, Dawood},
  journal={arXiv preprint arXiv:1906.02569},
  year={2019},
  url={https://arxiv.org/abs/1906.02569},
}
```.text

#let fcite = format-citation-numeric()
#let fref = format-reference(reference-label: fcite.reference-label)

#add-bib-resource(bib)

#refsection(format-citation: fcite.format-citation)[
  Article with URL: #cite("abid2019gradio")

  #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
]
