# tRPC — Jotai Extension

You can use Jotai with tRPC.

## Install

You have to install `jotai-trpc`, `@trpc/client` and `@trpc/server` to use the extension.

```bash
npm install jotai-trpc @trpc/client @trpc/server
```

## Usage

```typescript
import { createTRPCJotai } from 'jotai-trpc'

const trpc = createTRPCJotai<MyRouter>({
  links: [
    httpLink({
      url: myUrl,
    }),
  ],
})

const idAtom = atom('foo')
const queryAtom = trpc.bar.baz.atomWithQuery((get) => get(idAtom))
```

## atomWithQuery

`...atomWithQuery` creates a new atom with "query". It internally uses Vanilla Client's `...query` procedure.

```typescript
import { atom, useAtom } from 'jotai'
import { httpLink } from '@trpc/client'
import { createTRPCJotai } from 'jotai-trpc'
import { trpcPokemonUrl } from 'trpc-pokemon'
import type { PokemonRouter } from 'trpc-pokemon'

const trpc = createTRPCJotai<PokemonRouter>({
  links: [
    httpLink({
      url: trpcPokemonUrl,
    }),
  ],
})

const NAMES = [
  'bulbasaur',
  'ivysaur',
  'venusaur',
  'charmander',
  'charmeleon',
  'charizard',
  'squirtle',
  'wartortle',
  'blastoise',
]

const nameAtom = atom(NAMES[0])
const pokemonAtom = trpc.pokemon.byId.atomWithQuery((get) => get(nameAtom))

const Pokemon = () => {
  const [data, refresh] = useAtom(pokemonAtom)
  return (
    <div>
      <div>ID: {data.id}</div>
      <div>Height: {data.height}</div>
      <div>Weight: {data.weight}</div>
      <button onClick={refresh}>Refresh</button>
    </div>
  )
}
```

## atomWithMutation

`...atomWithMutation` creates a new atom with "mutate". It internally uses Vanilla Client's `...mutate` procedure.

FIXME: add code example and codesandbox

## atomWithSubscription

`...atomWithSubscription` creates a new atom with "subscribe". It internally uses Vanilla Client's `...subscribe` procedure.

FIXME: add code example and codesandbox