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



-- elm graphics implementation
-- Steps
-- Do some logic (is collision? and what happens if so?)


type alias Drawable =
    { x : Float
    , y : Float
    , r : Float
    , color : Color.Color
    }


drawCharacters : Virus -> List Virus -> Html msg
drawCharacters playerVirus npcs =
    let
        playerDrawable =
            player playerVirus

        npcDrawables =
            List.map npc npcs
    in
        draw (playerDrawable :: npcDrawables)


draw : List Drawable -> Html msg
draw drawables =
    Element.toHtml <|
        Collage.collage 500 500 <|
            (petriDish
                :: (List.map toCollageForm drawables)
            )


petriDish : Collage.Form
petriDish =
    Collage.circle boundaryRadius
        |> Collage.outlined (Collage.solid Color.black)


player : Virus -> Drawable
player virus =
    virusToDrawable virus Color.blue


npc : Virus -> Drawable
npc virus =
    virusToDrawable virus Color.green


virusToDrawable : Virus -> Color.Color -> Drawable
virusToDrawable virus color =
    let
        { x, y } =
            location virus
    in
        { x = x
        , y = y
        , r = virus.size
        , color = color
        }


toCollageForm : Drawable -> Collage.Form
toCollageForm { x, y, r, color } =
    Collage.circle r
        |> Collage.filled color
        |> Collage.move ( x, y )
