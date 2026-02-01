# Immer Extension

## Install

You have to install `immer` and `jotai-immer` to use this feature.

```bash
npm install immer jotai-immer
```

## atomWithImmer

`atomWithImmer` creates a new atom similar to the regular `atom` with a different `writeFunction`. In this bundle, we don't have read-only atoms, because the point of these functions is the immer produce(mutability) function. The signature of writeFunction is `(get, set, update: (draft: Draft<Value>) => void) => void`.

```javascript
import { useAtom } from 'jotai'
import { atomWithImmer } from 'jotai-immer'

const countAtom = atomWithImmer({ value: 0 })

const Counter = () => {
  const [count] = useAtom(countAtom)
  return <div>count: {count.value}</div>
}

const Controls = () => {
  const [, setCount] = useAtom(countAtom)
  const inc = () =>
    setCount((draft) => {
      ++draft.value
    })
  return <button onClick={inc}>+1</button>
}
```

## withImmer

`withImmer` takes an atom and returns a derived atom, same as `atomWithImmer` it has a different `writeFunction`.

```javascript
import { useAtom, atom } from 'jotai'
import { withImmer } from 'jotai-immer'

const primitiveAtom = atom({ value: 0 })
const countAtom = withImmer(primitiveAtom)

const Counter = () => {
  const [count] = useAtom(countAtom)
  return <div>count: {count.value}</div>
}

const Controls = () => {
  const [, setCount] = useAtom(countAtom)
  const inc = () =>
    setCount((draft) => {
      ++draft.value
    })
  return <button onClick={inc}>+1</button>
}
```

## useImmerAtom

This hook takes an atom and replaces the atom's `writeFunction` with the new immer-like `writeFunction` like the previous helpers.

```javascript
import { atom } from 'jotai'
import { useImmerAtom } from 'jotai-immer'

const primitiveAtom = atom({ value: 0 })

const Counter = () => {
  const [count] = useImmerAtom(primitiveAtom)
  return <div>count: {count.value}</div>
}

const Controls = () => {
  const [, setCount] = useImmerAtom(primitiveAtom)
  const inc = () =>
    setCount((draft) => {
      ++draft.value
    })
  return <button onClick={inc}>+1</button>
}
```

It would be better if you don't use `withImmer` and `atomWithImmer` with `useImmerAtom` because they provide the immer-like `writeFunction` and we don't need to create a new one.

You can use `useSetImmerAtom` if you need only the setter part of `useImmerAtom`.