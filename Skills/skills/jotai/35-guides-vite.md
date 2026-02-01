# Vite

You can use the plugins from the `jotai/babel` bundle to enhance your developer experience when using Vite and Jotai.

In your `vite.config.ts`:

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import jotaiDebugLabel from 'jotai/babel/plugin-debug-label'
import jotaiReactRefresh from 'jotai/babel/plugin-react-refresh'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react({ babel: { plugins: [jotaiDebugLabel, jotaiReactRefresh] } }),
  ],
  // ... The rest of your configuration
})
```

There's a template below to try it yourself.

## Examples

### Vite Template

[Template available on the Jotai website]