# Jotai Family Utility

## atomFamily (Deprecated)

:::caution Deprecated
`atomFamily` is deprecated and will be removed in Jotai v3.

Please migrate to the `jotai-family` package, which provides the same API with additional features like `atomTree`.

**Migration:**
```bash
npm install jotai-family
```

```javascript
// Before
import { atomFamily } from 'jotai/utils'

// After
import { atomFamily } from 'jotai-family'
```

The API is identical, so no code changes are needed beyond the import statement.
:::

## Usage

```javascript
atomFamily(initializeAtom, areEqual): (param) => Atom
```

Creates a function that takes `param` and returns an atom. If the atom has already been created, it will be returned from the cache. `initializeAtom` is a function that can return any kind of atom (`atom()`, `atomWithDefault()`, ...). The `areEqual` argument is optional and compares if two params are equal (defaults to `Object.is`).

To reproduce behavior similar to Recoil's atomFamily/selectorFamily, specify a deepEqual function to `areEqual`:

```javascript
import { atom } from 'jotai'
import { atomFamily } from 'jotai/utils'
import deepEqual from 'fast-deep-equal'

const fooFamily = atomFamily((param) => atom(param), deepEqual)
```

## TypeScript Types

The atom family types will be inferred from initializeAtom. Here's a typical usage with a primitive atom:

```typescript
import type { PrimitiveAtom } from 'jotai'

/**
 * here the atom(id) returns a PrimitiveAtom<number>
 * and PrimitiveAtom<number> is a WritableAtom<number, SetStateAction<number>>
 */
const myFamily = atomFamily((id: number) => atom(id))
```

You can explicitly declare the type of parameter and atom type using TypeScript generics:

```typescript
atomFamily<Param, AtomType extends Atom<unknown>>(
  initializeAtom: (param: Param) => AtomType,
  areEqual?: (a: Param, b: Param) => boolean
): AtomFamily<Param, AtomType>
```

Example with explicit types:

```typescript
import { atom } from 'jotai'
import type { PrimitiveAtom } from 'jotai'
import { atomFamily } from 'jotai/utils'

const myFamily = atomFamily<number, PrimitiveAtom<number>>((id: number) =>
  atom(id),
)
```

## API Methods

The `atomFamily` function returns an object with the following methods:

### `myFamily(param)`

Returns an atom for the given param. If the atom has already been created, it will be returned from the cache.

### `getParams()`

Returns an iterable of all params currently in the cache.

```javascript
const todoFamily = atomFamily((name) => atom(name))

todoFamily('foo')
todoFamily('bar')

for (const param of todoFamily.getParams()) {
  console.log(param) // 'foo', 'bar'
}
```

### `remove(param)`

Removes a specific param from the cache.

```javascript
todoFamily.remove('foo')
```

### `setShouldRemove(shouldRemove)`

Registers a `shouldRemove` function which runs immediately **and** when you are about to get an atom from the cache.

- `shouldRemove` is a function that takes two arguments: `createdAt` (in milliseconds) and `param`, and returns a boolean value.
- Setting `null` will remove the previously registered function.

```javascript
// Remove atoms older than 1 hour
todoFamily.setShouldRemove((createdAt, param) => {
  return Date.now() - createdAt > 60 * 60 * 1000
})
```

### `unstable_listen(callback)`

**⚠️ Unstable API**: This API is for advanced use cases and can change without notice.

Fires when an atom is created or removed. Returns a cleanup function.

```javascript
const cleanup = todoFamily.unstable_listen((event) => {
  console.log(event.type) // 'CREATE' or 'REMOVE'
  console.log(event.param) // the param
  console.log(event.atom) // the atom
})

// Later, stop listening
cleanup()
```

## Memory Leak Caveats

Internally, atomFamily is just a Map whose key is a param and whose value is an atom config. Unless you explicitly remove unused params, this leads to memory leaks. This is crucial if you use infinite number of params.

Use `myFamily.remove(param)` or `myFamily.setShouldRemove(shouldRemove)` to manage memory.

## Examples

### Basic Usage

```javascript
import { atom } from 'jotai'
import { atomFamily } from 'jotai/utils'

const todoFamily = atomFamily((name) => atom(name))

todoFamily('foo')
// this will create a new atom('foo'), or return the one if already created
```

### Derived Atom

```javascript
import { atom } from 'jotai'
import { atomFamily } from 'jotai/utils'

const todoFamily = atomFamily((name) =>
  atom(
    (get) => get(todosAtom)[name],
    (get, set, arg) => {
      const prev = get(todosAtom)
      set(todosAtom, { ...prev, [name]: { ...prev[name], ...arg } })
    },
  ),
)
```

### Custom Equality

```javascript
import { atom } from 'jotai'
import { atomFamily } from 'jotai/utils'

const todoFamily = atomFamily(
  ({ id, name }) => atom({ name }),
  (a, b) => a.id === b.id,
)
```

## Migration to jotai-family

For new projects or when updating existing code, we recommend using the `jotai-family` package instead. It provides:

- **Same API**: Drop-in replacement for `atomFamily`
- **Additional features**: Includes `atomTree` for hierarchical atom management
- **Better maintenance**: Dedicated package with focused development
- **Future-proof**: Will continue to be supported in Jotai v3 and beyond

See the jotai-family documentation for more details.