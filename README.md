# elm-reference

[![Build Status](https://travis-ci.org/arowM/elm-reference.svg?branch=master)](https://travis-ci.org/arowM/elm-reference)

An immutable approach imitating references of mutable languages.

[![elm-reference-small](https://user-images.githubusercontent.com/1481749/43362741-ad7a4868-932c-11e8-94a6-850c904b814e.png)
](https://twitter.com/hashtag/%E3%81%95%E3%81%8F%E3%82%89%E3%81%A1%E3%82%83%E3%82%93%E6%97%A5%E8%A8%98?src=hash)

Any PRs are welcome, even for documentation fixes.  (The main author of this library is not an English native.)

![example](https://user-images.githubusercontent.com/1481749/43438888-6a75b5e8-94cb-11e8-873d-06778ead6051.gif)

## Top of Contents

* [What problem can `Reference` resolve?](#what-problem-can-reference-resolve)
* [Reference of mutable programing languages help us!](#reference-of-mutable-programing-languages-help-us)
* [Concept of the `Reference`](#concept-of-the-reference)
* [Example code using `Reference`](#example-code-using-reference)
* [More examples](#more-examples)
* [Related works](#related-works)

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

## Concept of the `Reference`

`Reference` has concept of `this` and `root`.

* `this` means focused value (`x = arr[1]` in the previous JS example)
* `root` means root value (`arr` in the previous JS example)

The core data type of `Reference` is `Reference this root`, which can be created by prividing `this` value and function to specify how `root` depends on the `this` value.

```elm
fromRecord : { this : a, rootWith : a -> root } -> Reference a root
```

To pick out `this` value and `root` value from `Reference`, use following functions.

```elm
this : Reference this root -> this
root : Reference this root -> root
```

Now we can create `Reference` and then pick out `this` and `value`.

```elm
ref : Reference Int (List Int)
ref = fromRecord
    { this = 3
    , rootWith = \x -> [1,2] ++ x :: [4,5]
    }

this ref
--> 3

root ref
--> [ 1, 2, 3, 4, 5 ]
```

Next, let's modify the `ref` value declared in the above example.
We can use `modify` for the purpose.

```elm
modify : (a -> a) -> Reference a root -> Reference a root
```

As you can see in the bellow example, `modify` also updates `root` value.

```elm
ref2 : Reference Int (List Int)
ref2 = modify (\n -> n + 1) ref

this ref
--> 3
this ref2
--> 4

root ref
--> [ 1, 2, 3, 4, 5 ]
root ref2
--> [ 1, 2, 4, 4, 5 ]
```

## Example code using `Reference`

The following code is the same application using `Reference`s instead of index numbers.

```elm
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

## Related works

### Lens

[Monocle-Lens](http://package.elm-lang.org/packages/arturopala/elm-monocle/1.7.0/Monocle-Lens) is one of the similar concept to `Reference`.

There are three reasons why I developed this library.

First, this is not completely the same structure with Lens. `Reference this root` can be rewritten by following definition.

```elm
type alias Reference this root = ( this, Lens this root )
```

The main target usage of this library is updating list value when some events are fired on sub view as example app described previously.
So, it is important to hold current value (i.e., `this`) itself in the data type.

Second, it is recommended to target a concrete use case as [Designing APIs](https://github.com/elm-lang/elm-package#designing-apis) of elm-package says.
It means `elm-reference` should be published as an independent library to handle concrete use case described above.

Third, the `Reference.List.unwrap` function is so powerfull for such a usage but not so easy for end users to implement by themselves.
It is worth publishing `elm-reference` just to provide `Reference.List.unwrap`.

### Zipper

There is an approach called `Zipper` to handle tree-like structures.

For example, following implementations exist.

* `zwilias/elm-rosetree/Tree-Zipper` simple but fast
* `tomjkidd/elm-multiway-tree-zipper` sturdy but faster
* `turboMaCk/lazy-tree-with-zipper` - [Experimental] lazy but very fast

The relation between `Zipper` and `Reference` is:

* `this` is equivalent to a `label`
* `root` is equivalent to the `zipped tree`
* `ref` is equivalent to a tree zipper

But `Zipper` is not exactly for the purpose of updating an element by View events.
I guess it's not so easy question "How to resolve Vue tree view example in Elm using Zipper?".
In that point of view, `Reference` is more suitable to handle such problems.
(Of course, it is recommended to use `Zipper` if an application requires tree navigation feature.)

From another point of view, `Reference` is one of the abstruction of tree Zipper.
The `Zipper` is specialized version of `Reference` (`type alias Zipper a = Reference a (Tree a)`).
It means `Reference` can handle any structures in addition to `Tree`.
One example that `Zipper` cannot handle is strange Tree structure such as `type BiTree = Node (List BiTree) (List BiTree)`.
Another example that `Zipper` could not handle easily is [UpDown example](https://github.com/arowM/elm-reference/blob/master/example/src/UpDown.elm) in the `example` directory.
