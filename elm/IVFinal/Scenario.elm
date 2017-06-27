module IVFinal.Scenario exposing
  ( Scenario
  , carboy

  , findLevel
  , justMinutes
  )

import IVFinal.Util.Measures as Measure
import Tagged exposing (Tagged(..))


type alias Scenario = 
  { animal : String
  , bagType : String
  , containerVolume : Measure.Liters
  , startingFluid : Measure.Liters
  , dropsPerMil : Int
  }

carboy : Scenario  
carboy =
  { animal = "a 1560 lb 3d lactation purebred Holstein"
  , bagType = "5-gallon carboy"
  , containerVolume = Measure.liters 20.0
  , startingFluid = Measure.liters 19.0
  , dropsPerMil = 15
  }

----   

justMinutes : Measure.Hours -> Measure.Minutes -> Measure.Minutes
justMinutes (Tagged hourPart) (Tagged minutePart) =
  Measure.minutes <| 60 * hourPart + minutePart

findLevel : Measure.DropsPerSecond -> Measure.Minutes -> Scenario
          -> Measure.Liters
findLevel dropsPerSecond minutes scenario =
  let 
    litersPerMinute = flowRate dropsPerSecond scenario
    litersDrained = litersOverTime litersPerMinute minutes
  in
    minusMinus scenario.containerVolume scenario.startingFluid litersDrained
    
-- Private
    
flowRate : Measure.DropsPerSecond -> Scenario -> Measure.LitersPerMinute
flowRate (Tagged dropsPerSecond) {dropsPerMil} =
  let
    milsPerSecond = dropsPerSecond / (toFloat dropsPerMil)
    milsPerHour = milsPerSecond * 60.0
  in
    Measure.litersPerMinute (milsPerHour / 1000.0)

litersOverTime : Measure.LitersPerMinute -> Measure.Minutes -> Measure.Liters
litersOverTime (Tagged lpm) (Tagged minutes) =
  lpm * (toFloat minutes) |> Measure.liters

minusMinus : Tagged a Float -> Tagged a Float -> Tagged a Float -> Tagged a Float
minusMinus (Tagged x) (Tagged y) (Tagged z) =
  Tagged (x - y - z)
