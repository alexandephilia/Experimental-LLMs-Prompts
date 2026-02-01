# Testing — Jotai

We echo the guiding principles of Testing library:

- "The more your tests resemble the way your software is used, the more confidence they can give you."

We encourage you to write tests, like the user would interact with your atoms and components, therefore treating Jotai as an implementation detail.

Here's an example using React testing library:

`Counter.tsx`:

```javascript
import { atom, useAtom } from 'jotai'

export const countAtom = atom(0)

export function Counter() {
  const [count, setCount] = useAtom(countAtom)
  return (
    <h1>
      <p>{count}</p>
      <button onClick={() => setCount((c) => c + 1)}>one up</button>
    </h1>
  )
}
```

`Counter.test.ts`:

```javascript
import React from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Counter } from './Counter'

test('should increment counter', () => {
  render(<Counter />)
  const counter = screen.getByText('0')
  const incrementButton = screen.getByText('one up')
  await userEvent.click(incrementButton)
  expect(counter.textContent).toEqual('1')
})
```

## Injected Values

You may want to inject arbitrary values to your atom before starting some tests. Maybe the counter should be limited to 100. Let's see how to test that it doesn't increase after reaching 100. In order to do that, simply use a Provider, and export your atom to be filled-in.

```javascript
import React from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { useHydrateAtoms } from 'jotai/utils'
import { countAtom, Counter } from './Counter'
import { Provider } from 'jotai'

const HydrateAtoms = ({ initialValues, children }) => {
  useHydrateAtoms(initialValues)
  return children
}

const TestProvider = ({ initialValues, children }) => (
  <Provider>
    <HydrateAtoms initialValues={initialValues}>{children}</HydrateAtoms>
  </Provider>
)

const CounterProvider = () => {
  return (
    <TestProvider initialValues={[[countAtom, 100]]}>
      <Counter />
    </TestProvider>
  )
}

test('should not increment on max (100)', () => {
  render(<CounterProvider />)
  const counter = screen.getByText('100')
  const incrementButton = screen.getByText('one up')
  await userEvent.click(incrementButton)
  expect(counter.textContent).toEqual('100')
})
```

## Custom hooks

If you have complex atoms, sometimes you want to test them in isolation.

For that, you can use React Hooks Testing Library. Here's an example below:

`countAtom.ts`:

```javascript
import { useAtom } from 'jotai'
import { atomWithReducer } from 'jotai/utils'

const reducer = (state: number, action?: 'INCREASE' | 'DECREASE') => {
  switch (action) {
    case 'INCREASE':
      return state + 1
    case 'DECREASE':
      return state - 1
    case undefined:
      return state
  }
}

export const countAtom = atomWithReducer(0, reducer)
```

`countAtom.test.ts`:

```javascript
import { renderHook, act } from '@testing-library/react-hooks'
import { useAtom } from 'jotai'
import { countAtom } from './countAtom'

test('should increment counter', () => {
  const { result } = renderHook(() => useAtom(countAtom))
  act(() => {
    result.current[1]('INCREASE')
  })
  expect(result.current[0]).toBe(1)
})
```

## Example with React-Native

Of course, you can test React-Native components too the same way, with or without `Provider`.

```javascript
import React from 'react'
import { render, fireEvent } from '@testing-library/react-native'
import { Counter } from './counter'

test('should increment counter', () => {
  const { getByText } = render(<Counter />)
  const counter = getByText('0')
  const incrementButton = getByText('one up')
  fireEvent.press(incrementButton)
  expect(counter.props.children.toString()).toEqual('1')
})
```