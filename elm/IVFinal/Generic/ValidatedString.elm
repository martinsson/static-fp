module IVFinal.Generic.ValidatedString exposing
  ( ValidatedString
  , checked
  )

{-| A record that stores both a string and, maybe, the value it parses to.
-}

type alias ValidatedString a =
  { literal : String
  , value : Maybe a
  }

{-| Construct a validated string with this. The name `checked` implies
that the string has already been validated to produce the second argument
(either a `Just` legitimate value or `Nothing`).
-}
  
checked : String -> Maybe a -> ValidatedString a
checked literal value =
  { literal = literal
  , value = value
  }
