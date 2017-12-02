module Virus
    exposing
        ( applyAcceleration
        , BoundaryConflict(..)
        , location
        , Mortal(..)
        , move
        , player
        , random
        , resolveBattles
        , safeCreate
        , Virus
        )

import Virus.Collision exposing (isCollision)
import Virus.Generator as Gen
import Virus.Math2D as Math2D
import Math.Vector2 as Vector2 exposing (Vec2)
import Random


type alias Virus =
    { location : Vec2
    , size : Float
    , velocity : Vec2
    }



-- >>>>>>>>>>>>>>>>>>>>>> CREATION


player : Float -> Virus
player size =
    Virus (Vector2.vec2 0 0) size (Vector2.vec2 0 0)


safeCreate : Float -> Vec2 -> Float -> Vec2 -> Virus
safeCreate boundaryRadius location size velocity =
    Virus (Math2D.scaleWithinBoundary boundaryRadius size location) size velocity



-- >>>>>>>>>>>>>>>>>>>>>> GETTERS


location : Virus -> ( Float, Float )
location { location } =
    Vector2.toTuple location



-- >>>>>>>>>>>>>>>>>>>>>> UPDATES


applyAcceleration : ( Float, Float ) -> Virus -> Virus
applyAcceleration delta { location, size, velocity } =
    delta
        |> Vector2.fromTuple
        |> Vector2.add velocity
        |> limitVelocity
        |> Virus location size


limitVelocity : Vec2 -> Vec2
limitVelocity vel =
    let
        ( dx, dy ) =
            Vector2.toTuple vel
    in
        Vector2.vec2 (limit dx) (limit dy)


limit : Float -> Float
limit x =
    if x > 3 then
        3
    else if x < -3 then
        -3
    else
        x



-- >>>>>>>>>>>>>>>>>>>>>> MOVEMENT
-- move is the public API, pass a conflict type
-- delegated to one of the internal functions


type BoundaryConflict
    = Bounce
    | Slide


move : BoundaryConflict -> Float -> Virus -> Virus
move onConflict boundaryRadius mover =
    case onConflict of
        Bounce ->
            moveWithBounce boundaryRadius mover

        Slide ->
            moveWithSlide boundaryRadius mover


{-| Bounce off of interior of boundary
-}
moveWithBounce : Float -> Virus -> Virus
moveWithBounce boundaryRadius { velocity, size, location } =
    let
        ( newLoc, newVel ) =
            Math2D.moveWithBounce location velocity (boundaryRadius - size)
    in
        Virus newLoc size newVel


{-| negate all velocity toward boundary
Project onto the tangent to the circle.
-}
moveWithSlide : Float -> Virus -> Virus
moveWithSlide boundaryRadius { velocity, size, location } =
    let
        ( newLoc, newVel ) =
            Math2D.moveWithSlide location velocity (boundaryRadius - size)
    in
        Virus newLoc size newVel


{-| move, and if outside the boundary
scale it back in directly towards origin
-}
moveAndScale : Float -> Virus -> Virus
moveAndScale boundaryRadius { location, size, velocity } =
    let
        newLocation =
            location
                |> Vector2.add velocity
                |> Math2D.scaleWithinBoundary boundaryRadius size
    in
        Virus newLocation size velocity



-- >>>>>>>>>>>>>>>>>>>>>> BATTLES


type Mortal a
    = Alive a
    | Dead


{-| resolveBattles
Determines which NPCs are battled (partion yields (collided, nonCollided))
Resolve each battle. Fold all battles on to our Mortal Virus
Return the new Mortal virus and uncollided Viruss
-}
resolveBattles : Virus -> List Virus -> ( Mortal Virus, List Virus )
resolveBattles player npcs =
    npcs
        |> List.partition (isCollision player)
        |> Tuple.mapFirst (List.foldl battle (Alive player))


{-| battle
This is internal only, the exposed api should be nicer to work with
Like the handling multiple collisions and returning the new list and whether
we survived or not.

If we battle an NPC
a. We are already dead from an earlier battle: remain dead
b. We are larger than the other virus: eat it
c. We are smaller than the other virus: we die

-}
battle : Virus -> Mortal Virus -> Mortal Virus
battle enemy mortalPlayer =
    case mortalPlayer of
        Alive player ->
            if player.size >= enemy.size then
                player |> eat enemy
            else
                Dead

        Dead ->
            Dead


eat : Virus -> Virus -> Mortal Virus
eat enemy { location, size, velocity } =
    Alive <| Virus location (size + transferableEnergy (enemy)) velocity


{-| Radius increase for a kill
-}
transferableEnergy : Virus -> Float
transferableEnergy { size } =
    size * 0.1



-- >>>>>>>>>>>>>>>>>>>>>> RANDOM


random : Virus -> Float -> Float -> Random.Generator Virus
random player boundaryRadius maxVelocity =
    let
        seed =
            { boundaryRadius = boundaryRadius
            , currentPosition = player.location
            , maxVelocity = maxVelocity
            , size = player.size
            }
    in
        Gen.one seed (safeCreate boundaryRadius)
