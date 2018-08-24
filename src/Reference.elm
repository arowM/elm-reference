module Reference exposing
    ( Reference
    , this
    , root
    , rootWith
    , fromRecord
    , top
    , modify
    , map
    )

{-| `Reference` is a concept to handle immutable data structure flexibly as using "reference" in mutable languages.


# Primitives

@docs Reference
@docs this
@docs root
@docs rootWith


# Constructors

@docs fromRecord
@docs top


# Operators

@docs modify
@docs map

-}


{-| A core data type to realize references of mutable programing languages in Elm.
After modifying target value by `modify` function, `root` value is also updated as an example bellow.

    ref : Reference Int (List Int)
    ref = fromRecord
        { this = 3
        , rootWith = \x -> [1,2] ++ x :: [4,5]
        }

    this ref
    --> 3

    root ref
    --> [ 1, 2, 3, 4, 5 ]

    ref2 : Reference Int (List Int)
    ref2 = modify (\n -> n + 1) ref

    this ref2
    --> 4

    root ref2
    --> [ 1, 2, 4, 4, 5 ]

-}
type Reference a root
    = Reference
        { this : a
        , rootWith : a -> root
        }



-- Primitives


{-| A constructor for `Reference`.
-}
fromRecord : { this : a, rootWith : a -> root } -> Reference a root
fromRecord =
    Reference


{-| Get focused object from `Reference` value.

    ref : Reference Int (List Int)
    ref = fromRecord
        { this = 2
        , rootWith = \x -> [1] ++ [x] ++ [3]
        }

    this ref
    --> 2

-}
this : Reference a root -> a
this (Reference o) =
    o.this


{-| Pick out root object from `Reference` value by specifying `this` value.

    rootWith ref a == root <| modify (\_ -> a) ref

-}
rootWith : Reference a root -> a -> root
rootWith (Reference o) =
    o.rootWith



-- Helper functions


{-| Pick out root object from `Reference` value.

    ref : Reference Int (List Int)
    ref = fromRecord
        { this = 2
        , rootWith = \x -> [1] ++ [x] ++ [3]
        }

    root ref
    --> [1, 2, 3]

-}
root : Reference a root -> root
root ref =
    rootWith ref (this ref)


{-| Modify an object. It makes root object also changed.

    ref : Reference Int (List Int)
    ref = fromRecord
        { this = 2
        , rootWith = \x -> [1] ++ [x] ++ [3]
        }

    modifiedRef : Reference Int (List Int)
    modifiedRef = modify (\n -> n * 10) ref

    this modifiedRef
    --> 20

    root modifiedRef
    --> [1, 20, 3]

-}
modify : (a -> a) -> Reference a root -> Reference a root
modify f ref =
    fromRecord
        { this = f <| this ref
        , rootWith = rootWith ref
        }


{-| Change root object type by providing convert function.

    ref : Reference Int (List Int)
    ref = fromRecord
        { this = 4
        , rootWith = \x ->
            x :: [5]
        }

    rootWith : List Int -> List (List Int)
    rootWith ls =
        [[2, 3]] ++ [ls] ++ [[6, 7]]

    newRef : Reference Int (List (List Int))
    newRef = map rootWith ref

    this ref
    --> 4

    root ref
    --> [4, 5]

    this newRef
    --> 4

    root newRef
    --> [[2,3], [4,5], [6,7]]

    modifiedRef : Reference Int (List (List Int))
    modifiedRef = modify (\_ -> 8) newRef

    this modifiedRef
    --> 8

    root modifiedRef
    --> [[2,3], [8,5], [6,7]]

-}
map : (b -> c) -> Reference a b -> Reference a c
map f ref =
    fromRecord
        { this = this ref
        , rootWith = rootWith ref >> f
        }


{-| A constructor for `Reference` to create top root object.

    ref : Reference (Maybe Int) (Maybe Int)
    ref = top (Just 3)

    this ref
    --> Just 3

    root ref
    --> Just 3

-}
top : a -> Reference a a
top a =
    fromRecord
        { this = a
        , rootWith = identity
        }
