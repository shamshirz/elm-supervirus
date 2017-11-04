module Virus exposing (..)

import Location exposing (..)


type alias Virus =
    { size : Int
    , location : Location
    }


player : Virus
player =
    Virus 5 playerStart


newVirus : Int -> ( Float, Float ) -> Virus
newVirus size ( x, y ) =
    Virus size <| Location x y


npc : Virus
npc =
    Virus 4 npcStart


move : ( Float, Float ) -> Virus -> Virus
move tuple { size, location } =
    location
        |> Location.applyVector (tupleToVector tuple)
        |> Virus size


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
    Location.isCollision first.location second.location


handleCollisions : Virus -> List Virus -> ( Mortal Virus, List Virus )
handleCollisions player npcs =
    let
        ( collisions, others ) =
            List.partition (isCollision player) npcs

        mortalVirus =
            List.foldl handleCollision (Alive player) collisions
    in
        ( mortalVirus, others )
