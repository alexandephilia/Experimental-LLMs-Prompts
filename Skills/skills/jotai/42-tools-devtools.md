# Jotai DevTools

## Installation

```bash
npm install jotai-devtools
```

## UI DevTools Component

```tsx
import { DevTools } from 'jotai-devtools'

function App() {
  return (
    <>
      <MyApp />
      <DevTools />
    </>
  )
}
```

### Props

```tsx
interface DevToolsProps {
  theme?: 'dark' | 'light' | 'auto'
  position?: 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right'
  nonce?: string
  store?: Store
}
```

## Babel Setup

```json
{
  "plugins": [
    ["jotai/babel/plugin-debug-label"],
    ["jotai/babel/plugin-react-refresh"]
  ]
}
```

## Next.js Configuration

```js
// next.config.js
module.exports = {
  transpilePackages: ['jotai-devtools']
}
```

## Hooks

### useAtomsDebugValue

```tsx
import { useAtomsDebugValue } from 'jotai-devtools/utils'

function DebugAtoms() {
  const atoms = useAtomsDebugValue()
  return <pre>{JSON.stringify(atoms, null, 2)}</pre>
}
```

### useAtomDevtools

```tsx
import { useAtomDevtools } from 'jotai-devtools/utils'

function MyComponent() {
  const [value, setValue] = useAtom(myAtom)
  useAtomDevtools(myAtom, { name: 'myAtom' })
  
  return <div>{value}</div>
}
```

### useAtomsDevtools

```tsx
import { useAtomsDevtools } from 'jotai-devtools/utils'

function App() {
  useAtomsDevtools('myStore')
  return <MyApp />
}
```

### useAtomsSnapshot

```tsx
import { useAtomsSnapshot } from 'jotai-devtools/utils'

function DebugSnapshot() {
  const snapshot = useAtomsSnapshot()
  
  return (
    <button onClick={() => console.log(snapshot)}>
      Log Snapshot
    </button>
  )
}
```

### useGotoAtomsSnapshot

```tsx
import { useGotoAtomsSnapshot } from 'jotai-devtools/utils'

function TimeTravel() {
  const goToSnapshot = useGotoAtomsSnapshot()
  
  const restoreSnapshot = () => {
    goToSnapshot(previousSnapshot)
  }
  
  return <button onClick={restoreSnapshot}>Restore</button>
}
```