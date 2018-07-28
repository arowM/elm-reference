module ReferenceSuite exposing (suite)

import Expect
import Test exposing (..)
import Reference exposing (..)
import ReferenceSuite.Util exposing (reference)


suite : Test
suite =
    describe "rootWith"
        [ describe "RootWith"
            [ fuzz2 reference string "is equals" <|
                \ref a ->
                    rootWith ref a
                        |> Expect.equal (root <| modify (\_ -> a) ref)
            ]
        ]
