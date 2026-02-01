# SWC Tools

SWC plugins for enhanced Jotai development experience.

## @swc-jotai/react-refresh

Enables React Refresh support for Jotai atoms.

### Installation

```bash
npm install --save-dev @swc-jotai/react-refresh
```

### Configuration

`.swcrc`:
```json
{
  "jsc": {
    "experimental": {
      "plugins": [
        ["@swc-jotai/react-refresh", {}]
      ]
    }
  }
}
```

### Next.js Usage

`next.config.js`:
```js
module.exports = {
  experimental: {
    swcPlugins: [
      ["@swc-jotai/react-refresh", {}]
    ]
  }
}
```

## @swc-jotai/debug-label

Automatically adds `debugLabel` to atoms for better debugging.

### Installation

```bash
npm install --save-dev @swc-jotai/debug-label
```

### Configuration

`.swcrc`:
```json
{
  "jsc": {
    "experimental": {
      "plugins": [
        ["@swc-jotai/debug-label", {}]
      ]
    }
  }
}
```

### Custom Atom Names

```json
{
  "jsc": {
    "experimental": {
      "plugins": [
        ["@swc-jotai/debug-label", {
          "atomNames": ["atom", "customAtom", "myAtom"]
        }]
      ]
    }
  }
}
```

### Next.js Usage

`next.config.js`:
```js
module.exports = {
  experimental: {
    swcPlugins: [
      ["@swc-jotai/debug-label", {
        "atomNames": ["atom", "customAtom"]
      }]
    ]
  }
}
```

## Combined Usage

`.swcrc`:
```json
{
  "jsc": {
    "experimental": {
      "plugins": [
        ["@swc-jotai/react-refresh", {}],
        ["@swc-jotai/debug-label", {}]
      ]
    }
  }
}
```