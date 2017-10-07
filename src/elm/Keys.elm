module Keys exposing (Keys, Key(..), updateKeys, init)

import Char exposing (fromCode)


type Key
    = Down Int
    | Up Int


type alias Keys =
    { down : Bool
    , left : Bool
    , right : Bool
    , up : Bool
    }


init : Keys
init =
    { down = False
    , left = False
    , right = False
    , up = False
    }


updateKeys : Key -> Keys -> Keys
updateKeys key keys =
    case key of
        Down keyCode ->
            keys
                |> applyKeyChange keyCode True

        Up keyCode ->
            keys
                |> applyKeyChange keyCode False


applyKeyChange : Int -> Bool -> Keys -> Keys
applyKeyChange keyCode pressed currentKeys =
    case fromCode keyCode of
        'A' ->
            { currentKeys | left = pressed }

        'W' ->
            { currentKeys | up = pressed }

        'S' ->
            { currentKeys | down = pressed }

        'D' ->
            { currentKeys | right = pressed }

        -- For some reason, we don't catch arrow keys...growl
        _ ->
            currentKeys
