module IVFinal.Apparatus.Droplet exposing (..)

import Svg as S exposing (Svg)
import Svg.Attributes as SA
import Animation exposing (px)
import Time
import Ease 

import IVFinal.Types exposing (AnimationModel)
import IVFinal.Apparatus.AppAnimation exposing (..)
import IVFinal.Util.EuclideanTypes exposing (Rectangle)
import IVFinal.Util.EuclideanRectangle as Rect
import IVFinal.Apparatus.Constants as C
import IVFinal.FloatInput as FloatInput exposing (FloatInput)

import IVFinal.View.AppSvg as AppSvg exposing ((^^))

view : AnimationModel -> Svg msg
view =
  animatable S.rect <| HasFixedPart
    [ SA.width ^^ (Rect.width C.startingDroplet)
    , SA.fill C.fluidColorString
    , SA.x ^^ (Rect.x C.startingDroplet)
    ]

type alias DropletData r =
  { r | droplet : AnimationModel
      , desiredDripRate : FloatInput
  }

-- Animations

falls : DropletData {} -> AnimationModel
falls {droplet, desiredDripRate} =
  case desiredDripRate.value of
    Nothing ->
      droplet
    Just float -> 
      Animation.interrupt
        [ Animation.loop
            [ Animation.set initStyles
            , Animation.toWith (growing float) grownStyles
            , Animation.toWith falling fallenStyles
            ]
        ]
        droplet

stops : AnimationModel -> AnimationModel
stops =
  Animation.interrupt
    [ Animation.set initStyles ] -- reset back to invisible droplet


-- Styles
    
initStyles : List Animation.Property
initStyles =
  [ Animation.y (Rect.y C.startingDroplet)
  , Animation.height (px 0)
  ]

grownStyles : List Animation.Property
grownStyles =
  [ Animation.height (px C.dropletSideLength) ]

    
fallenStyles : List Animation.Property
fallenStyles =
  [ Animation.y (Rect.y C.endingDroplet) ]


-- Timing

dropStreamCutoff = 6.0

-- Following is slower than reality (in a vacuum), but looks better
timeForDropToFall = rateToSeconds dropStreamCutoff

rateToSeconds : Float -> Float
rateToSeconds rate = 
  (1 / rate ) * Time.second

                    
falling : Animation.Interpolation  
falling =
  Animation.easing
    { duration = timeForDropToFall
    , ease = Ease.inQuad
    }

growing : Float -> Animation.Interpolation  
growing rate =
  Animation.easing
    { duration = (rateToSeconds rate) - timeForDropToFall
    , ease = Ease.linear
    }

