# Initializing state on render

## Introduction

Jotai takes an atomic approach to global React state management.

Build state by combining atoms and renders are automatically optimized based on atom dependency. This solves the extra re-render issue of React context, eliminates the need for memoization, and provides a similar developer experience to signals while maintaining a declarative programming model.

It scales from a simple `useState` replacement to an enterprise TypeScript application with complex requirements. Plus there are plenty of utilities and extensions to help you along the way!

## Getting started

This walks you through the process of creating a simple Jotai application. It starts with installation, then explores the basics of the core API, and ends with server-side rendering in a React framework.

### Installation

First add Jotai as a dependency to your React project.

```bash
npm install jotai
# or
yarn add jotai
# or
pnpm add jotai
```

### Create atoms

First create primitive and derived atoms to build state.

#### Primitive atoms

A primitive atom can be any type: booleans, numbers, strings, objects, arrays, sets, maps, and so on.

```javascript
import { atom } from 'jotai'

const countAtom = atom(0)
const countryAtom = atom('Japan')
const citiesAtom = atom(['Tokyo', 'Kyoto', 'Osaka'])

export const animeAtom = atom([
  {
    title: 'Ghost in the Shell',
    year: 1995,
    watched: true
  },
  {
    title: 'Serial Experiments Lain',
    year: 1998,
    watched: false
  }
])
```

#### Derived atoms

A derived atom can read from other atoms before returning its own value.

```javascript
const progressAtom = atom((get) => {
  const anime = get(animeAtom)
  return anime.filter((item) => item.watched).length / anime.length
})
```

### Use atoms

Then use atoms within React components to read or write state.

#### Read and write from same component

When atoms are both read and written within the same component, use the combined `useAtom` hook for simplicity.

```javascript
import { useAtom } from 'jotai'
import { animeAtom } from './atoms'

const AnimeApp = () => {
  const [anime, setAnime] = useAtom(animeAtom)
  
  return (
    <>
      <ul>
        {anime.map((item) => (
          <li key={item.title}>{item.title}</li>
        ))}
      </ul>
      <button onClick={() => {
        setAnime((anime) => [
          ...anime,
          {
            title: 'Cowboy Bebop',
            year: 1998,
            watched: false
          }
        ])
      }}>
        Add Cowboy Bebop
      </button>
    </>
  )
}
```

#### Read and write from separate components

When atom values are only read or written, use the separate `useAtomValue` and `useSetAtom` hooks to optimize re-renders.

```javascript
import { useAtomValue, useSetAtom } from 'jotai'
import { animeAtom } from './atoms'

const AnimeList = () => {
  const anime = useAtomValue(animeAtom)
  
  return (
    <ul>
      {anime.map((item) => (
        <li key={item.title}>{item.title}</li>
      ))}
    </ul>
  )
}

const AddAnime = () => {
  const setAnime = useSetAtom(animeAtom)
  
  return (
    <button onClick={() => {
      setAnime((anime) => [
        ...anime,
        {
          title: 'Cowboy Bebop',
          year: 1998,
          watched: false
        }
      ])
    }}>
      Add Cowboy Bebop
    </button>
  )
}

const ProgressTracker = () => {
  const progress = useAtomValue(progressAtom)
  
  return (
    <div>{Math.trunc(progress * 100)}% watched</div>
  )
}

const AnimeApp = () => {
  return (
    <>
      <AnimeList />
      <AddAnime />
      <ProgressTracker />
    </>
  )
}
```

## Server-side rendering

If server-side rendering with a framework such as Next.js or Waku, make sure to add a Jotai Provider component at the root.

### Next.js (app directory)

Create the provider in a separate client component. Then import the provider into the root `layout.js` server component.

```javascript
'use client'

import { Provider } from 'jotai'

export const Providers = ({ children }) => {
  return (
    <Provider>
      {children}
    </Provider>
  )
}
```

```javascript
import { Providers } from '../components/providers'

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
        <Providers>
          {children}
        </Providers>
      </body>
    </html>
  )
}
```

### Next.js (pages directory)

Create the provider in `_app.js`.

```javascript
import { Provider } from 'jotai'

export default function App({ Component, pageProps }) {
  return (
    <Provider>
      <Component {...pageProps} />
    </Provider>
  )
}
```

### Waku

Create the provider in a separate client component. Then import the provider into the root layout.

```javascript
'use client'

import { Provider } from 'jotai'

export const Providers = ({ children }) => {
  return (
    <Provider>
      {children}
    </Provider>
  )
}
```

```javascript
import { Providers } from '../components/providers'

export default async function RootLayout({ children }) {
  return (
    <Providers>
      {children}
    </Providers>
  )
}
```

## API overview

### Core

Jotai has a very minimal API and is TypeScript oriented. It is as simple to use as React's integrated `useState` hook, but all state is globally accessible, derived state is easy to implement, and unnecessary re-renders are automatically eliminated.

```javascript
import { atom, useAtom } from 'jotai'

const textAtom = atom('hello')

const uppercaseAtom = atom(
  (get) => get(textAtom).toUpperCase()
)

const Input = () => {
  const [text, setText] = useAtom(textAtom)
  const handleChange = (e) => setText(e.target.value)
  
  return (
    <input value={text} onChange={handleChange} />
  )
}

const Uppercase = () => {
  const [uppercase] = useAtom(uppercaseAtom)
  
  return (
    <div>Uppercase: {uppercase}</div>
  )
}

const App = () => {
  return (
    <>
      <Input />
      <Uppercase />
    </>
  )
}
```

### Utilities

The Jotai package also includes a `jotai/utils` bundle. These extra functions add support for persisting an atom in localStorage, hydrating an atom during server-side rendering, creating atoms with Redux-like reducers and action types, and much more.

This toggle will be persisted between user sessions via localStorage.

```javascript
import { useAtom } from 'jotai'
import { atomWithStorage } from 'jotai/utils'

const darkModeAtom = atomWithStorage('darkMode', false)

const Page = () => {
  const [darkMode, setDarkMode] = useAtom(darkModeAtom)
  const toggleDarkMode = () => setDarkMode(!darkMode)
  
  return (
    <>
      <h1>Welcome to {darkMode ? 'dark' : 'light'} mode!</h1>
      <button onClick={toggleDarkMode}>toggle theme</button>
    </>
  )
}
```

### Extensions

There are also separate packages for each official extension: tRPC, Immer, Query, XState, URQL, Optics, Relay, location, molecules, cache, and more.

Some extensions provide new atom types with alternate write functions such as `atomWithImmer` (Immer) or `atomWithMachine` (XState).

Others provide new atom types with two-way data binding such as `atomWithLocation` or `atomWithHash`.

```javascript
import { useAtom } from 'jotai'
import { atomWithImmer } from 'jotai-immer'

const countAtom = atomWithImmer(0)

const Counter = () => {
  const [count] = useAtom(countAtom)
  
  return (
    <div>count: {count}</div>
  )
}

const Controls = () => {
  const [, setCount] = useAtom(countAtom)
  const increment = () => setCount((c) => (c = c + 1))
  
  return (
    <button onClick={increment}>+1</button>
  )
}
```