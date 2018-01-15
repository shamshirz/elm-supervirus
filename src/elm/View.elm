module View exposing (view)

import Html exposing (Html, button, div, p, br, h2, header, img, text, span, Attribute)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Model exposing (..)
import View.Game
import View.Form


view : Model -> Html Msg
view ({ game } as model) =
    case game of
        GameOver score ->
            pageBody model <| gameOver score

        Lobby ->
            pageBody model intro

        Paused clock culture ->
            -- Maybe show stats here
            pageBody model <| paused culture

        Playing _ _ culture ->
            pageBody model <| playing culture

        Win score ->
            pageBody model <| centered [] (winView score)


pageBody : Model -> Html Msg -> Html Msg
pageBody model body =
    div [ class "main" ]
        [ pageHeader
        , div [ class "game" ] [ body ]
        , View.Form.view model
        ]


pageHeader : Html Msg
pageHeader =
    header []
        [ div [ class "background__header" ] []
        , div [ class "header" ] [ text "2upervirus: Evolution" ]
        ]


centered : List (Html.Attribute msg) -> List (Html msg) -> Html msg
centered attrs children =
    div (class "centered" :: attrs) children


intro : Html msg
intro =
    div [ class "intro" ]
        [ div []
            [ text "You are the second most lethal virus in the world, conquer the univers (pitri dish). Feed your insatiable hunger by eating lesser organisms."
            , br [] []
            , br [] []
            , text "Tip: Keep your metabilism cranking, it will help you survive."
            ]
        , controls
        , playGif
        ]


paused : Culture -> Html Msg
paused culture =
    centered []
        [ div [] [ Html.button [ onClick End ] [ text "End" ] ]
        , View.Game.view culture
        , pauseText
        ]


pauseText : Html msg
pauseText =
    div [ class "paused" ] [ text "Paused" ]


playing : Culture -> Html Msg
playing culture =
    centered []
        [ div [] [ Html.button [ onClick End ] [ text "End" ] ]
        , View.Game.view culture
        ]


gameOver : Int -> Html msg
gameOver score =
    centered []
        [ text <| "Game over, your score was : " ++ (toString score)
        , playGif
        ]


controls : Html msg
controls =
    div [ class "controls" ]
        [ h2 [] [ text "Controls" ]
        , text "use WASD to move around the pitri dish"
        , text "Beware of anything larger than yourself!"
        ]


playGif : Html msg
playGif =
    div [ class "play-gif" ]
        [ text "Hit space to play!"
        , img [ src "static/img/pressspace.gif" ] []
        ]


winView : Int -> List (Html Msg)
winView score =
    [ span [ class "win-congrats" ] [ text "Congrats" ]
    , span [ class "win-body" ]
        [ text <| "Score: " ++ (toString score)
        , br [] []
        , br [] []
        , text "You Won…Didn't actually think this was possibre."
        , br [] []
        , text "Seriously though, tell Aaron, send a screenshot. He will buy you a cookie."
        ]
    ]
