module Main exposing (..)

import AnimationFrame
import Clock exposing (Clock)
import Model exposing (Msg(..))
import Location
import Keys
import View exposing (display, playZone)
import Html exposing (div)
import Html exposing (Html)
import Keyboard exposing (..)
import Time exposing (Time)


main : Program Never Model.Model Msg
main =
    Html.program
        { init = Model.init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- SUBSCRIPTIONS


subscriptions : Model.Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs KeyDown
        , Keyboard.ups KeyUp
        , AnimationFrame.diffs TimeDelta
        ]



-- UPDATE


update : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
update msg model =
    case msg of
        TimeDelta dt ->
            let
                ( clock, newModel ) =
                    Clock.update tick dt model.clock model
            in
                { newModel | clock = clock } ! []

        KeyDown keyNum ->
            { model | keys = Keys.updateKeys (Keys.Down keyNum) model.keys } ! []

        KeyUp keyNum ->
            { model | keys = Keys.updateKeys (Keys.Up keyNum) model.keys } ! []


tick : Time -> Model.Model -> Model.Model
tick _ model =
    Model.updateLocation model


view : Model.Model -> Html Msg
view ({ location } as model) =
    div []
        [ display model
        , playZone (Location.unwrapLocation location)
        ]
