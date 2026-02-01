# Jotai Storage Utilities

## atomWithStorage

Creates an atom that persists its value to storage (localStorage by default).

```js
import { atomWithStorage } from 'jotai/utils'

const countAtom = atomWithStorage('count', 0)
```

### Parameters

- `key` (string): Storage key
- `initialValue`: Default value when storage is empty
- `storage` (optional): Storage implementation (defaults to localStorage)
- `options` (optional): Configuration object

```js
const userAtom = atomWithStorage('user', null, undefined, {
  getOnInit: true // Read from storage on initialization
})
```

## createJSONStorage

Creates a storage implementation that serializes values as JSON.

```js
import { createJSONStorage } from 'jotai/utils'

const storage = createJSONStorage(() => localStorage)
const settingsAtom = atomWithStorage('settings', {}, storage)
```

## Server-Side Rendering

Use `getOnInit: true` to prevent hydration mismatches:

```js
const themeAtom = atomWithStorage('theme', 'light', undefined, {
  getOnInit: true
})
```

## Deleting Items with RESET

Use the `RESET` symbol to remove items from storage:

```js
import { RESET } from 'jotai/utils'

const [value, setValue] = useAtom(storageAtom)
setValue(RESET) // Removes from storage, resets to initial value
```

## React Native with AsyncStorage

```js
import AsyncStorage from '@react-native-async-storage/async-storage'
import { createJSONStorage } from 'jotai/utils'

const storage = createJSONStorage(() => AsyncStorage)
const userAtom = atomWithStorage('user', null, storage)
```

## Validation with Zod

```js
import { z } from 'zod'

const userSchema = z.object({
  name: z.string(),
  age: z.number()
})

const storage = createJSONStorage(() => localStorage)
const userAtom = atomWithStorage('user', { name: '', age: 0 }, storage, {
  serialize: JSON.stringify,
  deserialize: (str) => {
    const parsed = JSON.parse(str)
    return userSchema.parse(parsed)
  }
})
```