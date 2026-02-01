# Using store outside React

Jotai's state resides in React, but sometimes it would be nice to interact with the world outside React.

## createStore

`createStore` provides a store interface that can be used to store your atoms. Using the store, you can access and mutate the state of your stored atoms from outside React.

```tsx
import { atom, useAtomValue, createStore, Provider } from 'jotai'

const timeAtom = atom(0)

const store = createStore()

store.set(timeAtom, (prev) => prev + 1)

store.get(timeAtom)

function Component() {
  const time = useAtomValue(timeAtom)
  return (
    <div className="App">
      <h1>{time}</h1>
    </div>
  )
}

export default function App() {
  return (
    <Provider store={store}>
      <Component />
    </Provider>
  )
}
```

### Examples

The store interface allows you to interact with atoms from outside React components, making it useful for:
- Setting up initial state
- Responding to external events
- Integrating with non-React libraries
- Server-side operations