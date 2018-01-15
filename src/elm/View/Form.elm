module View.Form exposing (view)

import Html exposing (Html, Attribute, a, footer, div, img, input, text, textarea)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit, onBlur)
import RemoteData exposing (WebData)
import Model exposing (Model, Msg(..))


view : Model -> Html Msg
view model =
    div [ class "footer" ]
        [ div [ class "left-side" ]
            [ left ]
        , div [ class "center" ]
            [ center model ]
        , div [ class "right-side" ]
            [ right ]
        ]


left : Html Msg
left =
    div [ class "background__left" ]
        [ a [ class "git-link", href "https://github.com/shamshirz/elm-supervirus/" ]
            [ text "Shamshirz" ]
        ]


right : Html Msg
right =
    div [ class "background__right" ]
        [ a [ class "logo", href "http://samgqroberts.com/sylverstudios/" ]
            [ img [ src "static/img/sylverbar100.png", target "_blank", alt "AgStudios" ] [] ]
        ]


center : Model -> Html Msg
center { feedback, submitRequest } =
    case submitRequest of
        RemoteData.Loading ->
            -- indicate that it's in flight
            feedbackForm feedback (overlayMessage "Sending…")

        RemoteData.Failure reason ->
            feedbackForm feedback (overlayMessage "That didn't work as planned… Try it again in a sec")

        RemoteData.Success _ ->
            feedbackForm feedback (overlayMessage "Thanks!")

        RemoteData.NotAsked ->
            feedbackForm feedback []


feedbackForm : String -> List (Html Msg) -> Html Msg
feedbackForm formText children =
    Html.form [ class "feedback-form", onSubmit FormSubmitFeedback ] <|
        (userInput formText)
            :: children


overlayMessage : String -> List (Html Msg)
overlayMessage text_ =
    [ div [ class "request-overlay" ] [ text text_ ] ]


userInput : String -> Html Msg
userInput text_ =
    textarea
        [ id "textArea"
        , name "message"
        , onInput FormUpdateFeedback
        , onBlur FormSubmitFeedback
        , placeholder "Help me make this better, leave any thoughts here! (saves automatically)"
        , value text_
        ]
        []


formMessage : String -> Html Msg
formMessage message =
    div [ class "form-message" ]
        [ text message ]
