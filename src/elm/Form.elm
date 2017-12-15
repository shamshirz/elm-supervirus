module Form exposing (..)

import Html exposing (Html, Attribute, footer, div, input, text, textarea)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit, onBlur)
import RemoteData exposing (WebData)
import Http
import Json.Decode as Decode


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
    , formName : String
    , submitRequest : WebData String
    }


formToUrl : Model -> String
formToUrl { feedback, formName } =
    "/?" ++ "form-name=" ++ Http.encodeUri formName ++ "&feedback=" ++ Http.encodeUri feedback


postCmd : String -> Cmd Msg
postCmd address =
    Http.post address Http.emptyBody (Decode.field "data" Decode.string)
        |> RemoteData.sendRequest
        |> Cmd.map SubmitCompleted



-- INIT


init : ( Model, Cmd Msg )
init =
    { feedback = ""
    , formName = "feedback-form"
    , submitRequest = RemoteData.NotAsked
    }
        ! []



-- UPDATE


type Msg
    = SubmitFeedback
    | SubmitCompleted (WebData String)
    | UpdateFeedback String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateFeedback newFeedback ->
            { model | feedback = newFeedback } ! []

        SubmitFeedback ->
            let
                _ =
                    Debug.log "Submit" model
            in
                model ! []

        SubmitCompleted data ->
            let
                _ =
                    Debug.log "Response data" data
            in
                model ! []



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
    Html.form [ class "feedback-form", onSubmit SubmitFeedback ]
        [ textarea
            [ id "textArea"
            , onInput UpdateFeedback
            , onBlur SubmitFeedback
            , placeholder "Help me make this better, leave any thoughts here! (saves automatically)"
            ]
            [ text text_ ]
        ]
