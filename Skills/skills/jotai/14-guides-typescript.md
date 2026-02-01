# TypeScript Guide

## Version requirement

Jotai uses TypeScript 3.8+ syntax. Upgrade your TypeScript version if you're on 3.7.5 or lower.

Jotai relies heavily on type inferences and requires `strictNullChecks` to be enabled. Consider adding `"strict": true` in your tsconfig.json.

## Notes

### Primitive atoms are basically type inferred

```typescript
const numAtom = atom(0)
const strAtom = atom('')
```

### Primitive atoms can be explicitly typed

```typescript
const numAtom = atom<number>(0)
const numAtom = atom<number | null>(0)
const arrAtom = atom<string[]>([])
```

### Derived atoms can mostly have their types inferred

In general, this is the recommended approach since typing derived atoms can get a little confusing, particularly for those who are doing it for the first time.

#### Read only derived atoms

```typescript
const readOnlyAtom = atom((get) => get(numAtom))
const asyncReadOnlyAtom = atom(async (get) => await get(someAsyncAtom))
```

#### Write only atoms

```typescript
const writeOnlyAtom = atom(null, (_get, set, str: string) => set(fooAtom, str))

const multipleArgumentsAtom = atom(
  null,
  (_get, set, valueOne: number, valueTwo: number) =>
    set(fooAtom, Math.max(valueOne, valueTwo))
);
```

#### Read/Write atoms

```typescript
const readWriteAtom = atom(
  (get) => get(strAtom),
  (_get, set, num: number) => set(strAtom, String(num))
)

const asyncReadWriteAtom = atom(
  async (get) => await get(asyncStrAtom),
  (_get, set, num: number) => set(strAtom, String(num))
)
```

### Derived atoms can also be explicitly typed

If you encounter a situation where you need or want to explicitly type your derived atoms, you can do that as well.

```typescript
const asyncStrAtom = atom<Promise<string>>(async () => 'foo')

/**
 * For write only atoms you'll need to supply three type parameters.
 * The first type parameter describes the value returned from the atom. In the
 * following example this is `null`.
 * The second type parameter describes the arguments (plural) you will pass to
 * the "write" function. Even if you only
 * plan to have one argument, this type must be an array as show in the
 * example.
 * The third type parameter describes the return value of the "write" function.
 * Normally, there is no return value,
 * which is why we use `void` in the example below.
 */
const writeOnlyAtom = atom<null, [string, number], void>(
  null,
  (_get, set, stringValue, numberValue) => set(fooAtom, stringValue),
)

/**
 * Read/Write atoms also take the same three type parameters.
 * Just for the sake of completeness, in this example, we show that the first
 * type parameter
 * can also describe an async atom.
 */
const readWriteAtom = atom<Promise<string>, [number], void>(
  async (get) => await get(asyncStrAtom),
  (_get, set, num) => set(strAtom, String(num)),
)
```

### useAtom is typed based on atom types

```typescript
const [num, setNum] = useAtom(primitiveNumAtom)
const [num] = useAtom(readOnlyNumAtom)
const [, setNum] = useAtom(writeOnlyNumAtom)
```

### Access to the value type of an atom

```typescript
import { ExtractAtomValue, useAtomValue } from 'jotai'
import { userAtom } from 'state'
import { useQuery } from '@tanstack/react-query'

export default function WriteReview(hid) {
  const user = useAtomValue(userAtom)
  const res = useGetReviewQuery(user)
}

function useGetReviewQuery(user: ExtractAtomValue<typeof userAtom>) {
  return fetch('/api/user/' + user.id + '/review')
}
```