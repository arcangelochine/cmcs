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
