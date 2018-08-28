module ListWithIndex exposing (main)

import Browser
import Html exposing (Html, div, text)
import Html.Events as Events
import List.Extra



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
    = ClickNumber Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickNumber idx ->
            ( { model
                | nums =
                    List.Extra.updateAt idx ((+) 1) model.nums
              }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    div [] <| List.indexedMap renderRow model.nums


renderRow : Int -> Int -> Html Msg
renderRow idx n =
    div
        [ Events.onClick (ClickNumber idx)
        ]
        [ text <| String.fromInt n
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
