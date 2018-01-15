module Model exposing (..)

import Clock exposing (Clock)
import Keys exposing (GameKey(..), Keys)
import Time exposing (Time)
import Virus exposing (BoundaryConflict(..), Mortal(..), Npc, Player)
import Config exposing (gameLoopPeriod, boundaryRadius, playerStartingSize, npcStartingSize, metabolismCost, metabolismResting)


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
        Culture [] newPlayer


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
updatePlayingState keys clock { npcs, player } =
    let
        newPlayer =
            player
                |> movePlayer boundaryRadius keys
                |> reduceMetabolism

        newNpcs =
            List.map (moveNpc boundaryRadius) npcs

        ( mortalVirus, remainingNpcs ) =
            Virus.resolveBattles newPlayer newNpcs

        mergedNpcs =
            Virus.mergeNpcs [] remainingNpcs
    in
        case mortalVirus of
            Dead ->
                GameOver <| round player.prowess

            Alive virus ->
                Playing keys clock <| Culture mergedNpcs virus


{-| Reduces the metabolism towards a resting rate
This has a greater impact the higher the metabolism is from resting
change in metabolism is =
((current - resting) * .01)
This way your metabolism will never go below the resting, and it will
be more challenging the higher your metabolism (aka the better your combo)
-}
reduceMetabolism : Player -> Player
reduceMetabolism player =
    { player
        | metabolism = player.metabolism - ((player.metabolism - metabolismResting) * metabolismCost)
    }


movePlayer : Float -> Keys -> Player -> Player
movePlayer boundaryRadius keys player =
    player
        |> Virus.applyAcceleration (Keys.keysToTuple keys)
        |> Virus.move Bounce boundaryRadius


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
