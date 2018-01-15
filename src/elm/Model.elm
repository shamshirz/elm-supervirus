module Model exposing (..)

import Clock exposing (Clock)
import Config exposing (collisionMaxAge, gameLoopPeriod, boundaryRadius, playerStartingSize, npcStartingSize, metabolismCost, metabolismResting)
import Keys exposing (GameKey(..), Keys)
import Math.Vector2 as Vector2 exposing (Vec2)
import Time exposing (Time)
import Virus exposing (BoundaryConflict(..), Mortal(..), Npc, Player)


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
    | Win Int


type alias Culture =
    { collisions : List Collision
    , npcs : List Npc
    , player : Player
    }


{-| Collision location magnitude age
-}
type Collision
    = Collision Vec2 Float Float


collisionLocation : Collision -> ( Float, Float )
collisionLocation (Collision location _ _) =
    Vector2.toTuple location



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
        Culture [] [] newPlayer


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
updatePlayingState keys clock { collisions, npcs, player } =
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

        isDefeated npc =
            not <| List.any (\vir -> vir.location == npc.location) mergedNpcs

        newCollisions =
            List.filter (isDefeated) newNpcs
                |> List.map (\{ location, size } -> Collision location size 0)
                |> List.foldl (::) collisions
                |> List.filterMap chronicalCollision
    in
        case mortalVirus of
            Dead ->
                GameOver <| round player.prowess

            Alive virus ->
                if virus.size >= (boundaryRadius * 0.6) then
                    Win <| round player.prowess
                else
                    Playing keys clock <| Culture newCollisions mergedNpcs virus


chronicalCollision : Collision -> Maybe Collision
chronicalCollision (Collision location magnitude age) =
    if age >= collisionMaxAge then
        Nothing
    else
        Just <| Collision location magnitude (age + 1)


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
        Playing keys clock culture ->
            { model | game = Playing keys clock (addNpcToCulture npc culture) }

        _ ->
            model


addNpcToCulture : Npc -> Culture -> Culture
addNpcToCulture npc culture =
    { culture | npcs = npc :: culture.npcs }
