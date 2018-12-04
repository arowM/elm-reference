module UpDown exposing (main)

import Browser
import Html exposing (Html, div, text)
import Html.Attributes as Attributes
import Html.Events as Events
import SelectList exposing (SelectList)



-- APP


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( { todos =
            [ "foo"
            , "bar"
            , "baz"
            , "foobar"
            , "foobaz"
            , "barbaz"
            , "foobarbaz"
            ]
      }
    , Cmd.none
    )



-- MODEL


type alias Model =
    { todos : List String
    }



-- UPDATE


type Msg
    = UpdateTodo Operation (SelectList String)


type Operation
    = Up
    | Down
    | Remove
    | Edit String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateTodo op sl ->
            ( { model
                | todos =
                    updateTodo op sl
              }
            , Cmd.none
            )


updateTodo : Operation -> SelectList String -> List String
updateTodo op sl =
    case op of
        Up ->
            SelectList.toList <|
                SelectList.moveBy -1 sl

        Down ->
            SelectList.toList <|
                SelectList.moveBy 1 sl

        Remove ->
            Maybe.withDefault [] <|
                Maybe.map SelectList.toList <|
                    SelectList.delete sl

        Edit new ->
            SelectList.toList <|
                SelectList.updateSelected (\_ -> new) sl



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [] <|
            SelectList.selectedMapForList renderRow model.todos
        , div []
            [ text "Results:"
            , div [ Attributes.style "padding-left" "1em" ] <|
                List.map (\str -> div [] [ text str ]) model.todos
            ]
        ]




renderRow : SelectList String -> Html Msg
renderRow sl =
    div
        []
        [ Html.input
            [ Attributes.type_ "text"
            , Events.onInput (\str -> UpdateTodo (Edit str) sl)
            , Attributes.value <| SelectList.selected sl
            ]
            []
        , Html.button
            [ Attributes.type_ "button"
            , Events.onClick (UpdateTodo Remove sl)
            ]
            [ text "×"
            ]
        , Html.button
            [ Attributes.type_ "button"
            , Events.onClick (UpdateTodo Up sl)
            ]
            [ text "△"
            ]
        , Html.button
            [ Attributes.type_ "button"
            , Events.onClick (UpdateTodo Down sl)
            ]
            [ text "▽"
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
