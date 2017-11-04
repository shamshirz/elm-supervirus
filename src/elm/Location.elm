module Location
    exposing
        ( applyVector
        , center
        , isCollision
        , Location
        , npcStart
        , playerCollisions
        , playerStart
        , tupleToVector
        , Vector
        )

import Collision2D exposing (circle, Circle, circleToCircle)


-- Types & Constructors


type alias Vector =
    { dx : Float
    , dy : Float
    }


tupleToVector : ( Float, Float ) -> Vector
tupleToVector ( x, y ) =
    Vector x y


type alias Location =
    { x : Float
    , y : Float
    }



-- Defaults


radius : Float
radius =
    5


boundary : Circle
boundary =
    circle 0 0 40


center : Location
center =
    Location 0 0



-- Actual functions


playerStart : Location
playerStart =
    center


{-| npcStart
These should ideally be random
-}
npcStart : Location
npcStart =
    Location 10 10


applyVector : Vector -> Location -> Location
applyVector { dx, dy } { x, y } =
    let
        newLocation =
            Location (x + dx) (y + dy)
    in
        if circleToCircle (locationToCircle newLocation) boundary then
            -- Find the closest possible location without colliding
            newLocation
        else
            Location x y



--  COLLISION DETECTION


{-| playerCollisions
Compares the player against all other Npcs to detect
a collision. Currently returning a list of colliding locations.
-}
playerCollisions : Location -> List Location -> List Location
playerCollisions target others =
    others
        |> List.filter (isCollision target)


isCollision : Location -> Location -> Bool
isCollision first second =
    circleToCircle
        (locationToCircle first)
        (locationToCircle second)


locationToCircle : Location -> Circle
locationToCircle { x, y } =
    circle x y radius
