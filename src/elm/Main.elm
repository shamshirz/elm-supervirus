module Main exposing (..)

import AnimationFrame
import Clock exposing (Clock)
import Model exposing (Msg(..), Model, updateGame, endGame)
import Keys
import View exposing (view)
import Html exposing (div)
import Html exposing (Html)
import Keyboard exposing (..)
import Time exposing (Time)
import Random
import Virus exposing (Virus)
import Generator


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
subscriptions model =
    Sub.batch
        [ Keyboard.downs KeyDown
        , Keyboard.ups KeyUp
        , AnimationFrame.diffs TimeDelta
        ]



-- INIT


{-| milliseconds between frames
30 FPS
-}
gameLoopPeriod : Time.Time
gameLoopPeriod =
    33 * Time.millisecond


init : ( Model, Cmd Msg )
init =
    { clock = Clock.withPeriod gameLoopPeriod
    , keys = Keys.init
    , game = Model.initGame
    }
        ! [ populateCmd ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        End ->
            { model | game = endGame } ! []

        GetRandom virus ->
            model ! [ npcCmd virus ]

        KeyDown keyNum ->
            { model | keys = Keys.updateFromKeyCode keyNum True model.keys } ! []

        KeyUp keyNum ->
            { model | keys = Keys.updateFromKeyCode keyNum False model.keys } ! []

        Spawn npc ->
            Model.addNpc npc model ! []

        Populate npcs ->
            List.foldl Model.addNpc model npcs ! []

        TimeDelta dt ->
            let
                ( clock, newModel ) =
                    Clock.update tick dt model.clock model
            in
                { newModel | clock = clock } ! []


tick : Time -> Model -> Model
tick _ ({ keys, game } as model) =
    { model | game = updateGame keys game }


npcCmd : Virus -> Cmd Msg
npcCmd virus =
    Random.generate Spawn <| Generator.npc virus Model.boundaryRadius


populateCmd : Cmd Msg
populateCmd =
    Random.generate Populate <| Generator.startingNpcs Model.boundaryRadius 10
