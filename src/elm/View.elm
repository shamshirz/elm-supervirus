module View exposing (view)

import Config exposing (boundaryRadius, collisionMaxAge)
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

        Win score ->
            centered [] <|
                winView score


centered : List (Html.Attribute msg) -> List (Html msg) -> Html msg
centered attrs children =
    div (class "centered" :: attrs) children


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
