module View.Game exposing (view)

import Config exposing (boundaryRadius, collisionMaxAge)
import Color exposing (..)
import Collage
import Element
import Html exposing (Html, button, div, p, br, h2, img, text, span, Attribute)
import Model exposing (..)
import Virus exposing (..)


view : Culture -> Html Msg
view =
    displayCulture


displayCulture : Culture -> Html Msg
displayCulture culture =
    culture.npcs
        |> List.map npc
        |> (::) (player culture.player)
        |> consCollisions culture.collisions
        |> (::) petriDish
        |> draw


consCollisions : List Collision -> List Collage.Form -> List Collage.Form
consCollisions collisions elements =
    collisions
        |> List.map collisionElement
        |> List.foldl (::) elements


collisionElement : Collision -> Collage.Form
collisionElement ((Collision location magnitude age) as col) =
    let
        lifeSpanRatio =
            age / collisionMaxAge

        size =
            magnitude + (lifeSpanRatio * 10)
    in
        Collage.circle size
            |> Collage.filled (Color.rgba 255 0 0 (1 - lifeSpanRatio))
            |> Collage.move (collisionLocation col)


draw : List Collage.Form -> Html msg
draw elements =
    Element.toHtml <|
        Collage.collage 500 500 elements


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
