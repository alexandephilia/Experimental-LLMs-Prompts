# Waku

## Hydration

Jotai has support for hydration of atoms with `useHydrateAtoms`. The documentation for the hook can be seen [here](https://jotai.org/docs/utilities/ssr).

## Server-side rendering with Waku

When using server-side rendering with Waku, make sure to add a Jotai Provider component at the root.

Create the provider in a separate client component. Then import the provider into the root layout.

```tsx
'use client'
import { Provider } from 'jotai'

export const Providers = ({ children }) => {
  return (
    <Provider>
      {children}
    </Provider>
  )
}
```

```tsx
import { Providers } from '../components/providers'

export default async function RootLayout({ children }) {
  return (
    <Providers>
      {children}
    </Providers>
  )
}
```