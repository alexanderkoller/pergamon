#import "/lib.typ": *
#import "/src/bibtypst.typ": *


#let small1 = "
@thesis{kuhlmann2003tiny,
	Address = {Saarbrücken, Germany},
	Author = {Marco Kuhlmann},
	Date-Added = {2008-11-04 15:02:46 +0100},
	Date-Modified = {2009-09-04 23:01:26 +0200},
	School = {Saarland University},
	Title = {A Tiny Constraint Modelling Language},
	Type = {Bachelor's thesis},
	Year = {2003}}
    "

#let small2 = "

@mastersthesis{fake-mastersthesis,
	Address = {Saarbrücken, Germany},
	Author = {Great Student},
	Date-Added = {2008-11-04 15:02:46 +0100},
	Date-Modified = {2009-09-04 23:01:26 +0200},
	School = {Saarland University},
	Title = {A Tiny Constraint Modelling Language},
	Year = {2003}}


@misc{multi1,
  author = {A B and C D and E F and G H},
  title = {First paper},
  date = 2020
}


@misc{multi2,
  author = {A B and C D and E F and K L},
  title = {Second paper},
  language = {French and Latin and German},
  date = 2020
}
"




#add-bib-resource(small1)

#refsection[
  #add-bib-resource(small2, local: true)

  #context {
    assert( bibliography.get().keys() == ("kuhlmann2003tiny",) )

    assert( local-bibliography-at-refsection-end().keys() == ("fake-mastersthesis", "multi1", "multi2") )
  }
]

#refsection[
  #context {
    assert( bibliography.get().keys() == ("kuhlmann2003tiny",) )

    assert( local-bibliography-at-refsection-end().keys() == () )
  }
]


