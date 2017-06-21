module IVFinal.Measures exposing (..)

import Tagged exposing (Tagged(..))
import IVFinal.Util.AppTagged exposing (UnusableConstructor)

type alias DropsPerSecond = Tagged DropsPerSecondTag Float

dripRate : Float -> DropsPerSecond
dripRate = Tagged

--- Support for tagging

type DropsPerSecondTag = DropsPerSecondTag UnusableConstructor

