module Model exposing (..)

import Clock exposing (Clock)
import Location
import Keys exposing (GameKey(..))
import Time exposing (Time)


-- 30 FPS


gameLoopPeriod : Time.Time
gameLoopPeriod =
    33 * Time.millisecond


type Msg
    = KeyDown Int
    | KeyUp Int
    | TimeDelta Time


type alias Model =
    { clock : Clock
    , keys : Keys.Keys
    , location : Location.Location
    }


init : ( Model, Cmd Msg )
init =
    { clock = Clock.withPeriod gameLoopPeriod
    , keys = Keys.init
    , location = Location.init
    }
        ! []


updateLocation : Model -> Model
updateLocation { clock, keys, location } =
    let
        vector =
            keysToVector keys
    in
        location
            |> Location.applyVector vector
            |> Model clock keys


keysToVector : Keys.Keys -> Location.Vector
keysToVector keysDict =
    keysDict
        |> Keys.pressedKeys
        |> List.foldr foldKey ( 0, 0 )
        |> Location.toVector


foldKey : Keys.GameKey -> ( Float, Float ) -> ( Float, Float )
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
