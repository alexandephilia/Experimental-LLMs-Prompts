# Effect Extension

The `jotai-effect` package provides utilities for managing side effects in Jotai atoms.

## Installation

```bash
npm install jotai-effect
```

## observe

Observes atom value changes and triggers effects.

```js
import { observe } from 'jotai-effect'

const countAtom = atom(0)

// Basic observation
const unsubscribe = observe(countAtom, (value) => {
  console.log('Count changed:', value)
})

// With store
observe(countAtom, (value) => {
  console.log('Count:', value)
}, store)
```

## atomEffect

Creates an atom that runs effects when dependencies change.

```js
import { atomEffect } from 'jotai-effect'

const countAtom = atom(0)
const nameAtom = atom('John')

// Effect atom with dependencies
const logEffect = atomEffect((get, set) => {
  const count = get(countAtom)
  const name = get(nameAtom)
  
  console.log(`${name}: ${count}`)
  
  // Cleanup function
  return () => {
    console.log('Effect cleanup')
  }
})
```

## withAtomEffect

Higher-order function that adds effect capabilities to existing atoms.

```js
import { withAtomEffect } from 'jotai-effect'

const baseAtom = atom(0)

const enhancedAtom = withAtomEffect(baseAtom, (get, set) => {
  const value = get(baseAtom)
  
  // Side effect
  localStorage.setItem('count', value.toString())
  
  return () => {
    localStorage.removeItem('count')
  }
})
```

## Dependency Management

Effects automatically track dependencies through `get()` calls:

```js
const userAtom = atom({ id: 1, name: 'John' })
const settingsAtom = atom({ theme: 'dark' })

const syncEffect = atomEffect((get, set) => {
  const user = get(userAtom)
  const settings = get(settingsAtom)
  
  // Only runs when user or settings change
  api.sync({ user, settings })
})
```

## Effect Behavior

- Effects run after atom updates
- Cleanup functions run before next effect or unmount
- Effects are batched within the same update cycle
- Circular dependencies are prevented

```js
const dataAtom = atom([])
const loadingAtom = atom(false)

const fetchEffect = atomEffect((get, set) => {
  const loading = get(loadingAtom)
  
  if (loading) {
    const controller = new AbortController()
    
    fetch('/api/data', { signal: controller.signal })
      .then(res => res.json())
      .then(data => set(dataAtom, data))
      .finally(() => set(loadingAtom, false))
    
    return () => controller.abort()
  }
})
```