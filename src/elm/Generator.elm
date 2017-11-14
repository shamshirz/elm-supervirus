module Generator
    exposing
        ( npc
        , npcs
        , startingNpcs
        )

import Virus exposing (..)
import Math.Vector2 as Vector2
import Random exposing (Generator)


-- Public API


startingNpcs : Float -> Int -> Generator (List Npc)
startingNpcs boundary num =
    Random.list num <| startingNpc boundary


npcs : Virus -> Float -> Int -> Generator (List Npc)
npcs virus boundary num =
    Random.list num <| npc virus boundary


npc : Virus -> Float -> Generator Npc
npc virus boundaryRadius =
    let
        randomSize =
            relativeSize virus.size

        randomLocation =
            relativePosition virus boundaryRadius

        velocity =
            randomVelocity 1
    in
        Random.map3 (makeNpc boundaryRadius) randomSize randomLocation velocity



-- End Public API


startingNpc : Float -> Generator Npc
startingNpc boundaryRadius =
    let
        randomSize =
            relativeSize 4

        randomLocation =
            relativeToStart boundaryRadius

        velocity =
            randomVelocity 2
    in
        Random.map3 (makeNpc boundaryRadius) randomSize randomLocation velocity


relativeSize : Float -> Generator Float
relativeSize size =
    Random.float (size * 0.7) (size * 1.7)


relativeToStart : Float -> Generator Vector2.Vec2
relativeToStart boundaryRadius =
    Random.pair (Random.float 30 boundaryRadius) (Random.float 0 360)
        |> Random.map (fromPolar >> Vector2.fromTuple)


relativePosition : Virus -> Float -> Generator Vector2.Vec2
relativePosition { location } boundaryRadius =
    let
        ( ( minX, maxX ), ( minY, maxY ) ) =
            rangeOutsideMyQuad location boundaryRadius

        outsideMyQuad =
            Random.pair (Random.float minX maxX) (Random.float minY maxY)
    in
        outsideMyQuad |> Random.map Vector2.fromTuple


randomVelocity : Float -> Generator Vector2.Vec2
randomVelocity vel =
    let
        range =
            Random.float (-1 * vel) vel
    in
        Random.pair range range
            |> Random.map (\pair -> Vector2.fromTuple pair)


{-| Do you dare try and solve for all points within a circle and outside of another?
-}
rangeOutsideMyQuad : Vector2.Vec2 -> Float -> ( ( Float, Float ), ( Float, Float ) )
rangeOutsideMyQuad myPosition boundaryRadius =
    let
        ( x, y ) =
            Vector2.toTuple myPosition

        xRange =
            if x > 0 then
                ( -1 * boundaryRadius, 0 )
            else
                ( 0, boundaryRadius )

        yRange =
            if y > 0 then
                ( -1 * boundaryRadius, 0 )
            else
                ( 0, boundaryRadius )
    in
        ( xRange, yRange )
