module ListWithReference exposing (main)

import Html exposing (Html, div, text)
import Html.Events as Events
import Reference exposing (Reference)
import Reference.List


-- APP


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( { nums = [ 1, 2, 3, 4, 5, 6 ]
      }
    , Cmd.none
    )



-- MODEL


type alias Model =
    { nums : List Int
    }



-- UPDATE


type Msg
    = ClickNumber (Reference Int (List Int))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickNumber ref ->
            ( { model
                | nums =
                    Reference.root <| Reference.modify ((+) 1) ref
              }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    div [] <| Reference.List.unwrap renderRow <| Reference.top model.nums


renderRow : Reference Int (List Int) -> Html Msg
renderRow ref =
    div
        [ Events.onClick (ClickNumber ref)
        ]
        [ text <| toString <| Reference.this ref
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
