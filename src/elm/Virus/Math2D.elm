module Virus.Math2D
    exposing
        ( moveWithBounce
        , moveWithSlide
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
moveWithBounce : Vec2 -> Vec2 -> Float -> ( Vec2, Vec2 )
moveWithBounce point velocity radius =
    InMotion velocity (Position point) (Velocity velocity)
        |> move Bounce radius
        |> unwrap


moveWithSlide : Vec2 -> Vec2 -> Float -> ( Vec2, Vec2 )
moveWithSlide point velocity radius =
    InMotion velocity (Position point) (Velocity velocity)
        |> move Slide radius
        |> unwrap


type BoundaryResponse
    = Bounce
    | Slide



-- Internal function will take
-- 1. boundary radius
-- 2. Start Point
-- 3. Velocity
-- 4. movementVector
-- 5. Collision Type
-- We can call this recursively to handle multiple bounces in a single turn


move : BoundaryResponse -> Float -> InMotion -> ( Position, Velocity )
move responseType boundaryRadius ({ momentum, velocity, position } as currentMotion) =
    let
        naiveNext =
            naiveNextPosition position momentum
    in
        if isOutsideRadius boundaryRadius naiveNext then
            currentMotion
                |> handleCollision responseType boundaryRadius naiveNext
                |> toTuple
        else
            ( naiveNext, velocity )


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
                |> Vector2.scale (boundaryMinusSize - 0.0001)
        else
            position



-- Internal types to help make sense of functions / add some safety


{-| Start position, original velocity, remaining current movement
-}
type alias InMotion =
    { momentum : Vec2
    , position : Position
    , velocity : Velocity
    }


toTuple : InMotion -> ( Position, Velocity )
toTuple { momentum, position, velocity } =
    ( position, velocity )


type Position
    = Position Vec2


type Velocity
    = Velocity Vec2


position : ( Float, Float ) -> Position
position ( x, y ) =
    Position <| Vector2.vec2 x y


velocity : ( Float, Float ) -> Velocity
velocity ( x, y ) =
    Velocity <| Vector2.vec2 x y


handleCollision : BoundaryResponse -> Float -> Position -> InMotion -> InMotion
handleCollision response =
    case response of
        Bounce ->
            bounce

        Slide ->
            slide


{-| Math for orthogonal projection of next point and velocity

1.  find collision
2.  find portion of vector outside
3.  Vector rejection (Orthogonal projection) that across line pointing towards origin
4.  Vector rejection of velocity across that line too

Return the (collision, projected Vel, projected remaining movement)

-}
bounce : Float -> Position -> InMotion -> InMotion
bounce boundaryRadius (Position outsidePoint) { momentum, velocity, position } =
    case collisionPoint boundaryRadius position (Position outsidePoint) of
        Just (Position col) ->
            let
                intersection =
                    col
                        |> Vector2.normalize
                        |> Vector2.scale (boundaryRadius - 0.001)

                vectorOutside =
                    Vector2.sub outsidePoint intersection

                collisionToOriginUnitVecor =
                    Vector2.direction origin intersection

                (Velocity reflectedOutsideVector) =
                    rejectOn collisionToOriginUnitVecor (Velocity vectorOutside)

                newPosition =
                    intersection
                        |> Vector2.add reflectedOutsideVector
                        |> Position

                reflectedVelocity =
                    rejectOn collisionToOriginUnitVecor velocity
            in
                InMotion (Vector2.vec2 0 0) newPosition reflectedVelocity

        Nothing ->
            let
                _ =
                    Debug.crash "Disaster strikes! No intersection with circle! Redirecting towards circle"
            in
                InMotion (Vector2.direction origin outsidePoint) position velocity


slide : Float -> Position -> InMotion -> InMotion
slide boundaryRadius (Position outsidePoint) { momentum, position, velocity } =
    let
        newPosition =
            outsidePoint
                |> scaleWithinBoundary boundaryRadius 0
                |> Position
                |> Debug.log "New Position: "

        (Velocity vel) =
            velocity

        tangentLine =
            tangentTowards newPosition (Position (Vector2.add outsidePoint vel))

        --         |> Velocity
        -- velDir =
        --     Vector2.dir
        projectedVelocity =
            velocity
                |> projectOn tangentLine
                |> Debug.log "Projected Velocity: "
    in
        InMotion (Vector2.vec2 0 0) newPosition projectedVelocity


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


{-| Find the intersection points between a line and a circle.
It's possible there is only 1 (if we intersect at a tangent)
It's possible there are none (Just totally different place)
This will return the intersection point closest to the second point on the line
Or Nothing if the case of no intersection.
-}
collisionPoint : Float -> Position -> Position -> Maybe Position
collisionPoint radius insidePoint outsidePoint =
    outsidePoint
        |> slopeIntercept insidePoint
        |> intersectionWithCircle radius
        |> closerPointTo outsidePoint
        |> dropNanOrInfinity


dropNanOrInfinity : Position -> Maybe Position
dropNanOrInfinity ((Position vec) as pos) =
    let
        x =
            Vector2.getX vec
    in
        if isNaN x || isInfinite x then
            Nothing
        else
            Just pos


closerPointTo : Position -> ( Position, Position ) -> Position
closerPointTo (Position start) ( Position a, Position b ) =
    let
        distanceSqAToStart =
            Vector2.distance start a

        distanceSqBToStart =
            Vector2.distance start b
    in
        if distanceSqAToStart <= distanceSqBToStart then
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
rejectOn : Vec2 -> Velocity -> Velocity
rejectOn onto (Velocity projecting) =
    let
        aDotN =
            Vector2.dot projecting onto

        rhs =
            Vector2.scale (2 * aDotN) onto
    in
        Velocity <| Vector2.sub projecting rhs


{-| projecting (a) onto normalized vector (b)
scale a to : aDotb over (length of a)^2
-}
projectOn : Vec2 -> Velocity -> Velocity
projectOn onto (Velocity projecting) =
    let
        normalB =
            Vector2.normalize onto

        dot =
            Vector2.dot projecting normalB
                |> Debug.log "DotProduct: "

        magSquared =
            (Vector2.length normalB) ^ 2

        -- |> Debug.log "MagSqrd: "
    in
        if magSquared == 0 then
            Velocity (Vector2.vec2 0 0)
        else
            Velocity <| Vector2.scale (dot / magSquared) normalB


{-| Assuming on the edge of a circle at (0,0)
-}
tangentTowards : Position -> Position -> Vec2
tangentTowards (Position pos) target =
    let
        ( a, b ) =
            pos
                |> Vector2.direction origin
                |> Vector2.toTuple
                |> (\( x, y ) -> ( ( -1 * y, x ), ( y, -1 * x ) ))

        (Position closerToX) =
            ( Position <| Vector2.fromTuple a, Position <| Vector2.fromTuple b )
                |> closerPointTo target
    in
        closerToX



-- >>>>>>>>>>>>>>> UTIL <<<<<<<<<<<<<<<<<
-- These are basically just aliases for simple math
-- goal is readability & simplicity


{-| assumes origin is (0, 0)
-}
isOutsideRadius : Float -> Position -> Bool
isOutsideRadius radius (Position point) =
    Vector2.length point > radius


naiveNextPosition : Position -> Vec2 -> Position
naiveNextPosition (Position point) movementVector =
    Position <| Vector2.add point movementVector


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
