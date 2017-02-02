+++
date = "2017-02-02T17:33:00+11:00"
title = "From React to Elm"
draft = false

+++

I have been working in React full time for probably two and a half years now. I work for https://staxapp.io which is large application mostly built on React for the Front end. During this time I have enjoyed working with React very much, it is a great library for building front end applications.

At some point in 2015 I heard about Elm and I was intrigued. I have been dabbling in Elm for over a year, mostly building libraries and making little side projects. 

About two months ago we decided to give Elm a try in our production code, so I have been writing Elm almost full time for the last 2 months. This is how I see Elm compared to React.

# General differences from JavaScript

## Elm is safe and robust

In JavaScript it is common to have runtime exceptions, in Elm on the other hand this is rare. To give you an example I might have an empty list, but I try to access the first element and do something with it:

```js
var users = []
...
users[0].name()
```

It is easy to do such mistakes in JS as there is nothing to in the language to prevent it.

In Elm this kind of run time errors cannot happen. You will have to deal with the possibility of the list being empty.

```elm
list
    |> head
    |> Maybe.map .name
```

This kind of safety is everywhere in Elm. This results in applications that are a lot more resilient and robust.

## Better error handling

In JavaScript it is easy to forget about handling errors and edge cases. The language doesn't push you to think about them in any way. You can just ignore all errors and code only the happy path. There won't be any obvious code smells after doing this. But most likely the app will break at some point in production.

Elm on the other hands is always reminding you about the errors and edge cases you need to deal with. You always need to do something about it.

```
case response of
    Success data ->
        ...
    Err e ->
        ... Do something with the error
```

If I decide to ignore an error or edge case in Elm, I have to do so explicitly.


```
case response of 
    Success data ->
        ...
    _ ->
        ... Ignore this
```

Seeing `_ ->` tells me that I haven't dealt with some code paths in a specific way.

## Terse

With ES6 we can write functions that can be partially applied like:

```js
const sum = (a) => (b) => a + b

const sum4 = sum(4)
```

This is ok, but Elm is much terser:

```elm
sum a b =
    a + b

sum4 =
    sum 4
```

I usually like to use Ramda or Lodash in order to make data pipelines e.g.

```js
_.(collection)
    .map(f1)
    .filter(f2)
    .value()
```

Elm makes these kind of pipeline even nicer:

```elm
collection
    |> map f1
    |> filter f2
```

If you like functional programming in JavaScript you will find that Elm is a much nicer fit.

## Real immutability

Immutability is great for making predictable and robust applications. In JavaScript there are libraries like **Immutable.js** which take you some of the way there. But Immutable.js is not really immutable, you can still mutate objects inside collections. While using this library you need to be diligent and careful, is  easy to do forget to do the correct thing and mutate state even using this library.

Another library that deserves a mention is **seamless-immutable**. This library enforces immutability of objects in a collection. But by doing so you cannot do object equality as you can with Immutable.js.

It is all trade-off with immutability when doing JavaScript.

In Elm everything is immutable. There is no possibility of doing the incorrect thing, you can never mutate an existing thing, the language just doesn't let you.

## Easier to learn

I believe that JavaScript has grown quite complex, there are so many concepts to learn now, like prototypes, classes, this, coercions, promises, generators, async/await, ES6+ features, experimental features that people use everywhere. And the language just keeps growing.

Many of the things you learn are often at odds with other things in the language e.g. classes and this vs functional programming.

Elm in the other hand is a smaller and coherent language. I'm convinced that Elm is an easier language to learn than JS for a new programmer.

## JS caveats

JavaScript is also full of caveats that trip people: 

- coercions
- scoping of `this`
- forgetting to handle errors in promises
- etc

I consider myself to be have a good handle of these things now, but I can see how these can confuse and trip people. Good linting helps a lot to avoid many of these issues.

With Elm we avoid all these things.

## A type system that works

We use **Flow** in our app. It helps, but it has a hard time enforcing types with the dynamism of JavaScript. There are many layers in our application where Flow just can't connect the dots between layers, thus problems are not seen until a runtime exception occurs. I like to call these type black holes. A place where my types are sucked in and nothing comes out.

To give a simple example. If I do something like:

```js
// @flow

var users = [{
    name: "Sam"
}]

users[0].name.foo()
```

Flow will complain that `foo` doesn't exist in `name`. Which is what I want.

But then if I use **lodash** to transform the data:

```js
// @flow

import _ from 'lodash'

var users = [{
    name: "Sam"
}]

var names = _.map(users, 'name')

names[0].foo()
```

Flow says there are no errors. But `foo` doesn't exist on the transformed collection. Lodash acts like a type black hole in my code. 

This can be partially fixed by adding a type annotation to `names`. But what if I add the wrong type annotation? I'm telling a lie and Flow doesn't care.

There are many cases like this when building a large app in JS. We use **Relay**, and it acts like a huge type black hole in our app. Flow cannot connect the types between components on both sides of a Relay container.

On the other hand, the type system in Elm is extremely robust. The Elm compiler will pick up every single problem and offer very nice error messages to help resolve the issues. Because every library in Elm is built from the ground up using the same type system, there are no black holes as it happens in Flow.

I have used **Typescript** for small projects and it seems to pick more things than Flow. But I would need to make a large application with TS to be confident that is more robust.

## Faster iteration

While doing UI work using JavaScript my usual workflow is to code something, open the browser, click around and watch something blow up. Then fix that error and repeat until everything works without issues. This process can be time consuming. Hot state reloading helps with this when it works.

I have noticed that with Elm my workflow has changed substantially. Now I usually code something, run the compiler in the CLI and see the errors there. Then keep doing this until it compiles. Just then open the browser and click around for find issues. Most of the time things work as expected, if they don't it is because a business logic issue, almost never due to a runtime error. This process is much faster than refreshing the page and interacting with the browser, and also finds edge-case errors that might not be obvious with manual testing.

## Better refactoring

Because of the type system, refactoring in Elm is a great experience. I can change a function parameter and the compiler will tell me all the places I need to fix in the application. I haven't found Flow to be that useful in refactoring. I would say that a statically typed language like Elm allows me to be more agile than a dynamic language. I can change and refactor code easily with confidence. The cost of change in JavaScript feels much higher.

## Controlled side effects

In JavaScript I can have side effects anywhere e.g. get the current time, access local storage, mutate state, etc. This can be handy but also makes my functions difficult to test and reason about. I cannot tell what a function is doing without looking at the implementation.

In Elm all functions are pure, meaning they can't interact with the “outside world”. When I need to do some side effects I return a list of things to do instead. These will be executed by the Elm runtime at the top level of my application. In this way functions in Elm are:

- Easier to test, because they can only return values, not interact with the outside world 
- And easier to reason about, as I can see exactly what a function is doing by looking at the type signature.

# React specific

## Simpler

In React you have many way to do things e.g.

*What kind of components should I use?*

- A class extending React.Component
- A Stateless components


*Where do I put my state?*

- Context
- Component state
- Some central state like Redux


*How do I store my state?*

- Plain JS collections
- Some library like Immutable.js, mobx, etc

I often find myself going for one way of doing something and then later on changing it because the requirements has changed. For example I might start with an stateless component and later on need to keep some state, thus having to refactor into a React class.

In Elm there are less decisions to make, there is only way of doing things, which is just composing pure functions.

## More flexibility

In React every component must return one root element. This works most of the time except when it doesn't. For example sometimes I want a component to return two table rows as they represent a logical unit. You can't do this with React.

In Elm there is no such limitation. Your views can return a list of elements, then we just concatenate the list together. Views in Elm are just functions and they can return whatever I need.

## Easier to set up

Setting up a React project can be very involving, there are lots of decisions to make and everything has to be set just right for it to work together. Common things that need to be configured can include:

- Babel + Flow or Typescript
- Many Babel plug-ins
- React + React DOM
- Redux
- Some immutable library
- Ramda, lodash
- Webpack

Getting all these things to work nicely together can be huge time sink.

In Elm there is a lot less to do, usually it comes down to downloading Elm and setting webpack. Everything else is already covered by Elm.

## Simpler routing

We use React Router 2 in our application, I haven't tried the newest version yet, so RR 4 may be much simpler. But in comparison to RR 2, routing in Elm feels incredible simple. RR is full of lifecycle hooks and has a non-trivial API to learn. 

In contrast, routing in Elm is just a function that takes the browser location and returns a matched route. Using the matched route we can decide what to show in the views. Elm doesn't try to manage your application views like RR and this simple approach works surprisingly well.

Adding "middleware" or "hooks" in Elm is also very straightforward, everything is made of functions that can be trivially composed together.

# Trade-offs

There are of course trade-offs:

## More DIY

There are a lot more ready made components in React than Elm. We haven't found this to be huge issue however. We had to build some common components ourselves but the amount of available libraries is increasing rapidly as the community is growing.

## Code splitting, code sharing and SSR

Code splitting in Elm is not a thing for the moment. We do this using Webpack, but we do it in the JavaScript side.

Also sharing bundled code between Elm apps is not possible yet, as I understand work is being done about this.

Furthermore, server side rendering still not possible. Not easily at least.

## Interacting with JavaScript

Interacting with JavaScript libraries is possible, via ports, but can be tedious.

This is not a big deal when there is only a handful of things you need to do in JavaScript, but it can become annoying if you need to pass a lot of message back and forth.

## JSON decoders

As Elm is a static typed language we need to decode and encode between JSON and Elm records all the time. This can feel laborious and confusing at first, but with practice it becomes a non-issue. The type safety is definitely worth this.

## Some boilerplate for simple things

There are times where you need a simple piece of "internal" state in a view e.g. `collapsed=true/false`. This is quite simple to handle with component state in React. 

In Elm we cannot do this, all state must be in one place. This forces us to add a decent amount of boilerplate in the application to handle to handle the state for a view. E.g. state needs to be passed down the views. Messages need to wired up from the root to the relevant views.

## CSS still a WIP

Dealing with CSS in Elm still feels like a work in progress. There is `elm-css` which is great library for defining CSS rules. But we  are still experimenting on how to structure the CSS in a big application. For example: how to aggregate all CSS for all views, how to namespace class names, how to inject the CSS in the page. These are some problems that are already solved in JavaScript, but still unclear in Elm.

# Conclusion

I'm enjoying developing with Elm a lot, I believe that the benefits far outweigh the trade-offs. The safety and refactoring experience alone are huge selling points for me. We definitely intend do keep using Elm in new features in our application and new projects.

If you are interested here are some good learning resources:

- https://pragmaticstudio.com/elm
- http://elm-tutorial.org/
- http://elmprogramming.com/
