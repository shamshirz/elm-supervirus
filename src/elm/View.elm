module View exposing (display, draw)

import Color exposing (..)
import Collage
import Element
import Html exposing (Html, button, div, p, br, text, span, Attribute)
import Model exposing (Model, Msg(..))


display : Model -> Html Msg
display model =
    div []
        [ div [] [ Html.text "hello" ]
        , div [] [ Html.text <| "Position: " ++ (toString model.location) ]
        , div [] [ Html.text <| "Keys: " ++ (toString model.keys) ]
        , br [] []
        ]


type alias Drawable a =
    { a | x : Float, y : Float }



-- elm graphics implementation


draw : List (Drawable a) -> Html msg
draw drawables =
    Element.toHtml <|
        Collage.collage 500 500 <|
            List.map drawableToForm drawables


drawableToForm : Drawable a -> Collage.Form
drawableToForm drawable =
    Collage.oval 10 10
        |> Collage.filled Color.blue
        |> Collage.move ( drawable.x, drawable.y )
