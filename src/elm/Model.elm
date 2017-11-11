module Model exposing (..)

import Clock exposing (Clock)
import Keys exposing (GameKey(..), Keys)
import Time exposing (Time)
import Virus exposing (..)
import Math.Vector2 as Vector2


-- 30 FPS


gameLoopPeriod : Time.Time
gameLoopPeriod =
    33 * Time.millisecond


type Msg
    = KeyDown Int
    | KeyUp Int
    | TimeDelta Time
    | End


type alias Model =
    { clock : Clock
    , keys : Keys.Keys
    , game : Game
    }


type Game
    = Playing Culture
    | GameOver Int


type alias Culture =
    { npcs : List Npc
    , player : Virus
    , score : Int
    }


boundaryRadius : Float
boundaryRadius =
    100


createNpcs : List Npc
createNpcs =
    [ npc boundaryRadius
    , npc boundaryRadius |> setVelocity (Vector2.vec2 1 3)
    , npc boundaryRadius |> setVelocity (Vector2.vec2 -1 1)
    , npc boundaryRadius |> setVelocity (Vector2.vec2 -3 4)
    , npc boundaryRadius |> setVelocity (Vector2.vec2 0.5 1.3)
    , npc boundaryRadius |> setVelocity (Vector2.vec2 0.9 -0.2)
    ]


init : ( Model, Cmd Msg )
init =
    { clock = Clock.withPeriod gameLoopPeriod
    , keys = Keys.init
    , game = Playing <| Culture createNpcs (player boundaryRadius) 0
    }
        ! []


endGame : Game
endGame =
    GameOver 0


updateGame : Keys -> Game -> Game
updateGame keys game =
    case game of
        GameOver score ->
            GameOver score

        Playing culture ->
            culture
                |> updateCulture keys


updateCulture : Keys -> Culture -> Game
updateCulture keys { npcs, player, score } =
    let
        newPlayer =
            move (Keys.keysToTuple keys) boundaryRadius player

        newNpcs =
            updateNpcs boundaryRadius npcs
    in
        handleCollisions score newPlayer newNpcs


{-| updateNpcs
This is the place where the magic AI happens
probably just bounce at the reflected angle off the walls
Which would mean I need to track trajectory
-}
updateNpcs : Float -> List Npc -> List Npc
updateNpcs boundaryRadius npcs =
    List.map (updateNpc boundaryRadius) npcs


handleCollisions : Int -> Virus -> List Npc -> Game
handleCollisions score player npcs =
    let
        ( mortalVirus, remainingNpcs ) =
            Virus.handleCollisions player npcs
    in
        case mortalVirus of
            Dead ->
                GameOver score

            Alive virus ->
                Playing <| Culture remainingNpcs virus (score + 1)
