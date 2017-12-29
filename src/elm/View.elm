module View exposing (view)

import Config exposing (boundaryRadius)
import Color exposing (..)
import Collage
import Element
import Html exposing (Html, button, div, p, br, text, span, Attribute)
import Html.Events exposing (onClick)
import Model exposing (..)
import Virus exposing (..)


view : Model -> Html Msg
view { game } =
    case game of
        GameOver score ->
            div []
                [ text <| "Game over, your score was : " ++ (toString score)
                , div [] [ Html.button [ onClick StartGame ] [ text "Restart" ] ]
                ]

        Lobby ->
            div []
                [ text "Welcome to 2uperVirus!"
                , div [] [ Html.button [ onClick StartGame ] [ text "Start" ] ]
                ]

        Playing _ _ culture ->
            div []
                [ div [] [ Html.button [ onClick End ] [ text "End" ] ]
                , displayCulture culture
                ]


displayCulture : Culture -> Html Msg
displayCulture { npcs, player, score } =
    div []
        [ banner player score
        , drawCharacters player npcs
        ]


banner : Virus a -> Int -> Html Msg
banner player score =
    div []
        [ div [] [ Html.text <| "Position: " ++ (toString player.location) ]
        , div [] [ Html.text <| "Size: " ++ (toString player.size) ]
        , div [] [ Html.text <| "Score: " ++ (toString score) ]
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
player =
    drawVirus Color.blue


npc : Npc -> Collage.Form
npc =
    drawVirus Color.darkRed


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
