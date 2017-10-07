module Model exposing (..)

import Clock exposing (Clock)
import Location
import Keys
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
            buildVector keys
    in
        location
            |> Location.applyVector vector
            |> Model clock keys


buildVector : Keys.Keys -> Location.Vector
buildVector keys =
    let
        x =
            0
                |> addIfTrue keys.right 1
                |> addIfTrue keys.left -1

        y =
            0
                |> addIfTrue keys.up -1
                |> addIfTrue keys.down 1
    in
        { dx = Location.Magnitude x
        , dy = Location.Magnitude y
        }


addIfTrue : Bool -> Float -> Float -> Float
addIfTrue isTrue delta current =
    if isTrue then
        current + delta
    else
        current
