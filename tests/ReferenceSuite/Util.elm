module ReferenceSuite.Util
    exposing
        ( reference
        , listReference
        )

import Fuzz exposing (Fuzzer, list, string)
import Test exposing (..)
import Reference exposing (..)


reference : Fuzzer (Reference String (List String))
reference =
    Fuzz.map2
        (\a ls ->
            Reference.fromRecord
                { this = a
                , rootWith = \x -> x :: ls
                }
        )
        string
        (list string)


listReference : Fuzzer (Reference (List String) (List (List String)))
listReference =
    Fuzz.map2
        (\a ls ->
            Reference.fromRecord
                { this = a
                , rootWith = \x -> x :: ls
                }
        )
        (list string)
        (list (list string))
