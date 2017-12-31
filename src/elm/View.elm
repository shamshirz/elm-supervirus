module View exposing (view)

import Config exposing (boundaryRadius)
import Color exposing (..)
import Collage
import Element
import Html exposing (Html, button, div, p, br, h2, img, text, span, Attribute)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Model exposing (..)
import Virus exposing (..)


view : Model -> Html Msg
view { game } =
    case game of
        GameOver score ->
            centered []
                [ text <| "Game over, your score was : " ++ (toString score)
                , playGif
                ]

        Lobby ->
            centered []
                [ intro ]

        Playing _ _ culture ->
            centered []
                [ div [] [ Html.button [ onClick End ] [ text "End" ] ]
                , displayCulture culture
                ]


centered : List (Html.Attribute msg) -> List (Html msg) -> Html msg
centered attrs children =
    div (class "centered" :: attrs) children


displayCulture : Culture -> Html Msg
displayCulture { npcs, player } =
    div []
        [ banner player
        , drawCharacters player npcs
        ]


banner : Player -> Html Msg
banner player =
    div []
        [ div [] [ Html.text <| "Position: " ++ (toString player.location) ]
        , div [] [ Html.text <| "Size: " ++ (toString player.size) ]
        , div [] [ Html.text <| "Score: " ++ (toString <| round player.prowess) ]
        , div [] [ Html.text <| "Metabolism: " ++ (toString player.metabolism) ]
        , br [] []
        ]


drawCharacters : Player -> List Npc -> Html msg
drawCharacters playerVirus npcs =
    draw <| player playerVirus :: List.map npc npcs


draw : List Collage.Form -> Html msg
draw viruses =
    Element.toHtml <|
        Collage.collage 500 500 <|
            (petriDish :: viruses)


player : Player -> Collage.Form
player playerVirus =
    let
        intensity =
            round (playerVirus.metabolism * 75)

        red =
            min (20 + intensity) 255

        others =
            max (50 - intensity) 0

        color =
            Color.rgb red others others
    in
        drawVirus color playerVirus


npc : Npc -> Collage.Form
npc =
    drawVirus <| Color.rgb 94 233 59


petriDish : Collage.Form
petriDish =
    Collage.circle boundaryRadius
        |> Collage.outlined (Collage.solid Color.black)


drawVirus : Color.Color -> Virus a -> Collage.Form
drawVirus color virus =
    let
        ( x, y ) =
            location virus
    in
        Collage.circle virus.size
            |> Collage.filled color
            |> Collage.move ( x, y )


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
