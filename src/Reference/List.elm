module Reference.List
    exposing
        ( unwrap
        )

{-| `List` specific functions for `Reference`.

@docs unwrap

-}

import Reference exposing (..)


{-| Map and unwrap to list.
This is especially useful for updating list of sub views in the Elm architecture.

See more about [README](http://package.elm-lang.org/packages/arowM/elm-reference/latest)

-}
unwrap : (Reference a x -> b) -> Reference (List a) x -> List b
unwrap =
    unwrap_ identity


unwrap_ : (List a -> List a) -> (Reference a x -> b) -> Reference (List a) x -> List b
unwrap_ past f ref =
    case this ref of
        [] ->
            []

        x :: xs ->
            f
                (fromRecord
                    { this = x
                    , rootWith = \a -> rootWith ref <| past (a :: xs)
                    }
                )
                :: unwrap_ (past << (::) x) f (modify (\_ -> xs) ref)
