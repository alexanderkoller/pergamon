
#import "/lib.typ": *


#let bib = ```
@article{abid2019gradio,
  title={Gradio: Hassle-free sharing and testing of ML models in the wild},
  author={Abid, Abubakar and Abdalla, Ali and Abid, Ali and Khan, Dawood},
  journal={arXiv preprint arXiv:1906.02569},
  year={2019},
  url={https://arxiv.org/abs/1906.02569},
}
```.text

#add-bib-resource(bib)


#let test-alphabetic(minalphanames, maxalphanames) = {
  let fcite = format-citation-alphabetic(minalphanames: minalphanames, maxalphanames: maxalphanames)
  let fref = format-reference(reference-label: fcite.reference-label)


  refsection(format-citation: fcite.format-citation)[
    = Minalphanames: #minalphanames, maxalphanames: #maxalphanames
    Article with URL: #cite("abid2019gradio")

    #print-bibliography(format-reference: fref, label-generator: fcite.label-generator)
  ]
}


#test-alphabetic(none, 3)   // minalphanames implicitly 3 => [AAA+]
#test-alphabetic(2, 3)      // abbreviate to 2 => [AA+]
#test-alphabetic(4, 3)      // minalphanames truncated to 3
#test-alphabetic(5, 3)      // minalphanames truncated to 3
#test-alphabetic(1, 2)
#test-alphabetic(1, 4)