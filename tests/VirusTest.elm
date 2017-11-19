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


northEast : Vec2.Vec2
northEast =
    Vec2.vec2 1 1


origin : Vec2.Vec2
origin =
    Vec2.vec2 0 0


suite : Test
suite =
    describe "The Virus module"
        [ describe "Virus.move"
            -- Nest descriptions!
            [ test "updates the location of a virus" <|
                \_ ->
                    let
                        targetPosition =
                            ( 1, 1 )

                        virus =
                            Virus.safeCreate testingBoundary origin 2 northEast

                        afterMove =
                            Virus.move testingBoundary Bounce virus
                    in
                        Expect.equal (location afterMove) targetPosition
            , test "updates the location relative to current position" <|
                \_ ->
                    let
                        targetPosition =
                            ( 2, 2 )

                        virus =
                            Virus.safeCreate testingBoundary origin 2 northEast

                        afterMove =
                            virus
                                |> Virus.move testingBoundary Bounce
                                |> Virus.move testingBoundary Bounce
                    in
                        Expect.equal (location afterMove) targetPosition
            ]
        , fuzz2 (Fuzz.floatRange -2 2) (Fuzz.floatRange -2 2) "FUZZ: random velocity always keeps us within the boundary" <|
            \float1 float2 ->
                let
                    -- This fails if we are moving fast enough to not land in the boundary after the bounce
                    randomVelocity =
                        Vec2.vec2 float1 float2

                    virus =
                        Virus.safeCreate testingBoundary origin 2 randomVelocity

                    move =
                        Virus.move testingBoundary Bounce

                    repeat =
                        List.repeat 100 1
                in
                    repeat
                        |> List.foldl (\_ virus -> move virus) virus
                        |> (.location >> Vec2.length)
                        |> Expect.within (Relative 100.0001) 0
        , describe "Virus.resolveBattles"
            [ test "player dies if collides with bigger virus" <|
                \_ ->
                    let
                        player =
                            Virus.safeCreate testingBoundary origin 2 northEast

                        biggerVirus =
                            Virus.safeCreate testingBoundary origin 4 northEast
                    in
                        case Virus.resolveBattles player [ biggerVirus ] of
                            ( Dead, _ ) ->
                                Expect.pass

                            _ ->
                                Expect.fail "We should have died, but didn't!"
            , test "player lives if collides with smaller virus" <|
                \_ ->
                    let
                        player =
                            Virus.safeCreate testingBoundary origin 2 northEast

                        smallerVirus =
                            Virus.safeCreate testingBoundary origin 1 northEast
                    in
                        case Virus.resolveBattles player [ smallerVirus ] of
                            ( Dead, _ ) ->
                                Expect.fail "We should have lived, but didn't!"

                            ( Alive virus, _ ) ->
                                Expect.equal virus.size 2.1
            , test "A dead virus can't come back to life" <|
                \_ ->
                    let
                        player =
                            Virus.safeCreate testingBoundary origin 2 northEast

                        biggerVirus =
                            Virus.safeCreate testingBoundary origin 4 northEast

                        smallerVirus =
                            Virus.safeCreate testingBoundary origin 1 northEast
                    in
                        case Virus.resolveBattles player [ biggerVirus, smallerVirus, smallerVirus ] of
                            ( Dead, _ ) ->
                                Expect.pass

                            _ ->
                                Expect.fail "We should have died, but didn't!"
            ]
        , describe "Virus.newVirus"
            [ fuzz3 Fuzz.float Fuzz.float Fuzz.float "a new virus will always start in the play area" <|
                \fl1 fl2 fl3 ->
                    let
                        positiveRandom =
                            abs fl1

                        virus =
                            Virus.safeCreate (positiveRandom * 2) (Vec2.vec2 fl2 fl3) positiveRandom northEast

                        position =
                            location virus
                    in
                        position
                            |> Vec2.fromTuple
                            |> Vec2.length
                            |> Expect.within (Relative 100.0001) 0
            ]
        ]
