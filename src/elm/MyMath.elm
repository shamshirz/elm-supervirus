module MyMath exposing (collisionPoint, safeSlope)

{-| A not so great performance math library specifically for
finding the intersection of a line and a circle. We know there will be no evil
and thus we use a `safeSlope` that always returns a value, etc etc.

The primary function here is collisionPoint. which takes two points and the radius of a circle
assumed to have origin (0,0). It always returns the collision point from the direction you are
moving at.

You might wonder

  - how does it always return?
  - What if they don't collide?
  - What if you only collide at one point, like a tangent?

…The world may never know

-}

import Math.Vector2 as Vector2 exposing (Vec2)


{-| Rise over run, and we stay safe from NaN
by returning the largest possible slope
-}
safeSlope : Vec2 -> Float
safeSlope vec =
    let
        rise =
            Vector2.getY vec

        run =
            Vector2.getX vec
    in
        if run == 0 && rise > 0 then
            maxAbsValue
        else if run == 0 && rise < 0 then
            negSmallestNormal
        else
            rise / run


yIntercept : Vec2 -> Float -> Float
yIntercept point slope =
    let
        y =
            Vector2.getY point

        x =
            Vector2.getX point
    in
        y - (slope * x)


{-| SlopeIntercept applied between two points of a line
Returns a tuple of (slope, yIntercept)
-}
slopeIntercept : Vec2 -> Vec2 -> ( Float, Float )
slopeIntercept pointA pointB =
    let
        m =
            safeSlope <| Vector2.sub pointA pointB

        b =
            yIntercept pointA m
    in
        ( m, b )


collisionPoint : Vec2 -> Vec2 -> Float -> Vec2
collisionPoint pointA pointB radius =
    let
        ( slope, yIntercept ) =
            slopeIntercept pointA pointB

        ( intersection1, intersection2 ) =
            intersectionOfLineAndCircle ( slope, yIntercept ) radius

        -- Interesting caveat, Vector2.direction is from b to a
        -- from the second position passed, to the first
        ( xDirection, yDirection ) =
            Vector2.direction pointB pointA
                |> Vector2.toTuple

        ( xIntersect1, yIntersect1 ) =
            Vector2.toTuple intersection1
    in
        if isSameSign xDirection xIntersect1 && isSameSign yDirection yIntersect1 then
            intersection1
        else
            intersection2


isSameSign : Float -> Float -> Bool
isSameSign a b =
    (a >= 0 && b >= 0) || (a < 0 && b < 0)


{-| Do math, return the intersection point of a line we know and a cirle with origin (0, 0)
This is the result of a system of equations for the line (y = mx + b)
and the equation of a circle (sqrt(x^2 + y^2) = r)
…y substitution yields a quadratic equation…
0 = (1+m)x^2 + (2mb)x + (b^2 - r^2)
a = 1 + slope
b = (2 * slope * yIntercept)
c = (yIntercept^2 - radius^2)
-}
intersectionOfLineAndCircle : ( Float, Float ) -> Float -> ( Vec2, Vec2 )
intersectionOfLineAndCircle ( slope, yIntercept ) radius =
    let
        a =
            1 + slope

        b =
            2 * slope * yIntercept

        c =
            (yIntercept ^ 2) - (radius ^ 2)

        ( posX, negX ) =
            quadratic a b c

        posY =
            (slope * posX) + yIntercept

        negY =
            (slope * negX) + yIntercept
    in
        ( Vector2.vec2 posX posY, Vector2.vec2 negX negY )


{-| Applies the quadratic equation using a b c returning x
-}
quadratic : Float -> Float -> Float -> ( Float, Float )
quadratic a b c =
    let
        sqrtTerm =
            sqrt <| b ^ 2 - (4 * a * c)

        plusB =
            (-b + sqrtTerm) / (2 * a)

        minusB =
            (-b - sqrtTerm) / (2 * a)
    in
        ( plusB, minusB )



-- Copied from elm-test


{-| Smallest absolute value representable in a 64 bit float.
-}
negSmallestNormal : Float
negSmallestNormal =
    -1 * (2.0 ^ 1022)


{-| Largest finite absolute value representable in a 64 bit float.
-}
maxAbsValue : Float
maxAbsValue =
    2.0
        - (2.0 ^ -52)
        |> (*) (2.0 ^ 1023)
