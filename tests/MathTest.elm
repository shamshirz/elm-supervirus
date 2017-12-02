module MathTest exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import Virus.Math2D as Math
import Math.Vector2 as Vector2


suite : Test
suite =
    describe "Math module"
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
                            Math.updatePositionAndVelocity pointA velocity radius
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
                            Math.updatePositionAndVelocity pointA velocity radius
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
                            Math.updatePositionAndVelocity pointA velocity radius

                        ( x, y ) =
                            Vector2.toTuple newPos
                    in
                        x
                            |> Expect.within (Expect.Relative 0.01) 1
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
                            Math.updatePositionAndVelocity pointA velocity radius
                    in
                        Expect.equal newVel (Vector2.vec2 -3 -3)
            ]
        , test "We can handle zero velocity" <|
            \_ ->
                let
                    origin =
                        Vector2.vec2 0 0

                    velocity =
                        Vector2.vec2 0 7.6000364156427604

                    ( newPos, newVel ) =
                        Math.updatePositionAndVelocity origin velocity 5

                    ( x, y ) =
                        Vector2.toTuple newPos
                in
                    y
                        |> Expect.within (Expect.Relative 5.0001) 0
        , test "velocity at boundary" <|
            \_ ->
                let
                    atBoundary =
                        Vector2.vec2 0 -5

                    velocity =
                        Vector2.vec2 1 0

                    ( newPos, newVel ) =
                        Math.updatePositionAndVelocity atBoundary velocity 5

                    ( x, y ) =
                        Vector2.toTuple newPos
                in
                    y
                        |> Expect.greaterThan -5
        ]
