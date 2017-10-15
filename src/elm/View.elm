module View exposing (view)

import Color exposing (..)
import Collage
import Element
import Html exposing (Html, button, div, p, br, text, span, Attribute)
import Location exposing (Location)
import Model exposing (Model, Msg(..))


view : Model.Model -> Html Msg
view ({ location } as model) =
    div []
        [ display model
        , drawCharacters model
        ]


display : Model -> Html Msg
display model =
    div []
        [ div [] [ Html.text "hello" ]
        , div [] [ Html.text <| "Position: " ++ (toString model.location) ]
        , div [] [ Html.text <| "Keys: " ++ (toString model.keys) ]
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


drawCharacters : Model -> Html msg
drawCharacters model =
    let
        main =
            model.location
                |> player
                |> (\pl -> { pl | color = playerColor model })

        npcs =
            List.map npc model.npcs
    in
        draw (main :: npcs)


draw : List Drawable -> Html msg
draw drawables =
    Element.toHtml <|
        Collage.collage 500 500 <|
            (List.map toCollageForm drawables)


player : Location.Location -> Drawable
player { x, y } =
    Drawable x y 10 Color.blue


npc : Location.Location -> Drawable
npc { x, y } =
    Drawable x y 10 Color.green


toCollageForm : Drawable -> Collage.Form
toCollageForm { x, y, r, color } =
    Collage.oval r r
        |> Collage.filled color
        |> Collage.move ( x, y )


playerColor : Model -> Color.Color
playerColor model =
    if not <| List.isEmpty <| Location.playerCollisions model.location model.npcs then
        Color.red
    else
        Color.blue
