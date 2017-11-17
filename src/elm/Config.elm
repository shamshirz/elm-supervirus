module Config exposing (..)

import Time exposing (Time)


{-| milliseconds between frames
30 FPS
-}
gameLoopPeriod : Time.Time
gameLoopPeriod =
    33 * Time.millisecond


boundaryRadius : Float
boundaryRadius =
    100


playerStartingSize : Float
playerStartingSize =
    5


npcStartingSize : Float
npcStartingSize =
    4
