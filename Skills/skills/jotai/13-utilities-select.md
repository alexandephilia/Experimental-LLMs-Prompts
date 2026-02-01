# Select

## selectAtom

⚠️ Unlike its name, `selectAtom` is provided as an escape hatch. Using it means building not 100% pure atom model. Prefer using derived atoms and use `selectAtom` only when `equalityFn` or `prevSlice` is unavoidable.

### Signatures

```typescript
function selectAtom<Value, Slice>(
  anAtom: Atom<Value>,
  selector: (v: Value, prevSlice?: Slice) => Slice,
  equalityFn: (a: Slice, b: Slice) => boolean = Object.is,
): Atom<Slice>
```

This function creates a derived atom whose value is a function of the original atom's value, determined by `selector.` The selector function runs whenever the original atom changes; it updates the derived atom only if `equalityFn` reports that the derived value has changed. By default, `equalityFn` is reference equality, but you can supply your favorite deep-equals function to stabilize the derived value where necessary.

### Examples

```javascript
const defaultPerson = {
  name: {
    first: 'Jane',
    last: 'Doe',
  },
  birth: {
    year: 2000,
    month: 'Jan',
    day: 1,
    time: {
      hour: 1,
      minute: 1,
    },
  },
}

const personAtom = atom(defaultPerson)
const nameAtom = selectAtom(personAtom, (person) => person.name)
const birthAtom = selectAtom(personAtom, (person) => person.birth, deepEquals)
```

### Hold stable references

As always, to prevent an infinite loop when using `useAtom` in render cycle, you must provide `useAtom` a stable reference of your atoms. For `selectAtom`, we need **both** the base atom and the selector to be stable.

```javascript
const [value] = useAtom(selectAtom(atom(0), (val) => val))
```

You have multiple options in order to satisfy these constraints:

```javascript
const baseAtom = atom(0)
const baseSelector = (v) => v

const Component = () => {
  const [value] = useAtom(useMemo(() => selectAtom(baseAtom, (v) => v), []))
  
  const [value] = useAtom(
    selectAtom(
      baseAtom,
      useCallback((v) => v, []),
    ),
  )
  
  const [value] = useAtom(selectAtom(baseAtom, baseSelector))
}
```