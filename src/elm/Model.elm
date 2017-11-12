module Model exposing (..)

import Clock exposing (Clock)
import Keys exposing (GameKey(..), Keys)
import Time exposing (Time)
import Virus exposing (..)
import Math.Vector2 as Vector2
import Random exposing (Generator)


-- 30 FPS


gameLoopPeriod : Time.Time
gameLoopPeriod =
    33 * Time.millisecond


type Msg
    = End
    | GetRandom Virus
    | KeyDown Int
    | KeyUp Int
    | Spawn Npc
    | TimeDelta Time


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



-- GetRandom


randomNpc : Virus -> Generator Npc
randomNpc virus =
    let
        randomSize =
            Random.float (virus.size - 1) (virus.size + 1)

        randomLocation =
            randomPosition virus
    in
        Random.map3 (makeNpc boundaryRadius) randomSize randomLocation randomVelocity


randomPosition : Virus -> Generator Vector2.Vec2
randomPosition { location } =
    let
        ( ( minX, maxX ), ( minY, maxY ) ) =
            rangeOutsideMyQuad location

        outsideMyQuad =
            Random.pair (Random.float minX maxX) (Random.float minY maxY)
    in
        outsideMyQuad |> Random.map (\pair -> Vector2.fromTuple pair)


randomVelocity : Generator Vector2.Vec2
randomVelocity =
    Random.pair (Random.float -4 4) (Random.float -4 4)
        |> Random.map (\pair -> Vector2.fromTuple pair)


rangeOutsideMyQuad : Vector2.Vec2 -> ( ( Float, Float ), ( Float, Float ) )
rangeOutsideMyQuad myPosition =
    let
        ( x, y ) =
            Vector2.toTuple myPosition

        xRange =
            if x > 0 then
                ( -1 * boundaryRadius, 0 )
            else
                ( 0, boundaryRadius )

        yRange =
            if y > 0 then
                ( -1 * boundaryRadius, 0 )
            else
                ( 0, boundaryRadius )
    in
        ( xRange, yRange )



-- Spawn


addNpc : Npc -> Model -> Model
addNpc npc model =
    case model.game of
        GameOver _ ->
            model

        Playing culture ->
            { model | game = Playing (addNpcToCulture npc culture) }


addNpcToCulture : Npc -> Culture -> Culture
addNpcToCulture npc culture =
    { culture | npcs = npc :: culture.npcs }
