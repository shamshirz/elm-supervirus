module Model exposing (..)

import Clock exposing (Clock)
import Keys exposing (GameKey(..), Keys)
import Time exposing (Time)
import Virus exposing (BoundaryConflict(..), Mortal(..), Npc, Player)
import Config exposing (gameLoopPeriod, boundaryRadius, playerStartingSize, npcStartingSize)


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
    , player : Player
    , score : Int
    }



-- GAME submodel


newPlayer : Player
newPlayer =
    Virus.player


initGame : Game
initGame =
    Lobby


startGame : Game
startGame =
    Playing Keys.init (Clock.withPeriod gameLoopPeriod) <|
        Culture [] newPlayer 0


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
            movePlayer boundaryRadius keys player

        newNpcs =
            List.map (moveNpc boundaryRadius) npcs

        ( mortalVirus, remainingNpcs ) =
            Virus.resolveBattles newPlayer newNpcs
    in
        case mortalVirus of
            Dead ->
                GameOver score

            Alive virus ->
                Playing keys clock <| Culture remainingNpcs virus (score + 1)


movePlayer : Float -> Keys -> Player -> Player
movePlayer boundaryRadius keys player =
    player
        |> Virus.applyAcceleration (Keys.keysToTuple keys)
        |> Virus.move Slide boundaryRadius


moveNpc : Float -> Npc -> Npc
moveNpc boundaryRadius npc =
    npc
        |> Virus.move Bounce boundaryRadius



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
