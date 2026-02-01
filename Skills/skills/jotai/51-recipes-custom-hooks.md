# Custom useAtom hooks

This page shows the ways of creating different utility functions. Utility functions save your time on coding, and you can preserve your base atom for other usage.

## utils

### useSelectAtom

```tsx
import { useAtomValue } from 'jotai'
import { selectAtom } from 'jotai/utils'

export function useSelectAtom(anAtom, selector) {
  const selectorAtom = selectAtom(
    anAtom,
    selector,
  )
  return useAtomValue(selectorAtom)
}

function useN(n) {
  const selector = useCallback((v) => v[n], [n])
  return useSelectAtom(arrayAtom, selector)
}
```

Please note that in this case `keyFn` must be stable, either define outside render or wrap with `useCallback`.

### useFreezeAtom

```tsx
import { useAtom } from 'jotai'
import { freezeAtom } from 'jotai/utils'

export function useFreezeAtom(anAtom) {
  return useAtom(freezeAtom(anAtom))
}
```

### useSplitAtom

```tsx
import { useAtom } from 'jotai'
import { splitAtom } from 'jotai/utils'

export function useSplitAtom(anAtom) {
  return useAtom(splitAtom(anAtom))
}
```

## extensions

### useFocusAtom

```tsx
import { useAtom } from 'jotai'
import { focusAtom } from 'jotai-optics'

export function useFocusAtom(anAtom, keyFn) {
  return useAtom(focusAtom(anAtom, keyFn))
}

useFocusAtom(anAtom) {
  useMemo(() => atom(initValue), [initValue]),
  useCallback((optic) => optic.prop('key'), [])
}
```

Please note that in this case `keyFn` must be stable, either define outside render or wrap with `useCallback`.

### Stackblitz

[View examples on Stackblitz](https://stackblitz.com/)