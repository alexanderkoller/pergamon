
// tests the add-category and has-category functions, cf. #143

#import "/lib.typ": *

#let bib = ```
@misc{test_entry2,
      title={Doesnt matter 2.},
      author={Santa Claus},
      year={2025}
}

@InProceedings{rtg-discourse,
  author = 	 {Michaela Regneri and Markus Egg and Alexander Koller},
  title = 	 {Efficient Processing of Underspecified Discourse Representations},
  booktitle = {Proceedings of the 46th Annual Meeting of the Association for Computational Linguistics: Human Language Technologies (ACL-08: HLT), Short Papers},
  year = 	 2008,
  address = 	 {Columbus, Ohio},
  url = {https://aclanthology.org/P08-2062/},
  abstract = {Underspecification-based algorithms for processing partially disambiguated discourse
  structure must cope with extremely high numbers of
  readings. Based on previous work on dominance graphs and weighted
  tree grammars, we provide the first possibility for computing an underspecified discourse description and a best discourse representation efficiently enough to process even the longest discourses in the RST
  Discourse Treebank.},
  note = 	 {(25\%)}}


@InProceedings{charts-08,
  author = 	 {Alexander Koller and Michaela Regneri and Stefan Thater},
  title = 	 {Regular tree grammars as a formalism for scope underspecification},
  booktitle = {Proceedings of the 46th Annual Meeting of the Association for Computational Linguistics: Human Language Technologies (ACL-08: HLT)},
  year = 	 2008,
  address = 	 {Columbus, Ohio},
  abstract = {We propose the use of regular tree grammars (RTGs) as a formalism
  for the underspecified processing of scope ambiguities.  By applying
  standard results on RTGs, we obtain a novel algorithm for
  eliminating equivalent readings and the first efficient algorithm
  for computing the best reading of a scope ambiguity.  We also show
  how to derive RTGs from more traditional underspecified
  descriptions.},
  url = {https://aclanthology.org/P08-1026/},
  note = 	 {(25\%)}}

```.text


#add-bib-resource(bib)



#add-category("test-cat", "test_entry2", "charts-08")

#context { 
  assert(has-category("test_entry2", "test-cat"))
  assert(has-category("charts-08", "test-cat"))
  assert(not has-category("rtg-discourse", "test-cat"))
}

