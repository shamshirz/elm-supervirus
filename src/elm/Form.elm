module Form exposing (..)

import Html exposing (Html, Attribute, footer, div, input, text, textarea)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit, onBlur)
import RemoteData exposing (WebData)
import Http


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- MODEL


type alias Model =
    { feedback : String
    , submitRequest : WebData ()
    }



-- INIT


init : ( Model, Cmd Msg )
init =
    { feedback = ""
    , submitRequest = RemoteData.NotAsked
    }
        ! []



-- UPDATE


type Msg
    = SubmitFeedback
    | SubmitCompleted (WebData ())
    | UpdateFeedback String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateFeedback newFeedback ->
            { model | feedback = newFeedback } ! []

        SubmitFeedback ->
            submit model

        SubmitCompleted ((RemoteData.Success _) as data) ->
            { model | feedback = "", submitRequest = data } ! []

        SubmitCompleted data ->
            { model | submitRequest = data } ! []


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
            |> Cmd.map SubmitCompleted


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



-- VIEW


view : Model -> Html Msg
view model =
    footer [ class "footer" ]
        [ div [ class "left-accent" ] [ text "Left side" ]
        , div [ class "center" ] [ feedbackSection model.feedback model.submitRequest ]
        , div [ class "right-accent" ] [ text "Left side" ]
        ]


feedbackSection : String -> WebData a -> Html Msg
feedbackSection text_ request =
    case request of
        RemoteData.Loading ->
            -- indicate that it's in flight
            feedback Nothing text_

        RemoteData.Failure reason ->
            feedback (Just "Yikes, tell Aaron!") text_

        RemoteData.Success _ ->
            feedback Nothing text_

        RemoteData.NotAsked ->
            feedback Nothing text_


feedback : Maybe String -> String -> Html Msg
feedback mMessage formText =
    let
        children =
            mMessage
                |> Maybe.map (\message -> [ userInput formText, formMessage message ])
                |> Maybe.withDefault [ userInput formText ]
    in
        Html.form [ class "feedback-form", onSubmit SubmitFeedback ]
            children


userInput : String -> Html Msg
userInput text_ =
    textarea
        [ id "textArea"
        , name "message"
        , onInput UpdateFeedback
        , onBlur SubmitFeedback
        , placeholder "Help me make this better, leave any thoughts here! (saves automatically)"
        , value text_
        ]
        []


formMessage : String -> Html Msg
formMessage message =
    div [ class "form-message" ]
        [ text message ]
