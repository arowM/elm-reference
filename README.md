# elm-reference

[![Build Status](https://travis-ci.org/arowM/elm-reference.svg?branch=master)](https://travis-ci.org/arowM/elm-reference)

An immutable approach to mutable references.

[![elm-reference-small](https://user-images.githubusercontent.com/1481749/43362741-ad7a4868-932c-11e8-94a6-850c904b814e.png)
](https://twitter.com/hashtag/%E3%81%95%E3%81%8F%E3%82%89%E3%81%A1%E3%82%83%E3%82%93%E6%97%A5%E8%A8%98?src=hash)

Any PRs are welcome, even for documentation fixes.  (The main author of this library is not an English native.)

![example](https://user-images.githubusercontent.com/1481749/43438888-6a75b5e8-94cb-11e8-873d-06778ead6051.gif)

## Top of Contents

* [What problem can `Reference` resolve?](#what-problem-can-reference-resolve)
* [Mutable references can help!](#mutable-references-can-help)
* [Concept of a `Reference`](#concept-of-a-reference)
* [Example code using `Reference`](#example-code-using-reference)
* [More examples](#more-examples)
* [Related works](#related-works)

## What problem can `Reference` resolve?

Many programs need to render lists of things. (e.g. TODOs, registered users, lists of posts.)
`Reference` is here to help solve that problem.

Here's a simple application that increments numbers in a list.

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

This code uses a technique common in the Elm architecture. However, it isn't as straightforward as it could be.
How could we solve this problem more intuitively?

## Mutable references can help!

Some mutable programing languages use references. Here's an example in JS:

```js
> arr = [ {val: 1}, {val: 2}, {val: 3} ]
> x = arr[1]
> x.val = 3
> arr
[ { val: 1 }, { val: 3 }, { val: 3 } ]
```

If Elm could solve this problem in a similar way, a Msg type could be defined without an index like this:

```elm
type Msg
    = ClickNumber SomeSortOfReference
```

This is the motivation of the `Reference` library.

## Concept of a `Reference`

A `Reference` internally tracks two values: `this` and `root`.

* `this` is the currently focused value (`x = arr[1]` in the previous JS example)
* `root` is the root value (`arr` in the previous JS example)

The core data type of `Reference` is `Reference this root` where `this` is the type of an individual value and `root` is the container that the current value is stored inside of. For example, when referencing a `List Int` the signature would be `Reference Int (List Int)`.

Create a Reference by providing a `this` value and a function which specifies how `root` depends on the `this` value.

```elm
fromRecord : { this : a, rootWith : a -> root } -> Reference a root
```

To pick out the `this` value and the `root` value from a `Reference`, use these simple functions:

```elm
this : Reference this root -> this
root : Reference this root -> root
```

Putting it all together:

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

Here's where `Reference` really starts to shine. We'll modify the `ref` value we declared in the last example
by using the `modify` function.

```elm
modify : (a -> a) -> Reference a root -> Reference a root
```

As you can see in this example, `modify` updates both the `this` and `root` values.

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

Remember the first application we looked at earlier? Here's the same application using `Reference` instead of indexes.

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

Although working with just a `List Int` shows improvement, `Reference` can be even more
powerful with more complex structures like Trees.

```elm
type alias Model =
    { tree : List Node
    }


type Node
    = Node Int (List Node)
```

If you'd like to see what using `Reference` with this structure looks like, take a look in the `example` directory.

## Related works

### Lens

[Monocle-Lens](http://package.elm-lang.org/packages/arturopala/elm-monocle/1.7.0/Monocle-Lens) is similar in concept to `Reference`. However, it's not quite the same. I developed this library for three reasons:

First, `Reference` is at a slightly higher abstraction than Lens. If you used Lens to do what Reference does, you could
write the type signature like this:

```elm
type alias Reference this root = ( this, Lens this root )
```

Since we want to update a specific value, we need to indicate what that value is. `Reference` makes this structure easier to work with.
You could do it with Lens, but you'd write very similar code to what `Reference` already contains.

Second, as an extension of the first reason, the Elm community recommends [targeting concrete use cases](https://github.com/elm-lang/elm-package#designing-apis).
This is a concrete use case, so it should be published as an independent library.

Third, the `Reference.List.unwrap` function is very powerful, but its implementation is not very easy. It's might even be worth
publishing `elm-reference` just to provide `Reference.List.unwrap`.

### Zipper

There is another similar approach called Zippers.

Here's a few implementations for Trees:

* `zwilias/elm-rosetree/Tree-Zipper` simple but fast
* `tomjkidd/elm-multiway-tree-zipper` sturdy but faster
* `turboMaCk/lazy-tree-with-zipper` - [Experimental] lazy but very fast

`Reference` and `Zipper` correspond pretty well:

* `this` is equivalent to a `label`
* `root` is equivalent to the `zipped tree`
* `ref` is equivalent to a tree zipper (A `Zipper (Tree a)`, though no libraries offer that syntax.)

There are two main differences:

First, Zippers are typically focused on viewing specific elements of a collection,
while `Reference` is more focused on updating specific elements of a collection.

Second, Zipper's are targeted to specific collection types. There are list zippers, and binary tree
zippers and rose tree zippers, and probably more. `Reference` gives up some of the more convenent
methods of those specific implementations (since it knows nothing about its collection), but gains
the ability to work with very unusual and uncommon structures in exchange. Like this one `type BiTree = Node (List BiTree) (List BiTree)`,
or the UpDown structure in [this example](https://github.com/arowM/elm-reference/blob/master/example/src/UpDown.elm).
