#import "@preview/bookly:5.1.0": custom-box

// Avoid extra space after inline math before punctuation, and tighten
// comma/semicolon spacing inside math (Unicode punctuation class).
#show math.equation: it => {
  show ",": math.class("normal", ",")
  show ";": math.class("normal", ";")
  it
}

#let example-box(body, title: "Example") = custom-box(
  body,
  color: rgb("3c3c3c"),
  icon: "tip",
  title: title,
)

#let enrichment-box(body, title: "Optional enrichment") = custom-box(
  body,
  color: rgb("8a8a8a"),
  icon: "info",
  title: title,
)

// Visible stand-in for a figure the author will draw in draw.io and export to
// src/images/<path>. Replace the whole call with
// image("../images/<path>", width: ...) once the PDF exists.
#let drawio-placeholder(path, body, width: 70%, height: 5cm) = block(
  width: width,
  height: height,
  inset: 10pt,
  radius: 4pt,
  fill: luma(245),
  stroke: (paint: luma(150), thickness: 0.8pt, dash: "dashed"),
)[
  #set align(center + horizon)
  #set text(size: 8.5pt, fill: luma(90))
  #text(weight: "bold")[draw.io figure pending] \
  // Plain text, not raw(): a raw element would turn the figure into a Listing.
  #text(font: "DejaVu Sans Mono", size: 8pt, "src/images/" + path) \
  #v(0.3em)
  #body
]
