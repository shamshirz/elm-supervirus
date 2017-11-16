module Model exposing (..)

import Clock exposing (Clock)
import Keys exposing (GameKey(..), Keys)
import Time exposing (Time)
import Virus exposing (..)


type Msg
    = End
    | GetRandom Virus
    | KeyDown Int
    | KeyUp Int
    | Populate (List Npc)
    | Spawn Npc
    | StartGame
    | TimeDelta Time


type alias Model =
    { clock : Clock
    , keys : Keys.Keys
    , game : Game
    }


type Game
    = GameOver Int
    | Lobby
    | Playing Culture


type alias Culture =
    { npcs : List Npc
    , player : Virus
    , score : Int
    }


initGame : Game
initGame =
    Lobby


startGame : Game
startGame =
    Playing <| Culture [] (player boundaryRadius) 0


boundaryRadius : Float
boundaryRadius =
    100


endGame : Game
endGame =
    GameOver 0


updateGame : Keys -> Game -> Game
updateGame keys game =
    case game of
        GameOver score ->
            GameOver score

        Lobby ->
            Lobby

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



-- Spawn


addNpc : Npc -> Model -> Model
addNpc npc model =
    case model.game of
        GameOver _ ->
            model

        Lobby ->
            model

        Playing culture ->
            { model | game = Playing (addNpcToCulture npc culture) }


addNpcToCulture : Npc -> Culture -> Culture
addNpcToCulture npc culture =
    { culture | npcs = npc :: culture.npcs }
