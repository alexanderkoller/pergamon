// Test journal articles with subtitles, #171
#import "/lib.typ": *


#let bib = ```

@string{
  anch-ie = {Angew.~Chem. Int.~Ed.},
  cup     = {Cambridge University Press},
  dtv     = {Deutscher Taschenbuch-Verlag},
  hup     = {Harvard University Press},
  jams    = {J.~Amer. Math. Soc.},
  jchph   = {J.~Chem. Phys.},
  jomch   = {J.~Organomet. Chem.},
  pup     = {Princeton University Press}
}

@article{kastenholz,
  author       = {Kastenholz, M. A. and H{\"u}nenberger, Philippe H.},
  title        = {Computation of methodology-independent ionic solvation
                  free energies from molecular simulations},
  journaltitle = jchph,
  date         = 2006,
  subtitle     = {{I}. {The} electrostatic potential in molecular liquids},
  volume       = 124,
  eid          = 124106,
  doi          = {10.1063/1.2172593},
  langid       = {english},
  langidopts   = {variant=american},
  indextitle   = {Computation of ionic solvation free energies},
  annotation   = {An \texttt{article} entry with an \texttt{eid} and a
                  \texttt{doi} field. Note that the \textsc{doi} is transformed
                  into a clickable link if \texttt{hyperref} support has been
                  enabled},
  abstract     = {The computation of ionic solvation free energies from
                  atomistic simulations is a surprisingly difficult problem that
                  has found no satisfactory solution for more than 15 years. The
                  reason is that the charging free energies evaluated from such
                  simulations are affected by very large errors. One of these is
                  related to the choice of a specific convention for summing up
                  the contributions of solvent charges to the electrostatic
                  potential in the ionic cavity, namely, on the basis of point
                  charges within entire solvent molecules (M scheme) or on the
                  basis of individual point charges (P scheme). The use of an
                  inappropriate convention may lead to a charge-independent
                  offset in the calculated potential, which depends on the
                  details of the summation scheme, on the quadrupole-moment
                  trace of the solvent molecule, and on the approximate form
                  used to represent electrostatic interactions in the
                  system. However, whether the M or P scheme (if any) represents
                  the appropriate convention is still a matter of on-going
                  debate. The goal of the present article is to settle this
                  long-standing controversy by carefully analyzing (both
                  analytically and numerically) the properties of the
                  electrostatic potential in molecular liquids (and inside
                  cavities within them).},
}
```.text 



#add-bib-resource(bib)

#refsection(style: authoryear-style())[
  #cite("kastenholz")
  #print-bibliography()
]