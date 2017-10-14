module View exposing (view)

import Color exposing (..)
import Collage
import Element
import Html exposing (Html, button, div, p, br, text, span, Attribute)
import Location
import Model exposing (Model, Msg(..))


-- Testing

import Collision2D exposing (circle, Circle, circleToCircle)


type alias Drawable a =
    { a | x : Float, y : Float }


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


type alias VeryDrawable =
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
        betterDraw (main :: npcs)


betterDraw : List VeryDrawable -> Html msg
betterDraw veryDrawables =
    Element.toHtml <|
        Collage.collage 500 500 <|
            (List.map toCollageForm veryDrawables)


player : Location.Location -> VeryDrawable
player location =
    location
        |> Location.unwrapLocation
        |> (\loc -> VeryDrawable loc.x loc.y 10 Color.blue)


npc : Location.Location -> VeryDrawable
npc location =
    location
        |> Location.unwrapLocation
        |> (\loc -> VeryDrawable loc.x loc.y 10 Color.green)


toCollageForm : VeryDrawable -> Collage.Form
toCollageForm { x, y, r, color } =
    Collage.oval r r
        |> Collage.filled color
        |> Collage.move ( x, y )


playerColor : Model -> Color.Color
playerColor model =
    if playerInCollision model then
        Color.red
    else
        Color.blue


{-| playerInCollision
Compares the player against all other Npcs to detect
a collision. Currently returning a Bool, but could easily
return the list of collisions.
-}
playerInCollision : Model -> Bool
playerInCollision model =
    let
        player =
            locationToCircle model.location
    in
        model.npcs
            |> List.map locationToCircle
            |> List.filter (circleToCircle player)
            |> List.isEmpty
            |> not


locationToCircle : Location.Location -> Circle
locationToCircle location =
    location
        |> Location.unwrapLocation
        |> (\xNy -> circle xNy.x xNy.y 5)
