# Jotai Resettable Utilities

Utilities for creating atoms that can be reset to their initial values.

## atomWithReset

Creates an atom that can be reset to its initial value using the `useResetAtom` hook or `RESET` symbol.

```typescript
function atomWithReset<Value>(
  initialValue: Value,
): WritableAtom<Value, SetStateAction<Value> | typeof RESET>
```

### Example

```javascript
import { atomWithReset } from 'jotai/utils'

const dollarsAtom = atomWithReset(0)

const todoListAtom = atomWithReset([
  { description: 'Add a todo', checked: false },
])
```

## RESET Symbol

Special symbol accepted by resettable atoms created with `atomWithReset`, `atomWithDefault`, or custom writable atoms.

```typescript
const RESET: unique symbol
```

### Example

```javascript
import { atom, useSetAtom } from 'jotai'
import { atomWithReset, useResetAtom, RESET } from 'jotai/utils'

const dollarsAtom = atomWithReset(0)

const centsAtom = atom(
  (get) => get(dollarsAtom) * 100,
  (get, set, newValue: number | typeof RESET) =>
    set(dollarsAtom, newValue === RESET ? newValue : newValue / 100)
)

const ResetExample = () => {
  const setDollars = useSetAtom(dollarsAtom)
  const resetCents = useResetAtom(centsAtom)
  
  return (
    <>
      <button onClick={() => setDollars(RESET)}>Reset dollars</button>
      <button onClick={resetCents}>Reset cents</button>
    </>
  )
}
```

## useResetAtom Hook

Hook that resets a resettable atom to its initial value.

```typescript
function useResetAtom<Value>(
  anAtom: WritableAtom<Value, typeof RESET>,
): () => void | Promise<void>
```

### Example

```javascript
import { useResetAtom } from 'jotai/utils'
import { todoListAtom } from './store'

const TodoResetButton = () => {
  const resetTodoList = useResetAtom(todoListAtom)
  return <button onClick={resetTodoList}>Reset</button>
}
```

## atomWithDefault

Creates a resettable atom with a default value computed by a function instead of a static initial value.

```javascript
import { atomWithDefault } from 'jotai/utils'

const count1Atom = atom(1)
const count2Atom = atomWithDefault((get) => get(count1Atom) * 2)
```

### Resetting Default Values

```javascript
import { useAtom } from 'jotai'
import { atomWithDefault, useResetAtom, RESET } from 'jotai/utils'

const count1Atom = atom(1)
const count2Atom = atomWithDefault((get) => get(count1Atom) * 2)

const Counter = () => {
  const [count1, setCount1] = useAtom(count1Atom)
  const [count2, setCount2] = useAtom(count2Atom)
  const resetCount2 = useResetAtom(count2Atom)
  
  return (
    <>
      <div>
        count1: {count1}, count2: {count2}
      </div>
      <button onClick={() => setCount1((c) => c + 1)}>increment count1</button>
      <button onClick={() => setCount2((c) => c + 1)}>increment count2</button>
      <button onClick={() => resetCount2()}>Reset with useResetAtom</button>
      <button onClick={() => setCount2(RESET)}>Reset with RESET const</button>
    </>
  )
}
```

## atomWithRefresh

Creates an atom that can be refreshed to force reevaluation of its read function.

```typescript
function atomWithRefresh<Value>(
  read: Read<Value, [], void>,
): WritableAtom<Value, [], void>

function atomWithRefresh<Value, Args extends unknown[], Result>(
  read: Read<Value, Args, Result>,
  write: Write<Value, Args, Result>,
): WritableAtom<Value, Args | [], Result | void>
```

### Example

```javascript
import { atomWithRefresh } from 'jotai/utils'

const postsAtom = atomWithRefresh((get) =>
  fetch('https://jsonplaceholder.typicode.com/posts').then((r) => r.json()),
)

const PostsList = () => {
  const [posts, refreshPosts] = useAtom(postsAtom)
  
  return (
    <div>
      <ul>
        {posts.map((post) => (
          <li key={post.id}>{post.title}</li>
        ))}
      </ul>
      <button type="button" onClick={() => refreshPosts()}>
        Refresh posts
      </button>
    </div>
  )
}
```

## Key Points

- `atomWithReset` creates atoms that can be reset using `useResetAtom` or `RESET` symbol
- `RESET` is a special symbol that triggers reset behavior
- `useResetAtom` provides a convenient hook for resetting atoms
- `atomWithDefault` allows computed default values that can be reset
- `atomWithRefresh` enables force re-evaluation of async data
- Resetting restores original default values, discarding any changes made via `set`