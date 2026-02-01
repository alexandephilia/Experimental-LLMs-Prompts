# Query Extension - React Query Integration

TanStack Query provides a set of functions for managing async state (typically external data).

From the Overview docs:

> React Query is often described as the missing data-fetching library for React, but in more technical terms, it makes **fetching, caching, synchronizing and updating server state** in your React applications a breeze.

jotai-tanstack-query is a Jotai extension library for TanStack Query. It provides a wonderful interface with all of the TanStack Query features, providing you the ability to use those features in combination with your existing Jotai state.

## Support

jotai-tanstack-query currently supports TanStack Query v5.

## Install

In addition to `jotai`, you have to install `jotai-tanstack-query` and `@tanstack/query-core` to use the extension.

```bash
npm install jotai-tanstack-query @tanstack/query-core
```

## Incremental Adoption

You can incrementally adopt `jotai-tanstack-query` in your app. It's not an all or nothing solution. You just have to ensure you are using the same QueryClient instance.

```javascript
const { data, isPending, isError } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodoList,
})

const todosAtom = atomWithQuery(() => ({
  queryKey: ['todos'],
}))

const [{ data, isPending, isError }] = useAtom(todosAtom)
```

## Exported Functions

- `atomWithQuery` for useQuery
- `atomWithInfiniteQuery` for useInfiniteQuery
- `atomWithMutation` for useMutation
- `atomWithSuspenseQuery` for useSuspenseQuery
- `atomWithSuspenseInfiniteQuery` for useSuspenseInfiniteQuery
- `atomWithMutationState` for useMutationState

All functions follow the same signature:

```javascript
const dataAtom = atomWithSomething(getOptions, getQueryClient)
```

The first `getOptions` parameter is a function that returns an input to the observer. The second optional `getQueryClient` parameter is a function that return QueryClient.

## atomWithQuery Usage

`atomWithQuery` creates a new atom that implements a standard `Query` from TanStack Query.

```javascript
import { atom, useAtom } from 'jotai'
import { atomWithQuery } from 'jotai-tanstack-query'

const idAtom = atom(1)

const userAtom = atomWithQuery((get) => ({
  queryKey: ['users', get(idAtom)],
  queryFn: async ({ queryKey: [, id] }) => {
    const res = await fetch(`https://jsonplaceholder.typicode.com/users/${id}`)
    return res.json()
  },
}))

const UserData = () => {
  const [{ data, isPending, isError }] = useAtom(userAtom)

  if (isPending) return <div>Loading...</div>
  if (isError) return <div>Error</div>

  return <div>{JSON.stringify(data)}</div>
}
```

## atomWithInfiniteQuery Usage

`atomWithInfiniteQuery` is very similar to `atomWithQuery`, however it is for an `InfiniteQuery`, which is used for data that is meant to be paginated.

```javascript
import { atom, useAtom } from 'jotai'
import { atomWithInfiniteQuery } from 'jotai-tanstack-query'

const postsAtom = atomWithInfiniteQuery(() => ({
  queryKey: ['posts'],
  queryFn: async ({ pageParam }) => {
    const res = await fetch(`https://jsonplaceholder.typicode.com/posts?_page=${pageParam}`)
    return res.json()
  },
  getNextPageParam: (lastPage, allPages, lastPageParam) => lastPageParam + 1,
  initialPageParam: 1,
}))

const Posts = () => {
  const [{ data, fetchNextPage, isPending, isError, isFetching }] = useAtom(postsAtom)

  if (isPending) return <div>Loading...</div>
  if (isError) return <div>Error</div>

  return (
    <>
      {data.pages.map((page, index) => (
        <div key={index}>
          {page.map((post) => (
            <div key={post.id}>{post.title}</div>
          ))}
        </div>
      ))}
      <button onClick={() => fetchNextPage()}>Next</button>
    </>
  )
}
```

## atomWithMutation Usage

`atomWithMutation` creates a new atom that implements a standard `Mutation` from TanStack Query.

```javascript
const postAtom = atomWithMutation(() => ({
  mutationKey: ['posts'],
  mutationFn: async ({ title }) => {
    const res = await fetch(`https://jsonplaceholder.typicode.com/posts`, {
      method: 'POST',
      body: JSON.stringify({
        title,
        body: 'body',
        userId: 1,
      }),
      headers: {
        'Content-type': 'application/json; charset=UTF-8',
      },
    })
    const data = await res.json()
    return data
  },
}))

const Posts = () => {
  const [{ mutate, status }] = useAtom(postAtom)

  return (
    <div>
      <button onClick={() => mutate({ title: 'foo' })}>Click me</button>
      <pre>{JSON.stringify(status, null, 2)}</pre>
    </div>
  )
}
```

## Suspense Support

jotai-tanstack-query can also be used with React's Suspense.

### atomWithSuspenseQuery Usage

```javascript
import { atom, useAtom } from 'jotai'
import { atomWithSuspenseQuery } from 'jotai-tanstack-query'

const idAtom = atom(1)

const userAtom = atomWithSuspenseQuery((get) => ({
  queryKey: ['users', get(idAtom)],
  queryFn: async ({ queryKey: [, id] }) => {
    const res = await fetch(`https://jsonplaceholder.typicode.com/users/${id}`)
    return res.json()
  },
}))

const UserData = () => {
  const [{ data }] = useAtom(userAtom)
  return <div>{JSON.stringify(data)}</div>
}
```

## QueryClient Setup

To ensure you reference the same `QueryClient` object, wrap the root of your project in a `<Provider>` and initialize `queryClientAtom` with the same `queryClient` value you provided to `QueryClientProvider`.

```javascript
import { Provider } from 'jotai/react'
import { useHydrateAtoms } from 'jotai/react/utils'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { queryClientAtom } from 'jotai-tanstack-query'

const queryClient = new QueryClient()

const HydrateAtoms = ({ children }) => {
  useHydrateAtoms([[queryClientAtom, queryClient]])
  return children
}

export const App = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <Provider>
        <HydrateAtoms>
          <App />
        </HydrateAtoms>
      </Provider>
    </QueryClientProvider>
  )
}
```

## SSR Support

All atoms can be used within the context of a server side rendered app, such as a Next.js app or Gatsby app. You can use both options that React Query supports for use within SSR apps, hydration or `initialData`.

## Error Handling

Fetch error will be thrown and can be caught with ErrorBoundary. Refetching may recover from a temporary error.

## Devtools

In order to use the Devtools, you need to install it additionally:

```bash
npm install @tanstack/react-query-devtools
```

All you have to do is put the `<ReactQueryDevtools />` within `<QueryClientProvider />`.

```javascript
import { QueryClientProvider, QueryClient } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { queryClientAtom } from 'jotai-tanstack-query'

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: Infinity,
    },
  },
})

export const App = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <Provider>
        <HydrateAtoms>
          <App />
        </HydrateAtoms>
      </Provider>
      <ReactQueryDevtools />
    </QueryClientProvider>
  )
}
```

## Migration to v0.8.0

### Change in Atom Signature

All atom signatures have changed to be more consistent with TanStack Query. v0.8.0 returns only a single atom, instead of a tuple of atoms.

```javascript
// Before
const [dataAtom, statusAtom] = atomsWithSomething(getOptions, getQueryClient)

// After
const dataAtom = atomWithSomething(getOptions, getQueryClient)
```

### Simplified Return Structure

In v0.8.0, query atoms return only a single `dataAtom` that directly provides the `QueryObserverResult<TData, TError>`, aligning it closely with the behavior of TanStack Query's bindings.

```javascript
// Before
const [dataAtom, statusAtom] = atomsWithQuery()
const [data] = useAtom(dataAtom)
const [status] = useAtom(statusAtom)

// After
const dataAtom = atomWithQuery()
const [{ data, isPending, isError }] = useAtom(dataAtom)
```