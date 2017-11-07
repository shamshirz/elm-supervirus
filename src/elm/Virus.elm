module Virus
    exposing
        ( handleCollisions
        , handleCollision
        , location
        , Mortal(..)
        , move
        , npc
        , newVirus
        , player
        , Virus
        )

import Math.Vector2 as Vector2 exposing (Vec2)
import Collision2D as Collision exposing (Circle)


type alias Virus =
    { size : Float
    , location : Vec2
    }


type alias Moving a =
    { a | velocity : Vec2 }


type alias Npc =
    Moving Virus


location : Virus -> { x : Float, y : Float }
location virus =
    Vector2.toRecord virus.location


{-| Context free fxn, still requires the boundary radius
-}
player : Float -> Virus
player =
    newVirus 5 ( 0, 0 )


{-| Context free fxn, still requires the boundary radius
-}
npc : Float -> Virus
npc =
    newVirus 4 ( 10, 10 )


newVirus : Float -> ( Float, Float ) -> Float -> Virus
newVirus size location boundaryRadius =
    Vector2.vec2 0 0
        |> Virus size
        |> move location boundaryRadius


move : ( Float, Float ) -> Float -> Virus -> Virus
move tuple boundaryRadius { size, location } =
    let
        newVirus =
            tuple
                |> Vector2.fromTuple
                |> Vector2.add location
                |> Virus size
    in
        if virusWithinBoundary newVirus boundaryRadius then
            newVirus
        else
            newVirus
                |> moveToBoundary (boundaryRadius)


{-| This function will take a location vector, try to determine it's direction,
then scale it to the boundary (minus it's own size).
This will put the outside edge of the virus on the boundary.

If we are at the origin, there is no normalized vector, so I will send
you straight to hell (downward with no x value).

The nice thing about this function, is that we can move outside things in,
and inside things out.

-}
moveToBoundary : Float -> Virus -> Virus
moveToBoundary radiusOfBoundary virus =
    virus.location
        |> normalize
        |> Vector2.scale (radiusOfBoundary - virus.size)
        |> Virus virus.size


{-| Wrapper for normalize because we get NaN
if you do it from the origin. This is wonky, but
better than everything breaking
-}
normalize : Vec2 -> Vec2
normalize vec =
    if (Vector2.length vec) == 0 then
        Vector2.vec2 0 1
    else
        Vector2.normalize vec


virusWithinBoundary : Virus -> Float -> Bool
virusWithinBoundary virus radiusOfBoundary =
    Vector2.length virus.location <= (radiusOfBoundary - virus.size)



-- Collisions


{-| handleCollisions
Handles multiple collisions and returns
the virus wrapped in the status of the collisions
and the list of Viruses that were not involved in collisions
-}
handleCollisions : Virus -> List Virus -> ( Mortal Virus, List Virus )
handleCollisions player npcs =
    let
        ( collisions, others ) =
            List.partition (isCollision player) npcs

        mortalVirus =
            List.foldl handleCollision (Alive player) collisions
    in
        ( mortalVirus, others )


type Mortal a
    = Alive a
    | Dead


{-| handleCollision
This is internal only, the exposed api should be nicer to work with
Like the handling multiple collisions and returning the new list and whether
we survived or not.

If we collide with another virus,
a. We are already dead from an earlier collision: remain dead
b. We are larger than the other virus: eat it
c. We are smaller than the other virus: we die

-}
handleCollision : Virus -> Mortal Virus -> Mortal Virus
handleCollision enemy mortalPlayer =
    case mortalPlayer of
        Alive player ->
            if player.size >= enemy.size then
                Alive <| Virus (player.size + 1) player.location
            else
                Dead

        Dead ->
            Dead


isCollision : Virus -> Virus -> Bool
isCollision first second =
    Collision.circleToCircle
        (virusToCircle first)
        (virusToCircle second)


virusToCircle : Virus -> Circle
virusToCircle { size, location } =
    let
        ( x, y ) =
            Vector2.toTuple location
    in
        Collision.circle x y size
