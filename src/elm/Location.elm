module Location exposing (..)

import Collision2D exposing (circle, Circle, circleToCircle)


radius : Float
radius =
    5


boundary : Circle
boundary =
    circle 0 0 200


type alias Vector =
    { dx : Float
    , dy : Float
    }


type alias Location =
    { x : Float
    , y : Float
    }


center : Location
center =
    Location 0 0


applyVector : Vector -> Location -> Location
applyVector { dx, dy } { x, y } =
    Location (x + dx) (y + dy)


tupleToVector : ( Float, Float ) -> Vector
tupleToVector ( x, y ) =
    Vector x y



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
