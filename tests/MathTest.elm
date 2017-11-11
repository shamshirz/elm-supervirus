module MathTest exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import MyMath
import Math.Vector2 as Vector2


suite : Test
suite =
    describe "MyMath module"
        [ describe "safeSlope"
            [ test "We can calculate normal slope situations" <|
                \_ ->
                    let
                        vec =
                            Vector2.vec2 5 5

                        slope =
                            MyMath.safeSlope vec
                    in
                        Expect.equal slope 1
            , test "We return normal numbers for infinite slope situations" <|
                \_ ->
                    let
                        vec =
                            Vector2.vec2 0 5

                        slope =
                            MyMath.safeSlope vec
                    in
                        Expect.greaterThan 500 slope
            , test "We return normal numbers for negative infinite slope situations" <|
                \_ ->
                    let
                        vec =
                            Vector2.vec2 0 -1

                        slope =
                            MyMath.safeSlope vec
                    in
                        Expect.lessThan -500 slope
            ]
        , describe "collisionPoint"
            [ test "We can find basic collision points" <|
                \_ ->
                    let
                        origin =
                            Vector2.vec2 0 0

                        right =
                            Vector2.vec2 1 0

                        radius =
                            5

                        collisionPoint =
                            MyMath.collisionPoint origin right radius
                    in
                        Expect.equal collisionPoint (Vector2.vec2 5 0)
            ]
        , describe "normals"
            [ test "We can find the normal pointing towards the origin" <|
                \_ ->
                    let
                        origin =
                            Vector2.vec2 0 0

                        pointInQuadOne =
                            Vector2.vec2 4 4

                        lineTowardsQuadFour =
                            Vector2.vec2 5 -5

                        myNormalTowardsOrigin =
                            MyMath.inwardNormal pointInQuadOne lineTowardsQuadFour
                    in
                        Expect.equal myNormalTowardsOrigin (Vector2.vec2 -5 -5)
            ]
        , describe "updatePositionAndVelocity"
            [ test "We return the right position without a collision" <|
                \_ ->
                    let
                        origin =
                            Vector2.vec2 0 0

                        pointA =
                            Vector2.vec2 1 1

                        velocity =
                            Vector2.vec2 1 1

                        radius =
                            5

                        ( newPos, newVel ) =
                            MyMath.updatePositionAndVelocity pointA velocity radius
                    in
                        Expect.equal newPos (Vector2.vec2 2 2)
            , test "We return the right velocity without a collision" <|
                \_ ->
                    let
                        origin =
                            Vector2.vec2 0 0

                        pointA =
                            Vector2.vec2 1 1

                        velocity =
                            Vector2.vec2 1 1

                        radius =
                            5

                        ( newPos, newVel ) =
                            MyMath.updatePositionAndVelocity pointA velocity radius
                    in
                        Expect.equal newVel velocity
            , test "We return the right position WITH a collision" <|
                \_ ->
                    let
                        origin =
                            Vector2.vec2 0 0

                        pointA =
                            Vector2.vec2 1 0

                        velocity =
                            Vector2.vec2 2 0

                        radius =
                            2

                        ( newPos, newVel ) =
                            MyMath.updatePositionAndVelocity pointA velocity radius
                    in
                        Expect.equal newPos pointA
            , test "We return the right velocity WITH a collision" <|
                \_ ->
                    let
                        origin =
                            Vector2.vec2 0 0

                        pointA =
                            Vector2.vec2 1 1

                        velocity =
                            Vector2.vec2 3 3

                        radius =
                            2

                        ( newPos, newVel ) =
                            MyMath.updatePositionAndVelocity pointA velocity radius
                    in
                        Expect.equal newVel (Vector2.vec2 -3 -3)
            ]
        ]
