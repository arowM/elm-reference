module ReferenceSuite.List exposing (suite)

import Expect
import Test exposing (..)
import Reference exposing (..)
import Reference.List exposing (..)
import ReferenceSuite.Util exposing (listReference)


suite : Test
suite =
    describe "unwrap"
        [ describe "`unwrap this ref`"
            [ fuzz listReference "is equals to `this ref`" <|
                \ref ->
                    unwrap this ref
                        |> Expect.equal (this ref)
            ]
        , describe "`unwrap (this >> f) ref`"
            [ fuzz listReference "is equals to `List.map f <| this ref`" <|
                \ref ->
                    unwrap (this >> String.length) ref
                        |> Expect.equal (List.map String.length <| this ref)
            ]
        , describe "`unwrap root ref`"
            [ fuzz listReference "is equals to `List.map (\\_ -> root ref) <| this ref`" <|
                \ref -> unwrap root ref
                    |> Expect.equal (List.map (\_ -> root ref) <| this ref)
            ]
        ]
