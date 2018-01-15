module Main exposing (..)

import AnimationFrame
import Clock exposing (Clock)
import Config
import Model as M exposing (Msg(..), Game(..), Model, Culture)
import Keys exposing (Keys)
import View exposing (view)
import Html exposing (div)
import Html exposing (Html)
import Keyboard exposing (..)
import Time exposing (Time)
import Random
import Virus exposing (Player, Npc)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions { game } =
    case game of
        Playing _ _ _ ->
            Sub.batch
                [ Keyboard.downs KeyDown
                , Keyboard.ups KeyUp
                , AnimationFrame.diffs TimeDelta
                ]

        _ ->
            Sub.batch [ Keyboard.downs KeyDown ]



-- INIT


init : ( Model, Cmd Msg )
init =
    { game = M.initGame } ! []



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        End ->
            { model | game = Win 0 } ! []

        KeyDown 32 ->
            startGame model

        KeyDown keyNum ->
            handleKeyAction keyNum True model

        KeyUp keyNum ->
            handleKeyAction keyNum False model

        Spawn npc ->
            M.addNpc npc model ! []

        StartGame ->
            startGame model

        Populate npcs ->
            List.foldl M.addNpc model npcs ! []

        TimeDelta dt ->
            handleClockTick dt model


startGame : Model -> ( Model, Cmd Msg )
startGame model =
    case model.game of
        Playing _ _ _ ->
            model ! []

        Lobby ->
            { model | game = M.startGame } ! [ populateCmd ]

        GameOver _ ->
            { model | game = M.startGame } ! [ populateCmd ]

        Win _ ->
            { model | game = M.startGame } ! [ populateCmd ]


handleKeyAction : Int -> Bool -> Model -> ( Model, Cmd Msg )
handleKeyAction keyNum isDown model =
    case model.game of
        Playing keys _ _ ->
            { model | game = M.mapKeys (Keys.updateFromKeyCode keyNum isDown keys) model.game } ! []

        _ ->
            model ! []


handleClockTick : Time -> Model -> ( Model, Cmd Msg )
handleClockTick delta model =
    case model.game of
        Playing keys clock culture ->
            let
                ( newClock, newModel ) =
                    Clock.update (tick keys clock culture) delta clock model
            in
                { newModel | game = M.mapClock newClock newModel.game } ! [ sustainPopulation model newModel ]

        _ ->
            model ! []


tick : Keys -> Clock -> Culture -> Time -> Model -> Model
tick keys clock culture _ model =
    { model | game = M.updatePlayingState keys clock culture }



-- CMDs


npcCmd : Player -> Cmd Msg
npcCmd virus =
    Random.generate Spawn <| Virus.random virus Config.boundaryRadius Config.maxNpcVelocity


populateCmd : Cmd Msg
populateCmd =
    Random.generate Populate <|
        Random.list 10
            (Virus.random (Virus.player) Config.boundaryRadius Config.maxNpcVelocity)


sustainPopulation : Model -> Model -> Cmd Msg
sustainPopulation lastState currentState =
    case ( lastState.game, currentState.game ) of
        ( Playing _ _ lastTick, Playing _ _ thisTick ) ->
            let
                lastNpcs =
                    List.length lastTick.npcs

                thisNpcs =
                    List.length thisTick.npcs
            in
                if lastNpcs > thisNpcs then
                    npcCmd thisTick.player
                else
                    Cmd.none

        _ ->
            Cmd.none
