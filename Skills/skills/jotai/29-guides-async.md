# Async

Using async atoms, you gain access to real-world data while still managing them directly from your atoms and with incredible ease.

We can separate them in two main categories:

- **Async read atoms**: async request is started instantly as soon as you try to get its value. You could relate to them as "smart getters".
- **Async write atoms**: async request is started at a specific moment. You could relate to them as "actions".

## Async read atom

The `read` function of an atom can return a promise.

```javascript
const countAtom = atom(1)

const asyncAtom = atom(async (get) => get(countAtom) * 2)
```

Jotai is inherently leveraging `Suspense` to handle asynchronous flows.

```javascript
const ComponentUsingAsyncAtoms = () => {
  const [num] = useAtom(asyncAtom)
}

const App = () => {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <ComponentUsingAsyncAtoms />
    </Suspense>
  )
}
```

Alternatively, you could avoid the inherent suspending that Jotai does for you, by wrapping your atoms with the `loadable` API.

If another atom uses an async atom, it will return a promise. So, we need to make the atom also async.

```javascript
const anotherAtom = atom(async (get) => (await get(asyncAtom)) / 2)
```

This also applies to an atom with write function.

```javascript
const asyncAtom = atom(async (get) => ...)

const writeAtom = atom(null, async (get, set, payload) => {
  await get(asyncAtom)
})
```

## Async write atom

Async write atoms are another kind of async atom. When the `write` function of atom returns a promise.

```javascript
const countAtom = atom(1)

const asyncIncrementAtom = atom(null, async (get, set) => {
  set(countAtom, get(countAtom) + 1)
})

const Component = () => {
  const [, increment] = useAtom(asyncIncrementAtom)
  
  const handleClick = () => {
    increment()
  }
}
```

## Async sometimes

An interesting pattern that can be achieved with Jotai is switching from async to sync to trigger suspending when wanted.

```javascript
const request = async () => fetch('https://...').then((res) => res.json())

const baseAtom = atom(0)

const Component = () => {
  const [value, setValue] = useAtom(baseAtom)
  
  const handleClick = () => {
    setValue(request())
  }
}
```

### Usage in TypeScript

In TypeScript `atom(0)` is inferred as `PrimitiveAtom<number>`. It cannot accept `Promise<number>` as a value so preceding code would not typecheck. To accommodate for that you need to type your atom explicitly and add `Promise<number>` as accepted value.

```typescript
const baseAtom = atom<number | Promise<number>>(0) // Will accept sync and async values
```

## Async forever

Sometimes you may want to suspend until an unpredetermined moment (or never).

```javascript
const baseAtom = atom(new Promise(() => {}))
```

## Suspense

Async support is first class in Jotai. It fully leverages React Suspense at its core.

> Technically, Suspense usage other than React.lazy is still unsupported / undocumented in React 17. If this is blocking, so you can still use the `loadable` API to avoid suspending

To use async atoms, you need to wrap your component tree with `<Suspense>`.

> If you have a `<Provider>`, place **at least one**`<Suspense>` inside said `<Provider>`; otherwise, it may cause an endless loop while rendering the components.

```javascript
const App = () => (
  <Provider>
    <Suspense fallback="Loading...">
      <Layout />
    </Suspense>
  </Provider>
)
```

Having more `<Suspense>`s in the component tree is also possible and must be considered to profit from Jotai inherent handling at best.