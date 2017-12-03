module Config exposing (..)

import Time exposing (Time)


acceleration : Float
acceleration =
    0.5


boundaryRadius : Float
boundaryRadius =
    100


dragPercentage : Float
dragPercentage =
    0.02


{-| milliseconds between frames
30 FPS
-}
gameLoopPeriod : Time.Time
gameLoopPeriod =
    33 * Time.millisecond


playerStartingSize : Float
playerStartingSize =
    5


npcStartingSize : Float
npcStartingSize =
    4


maxNpcVelocity : Float
maxNpcVelocity =
    2


maxVelocity : Float
maxVelocity =
    2.5
