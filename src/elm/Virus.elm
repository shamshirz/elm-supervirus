module Virus
    exposing
        ( handleCollisions
        , handleCollision
        , location
        , Mortal(..)
        , move
        , npc
        , Npc
        , newVirus
        , player
        , updateNpc
        , Virus
        )

import Math.Vector2 as Vector2 exposing (Vec2)
import Collision2D as Collision exposing (Circle)
import DomainMath


type alias Virus =
    { size : Float
    , location : Vec2
    }


type alias Moving a =
    { a | velocity : Vec2 }


type alias Npc =
    Moving Virus


setVelocity : { a | velocity : Vec2 } -> Vec2 -> { a | velocity : Vec2 }
setVelocity mover vel =
    { mover | velocity = vel }


npc : Float -> Npc
npc boundary =
    makeNpc boundary 4 (Vector2.vec2 10 10) (Vector2.vec2 1 2)


makeNpc : Float -> Float -> Vec2 -> Vec2 -> Npc
makeNpc boundary size location velocity =
    { velocity = velocity
    , size = size
    , location = DomainMath.scaleWithinBoundary boundary size location
    }


setNpc : Float -> Vec2 -> Vec2 -> Npc
setNpc size location velocity =
    { velocity = velocity
    , size = size
    , location = location
    }


{-| Context free fxn, still requires the boundary radius
-}
player : Float -> Virus
player =
    newVirus 5 ( 0, 0 )


location : Virus -> ( Float, Float )
location virus =
    Vector2.toTuple virus.location


updateNpc : Float -> Npc -> Npc
updateNpc boundaryRadius { velocity, size, location } =
    let
        ( newLoc, newVel ) =
            DomainMath.updatePositionAndVelocity location velocity (boundaryRadius - size)
    in
        setNpc size newLoc newVel


newVirus : Float -> ( Float, Float ) -> Float -> Virus
newVirus size location boundaryRadius =
    Vector2.vec2 0 0
        |> Virus size
        |> move location boundaryRadius


move : ( Float, Float ) -> Float -> Virus -> Virus
move tuple boundaryRadius { size, location } =
    tuple
        |> Vector2.fromTuple
        |> Vector2.add location
        |> DomainMath.scaleWithinBoundary boundaryRadius size
        |> Virus size



-- Collisions


{-| handleCollisions
Handles multiple collisions and returns
the virus wrapped in the status of the collisions
and the list of Viruses that were not involved in collisions
-}
handleCollisions : Virus -> List Npc -> ( Mortal Virus, List Npc )
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
handleCollision : Npc -> Mortal Virus -> Mortal Virus
handleCollision enemy mortalPlayer =
    case mortalPlayer of
        Alive player ->
            if player.size >= enemy.size then
                Alive <| Virus (player.size + 1) player.location
            else
                Dead

        Dead ->
            Dead


isCollision : Virus -> Npc -> Bool
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
