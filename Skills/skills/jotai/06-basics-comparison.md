# Jotai Comparison Guide

## Jotai vs useContext

### Provider Hell Problem

**useContext approach:**
```jsx
function App() {
  return (
    <UserProvider>
      <ThemeProvider>
        <CartProvider>
          <NotificationProvider>
            <MyComponent />
          </NotificationProvider>
        </CartProvider>
      </ThemeProvider>
    </UserProvider>
  );
}
```

**Jotai approach:**
```jsx
const userAtom = atom({ name: '', email: '' });
const themeAtom = atom('light');
const cartAtom = atom([]);

function App() {
  return <MyComponent />; // No providers needed
}
```

### Dynamic State Addition

**useContext limitations:**
```jsx
// Cannot dynamically add new context without restructuring
const DynamicContext = createContext();
// Requires provider wrapper for each new state
```

**Jotai flexibility:**
```jsx
// Create atoms anywhere, anytime
const dynamicAtom = atom(initialValue);
const [value, setValue] = useAtom(dynamicAtom);
```

## Jotai vs Zustand

### State Model Differences

**Zustand (Store-based):**
```jsx
const useStore = create((set) => ({
  count: 0,
  user: { name: '' },
  increment: () => set((state) => ({ count: state.count + 1 })),
  setUser: (user) => set({ user }),
}));

function Component() {
  const { count, increment } = useStore();
  return <button onClick={increment}>{count}</button>;
}
```

**Jotai (Atomic):**
```jsx
const countAtom = atom(0);
const userAtom = atom({ name: '' });

function Component() {
  const [count, setCount] = useAtom(countAtom);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

### When to Use Which

**Use Zustand when:**
- You prefer centralized store patterns
- You have complex business logic in actions
- You want built-in middleware (persist, devtools)
- You're migrating from Redux

**Use Jotai when:**
- You want fine-grained reactivity
- You prefer bottom-up composition
- You need dynamic state creation
- You want to avoid provider hell

## Jotai vs Recoil

### Developer Experience Differences

**Recoil setup:**
```jsx
function App() {
  return (
    <RecoilRoot>
      <MyComponent />
    </RecoilRoot>
  );
}

const textState = atom({
  key: 'textState',
  default: '',
});
```

**Jotai setup:**
```jsx
function App() {
  return <MyComponent />; // No root provider
}

const textAtom = atom(''); // No keys required
```

### Technical Differences

**Recoil features:**
```jsx
// Requires unique keys
const userState = atom({
  key: 'userState',
  default: { name: '' },
});

// Built-in async support
const userQuery = selector({
  key: 'userQuery',
  get: async () => {
    const response = await fetch('/api/user');
    return response.json();
  },
});
```

**Jotai equivalents:**
```jsx
// No keys needed
const userAtom = atom({ name: '' });

// Async atoms
const userQueryAtom = atom(async () => {
  const response = await fetch('/api/user');
  return response.json();
});
```

### Key Differences Summary

| Feature | Jotai | Recoil |
|---------|-------|--------|
| Provider | Optional | Required |
| Keys | Not needed | Required |
| Bundle size | Smaller | Larger |
| Async support | Built-in | Built-in |
| DevTools | Third-party | Built-in |
| Stability | Stable | Experimental |