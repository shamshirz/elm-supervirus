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
        ]
