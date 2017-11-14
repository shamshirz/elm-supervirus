module MathTest exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import DomainMath
import Math.Vector2 as Vector2


suite : Test
suite =
    describe "DomainMath module"
        [ describe "updatePositionAndVelocity"
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
                            DomainMath.updatePositionAndVelocity pointA velocity radius
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
                            DomainMath.updatePositionAndVelocity pointA velocity radius
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
                            DomainMath.updatePositionAndVelocity pointA velocity radius
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
                            DomainMath.updatePositionAndVelocity pointA velocity radius
                    in
                        Expect.equal newVel (Vector2.vec2 -3 -3)
            ]
        ]
