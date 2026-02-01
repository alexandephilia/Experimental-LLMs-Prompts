# XState — Jotai Extension

Jotai's state management is primitive and flexible, but that sometimes means too free. XState is a sophisticated library to provide a better and safer abstraction for state management.

## Install

You have to install `xstate` and `jotai-xstate` to use this feature.

```bash
npm install xstate jotai-xstate
```

## atomWithMachine

`atomWithMachine` creates a new atom with XState machine. It receives a function `getMachine` to create a new machine. `getMachine` is invoked at the first use with `get` argument, with which you can read other atom values.

```typescript
import { useAtom } from 'jotai'
import { atomWithMachine } from 'jotai-xstate'
import { assign, createMachine } from 'xstate'

const createEditableMachine = (value: string) =>
  createMachine<{ value: string }>({
    id: 'editable',
    initial: 'reading',
    context: {
      value,
    },
    states: {
      reading: {
        on: {
          dblclick: 'editing',
        },
      },
      editing: {
        on: {
          cancel: 'reading',
          commit: {
            target: 'reading',
            actions: assign({
              value: (_, { value }) => value,
            }),
          },
        },
      },
    },
  })

const defaultTextAtom = atom('edit me')
const editableMachineAtom = atomWithMachine((get) =>
  createEditableMachine(get(defaultTextAtom)),
)

const Toggle = () => {
  const [state, send] = useAtom(editableMachineAtom)
  return (
    <div>
      {state.matches('reading') && (
        <strong onDoubleClick={send}>{state.context.value}</strong>
      )}
      {state.matches('editing') && (
        <input
          autoFocus
          defaultValue={state.context.value}
          onBlur={(e) => send({ type: 'commit', value: e.target.value })}
          onKeyDown={(e) => {
            if (e.key === 'Enter') {
              send({ type: 'commit', value: e.target.value })
            }
            if (e.key === 'Escape') {
              send('cancel')
            }
          }}
        />
      )}
      <br />
      <br />
      <div>
        Double-click to edit. Blur the input or press <code>enter</code> to
        commit. Press <code>esc</code> to cancel.
      </div>
    </div>
  )
}
```

## Restartable machine stored in a global Provider (provider-less mode)

When your machine reaches its final state it cannot receive any more events. If your atomWithMachine is initialized in global store (aka provider-less mode), to restart it you need to send a `RESTART` event to your machine like so:

```typescript
import { RESTART } from 'jotai-xstate'

const YourComponent = () => {
  const [current, send] = useAtom(yourMachineAtom)
  const isFinalState = current.matches('myFinalState')
  
  useEffect(() => {
    return () => {
      if (isFinalState) send(RESTART)
    }
  }, [isFinalState])
}
```

## Tutorials

Check out a course about Jotai and XState.

Complex State Management in React with Jotai and XState

(Note: In the course, it uses `jotai/xstate` which is supersede by `jotai-xstate`.)