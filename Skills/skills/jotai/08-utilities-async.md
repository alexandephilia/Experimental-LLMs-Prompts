# Jotai Async Utilities

## loadable

Transforms an async atom into a state-aware atom with loading/error/data states. Eliminates the need for `<Suspense>` boundaries.

### Signature
```typescript
loadable<T>(atom: Atom<Promise<T>>): Atom<{
  state: 'loading' | 'hasData' | 'hasError'
  data?: T
  error?: any
}>
```

### Example
```jsx
import { atom, useAtom } from 'jotai'
import { loadable } from 'jotai/utils'

const asyncAtom = atom(async () => {
  const response = await fetch('/api/data')
  return response.json()
})

const loadableAtom = loadable(asyncAtom)

function Component() {
  const [value] = useAtom(loadableAtom)
  
  if (value.state === 'loading') return <div>Loading...</div>
  if (value.state === 'hasError') return <div>Error: {value.error}</div>
  if (value.state === 'hasData') return <div>Data: {value.data}</div>
}
```

## atomWithObservable

Creates a Jotai atom from an RxJS observable. The atom's value is the last emitted value from the stream.

### Signature
```typescript
atomWithObservable<T>(
  getObservable: () => Observable<T>,
  options?: { initialValue?: T | (() => T) }
): Atom<T>
```

### Example
```jsx
import { useAtom } from 'jotai'
import { atomWithObservable } from 'jotai/utils'
import { interval } from 'rxjs'
import { map } from 'rxjs/operators'

const counterStream = interval(1000).pipe(map(i => `#${i}`))
const counterAtom = atomWithObservable(() => counterStream)

// With initial value to avoid Suspense
const counterAtomWithInitial = atomWithObservable(() => counterStream, {
  initialValue: '#0'
})

function Counter() {
  const [counter] = useAtom(counterAtom)
  return <div>Count: {counter}</div>
}
```

## unwrap

Converts an async atom to a sync atom with configurable fallback values. Errors are thrown directly rather than caught.

### Signature
```typescript
unwrap<T>(
  atom: Atom<Promise<T>>,
  fallback?: (prev: T | undefined) => T
): Atom<T | undefined>
```

### Example
```tsx
import { atom } from 'jotai'
import { unwrap } from 'jotai/utils'

const countAtom = atom(0)
const delayedCountAtom = atom(async (get) => {
  await new Promise(r => setTimeout(r, 500))
  return get(countAtom)
})

// Value is undefined while pending
const unwrappedAtom = unwrap(delayedCountAtom)

// Value is 0 initially, keeps previous value on updates
const unwrappedWithFallback = unwrap(delayedCountAtom, (prev) => prev ?? 0)
```