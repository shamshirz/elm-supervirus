module View exposing (display, playZone)

import Model exposing (Model, Msg(..))
import Html exposing (Html, button, div, p, br, text, span, Attribute)
import Svg exposing (..)
import Svg.Attributes exposing (..)


display : Model -> Html Msg
display model =
    div []
        [ div [] [ Html.text "hello" ]
        , div [] [ Html.text <| "Position: " ++ (toString model.location) ]
        , div [] [ Html.text <| "Keys: " ++ (toString model.keys) ]
        , br [] []
        ]


playZone : { x : Float, y : Float } -> Html msg
playZone { x, y } =
    div [ class "play-zone" ]
        [ Svg.svg [ Svg.Attributes.viewBox "0 0 100 100", Svg.Attributes.width "300px" ]
            [ circle [ cx <| toString x, cy <| toString y, r "5", stroke "blue", fill "blue" ] []
            ]
        ]
