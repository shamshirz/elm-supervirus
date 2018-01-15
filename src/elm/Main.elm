module Main exposing (..)

import AnimationFrame
import Clock exposing (Clock)
import Config
import Html exposing (Html, div)
import Http
import Keyboard exposing (..)
import Keys exposing (Keys)
import Model as M exposing (Msg(..), Game(..), Model, Culture)
import Process
import Random
import RemoteData exposing (WebData)
import Task
import Time exposing (Time)
import View exposing (view)
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
    { feedback = ""
    , game = M.initGame
    , submitRequest = RemoteData.NotAsked
    }
        ! []



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        End ->
            { model | game = Win 0 } ! []

        FormUpdateFeedback newFeedback ->
            { model | feedback = newFeedback } ! []

        FormSubmitFeedback ->
            submit model

        FormSubmitCompleted ((RemoteData.Success _) as data) ->
            { model | feedback = "", submitRequest = data } ! [ resetDebouncer ]

        FormSubmitCompleted data ->
            { model | submitRequest = data } ! [ resetDebouncer ]

        FormResetRequest ->
            { model | submitRequest = RemoteData.NotAsked } ! []

        KeyDown 32 ->
            toggleState model

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

        Toggle ->
            toggleState model


toggleState : Model -> ( Model, Cmd Msg )
toggleState model =
    case model.game of
        GameOver _ ->
            startGame model

        Lobby ->
            startGame model

        Paused clock culture ->
            { model | game = Playing Keys.init clock culture } ! []

        Playing _ clock culture ->
            { model | game = Paused clock culture } ! []

        Win _ ->
            startGame model


startGame : Model -> ( Model, Cmd Msg )
startGame model =
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


resetDebouncer : Cmd Msg
resetDebouncer =
    Process.sleep (10000 * Time.millisecond)
        |> Task.perform (always <| FormResetRequest)


submit : Model -> ( Model, Cmd Msg )
submit ({ feedback } as model) =
    if feedback == "" then
        let
            _ =
                Debug.log "Submit: " "Not submitting, empty form"
        in
            model ! []
    else
        let
            _ =
                Debug.log "Submit: " feedback
        in
            { model | submitRequest = RemoteData.Loading } ! [ submitCmd feedback ]


submitCmd : String -> Cmd Msg
submitCmd formContent =
    let
        body2 =
            Http.stringBody "application/x-www-form-urlencoded" <|
                "form-name=feedback&message="
                    ++ toString (Http.encodeUri formContent)
    in
        formPost body2
            |> RemoteData.sendRequest
            |> Cmd.map FormSubmitCompleted


formPost : Http.Body -> Http.Request ()
formPost body =
    Http.request
        { method = "POST"
        , headers = [ Http.header "Content-Type" "application/x-www-form-urlencoded" ]
        , url = "/"
        , body = body
        , expect = Http.expectStringResponse (\_ -> Ok ())
        , timeout = Nothing
        , withCredentials = False
        }
