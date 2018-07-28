module ReferenceSuite exposing (suite)

import Expect
import Fuzz exposing (string)
import Test exposing (..)
import Reference exposing (..)
import ReferenceSuite.Util exposing (reference)


suite : Test
suite =
    describe "Reference"
        [ describe "rootWith"
            [ describe "RootWith"
                [ fuzz2 reference string "is equals" <|
                    \ref a ->
                        rootWith ref a
                            |> Expect.equal (root <| modify (\_ -> a) ref)
                ]
            ]
        , describe "top"
            [ describe "`map f (top a)`"
                [ fuzz string "is equals to `fromRecord { this = a, rootWith = f }`" <|
                    \str ->
                        map String.reverse (top str)
                            |> sameReference (fromRecord { this = str, rootWith = String.reverse })
                ]
            ]
        ]


sameReference : Reference a b -> Reference a b -> Expect.Expectation
sameReference ref1 ref2 =
    ( this ref1, root ref1 )
        |> Expect.equal ( this ref2, root ref2 )
