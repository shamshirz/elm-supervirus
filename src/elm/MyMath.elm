module MyMath
    exposing
        ( collisionPoint
        , safeSlope
        , inwardNormal
        , updatePositionAndVelocity
        , isOutsideRadius
        , scaleWithinBoundary
        )

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


-- Whole thing. Bounce of of interior of a circle.
-- Given 2 points and a radius, we return a (Point, velocity) tuple
-- If no collision, whatever, return the next point and the current velocity
-- If a collision, do the baller shit
-- 1. Determine Collision Location
-- 2. Determine vector outside of boundary (direction * length)
-- 3. Determine normal unit vector towards origin
-- 4. Reject vector on normal vector


{-| Find the next point considering the boundary
If we land outside the boundary, then calculate the new point
and the new direction of the velocity.

If we aren't outside the boundary, the just return that new point
and the current velocity.

-}
updatePositionAndVelocity : Vec2 -> Vec2 -> Float -> ( Vec2, Vec2 )
updatePositionAndVelocity point velocity radius =
    let
        next =
            naiveNextPosition point velocity
    in
        if isOutsideRadius radius next then
            handleCollision point next velocity radius
        else
            ( next, velocity )



-- TODO: Convert everything to use these


type Position
    = Position Vec2


type Velocity
    = Velocity Vec2


{-| Yeesh

1.  find collision
2.  find portion of vector outside
3.  reflect that across line pointing towards origin
4.  reflect velocity across that line too

-}
handleCollision : Vec2 -> Vec2 -> Vec2 -> Float -> ( Vec2, Vec2 )
handleCollision insidePoint outsidePoint velocity radius =
    let
        intersection =
            collisionPoint insidePoint outsidePoint radius
                |> Debug.log "CollisionAt: "

        velocityUnitVector =
            Vector2.normalize velocity

        lengthAfterCollision =
            Vector2.distance outsidePoint intersection
                |> Debug.log "LengthAfterCollision: "

        vectorOutside =
            Vector2.scale (lengthAfterCollision) velocityUnitVector
                |> Debug.log "VectorAfterCollision: "

        normalOfCollisionTangent =
            Vector2.direction origin intersection

        reflectedOusideVector =
            reflect vectorOutside normalOfCollisionTangent
                |> Debug.log "Reflected outside vector!"

        newPosition =
            Vector2.add intersection reflectedOusideVector
                |> Debug.log "NewPosition"

        reflectedVelocity =
            reflect velocity normalOfCollisionTangent
    in
        ( newPosition, reflectedVelocity )


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



--  Normal equations


{-| get the normals, then pick the one pointing towards the origin
The interesting thing here is, if the point is at the origin.
then all is lost. Everything is pointing away.
-}
inwardNormal : Vec2 -> Vec2 -> Vec2
inwardNormal point line =
    if Vector2.getX point == 0 && Vector2.getY point == 0 then
        -- All must surely be lost. We have instersected at the origin.
        -- There goes the type safety.
        -- I'm returning a vector pointing up…I guess
        Vector2.vec2 0 1
    else
        whichPointsToOrigin point <| normals line


whichPointsToOrigin : Vec2 -> ( Vec2, Vec2 ) -> Vec2
whichPointsToOrigin point ( vec1, vec2 ) =
    let
        dirToOrigin =
            Vector2.direction origin point
    in
        if isSameDirection dirToOrigin vec1 then
            vec1
        else
            vec2


normals : Vec2 -> ( Vec2, Vec2 )
normals vec =
    let
        ( x, y ) =
            Vector2.toTuple vec
    in
        ( Vector2.vec2 x -y, Vector2.vec2 -x y )


{-| Vector orthagonal projection on normal
Known as a "rejection" on normal

b_bar = a_bar - 2(a_bar dot normal)normal

This always works. Real math, just vectors being vectors
Worst case scenario we are perpendicular and the rejection is itself

-}
reflect : Vec2 -> Vec2 -> Vec2
reflect vector normal =
    let
        aDotN =
            Vector2.dot vector normal

        rhs =
            Vector2.scale (2 * aDotN) normal
    in
        Vector2.sub vector rhs


{-| This function will take a location vector, try to determine it's direction,
then scale it to the boundary (minus it's own size).
This will put the outside edge of the virus on the boundary.

If we are already inside the boundary, then no modification is made

-}
scaleWithinBoundary : Float -> Float -> Vec2 -> Vec2
scaleWithinBoundary boundary size position =
    let
        boundaryMinusSize =
            boundary - size
    in
        if isOutsideRadius boundaryMinusSize position then
            position
                |> normalize
                |> Vector2.scale (boundaryMinusSize)
        else
            position



-- >>>>>>>>>>>>>>> UTIL <<<<<<<<<<<<<<<<<
-- These are basically just aliases for simple math
-- goal is readability & simplicity


{-| assumes origin is (0, 0)
-}
isOutsideRadius : Float -> Vec2 -> Bool
isOutsideRadius radius point =
    Vector2.length point > radius


naiveNextPosition : Vec2 -> Vec2 -> Vec2
naiveNextPosition point velocity =
    Vector2.add point velocity


{-| Wrapper for normalize because we get NaN
if you do it from the origin. This is wonky, but
better than everything breaking
-}
normalize : Vec2 -> Vec2
normalize vec =
    if (Vector2.length vec) == 0 then
        Vector2.vec2 0 0
    else
        Vector2.normalize vec


isSameSign : Float -> Float -> Bool
isSameSign a b =
    (a >= 0 && b >= 0) || (a < 0 && b < 0)


isSameDirection : Vec2 -> Vec2 -> Bool
isSameDirection a b =
    let
        ( xA, yA ) =
            Vector2.toTuple a

        ( xB, yB ) =
            Vector2.toTuple b
    in
        isSameSign xA xB && isSameSign yA yB


origin : Vec2
origin =
    Vector2.vec2 0 0



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
