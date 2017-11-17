module Model exposing (..)

import Clock exposing (Clock)
import Keys exposing (GameKey(..), Keys)
import Time exposing (Time)
import Virus exposing (..)
import Config exposing (gameLoopPeriod, boundaryRadius)


type Msg
    = End
    | KeyDown Int
    | KeyUp Int
    | Populate (List Npc)
    | Spawn Npc
    | StartGame
    | TimeDelta Time


type alias Model =
    { game : Game
    }


type Game
    = GameOver Int
    | Lobby
    | Playing Keys Clock Culture


type alias Culture =
    { npcs : List Npc
    , player : Virus
    , score : Int
    }



-- GAME submodel


initGame : Game
initGame =
    Lobby


startGame : Game
startGame =
    Playing Keys.init (Clock.withPeriod gameLoopPeriod) <| Culture [] (player boundaryRadius) 0


endGame : Game
endGame =
    GameOver 0


mapKeys : Keys -> Game -> Game
mapKeys keys game =
    case game of
        Playing _ clock culture ->
            Playing keys clock culture

        _ ->
            game


mapClock : Clock -> Game -> Game
mapClock incomingClock game =
    case game of
        Playing keys _ culture ->
            Playing keys incomingClock culture

        _ ->
            game


updatePlayingState : Keys -> Clock -> Culture -> Game
updatePlayingState keys clock { npcs, player, score } =
    let
        newPlayer =
            move (Keys.keysToTuple keys) boundaryRadius player

        newNpcs =
            updateNpcs boundaryRadius npcs
    in
        handleCollisions keys clock score newPlayer newNpcs


updateNpcs : Float -> List Npc -> List Npc
updateNpcs boundaryRadius npcs =
    List.map (updateNpc boundaryRadius) npcs



-- I'm bloated, clean me!


handleCollisions : Keys -> Clock -> Int -> Virus -> List Npc -> Game
handleCollisions keys clock score player npcs =
    let
        ( mortalVirus, remainingNpcs ) =
            Virus.handleCollisions player npcs
    in
        case mortalVirus of
            Dead ->
                GameOver score

            Alive virus ->
                Playing keys clock <| Culture remainingNpcs virus (score + 1)



-- Spawn


addNpc : Npc -> Model -> Model
addNpc npc model =
    case model.game of
        GameOver _ ->
            model

        Lobby ->
            model

        Playing keys clock culture ->
            { model | game = Playing keys clock (addNpcToCulture npc culture) }


addNpcToCulture : Npc -> Culture -> Culture
addNpcToCulture npc culture =
    { culture | npcs = npc :: culture.npcs }
