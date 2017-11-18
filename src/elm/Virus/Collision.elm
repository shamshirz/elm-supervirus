module Virus.Collision exposing (isCollision)

import Collision2D as Collision exposing (Circle)
import Math.Vector2 as Vector2 exposing (Vec2)


isCollision : { a | size : Float, location : Vec2 } -> { b | size : Float, location : Vec2 } -> Bool
isCollision first second =
    Collision.circleToCircle
        (collidableToCircle first.size first.location)
        (collidableToCircle second.size second.location)


collidableToCircle : Float -> Vec2 -> Circle
collidableToCircle size location =
    let
        ( x, y ) =
            Vector2.toTuple location
    in
        Collision.circle x y size
