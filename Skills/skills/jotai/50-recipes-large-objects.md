# Large objects

> The examples and descriptions below are based on this codesandbox, so it will give you a better understanding if you check it out along with these examples.

Sometimes we have nested data we need to store in atoms, and we may need to change that data at different levels, or we need to use part of that data without listening to all changes.

Consider this example:

```tsx
const initialData = {
  people: [
    {
      name: 'Luke Skywalker',
      information: { height: 172 },
      siblings: ['John Skywalker', 'Doe Skywalker'],
    },
    {
      name: 'C-3PO',
      information: { height: 167 },
      siblings: ['John Doe', 'Doe John'],
    },
  ],
  films: [
    {
      title: 'A New Hope',
      planets: ['Tatooine', 'Alderaan'],
    },
    {
      title: 'The Empire Strikes Back',
      planets: ['Hoth'],
    },
  ],
  info: {
    tags: ['People', 'Films', 'Planets', 'Titles'],
  },
}
```

## focusAtom

> `focusAtom` creates a new atom, based on the focus that you pass to it. [jotai-optics](https://github.com/jotaijs/jotai-optics)

We use this utility to focus an atom and create an atom from a specific part of the data. For example we may need to consume the people property of the above data, Here's how we do it:

```tsx
import { atom } from 'jotai'
import { focusAtom } from 'jotai-optics'

const dataAtom = atom(initialData)

const peopleAtom = focusAtom(dataAtom, (optic) => optic.prop('people'))
```

`focusAtom` returns `WritableAtom` which means it's possible to change the `peopleAtom` data.

If we change the `films` property of the above data example, the `peopleAtom` won't cause a re-render, so that's one of the benefits of using `focusAtom`.

## splitAtom

> The `splitAtom` utility is useful when you want to get an atom for each element in a list. [jotai/utils](https://jotai.org/docs/utilities/split)

We use this utility for atoms that return arrays as their values. For example, the `peopleAtom` we made above returns the people property array, so we can return an atom for each item of that array. If the array atom is writable, `splitAtom` returned atoms are going to be writable, if the array atom is read-only, the returned atoms will be read-only too.

```tsx
import { splitAtom } from 'jotai/utils'

const peopleAtomsAtom = splitAtom(peopleAtom)
```

And this is how we use it in components.

```tsx
const People = () => {
  const [peopleAtoms] = useAtom(peopleAtomsAtom)
  return (
    <div>
      {peopleAtoms.map((personAtom) => (
        <Person personAtom={personAtom} key={`${personAtom}`} />
      ))}
    </div>
  )
}
```

## selectAtom

> This function creates a derived atom whose value is a function of the original atom's value. [jotai/utils](https://jotai.org/docs/utilities/select)

This utility is like `focusAtom`, but it always returns a read-only atom.

Assume we want to consume the info data, and its data is always unchangeable. We can make a read-only atom from it and select that created atom.

```tsx
const infoAtom = atom((get) => get(dataAtom).info)
```

Then we use it in our component:

```tsx
import { atom, useAtom } from 'jotai'
import { selectAtom, splitAtom } from 'jotai/utils'

const tagsSelector = (s) => s.tags

const Tags = () => {
  const tagsAtom = selectAtom(infoAtom, tagsSelector)
  const tagsAtomsAtom = splitAtom(tagsAtom)
  const [tagAtoms] = useAtom(tagsAtomsAtom)
  return (
    <div>
      {tagAtoms.map((tagAtom) => (
        <Tag key={`${tagAtom}`} tagAtom={tagAtom} />
      ))}
    </div>
  )
}
```