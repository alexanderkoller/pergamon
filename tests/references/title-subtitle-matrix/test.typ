// Persistent coverage for Biblatex-style title/subtitle/titleaddon rendering.
#import "/lib.typ": *

#set page(width: 9in, height: 14in, margin: 0.35in)
#set text(size: 7pt)

#let bib = ```
@article{article-full,
  author = {Article Full},
  title = {Article Title},
  subtitle = {Article Subtitle},
  titleaddon = {Article Addon},
  journaltitle = {Journal},
  date = {2024},
}

@article{article-title,
  author = {Article Titleonly},
  title = {Article Title Only},
  journaltitle = {Journal},
  date = {2024},
}

@inbook{inbook-full,
  author = {Inbook Full},
  title = {Inbook Title},
  subtitle = {Inbook Subtitle},
  titleaddon = {Inbook Addon},
  booktitle = {Container Book},
  publisher = {Publisher},
  date = {2024},
}

@inbook{inbook-title,
  author = {Inbook Titleonly},
  title = {Inbook Title Only},
  booktitle = {Container Book},
  publisher = {Publisher},
  date = {2024},
}

@incollection{incollection-full,
  author = {Incollection Full},
  title = {Incollection Title},
  subtitle = {Incollection Subtitle},
  titleaddon = {Incollection Addon},
  booktitle = {Collected Work},
  publisher = {Publisher},
  date = {2024},
}

@incollection{incollection-title,
  author = {Incollection Titleonly},
  title = {Incollection Title Only},
  booktitle = {Collected Work},
  publisher = {Publisher},
  date = {2024},
}

@inproceedings{inproceedings-full,
  author = {Inproceedings Full},
  title = {Inproceedings Title},
  subtitle = {Inproceedings Subtitle},
  titleaddon = {Inproceedings Addon},
  booktitle = {Conference Book},
  date = {2024},
}

@inproceedings{inproceedings-title,
  author = {Inproceedings Titleonly},
  title = {Inproceedings Title Only},
  booktitle = {Conference Book},
  date = {2024},
}

@patent{patent-full,
  author = {Patent Full},
  title = {Patent Title},
  subtitle = {Patent Subtitle},
  titleaddon = {Patent Addon},
  number = {P-1},
  date = {2024},
}

@patent{patent-title,
  author = {Patent Titleonly},
  title = {Patent Title Only},
  number = {P-2},
  date = {2024},
}

@thesis{thesis-full,
  author = {Thesis Full},
  title = {Thesis Title},
  subtitle = {Thesis Subtitle},
  titleaddon = {Thesis Addon},
  type = {phdthesis},
  institution = {University},
  date = {2024},
}

@thesis{thesis-title,
  author = {Thesis Titleonly},
  title = {Thesis Title Only},
  type = {phdthesis},
  institution = {University},
  date = {2024},
}

@unpublished{unpublished-full,
  author = {Unpublished Full},
  title = {Unpublished Title},
  subtitle = {Unpublished Subtitle},
  titleaddon = {Unpublished Addon},
  date = {2024},
}

@unpublished{unpublished-title,
  author = {Unpublished Titleonly},
  title = {Unpublished Title Only},
  date = {2024},
}

@book{book-full,
  author = {Book Full},
  title = {Book Title},
  subtitle = {Book Subtitle},
  titleaddon = {Book Addon},
  publisher = {Publisher},
  date = {2024},
}

@book{book-title,
  author = {Book Titleonly},
  title = {Book Title Only},
  publisher = {Publisher},
  date = {2024},
}

@booklet{booklet-full,
  author = {Booklet Full},
  title = {Booklet Title},
  subtitle = {Booklet Subtitle},
  titleaddon = {Booklet Addon},
  date = {2024},
}

@booklet{booklet-title,
  author = {Booklet Titleonly},
  title = {Booklet Title Only},
  date = {2024},
}

@collection{collection-full,
  editor = {Collection Full},
  title = {Collection Title},
  subtitle = {Collection Subtitle},
  titleaddon = {Collection Addon},
  publisher = {Publisher},
  date = {2024},
}

@collection{collection-title,
  editor = {Collection Titleonly},
  title = {Collection Title Only},
  publisher = {Publisher},
  date = {2024},
}

@manual{manual-full,
  author = {Manual Full},
  title = {Manual Title},
  subtitle = {Manual Subtitle},
  titleaddon = {Manual Addon},
  date = {2024},
}

@manual{manual-title,
  author = {Manual Titleonly},
  title = {Manual Title Only},
  date = {2024},
}

@online{online-full,
  author = {Online Full},
  title = {Online Title},
  subtitle = {Online Subtitle},
  titleaddon = {Online Addon},
  url = {https://example.com/full},
  date = {2024},
}

@online{online-title,
  author = {Online Titleonly},
  title = {Online Title Only},
  url = {https://example.com/title},
  date = {2024},
}

@proceedings{proceedings-full,
  editor = {Proceedings Full},
  title = {Proceedings Title},
  subtitle = {Proceedings Subtitle},
  titleaddon = {Proceedings Addon},
  date = {2024},
}

@proceedings{proceedings-title,
  editor = {Proceedings Titleonly},
  title = {Proceedings Title Only},
  date = {2024},
}

@report{report-full,
  author = {Report Full},
  title = {Report Title},
  subtitle = {Report Subtitle},
  titleaddon = {Report Addon},
  type = {techreport},
  institution = {Institute},
  date = {2024},
}

@report{report-title,
  author = {Report Titleonly},
  title = {Report Title Only},
  type = {techreport},
  institution = {Institute},
  date = {2024},
}

@dataset{dataset-full,
  author = {Dataset Full},
  title = {Dataset Title},
  subtitle = {Dataset Subtitle},
  titleaddon = {Dataset Addon},
  date = {2024},
}

@dataset{dataset-title,
  author = {Dataset Titleonly},
  title = {Dataset Title Only},
  date = {2024},
}

@misc{misc-full,
  author = {Misc Full},
  title = {Misc Title},
  subtitle = {Misc Subtitle},
  titleaddon = {Misc Addon},
  date = {2024},
}

@misc{misc-title,
  author = {Misc Titleonly},
  title = {Misc Title Only},
  date = {2024},
}

@periodical{periodical-full,
  editor = {Periodical Full},
  title = {Periodical Title},
  subtitle = {Periodical Subtitle},
  titleaddon = {Periodical Addon},
  date = {2024},
}

@periodical{periodical-title,
  editor = {Periodical Titleonly},
  title = {Periodical Title Only},
  date = {2024},
}
```.text

#add-bib-resource(bib)

#refsection(style: authoryear-style(reference: (link-titles: false)))[
  #cite("article-full", "article-title", "inbook-full", "inbook-title")
  #cite("incollection-full", "incollection-title", "inproceedings-full", "inproceedings-title")
  #cite("patent-full", "patent-title", "thesis-full", "thesis-title", "unpublished-full", "unpublished-title")
  #cite("book-full", "book-title", "booklet-full", "booklet-title", "collection-full", "collection-title")
  #cite("manual-full", "manual-title", "online-full", "online-title", "proceedings-full", "proceedings-title")
  #cite("report-full", "report-title", "dataset-full", "dataset-title", "misc-full", "misc-title", "periodical-full", "periodical-title")

  #print-bibliography()
]
