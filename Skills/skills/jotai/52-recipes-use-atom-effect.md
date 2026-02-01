# useAtomEffect Recipe

A custom hook for running effects based on atom value changes.

## Basic Implementation

```js
import { useAtomValue } from 'jotai'
import { useEffect } from 'react'

function useAtomEffect(atom, effect, deps = []) {
  const value = useAtomValue(atom)
  
  useEffect(() => {
    return effect(value)
  }, [value, ...deps])
}
```

## Usage Examples

### Simple Effect

```js
const countAtom = atom(0)

function Counter() {
  const [count, setCount] = useAtom(countAtom)
  
  useAtomEffect(countAtom, (count) => {
    document.title = `Count: ${count}`
  })
  
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>
}
```

### Effect with Cleanup

```js
const userAtom = atom(null)

function UserProfile() {
  useAtomEffect(userAtom, (user) => {
    if (!user) return
    
    const interval = setInterval(() => {
      console.log(`Active user: ${user.name}`)
    }, 5000)
    
    return () => clearInterval(interval)
  })
  
  return <div>User Profile</div>
}
```

### Multiple Dependencies

```js
const searchAtom = atom('')
const filtersAtom = atom({})

function SearchResults() {
  useAtomEffect(searchAtom, async (query) => {
    if (query.length < 3) return
    
    const results = await searchAPI(query)
    // Handle results
  })
  
  // Effect with additional dependencies
  useAtomEffect(filtersAtom, (filters) => {
    analytics.track('filters_changed', filters)
  }, [])
  
  return <div>Search Results</div>
}
```

## Enhanced Version

```js
import { useAtomValue } from 'jotai'
import { useEffect, useRef } from 'react'

function useAtomEffect(atom, effect, options = {}) {
  const { 
    deps = [], 
    immediate = true,
    skipFirst = false 
  } = options
  
  const value = useAtomValue(atom)
  const isFirst = useRef(true)
  
  useEffect(() => {
    if (skipFirst && isFirst.current) {
      isFirst.current = false
      return
    }
    
    return effect(value)
  }, immediate ? [value, ...deps] : deps)
}
```

### Enhanced Usage

```js
function Component() {
  // Skip effect on first render
  useAtomEffect(dataAtom, (data) => {
    saveToLocalStorage(data)
  }, { skipFirst: true })
  
  // Effect with custom dependencies
  useAtomEffect(userAtom, (user) => {
    updateUserPreferences(user)
  }, { deps: [someOtherValue] })
}
```