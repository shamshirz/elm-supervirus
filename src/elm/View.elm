module View exposing (view)

import Color exposing (..)
import Collage
import Element
import Html exposing (Html, button, div, p, br, text, span, Attribute)
import Model exposing (..)
import Virus exposing (..)


view : Model -> Html Msg
view { game } =
    case game of
        GameOver score ->
            div [] [ text <| "Game over, your score was : " ++ (toString score) ]

        Playing culture ->
            displayCulture culture


displayCulture : Culture -> Html Msg
displayCulture { npcs, player, score } =
    div []
        [ banner player score
        , drawCharacters player npcs
        ]


banner : Virus -> Int -> Html Msg
banner player score =
    div []
        [ div [] [ Html.text <| "Position: " ++ (toString player.location) ]
        , div [] [ Html.text <| "Size: " ++ (toString player.size) ]
        , div [] [ Html.text <| "Score: " ++ (toString score) ]
        , br [] []
        ]


drawCharacters : Virus -> List Virus -> Html msg
drawCharacters playerVirus npcs =
    draw <| player playerVirus :: List.map npc npcs


draw : List Collage.Form -> Html msg
draw viruses =
    Element.toHtml <|
        Collage.collage 500 500 <|
            (petriDish :: viruses)


player : Virus -> Collage.Form
player virus =
    drawVirus Color.blue virus


npc : Virus -> Collage.Form
npc virus =
    drawVirus Color.green virus


petriDish : Collage.Form
petriDish =
    Collage.circle boundaryRadius
        |> Collage.outlined (Collage.solid Color.black)


drawVirus : Color.Color -> Virus -> Collage.Form
drawVirus color virus =
    let
        ( x, y ) =
            location virus
    in
        Collage.circle virus.size
            |> Collage.filled color
            |> Collage.move ( x, y )
