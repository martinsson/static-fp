module IVFinal.Apparatus.ChamberFluid exposing
  ( view
  , empties
  , initStyles
  )

import IVFinal.Apparatus.CommonFluid as Common
import IVFinal.App.Animation as Animation exposing (FixedPart(..), animatable)
import IVFinal.Apparatus.Constants as C
import Svg as S exposing (Svg)

import IVFinal.Types exposing (..)
import IVFinal.App.Svg exposing ((^^))
import IVFinal.Generic.EuclideanRectangle as Rect exposing (Rectangle)
import IVFinal.Generic.Measures as Measure
import Svg.Attributes as SA


--- Customizing `Model` to this module

type alias Obscured model =
  { model
    | chamberFluid : Animation.Model
  }

type alias Transformer model =
  Obscured model -> Obscured model

reanimate : List Animation.Step -> Transformer model
reanimate steps model =
  { model | chamberFluid = Animation.interrupt steps model.chamberFluid }

moduleRectangle : Rectangle
moduleRectangle = C.chamberFluid


-- Animations
      
empties : Continuation -> Transformer model
empties continuation =
  reanimate
    [ Animation.toWith
        (Animation.linear <| Measure.seconds 0.3)
        emptyStyles
    , Animation.request continuation
    ]

-- Styles

initStyles : List Animation.Styling
initStyles = 
  [ Animation.yFrom C.chamberFluid
  , Animation.heightFrom C.chamberFluid
  ]

emptyStyles : List Animation.Styling
emptyStyles  =
  let
    rect = C.chamberFluid |> Rect.lowerTo 0
  in
    [ Animation.yFrom rect
    , Animation.heightAttr 0
    ]

  

-- Timing

---- View

view : Animation.Model -> Svg msg
view = Common.view moduleRectangle
