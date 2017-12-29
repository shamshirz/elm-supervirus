module Virus
    exposing
        ( applyAcceleration
        , BoundaryConflict(..)
        , location
        , Mortal(..)
        , move
        , Npc
        , Player
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
import Config exposing (acceleration, playerStartingSize, maxVelocity, dragPercentage, transferableEnergy)


{-| Base type
-}
type alias Virus a =
    { a
        | location : Vec2
        , size : Float
        , velocity : Vec2
    }


type alias Npc =
    Virus {}


type alias Player =
    Virus
        { metabolism : Float
        , prowess : Float
        }



-- >>>>>>>>>>>>>>>>>>>>>> CREATION


player : Player
player =
    { location = Vector2.vec2 0 0
    , size = playerStartingSize
    , velocity = Vector2.vec2 0 0
    , metabolism = 1
    , prowess = 0
    }


npc : Vec2 -> Float -> Vec2 -> Npc
npc location size velocity =
    { location = location
    , size = size
    , velocity = velocity
    }


safeCreate : Float -> Vec2 -> Float -> Vec2 -> Npc
safeCreate boundaryRadius location size velocity =
    npc location size velocity
        |> scaleWithinBoundary boundaryRadius


scaleWithinBoundary : Float -> Virus a -> Virus a
scaleWithinBoundary boundaryRadius virus =
    { virus | location = Math2D.scaleWithinBoundary boundaryRadius virus.size virus.location }



-- >>>>>>>>>>>>>>>>>>>>>> GETTERS


location : Virus a -> ( Float, Float )
location { location } =
    Vector2.toTuple location



-- >>>>>>>>>>>>>>>>>>>>>> UPDATES


applyAcceleration : ( Float, Float ) -> Player -> Player
applyAcceleration delta ({ location, size, velocity, metabolism } as player) =
    delta
        |> Vector2.fromTuple
        |> Vector2.scale (metabolism * acceleration)
        |> Vector2.add velocity
        |> limitVelocity
        |> applyDrag
        |> (\newVel -> { player | velocity = newVel })


{-| scale velocity down proportionally to the amount of drag
…or should drag be a constant? no proportional
-}
applyDrag : Vec2 -> Vec2
applyDrag vel =
    vel
        |> Vector2.scale (1 - dragPercentage)


limitVelocity : Vec2 -> Vec2
limitVelocity vel =
    let
        ( dx, dy ) =
            Vector2.toTuple vel
    in
        Vector2.vec2 (limit dx) (limit dy)


limit : Float -> Float
limit x =
    if x > maxVelocity then
        maxVelocity
    else if x < (-1 * maxVelocity) then
        -1 * maxVelocity
    else
        x



-- >>>>>>>>>>>>>>>>>>>>>> MOVEMENT
-- move is the public API, pass a conflict type
-- delegated to one of the internal functions


type BoundaryConflict
    = Bounce
    | Slide


move : BoundaryConflict -> Float -> Virus a -> Virus a
move onConflict boundaryRadius mover =
    case onConflict of
        Bounce ->
            moveWithBounce boundaryRadius mover

        Slide ->
            moveWithSlide boundaryRadius mover


{-| Bounce off of interior of boundary
-}
moveWithBounce : Float -> Virus a -> Virus a
moveWithBounce boundaryRadius ({ velocity, size, location } as virus) =
    let
        ( newLoc, newVel ) =
            Math2D.moveWithBounce location velocity (boundaryRadius - size)
    in
        { virus | location = newLoc, velocity = newVel }


{-| negate all velocity toward boundary
Project onto the tangent to the circle.
-}
moveWithSlide : Float -> Virus a -> Virus a
moveWithSlide boundaryRadius ({ velocity, size, location } as virus) =
    let
        ( newLoc, newVel ) =
            Math2D.moveWithSlide location velocity (boundaryRadius - size)
    in
        { virus | location = newLoc, velocity = newVel }


{-| move, and if outside the boundary
scale it back in directly towards origin
-}
moveAndScale : Float -> Virus a -> Virus a
moveAndScale boundaryRadius ({ location, size, velocity } as virus) =
    { virus | location = Vector2.add velocity location }
        |> scaleWithinBoundary boundaryRadius



-- >>>>>>>>>>>>>>>>>>>>>> BATTLES


type Mortal a
    = Alive a
    | Dead


{-| resolveBattles
Determines which NPCs are battled (partion yields (collided, nonCollided))
Resolve each battle. Fold all battles on to our Mortal Virus
Return the new Mortal virus and uncollided Viruss
-}
resolveBattles : Player -> List (Virus a) -> ( Mortal Player, List (Virus a) )
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
battle : Virus a -> Mortal Player -> Mortal Player
battle enemy mortalPlayer =
    case mortalPlayer of
        Alive player ->
            if player.size >= enemy.size then
                Alive (player |> eat enemy)
            else
                Dead

        Dead ->
            Dead


{-| When we eat we must do several things

1.  Increase our size based on how much energy the victim yields
2.  Increase our prowess based on the difficulty of the enemy
3.  Increase our metabolism based on the difficulty of the enemy

-}
eat : Virus a -> Player -> Player
eat enemy ({ location, size, velocity } as player) =
    let
        difficulty =
            relativeDifficulty player enemy
    in
        { player
            | metabolism = player.metabolism + difficulty
            , prowess = player.prowess + (100 * difficulty * player.metabolism)
            , size = size + metabolize enemy
        }


type alias Sizable a =
    { a | size : Float }


{-| Radius increase for a kill
-}
metabolize : { a | size : Float } -> Float
metabolize { size } =
    size * transferableEnergy


{-| Scoring system from [0 - 1]
-}
relativeDifficulty : Sizable a -> Sizable b -> Float
relativeDifficulty player npc =
    npc.size / player.size



-- >>>>>>>>>>>>>>>>>>>>>> RANDOM


random : Virus a -> Float -> Float -> Random.Generator Npc
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
