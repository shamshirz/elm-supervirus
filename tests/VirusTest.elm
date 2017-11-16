module VirusTest exposing (..)

import Expect exposing (Expectation, FloatingPointTolerance(..))
import Fuzz


-- import Fuzz exposing (Fuzzer, int, list, string)

import Test exposing (..)
import Virus exposing (..)
import Math.Vector2 as Vec2


testingBoundary : Float
testingBoundary =
    40


suite : Test
suite =
    describe "The Virus module"
        [ describe "Virus.move"
            -- Nest descriptions!
            [ test "updates the location of a virus" <|
                \_ ->
                    let
                        targetPosition =
                            ( -2, 3 )

                        virus =
                            player testingBoundary
                                |> move targetPosition testingBoundary
                    in
                        Expect.equal (location virus) targetPosition
            , test "updates the location relative to current position" <|
                \_ ->
                    let
                        movementVector =
                            ( 1, 3 )

                        virus =
                            player testingBoundary
                                |> move movementVector testingBoundary
                                |> move movementVector testingBoundary
                                |> move movementVector testingBoundary
                    in
                        Expect.equal (location virus) ( 3, 9 )
            ]
        , describe "Virus.handleCollision"
            [ test "player dies if collides with bigger virus" <|
                \_ ->
                    let
                        player =
                            Alive <| newVirus 5 ( 0, 0 ) testingBoundary

                        biggerNpc =
                            makeNpc testingBoundary 10 (Vec2.vec2 0 0) (Vec2.vec2 0 0)
                    in
                        case handleCollision biggerNpc player of
                            Dead ->
                                Expect.pass

                            _ ->
                                Expect.fail "We should have died, but didn't!"
            , test "player lives if collides with smaller virus" <|
                \_ ->
                    let
                        player =
                            Alive <| newVirus 5 ( 0, 0 ) testingBoundary

                        smallerNpc =
                            makeNpc testingBoundary 2 (Vec2.vec2 0 0) (Vec2.vec2 0 0)
                    in
                        case handleCollision smallerNpc player of
                            Dead ->
                                Expect.fail "We should have lived, but didn't!"

                            Alive virus ->
                                Expect.equal virus.size 5.2
            , test "A dead virus can't come back to life" <|
                \_ ->
                    let
                        player =
                            Dead

                        smallerNpc =
                            makeNpc testingBoundary 2 (Vec2.vec2 0 0) (Vec2.vec2 0 0)
                    in
                        case handleCollision smallerNpc player of
                            Dead ->
                                Expect.pass

                            Alive virus ->
                                Expect.fail "We can't come back to life!"
            ]
        , describe "Virus.handleCollisions"
            -- Nest descriptions!
            [ test "handles multiple collisions" <|
                \_ ->
                    let
                        player =
                            newVirus 5 ( 0, 0 ) testingBoundary

                        smallerNpc =
                            makeNpc testingBoundary 2 (Vec2.vec2 0 0) (Vec2.vec2 0 0)

                        threeOfThem =
                            [ smallerNpc, smallerNpc, smallerNpc ]
                    in
                        case handleCollisions player threeOfThem of
                            ( Dead, _ ) ->
                                Expect.fail "we should have survived the onslaught!"

                            ( Alive virus, _ ) ->
                                virus.size
                                    |> Expect.within (Relative 0.0001) 5.6
            ]
        , describe "Virus.updateNpc"
            -- fuzzy test for math!
            [ fuzz3 Fuzz.float Fuzz.float Fuzz.float "restores the original string if you run it again" <|
                \fl1 fl2 fl3 ->
                    let
                        virus =
                            Virus.newVirus 20 ( fl2, fl3 ) 100

                        position =
                            location virus
                    in
                        position
                            |> Vec2.fromTuple
                            |> Vec2.length
                            |> Expect.within (Relative 100.0001) 0
            ]
        ]
