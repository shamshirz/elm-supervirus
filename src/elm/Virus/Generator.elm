module Virus.Generator exposing (one)

import Math.Vector2 as Vector2 exposing (Vec2)
import Random exposing (Generator)


-- Public API


type alias Seed =
    { boundaryRadius : Float
    , currentPosition : Vec2
    , maxVelocity : Float
    , size : Float
    }


one : Seed -> (Vec2 -> Float -> Vec2 -> a) -> Generator a
one { boundaryRadius, currentPosition, size, maxVelocity } typeConstructor =
    let
        randomSize =
            relativeSize size

        randomLocation =
            location boundaryRadius currentPosition

        randomVelocity =
            velocity maxVelocity
    in
        Random.map3 typeConstructor randomLocation randomSize randomVelocity



-- PRIVATE


relativeSize : Float -> Generator Float
relativeSize x =
    Random.float (x * 0.7) (x * 1.7)



-- >>>>>>>>>>>>>>>>>>>>>> LOCATION


location : Float -> Vec2 -> Generator Vec2
location boundaryRadius currentPosition =
    let
        ( r, theta ) =
            currentPosition
                |> Vector2.toTuple
                |> toPolar
    in
        if r < 30 then
            locationRelativeToOrigin boundaryRadius
        else
            locationOppositeTheta boundaryRadius theta


locationRelativeToOrigin : Float -> Generator Vec2
locationRelativeToOrigin boundaryRadius =
    Random.pair (Random.float 30 boundaryRadius) (Random.float 0 360)
        |> Random.map (fromPolar >> Vector2.fromTuple)


locationOppositeTheta : Float -> Float -> Generator Vec2
locationOppositeTheta boundaryRadius theta =
    (Random.float 0 boundaryRadius)
        |> Random.map (\r -> Vector2.fromTuple <| fromPolar ( r, theta - 180 ))



-- >>>>>>>>>>>>>>>>>>>>>> VELOCITY


velocity : Float -> Generator Vector2.Vec2
velocity max =
    let
        range =
            Random.float (-1 * max) max
    in
        Random.pair range range
            |> Random.map (\pair -> Vector2.fromTuple pair)
