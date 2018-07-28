# elm-reference

[![Build Status](https://travis-ci.org/arowM/elm-reference.svg?branch=master)](https://travis-ci.org/arowM/elm-reference)

An Elm library to handle immutable data structure flexibly as mutable languages.

Any PRs are welcome, even for documentation fixes.  (The main author of this library is not an English native.)

## What problem can `Reference` resolve?

It is often case to render list of sub views, such as TODO lists, registered user lists, list of posts, etc...
`Reference` is useful in such cases.

Here is an part of simple application code that increments numbers on each row by clicking.

```elm
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
        [ text <| toString n
        ]
```

In this code, index number of clicked number is passed to update function with `ClickNumber` message.
It is common technique of the Elm architecture, but it does not seem to be straightforward...
How can we realize this sort of probrem intuitively?

## Reference of mutable programing languages help us!

Some mutable programing languages can handle reference as following example of JS.

```js
> arr = [ {val: 1}, {val: 2}, {val: 3} ]
> x = arr[1]
> x.val = 3
> arr
[ { val: 1 }, { val: 3 }, { val: 3 } ]
```

If Elm could handle references as mutable languages, it would be possible to resolve the previous problem by passing reference of the clicked number to the `Msg` instead of index as follows.

```elm
type Msg
    = ClickNumber SomeSortOfReference
```

The basic motivation of `Reference` library is to empower the references of mutable languages to the Elm.

## Example code using `Reference`

The following code is the same application using `Reference`s instead of index numbers.

```elm
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
```

## More examples

Though it would not seem to be better than index number version of code in previous example,
it can be more powerful when we have to handle nested list like tree.

```elm
type alias Model =
    { tree : List Node
    }


type Node
    = Node Int (List Node)
```

Example codes including such cases are available in the `example` directory.
