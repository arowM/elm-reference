module Tree exposing (main)

import Html exposing (Attribute, Html, div, text)
import Html.Attributes as Attributes
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
    ( { tree =
            [ Node 1
                [ Node 2 []
                , Node 3
                    [ Node 4 []
                    , Node 5 []
                    ]
                , Node 4 []
                ]
            , Node 5 []
            ]
      }
    , Cmd.none
    )



-- MODEL


type alias Model =
    { tree : List Node
    }


type Node
    = Node Int (List Node)



-- UPDATE


type Msg
    = ClickNode (Reference Node (List Node))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickNode ref ->
            ( { model
                | tree =
                    Reference.root <| Reference.modify (\(Node n children) -> Node (n + 1) children) ref
              }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    div [ paddingLeft ] <|
        Reference.List.unwrap renderNode <|
            Reference.top model.tree


renderNode : Reference Node (List Node) -> Html Msg
renderNode ref =
    case Reference.this ref of
        Node n children ->
            div
                []
                [ div
                    [ Events.onClick (ClickNode ref)
                    ]
                    [ text <| toString n
                    ]
                , div [ paddingLeft ] <|
                    Reference.List.unwrap renderNode <|
                        Reference.fromRecord
                            { this = children
                            , rootWith = Reference.rootWith ref << Node n
                            }
                ]


paddingLeft : Attribute Msg
paddingLeft =
    Attributes.style
        [ ( "padding-left"
          , "1em"
          )
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
