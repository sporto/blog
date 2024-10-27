---
layout: default.liquid

published_date: 2024-10-27 21:00:00 +1000
title: Firing effects by observing state is not a good pattern
is_draft: false
---

I jumped into the React bandwagon many years ago, when React had class components and stateless components. React wasn't perfect, but it was very nice at the time. But then I moved to Elm full-time, I have been working for Elm for about 7 years. In this type I completly missed the introduction of hooks in React.

Last year I inherited a big React app. This app uses hooks heavily, which makes sense as that was the idiomatic way of building React apps when this app was built. Unfortunately what I encountered was a plethora of bugs for me to fix, these bugs were mostly related to complex user interactions. The UI will go into a bad state if users interact with the app in a certain way. These bugs were ever present in the app, several good React developers have tried to tacke them.

After struggling with these bugs for a while, I realised that the hard part of fixing these bugs was the difficulty of following the async flow of a user interactions. `useEffect` was used everywhere to **fire side effects by observing state changes**. For example:

```js
useEffect(() => {
  // do some side effect when state changes
  sendDebouncedSearchQuery(searchQuery)
}, [searchQuery]);
```

This is a common pattern in React, [Solid](https://docs.solidjs.com/concepts/effects#using-an-effect), [Svelte](https://svelte.dev/docs/svelte/$effect) and probably many others.

## What is the problem with this?

If you try to debug a buggy interaction, you probably start by looking at a user action like clicking a button, then follow the code breadcrumbs. But this pattern breaks this, you cannot linearly follow the breadcrumbs. You need to read all the code for a component to find pieces of code that observe state like the one above. Then you need to make a mental graph in your head of dependencies, changing this state, triggers this side effect, which then changes this other state and so on. The state and effect code is scattered around, resulting in a lot of overhead to understand a particular flow.

## What is a good alternative?

Turns out Elm had a great answer for this years ago. In Elm the UI triggers messages, which are handled in an `update` function (similar to Redux). But unlike Redux, the `update` function returns two things: the new state and any side effects to be fired. Something like this in JS:

```js
function update(state, action) {
  if (action.type === 'changeSearch') {
    return [
      // updated state
      {
        searchQuery: state.searchQuery
      },
      // side effects to be fired
      sendDebouncedSearchQuery(state.searchQuery)
    ];
  }
  ...
}
```

You have the new state and the side effects in one place. What this gives you is a much easier time following the breadcrumbs of complex user interactions. Experience tells me that this is a much better way of structuring an app. Unfortunately, this pattern doesn't seem to be popular in JS frameworks. [This](https://github.com/atheck/react-elmish) is the best implementation I have find so far.
