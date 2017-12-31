module Config
    exposing
        ( acceleration
        , boundaryRadius
        , dragPercentage
        , gameLoopPeriod
        , maxNpcVelocity
        , maxVelocity
        , metabolismCost
        , metabolismResting
        , npcStartingSize
        , playerStartingSize
        , transferableEnergy
        )

import Time exposing (Time)


acceleration : Float
acceleration =
    0.2


boundaryRadius : Float
boundaryRadius =
    200


dragPercentage : Float
dragPercentage =
    0.02


{-| milliseconds between frames
30 FPS
-}
gameLoopPeriod : Time.Time
gameLoopPeriod =
    33 * Time.millisecond


maxNpcVelocity : Float
maxNpcVelocity =
    2


maxVelocity : Float
maxVelocity =
    2.5


npcStartingSize : Float
npcStartingSize =
    4


playerStartingSize : Float
playerStartingSize =
    5


metabolismResting : Float
metabolismResting =
    1


metabolismCost : Float
metabolismCost =
    0.02


transferableEnergy : Float
transferableEnergy =
    0.08
