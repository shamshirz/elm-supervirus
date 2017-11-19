module Virus.Math2D
    exposing
        ( updatePositionAndVelocity
        , scaleWithinBoundary
        )

{-| The domain is 2d vector math between lines and circles

Primary goal is finding the intersection between lines and circles,
and "bouncing" the line off of the interior of that circle.

This involves finding the Vector Orthoganol Projection of the line on
the normal line to the tangent of the intersection with the circle.

That was a mouthful, what does it mean?
Luckily, "normal line to the tangent of the intersection with the circle"
happens to be a unit vector from the intersection to the origin. This is a simple
line to find.

The line we are projecting is the line that originates inside the circle and has a
second point outside of the circle. We want that part that goes beyond the circle to
be "orthogonally projected" back inside the the circle (this is math for - bounce off
of the interior of the circle).

Caveats. We base all assumptions on the fact that we start with a point within the
bounding circle. If that is not the case, then we live in of world of Hurt (NaN floats)

*We use the Position and Velocity types internally to keep track of what's going on
but those aren't exposed externally*

Math.Vector2.Vec2's come in, and they go out. Simple

-}

import Math.Vector2 as Vector2 exposing (Vec2)


-- >>>>>>>>>>>>>>>>>>>>>>> PUBLIC API <<<<<<<<<<<<<<<<<<<<<<<<


{-| Find the next point considering the boundary
If we land outside the boundary, then calculate the new point
and the new direction of the velocity.

If we aren't outside the boundary, the just return that new point
and the current velocity.

-}
updatePositionAndVelocity : Vec2 -> Vec2 -> Float -> ( Vec2, Vec2 )
updatePositionAndVelocity point velocity radius =
    let
        (Position next) =
            naiveNextPosition (Position point) (Velocity velocity)
    in
        if isOutsideRadius radius (Position next) then
            unwrap <| handleCollision (Position point) (Position next) (Velocity velocity) radius
        else
            ( next, velocity )


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
        if isOutsideRadius boundaryMinusSize (Position position) then
            position
                |> Vector2.normalize
                |> Vector2.scale (boundaryMinusSize)
        else
            position



-- Internal types to help make sense of functions / add some safety


type Position
    = Position Vec2


position : ( Float, Float ) -> Position
position ( x, y ) =
    Position <| Vector2.vec2 x y


type Velocity
    = Velocity Vec2


velocity : ( Float, Float ) -> Velocity
velocity ( x, y ) =
    Velocity <| Vector2.vec2 x y


{-| Math for orthogonal projection of next point and velocity

1.  find collision
2.  find portion of vector outside
3.  Vector rejection (Orthogonal projection) that across line pointing towards origin
4.  Vector rejection of velocity across that line too

-}
handleCollision : Position -> Position -> Velocity -> Float -> ( Position, Velocity )
handleCollision (Position insidePoint) (Position outsidePoint) (Velocity velocity) radius =
    let
        (Position intersection) =
            collisionPoint (Position insidePoint) (Position outsidePoint) radius

        vectorOutside =
            Vector2.sub outsidePoint intersection

        collisionToOriginUnitVecor =
            Vector2.direction origin intersection

        reflectedOusideVector =
            reflect vectorOutside collisionToOriginUnitVecor

        reflectedVelocity =
            reflect velocity collisionToOriginUnitVecor

        newPosition =
            Vector2.add intersection reflectedOusideVector
    in
        ( Position newPosition, Velocity reflectedVelocity )


{-| Rise over run, and we stay safe from NaN
by returning the largest possible slope
-}
safeSlope : Velocity -> Float
safeSlope (Velocity vec) =
    let
        ( run, rise ) =
            Vector2.toTuple vec
    in
        if run == 0 && rise > 0 then
            maxSlope
        else if run == 0 && rise < 0 then
            minSlope
        else
            rise / run


yIntercept : Position -> Float -> Float
yIntercept (Position point) slope =
    (Vector2.getY point) - (slope * (Vector2.getX point))


{-| SlopeIntercept applied between two points of a line
Returns a tuple of (slope, yIntercept)
-}
slopeIntercept : Position -> Position -> ( Float, Float )
slopeIntercept (Position pointA) (Position pointB) =
    let
        m =
            safeSlope <| Velocity <| Vector2.sub pointA pointB

        b =
            yIntercept (Position pointA) m
    in
        ( m, b )


collisionPoint : Position -> Position -> Float -> Position
collisionPoint insidePoint outsidePoint radius =
    outsidePoint
        |> slopeIntercept insidePoint
        |> intersectionWithCircle radius
        |> closerPointTo outsidePoint


closerPointTo : Position -> ( Position, Position ) -> Position
closerPointTo (Position start) ( Position a, Position b ) =
    let
        distanceSqAT =
            Vector2.distanceSquared start a

        distanceSqBT =
            Vector2.distanceSquared start b
    in
        if distanceSqAT <= distanceSqBT then
            Position a
        else
            Position b


{-| Do math, return the intersection point of a line we know and a cirle with origin (0, 0)
This is the result of a system of equations for the line (y = mx + b)
and the equation of a circle (sqrt(x^2 + y^2) = r)
…y substitution yields a quadratic equation…
0 = (1+m^2)x^2 + (2mb)x + (b^2 - r^2)
a = 1 + slope^2
b = (2 * slope * yIntercept)
c = (yIntercept^2 - radius^2)
-}
intersectionWithCircle : Float -> ( Float, Float ) -> ( Position, Position )
intersectionWithCircle radius ( slope, yIntercept ) =
    let
        a =
            1 + (slope ^ 2)

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
        ( Position <| Vector2.vec2 posX posY, Position <| Vector2.vec2 negX negY )


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



-- >>>>>>>>>>>>>>> UTIL <<<<<<<<<<<<<<<<<
-- These are basically just aliases for simple math
-- goal is readability & simplicity


{-| assumes origin is (0, 0)
-}
isOutsideRadius : Float -> Position -> Bool
isOutsideRadius radius (Position point) =
    Vector2.length point > radius


naiveNextPosition : Position -> Velocity -> Position
naiveNextPosition (Position point) (Velocity velocity) =
    Position <| Vector2.add point velocity


origin : Vec2
origin =
    Vector2.vec2 0 0


unwrap : ( Position, Velocity ) -> ( Vec2, Vec2 )
unwrap ( Position pos, Velocity vel ) =
    ( pos, vel )



-- Copied from elm-test


{-| Smallest absolute value representable in a 64 bit float.
-}
minSlope : Float
minSlope =
    -1 * maxSlope


{-| Largest finite absolute value representable in a 64 bit float.
-}
maxSlope : Float
maxSlope =
    2.0 ^ 100
