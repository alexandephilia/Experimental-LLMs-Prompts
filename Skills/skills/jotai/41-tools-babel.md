# Babel Tools

Jotai provides Babel plugins for development and debugging.

## babel/plugin-react-refresh

Enables React Fast Refresh for Jotai atoms.

### Installation

```bash
npm install --save-dev @jotai/babel/plugin-react-refresh
```

### Configuration

```js
// babel.config.js
module.exports = {
  plugins: ['@jotai/babel/plugin-react-refresh']
}
```

### Next.js

```js
// next.config.js
module.exports = {
  experimental: {
    swcPlugins: [
      ['@jotai/babel/plugin-react-refresh', {}]
    ]
  }
}
```

## babel/plugin-debug-label

Adds debug labels to atoms for better DevTools experience.

### Installation

```bash
npm install --save-dev @jotai/babel/plugin-debug-label
```

### Configuration

```js
// babel.config.js
module.exports = {
  plugins: ['@jotai/babel/plugin-debug-label']
}
```

### Custom Atom Names

```js
// Custom atom function names
module.exports = {
  plugins: [
    ['@jotai/babel/plugin-debug-label', {
      atomNames: ['atom', 'myAtom', 'customAtom']
    }]
  ]
}
```

### Example Output

```js
// Before
const countAtom = atom(0)

// After (with debug labels)
const countAtom = atom(0)
countAtom.debugLabel = 'countAtom'
```

## babel/preset

Combines both plugins for convenience.

### Installation

```bash
npm install --save-dev @jotai/babel/preset
```

### Configuration

```js
// babel.config.js
module.exports = {
  presets: ['@jotai/babel/preset']
}
```

### With Options

```js
module.exports = {
  presets: [
    ['@jotai/babel/preset', {
      debugLabel: true,
      reactRefresh: true,
      atomNames: ['atom', 'myAtom']
    }]
  ]
}
```

## Framework Examples

### Next.js

```js
// next.config.js
module.exports = {
  babel: {
    presets: ['next/babel', '@jotai/babel/preset']
  }
}
```

### Parcel

```json
// .babelrc
{
  "presets": ["@jotai/babel/preset"]
}
```

### Vite

```js
// vite.config.js
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    react({
      babel: {
        presets: ['@jotai/babel/preset']
      }
    })
  ]
})
```