module Keys exposing (Keys, GameKey(..), updateKeys, init, updateFromKeyCode, pressedKeys)

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
