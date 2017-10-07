module Location exposing (..)


type alias Vector =
    { dx : Magnitude
    , dy : Magnitude
    }


type alias Location =
    { x : Coordinate
    , y : Coordinate
    }


unwrapLocation : Location -> { x : Float, y : Float }
unwrapLocation { x, y } =
    { x = unwrapCoordinate x, y = unwrapCoordinate y }


init : Location
init =
    { x = Coordinate 0
    , y = Coordinate 0
    }


type Magnitude
    = Magnitude Float


type Coordinate
    = Coordinate Float


unwrapCoordinate : Coordinate -> Float
unwrapCoordinate (Coordinate fl) =
    fl


applyVector : Vector -> Location -> Location
applyVector { dx, dy } { x, y } =
    { x = applyMagnitude x dx
    , y = applyMagnitude y dy
    }


applyMagnitude : Coordinate -> Magnitude -> Coordinate
applyMagnitude (Coordinate pos) (Magnitude impulse) =
    Coordinate (pos + impulse)
