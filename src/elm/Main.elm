module Main exposing (..)

import AnimationFrame
import Clock exposing (Clock)
import Model exposing (Msg(..), Model, updateGame, endGame, init)
import Keys
import View exposing (view)
import Html exposing (div)
import Html exposing (Html)
import Keyboard exposing (..)
import Time exposing (Time)


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



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        End ->
            { model | game = endGame } ! []

        TimeDelta dt ->
            let
                ( clock, newModel ) =
                    Clock.update tick dt model.clock model
            in
                { newModel | clock = clock } ! []

        KeyDown keyNum ->
            { model | keys = Keys.updateFromKeyCode keyNum True model.keys } ! []

        KeyUp keyNum ->
            { model | keys = Keys.updateFromKeyCode keyNum False model.keys } ! []


tick : Time -> Model -> Model
tick _ ({ keys, game } as model) =
    { model | game = updateGame keys game }
