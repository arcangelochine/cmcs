#import "@preview/bookly:5.1.0": *
#import "lib.typ": *

#show: bookly.with(
  title: "Computational Models for\nComplex Systems",
  author: "",
  lang: "en",
  theme: orly,
  colors: (
    primary: rgb(55, 122, 170),
  ),
  title-page: book-title-page(
    series: emph("講義ノート"),
    subtitle: none,
    institution: none,
    edition: "Draft",
  ),
)

#show heading.where(level: 3): set heading(numbering: none, outlined: false)

#set table(
  fill: (col, row) => if row == 0 { rgb("3c3c3c") } else if calc.even(row) {
    rgb("f2f2f2")
  } else { none },
  inset: 8pt,
)

#set ref(supplement: auto)

#show: main-matter

#tableofcontents

#part("Abstract Models")

#include "chapters/01-introduction.typ"
#include "chapters/02-discrete-dynamical-systems.typ"
#include "chapters/03-continuous-dynamical-systems.typ"
#include "chapters/04-classical-compartmental-models.typ"
#include "chapters/05-chemical-reactions-and-stochastic-simulation.typ"
