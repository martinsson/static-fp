module Choose.MaybePartTest exposing (..)

import Test exposing (..)
import TestBuilders exposing (..)
import Choose.MaybePart as Opt
import Choose.Common as Opt
import Choose.Definitions as D
import Dict

accessors partChooser =
  ( Opt.get partChooser
  , Opt.set partChooser
  , Opt.update partChooser
  )

operations : Test
operations =
  let
    (get, set, update) = accessors D.dictOpt
  in
    describe "operations" 
      [ equal_ (get           <| D.dict1 "key" 58)    (Just 58)
      , equal_ (get           <| Dict.empty)           Nothing

      , equal_ (set 0         <| D.dict1 "key" 3)     (D.dict1 "key" 0)
      , equal_ (set 9         <| Dict.empty)          (D.dict1 "key" 9)

      , equal_ (update negate <| D.dict1 "key" 58)    (D.dict1 "key" -58)
      , equal_ (update negate <| Dict.empty)           Dict.empty
      ]

lawTests opt whole wholeTag =
  let
    (get, set, _) = accessors opt
  in
    describe wholeTag
      [ -- 1. if you `set` the part that `get` provides, whole is unchanged
        equal (get whole)           (Just "focus")   "here's what the get returns"
      , equal (set "focus" whole)   whole            "setting it to original"

      -- 2. What you `set` is what you `get`
      , equal_ (get (set "new" whole))  (Just "new")
      ]


laws =
  describe "laws for optionals (MaybePart)"
    [ lawTests D.dictOpt
               (D.dict1 "key" "focus")                       "Dict"
        
    , lawTests (Opt.dict "one" |> Opt.next (Opt.dict "two"))
               (D.dict1_1 "one" "two" "focus")               "Composition of Dict"
          
    ]


compositionHasQuirksInSet =
  let
    composed = Opt.dict "one" |> Opt.next (Opt.dict "two")
    -- Shorthand so the structure of test dicts is easier to skim
    -- Topmost key is the function name.
    one = D.dict1_1 "one"      -- make {"one": {key: val}} with given key/val
    other = D.dict1_1 "other"  -- ditto, but {"other": {key: val}}
    oneIsEmpty = D.dict1 "one" Dict.empty  -- {"one" : Dict.empty}
    (get, set, update) = accessors composed
  in
    describe "composition"
      [ describe "get" 
          [ equal_ (get <| one "two" 1.2)    (Just 1.2)
          , equal  (get <| one "ZZZ" 1.2)    Nothing  "no last key"
          , equal  (get <| oneIsEmpty)       Nothing  "alternate to above"
          , equal  (get <| Dict.empty)       Nothing  "no first key"
          ]
      , describe "set"
          [ equal_ (set 8.8 <| one "two" 0000)    (one "two" 8.8)
          , equal_ (set 2.2 <| oneIsEmpty)        (one "two" 2.2)

          -- You might expect the following two cases to do this:
          -- , equal_ (set 9.3 <| other "two" 0000)   (Dict.union (other "two" 0000)
          --                                                  (one "two" 9.3))
          --, equal_ (set 9.3 Dict.empty)            (one "two" 9.3)
          --, equal_ (set 9.3 Dict.empty)            (one "two" 9.3)
          --
          -- But they actually make no change because two levels of key
          -- would have to be added.
          , unchanged (set 9.3) (other "two" 0000)  "top-level key is 'two'"
          , unchanged (set 9.3) Dict.empty          "no top-level key"
          ]
      , describe "update"
          [ equal_    ((update negate)  (one "two" 1))    (one "two" -1)
          , unchanged  (update negate)  oneIsEmpty        "Nothing to get for 'two', so nothing to update"
          , unchanged  (update negate)  Dict.empty        "ditto, but not even top level"
          ]
      ]
