module Reference.List
    exposing
        ( unwrap
        )

{-| `List` specific functions for `Reference`.

@docs unwrap

-}

import Reference exposing (..)


{-| Map and unwrap to list.
This is especially useful for updating list on View of THE.

    type alias Model =
        { numbers : List Int
        }

    type Msg
        = Inc (Reference Int (List Int))

    update : Model -> Msg -> ( Model, Cmd Msg )
    update msg =
        case msg of
            Inc ref ->
                { model
                    | numbers =
                        root <| modify (\n -> n + 1) ref
                }

    view : Model -> Html Msg
    view model =
        div [] <|
            Reference.List.unwrap
                renderRow
                (Reference.top model.numbers)

    renderRow : Reference Int (List Int) -> Html Msg
    renderRow ref =
        div
            [ Events.onClick <| Inc ref
            ]
            [ text <| toString <| Reference.this ref
            ]

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
