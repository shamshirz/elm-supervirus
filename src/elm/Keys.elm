module Keys
    exposing
        ( GameKey(..)
        , init
        , Keys
        , keysToTuple
        , pressedKeys
        , updateFromKeyCode
        , updateKeys
        )

import Char exposing (fromCode, KeyCode)
import EveryDict exposing (EveryDict)


--  I'm not really using the 'value' in this dict, key existance is kind of all that matters rn


type GameKey
    = Left
    | Right
    | Up
    | Down


type alias Pressed =
    Bool


type alias Keys =
    EveryDict GameKey Pressed


init : Keys
init =
    EveryDict.empty


updateKeys : GameKey -> Pressed -> Keys -> Keys
updateKeys key pressed dict =
    if pressed then
        EveryDict.insert key pressed dict
    else
        EveryDict.remove key dict


updateFromKeyCode : Int -> Pressed -> Keys -> Keys
updateFromKeyCode keyCode pressed currentKeys =
    case fromCode keyCode of
        'A' ->
            updateKeys Left pressed currentKeys

        'W' ->
            updateKeys Up pressed currentKeys

        'S' ->
            updateKeys Down pressed currentKeys

        'D' ->
            updateKeys Right pressed currentKeys

        -- For some reason, we don't catch arrow keys...growl
        _ ->
            currentKeys


pressedKeys : Keys -> List GameKey
pressedKeys keys =
    EveryDict.keys keys


keysToTuple : Keys -> ( Float, Float )
keysToTuple keys =
    keys
        |> pressedKeys
        |> List.foldr foldKey ( 0, 0 )


foldKey : GameKey -> ( Float, Float ) -> ( Float, Float )
foldKey key ( x, y ) =
    case key of
        Down ->
            ( x, y - 1 )

        Left ->
            ( x - 1, y )

        Right ->
            ( x + 1, y )

        Up ->
            ( x, y + 1 )
