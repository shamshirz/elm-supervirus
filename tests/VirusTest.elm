module VirusTest exposing (..)

import Expect exposing (Expectation)


-- import Fuzz exposing (Fuzzer, int, list, string)

import Test exposing (..)
import Virus exposing (..)


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

                        biggerVirus =
                            newVirus 10 ( 0, 0 ) testingBoundary
                    in
                        case handleCollision biggerVirus player of
                            Dead ->
                                Expect.pass

                            _ ->
                                Expect.fail "We should have died, but didn't!"
            , test "player lives if collides with smaller virus" <|
                \_ ->
                    let
                        player =
                            Alive <| newVirus 5 ( 0, 0 ) testingBoundary

                        biggerVirus =
                            newVirus 2 ( 0, 0 ) testingBoundary
                    in
                        case handleCollision biggerVirus player of
                            Dead ->
                                Expect.fail "We should have lived, but didn't!"

                            Alive virus ->
                                Expect.equal virus.size 6
            , test "A dead virus can't come back to life" <|
                \_ ->
                    let
                        player =
                            Dead

                        biggerVirus =
                            newVirus 2 ( 0, 0 ) testingBoundary
                    in
                        case handleCollision biggerVirus player of
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

                        otherVirus =
                            newVirus 2 ( 0, 0 ) testingBoundary

                        threeOfThem =
                            [ otherVirus, otherVirus, otherVirus ]
                    in
                        case handleCollisions player threeOfThem of
                            ( Dead, _ ) ->
                                Expect.fail "we should have survived the onslaught!"

                            ( Alive virus, _ ) ->
                                Expect.equal virus.size 8
            ]
        ]
