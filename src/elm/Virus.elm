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

import Math.Vector2 exposing (..)
import Collision2D exposing (circle, Circle, circleToCircle)


type alias Virus =
    { size : Float
    , location : Vec2
    }


location : Virus -> { x : Float, y : Float }
location virus =
    toRecord virus.location


radius : Float
radius =
    5


boundaryRadius : Float
boundaryRadius =
    40


boundary : Circle
boundary =
    circle 0 0 boundaryRadius


center : Vec2
center =
    vec2 0 0


player : Virus
player =
    Virus 5 center


newVirus : Float -> ( Float, Float ) -> Virus
newVirus size ( x, y ) =
    center
        |> add (vec2 x y)
        |> Virus size


npc : Virus
npc =
    center
        |> add (vec2 10 10)
        |> Virus 4



-- Needs to handle boundary


move : ( Float, Float ) -> Virus -> Virus
move tuple { size, location } =
    let
        newVirus =
            tuple
                |> fromTuple
                |> add location
                |> Virus size
    in
        if circleToCircle (vec2Circle newVirus.location) boundary then
            -- We are within the boundary, so use this location
            newVirus
        else
            -- We are outside the boundary, bring us back to the edge
            newVirus
                |> moveWithinBoundary


moveWithinBoundary : Virus -> Virus
moveWithinBoundary virus =
    virus.location
        |> normalize
        |> scale (boundaryRadius + virus.size)
        |> Virus virus.size



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
    circleToCircle
        (vec2Circle first.location)
        (vec2Circle second.location)


vec2Circle : Vec2 -> Circle
vec2Circle vec =
    let
        ( x, y ) =
            toTuple vec
    in
        circle x y radius
