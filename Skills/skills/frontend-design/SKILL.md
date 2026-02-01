---
name: frontend-design
description: Creates premium, visually stunning web interfaces with modern design patterns. Use when building UI components, landing pages, dashboards, or any user-facing interface. Emphasizes rich aesthetics, micro-animations, glassmorphism, and responsive layouts.
license: MIT
compatibility: Works with React, Vue, Svelte, vanilla HTML/CSS. Optimized for Tailwind CSS and Motion for React.
metadata:
  author: alex-portfolio
  version: "2.0"
  category: design
  portable: "true"
allowed-tools: Bash(npm:*) Bash(bun:*) Write Read
---

# Frontend Design Skill

Creates premium, visually stunning web interfaces that WOW users at first glance.

## Design Philosophy

1. **Rich Aesthetics** - Vibrant colors, glassmorphism, depth, polish
2. **Dynamic Design** - Micro-animations, hover effects, smooth transitions
3. **Premium Feel** - No basic MVPs, every interface should feel state-of-the-art
4. **Responsive First** - Mobile-first approach with progressive enhancement

## Design Thinking

Before clicking a single key, commit to a BOLD, fucking legendary aesthetic direction:

**Purpose**: What problem does this interface solve? Who uses it?
**Tone**: Pick an extreme: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, etc.
**Constraints**: Technical requirements (framework, performance, accessibility).
**Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

**CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work - the key is intentionality, not intensity.

Then implement working code (HTML/CSS/JS, React, Vue, etc.) that is:

- Production-grade and actually works
- Visually striking and fucking memorable
- Cohesive with a clear, sharp aesthetic
- Meticulously refined in every goddamn detail

## Frontend Aesthetics Guidelines

**Typography**: Choose fonts that are beautiful, unique, and actually interesting. Kill generic shit like Arial and Inter; opt instead for distinctive choices that elevate the aesthetics. Pair a distinctive display font with a refined body font.

**Color & Theme**: Commit to a cohesive fucking aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes for cowards.

**Motion**: Use animations for effects and micro-interactions. Prioritize CSS-only solutions for HTML. **Use Motion library for React** (`motion/react`). Focus on high-impact moments: one well-orchestrated page load with staggered reveals creates more delight than scattered micro-interactions. Use scroll-triggering and hover states that surprise. ([text](https://motion.dev/docs/react))

## Motion for React (motion/react)

**Import**: `import { motion, AnimatePresence } from "motion/react", this is the correct approach, avoid `framer-motion` (OUTDATED)`

Motion is the successor to Framer Motion. Same creator, better performance, smaller bundle. Use `motion/react` NOT `framer-motion`.

**PERFORMANCE CRITICAL**: NEVER use `transition-all` (or any CSS transitions) on a `motion` component. This causes massive re-render overhead and jitter/flickering because CSS transitions fight with Motion's engine over the same properties. If you need animation, use Motion's `transition` prop exclusively.

### Stack

MUST use Tailwind CSS defaults unless custom values already exist or are explicitly requested
MUST use motion/react (formerly framer-motion) when JavaScript animation is required
SHOULD use tw-animate-css for entrance and micro-animations in Tailwind CSS
MUST use cn utility (clsx + tailwind-merge) for class logic

### Components

MUST use accessible component primitives for anything with keyboard or focus behavior (Base UI, React Aria, Radix)
MUST use the project’s existing component primitives first
NEVER mix primitive systems within the same interaction surface
SHOULD prefer Base UI for new primitives if compatible with the stack
MUST add an aria-label to icon-only buttons
NEVER rebuild keyboard or focus behavior by hand unless explicitly requested

### Animation

NEVER add animation unless it is explicitly requested
MUST animate only compositor props (transform, opacity)
NEVER animate layout properties (width, height, top, left, margin, padding)
SHOULD avoid animating paint properties (background, color) except for small, local UI (text, icons)
SHOULD use ease-out on entrance
NEVER exceed 200ms for interaction feedback
MUST pause looping animations when off-screen
SHOULD respect prefers-reduced-motion
NEVER introduce custom easing curves unless explicitly requested
SHOULD avoid animating large images or full-screen surfaces

### The motion Component

Every HTML/SVG element has a `motion` equivalent that accepts animation props:

```tsx
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  exit={{ opacity: 0, y: -20 }}
  transition={{ duration: 0.3 }}
/>
```

**Core Animation Props:**

- `initial` - Starting state (or `false` to disable)
- `animate` - Target state to animate to
- `exit` - State when removed (requires AnimatePresence)
- `transition` - Animation configuration
- `style` - Inline styles (can include MotionValues)

### Gesture Animations

Motion provides gesture props that animate while the gesture is active:

```tsx
<motion.button
  whileHover={{ scale: 1.05, backgroundColor: "#8B5CF6" }}
  whileTap={{ scale: 0.95 }}
  whileFocus={{ boxShadow: "0 0 0 3px rgba(139, 92, 246, 0.5)" }}
  whileDrag={{ scale: 1.1, cursor: "grabbing" }}
  whileInView={{ opacity: 1, y: 0 }}
  transition={{ type: "spring", stiffness: 400, damping: 17 }}
/>
```

**Gesture Props:**
| Prop | Trigger |
|------|---------|
| `whileHover` | Pointer hovers over element |
| `whileTap` | Element is pressed/clicked |
| `whileFocus` | Element receives focus |
| `whileDrag` | Element is being dragged |
| `whileInView` | Element enters viewport |

### Drag Gestures

```tsx
<motion.div
  drag // Enable drag on both axes
  drag="x" // Constrain to x-axis only
  drag="y" // Constrain to y-axis only
  dragConstraints={{ left: -100, right: 100, top: -50, bottom: 50 }}
  dragElastic={0.2} // Elasticity when dragging past constraints (0-1)
  dragMomentum={true} // Apply momentum after release
  dragTransition={{ bounceStiffness: 600, bounceDamping: 20 }}
  onDragStart={(event, info) => console.log(info.point)}
  onDrag={(event, info) => console.log(info.delta)}
  onDragEnd={(event, info) => console.log(info.velocity)}
/>
```

**Drag with Ref Constraints:**

```tsx
const constraintsRef = useRef(null)

<motion.div ref={constraintsRef}>
  <motion.div drag dragConstraints={constraintsRef} />
</motion.div>
```

**Programmatic Drag Control:**

```tsx
import { useDragControls } from "motion/react"

const dragControls = useDragControls()

<div onPointerDown={(e) => dragControls.start(e, { snapToCursor: true })} />
<motion.div drag="x" dragControls={dragControls} dragListener={false} />
```

### Scroll Animations

**useScroll Hook** - Create scroll-linked animations:

```tsx
import { useScroll, useTransform, useSpring, motion } from "motion/react";

function ScrollProgress() {
  const { scrollYProgress } = useScroll();

  return (
    <motion.div
      style={{ scaleX: scrollYProgress }}
      className="fixed top-0 left-0 right-0 h-1 bg-violet-500 origin-left"
    />
  );
}
```

**useScroll Returns:**

- `scrollX` / `scrollY` - Absolute scroll position (pixels)
- `scrollXProgress` / `scrollYProgress` - Scroll progress (0-1)

**Element Scroll Tracking:**

```tsx
const containerRef = useRef(null)
const { scrollYProgress } = useScroll({ container: containerRef })

<div ref={containerRef} style={{ overflow: "scroll" }}>
  {/* scrollable content */}
</div>
```

**Element Position in Viewport:**

```tsx
const targetRef = useRef(null)
const { scrollYProgress } = useScroll({
  target: targetRef,
  offset: ["start end", "end start"]  // When element enters/exits viewport
})

<motion.div ref={targetRef} style={{ opacity: scrollYProgress }} />
```

**Offset Options:**

- `"start start"` - Top of element meets top of viewport
- `"start end"` - Top of element meets bottom of viewport
- `"end start"` - Bottom of element meets top of viewport
- `"end end"` - Bottom of element meets bottom of viewport
- `"center center"` - Centers align

**Parallax Effect:**

```tsx
const { scrollYProgress } = useScroll()
const y = useTransform(scrollYProgress, [0, 1], [0, -200])

<motion.div style={{ y }} />
```

**Smooth Scroll Values:**

```tsx
const { scrollYProgress } = useScroll();
const smoothProgress = useSpring(scrollYProgress, {
  stiffness: 100,
  damping: 30,
});
```

### Layout Animations

Animate layout changes with a single prop. Motion uses FLIP for performance.

```tsx
<motion.div layout />                    // Animate position AND size
<motion.div layout="position" />         // Animate position only (no scale distortion)
<motion.div layout="size" />             // Animate size only
```

**Shared Layout Animations (Magic Motion):**

```tsx
// Two elements with same layoutId will animate between each other
{
  items.map((item) => (
    <motion.div key={item.id} layoutId={item.id}>
      {selectedId === item.id && <motion.div layoutId="highlight" />}
    </motion.div>
  ));
}
```

**Layout Transition Customization:**

```tsx
<motion.div
  layout
  transition={{
    layout: { type: "spring", stiffness: 300, damping: 30 },
  }}
/>
```

**LayoutGroup** - Sync layout animations across components:

```tsx
import { LayoutGroup } from "motion/react";

<LayoutGroup>
  <ComponentA /> {/* Layout changes here... */}
  <ComponentB /> {/* ...trigger animations here too */}
</LayoutGroup>;
```

**Scale Correction:**
Layout animations use `transform: scale()` which can distort children. Fix with:

- Give children their own `layout` prop
- Use `layout="position"` for text/images with different aspect ratios
- Set `borderRadius` and `boxShadow` via `style` prop (auto-corrected)

### AnimatePresence (Exit Animations)

Wrap components to enable `exit` animations when they unmount:

```tsx
import { AnimatePresence, motion } from "motion/react";

<AnimatePresence>
  {isVisible && (
    <motion.div
      key="modal"
      initial={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.9 }}
    />
  )}
</AnimatePresence>;
```

**AnimatePresence Props:**
| Prop | Default | Description |
|------|---------|-------------|
| `mode` | `"sync"` | `"sync"` \| `"wait"` \| `"popLayout"` |
| `initial` | `true` | Set `false` to disable initial animations |
| `onExitComplete` | - | Callback when all exit animations complete |
| `custom` | - | Pass data to exiting components |
| `propagate` | `false` | Propagate exit to nested AnimatePresence |

**Mode Options:**

- `"sync"` - Enter/exit simultaneously (default)
- `"wait"` - Wait for exit to complete before entering
- `"popLayout"` - Exiting elements "pop" out, siblings reflow immediately

```tsx
<AnimatePresence mode="wait">
  <motion.div key={currentPage} exit={{ opacity: 0 }} />
</AnimatePresence>
```

### Variants (Orchestrated Animations)

Define animation states and orchestrate children:

```tsx
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.2,
      when: "beforeChildren"
    }
  }
}

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 }
}

<motion.ul variants={containerVariants} initial="hidden" animate="visible">
  {items.map(item => (
    <motion.li key={item.id} variants={itemVariants} />
  ))}
</motion.ul>
```

**Orchestration Props:**

- `staggerChildren` - Delay between each child (seconds)
- `delayChildren` - Delay before first child starts
- `staggerDirection` - `1` (first to last) or `-1` (last to first)
- `when` - `"beforeChildren"` | `"afterChildren"`

**Dynamic Variants:**

```tsx
const variants = {
  visible: (custom: number) => ({
    opacity: 1,
    transition: { delay: custom * 0.1 }
  })
}

<motion.div custom={index} variants={variants} />
```

### Transitions

Configure how animations behave:

```tsx
<motion.div
  animate={{ x: 100 }}
  transition={{
    type: "spring", // "spring" | "tween" | "inertia"
    duration: 0.8, // Tween duration (seconds)
    delay: 0.2, // Delay before start
    repeat: 2, // Number of repeats (Infinity for loop)
    repeatType: "reverse", // "loop" | "reverse" | "mirror"
    repeatDelay: 0.5, // Delay between repeats
  }}
/>
```

**Spring Physics:**

```tsx
transition={{
  type: "spring",
  stiffness: 400,    // Higher = snappier (default: 100)
  damping: 25,       // Higher = less oscillation (default: 10)
  mass: 1,           // Higher = more sluggish (default: 1)
  velocity: 0,       // Initial velocity
  restDelta: 0.01,   // Animation ends when delta below this
  restSpeed: 0.01    // Animation ends when speed below this
}}
```

**Duration-Based Spring:**

```tsx
transition={{
  type: "spring",
  duration: 0.8,     // Visual duration
  bounce: 0.25       // Bounciness (0-1)
}}
```

**Tween (Easing):**

```tsx
transition={{
  type: "tween",
  duration: 0.5,
  ease: "easeInOut"  // Or [0.42, 0, 0.58, 1] cubic-bezier
}}
```

**Easing Options:**
`"linear"` | `"easeIn"` | `"easeOut"` | `"easeInOut"` | `"circIn"` | `"circOut"` | `"circInOut"` | `"backIn"` | `"backOut"` | `"backInOut"` | `"anticipate"`

**Per-Value Transitions:**

```tsx
transition={{
  opacity: { duration: 0.2 },
  x: { type: "spring", stiffness: 300 },
  default: { duration: 0.3 }  // Fallback for other values
}}
```

### Motion Hooks

**useAnimate** - Imperative animation control:

```tsx
import { useAnimate } from "motion/react";

function Component() {
  const [scope, animate] = useAnimate();

  const handleClick = async () => {
    await animate(scope.current, { scale: 1.2 }, { duration: 0.2 });
    await animate(scope.current, { scale: 1 });
    // Scoped selectors
    await animate("li", { opacity: 1, x: 0 }, { delay: stagger(0.1) });
  };

  return (
    <div ref={scope} onClick={handleClick}>
      ...
    </div>
  );
}
```

**useMotionValue** - Create animatable values:

```tsx
import { useMotionValue, motion } from "motion/react"

const x = useMotionValue(0)
const opacity = useMotionValue(1)

<motion.div style={{ x, opacity }} drag="x" />
```

**useTransform** - Derive values from other motion values:

```tsx
import { useTransform, useMotionValue } from "motion/react"

const x = useMotionValue(0)
const opacity = useTransform(x, [-200, 0, 200], [0, 1, 0])
const backgroundColor = useTransform(x, [-200, 200], ["#ff0000", "#00ff00"])

<motion.div style={{ x, opacity, backgroundColor }} drag="x" />
```

**useSpring** - Create spring-animated motion values:

```tsx
import { useSpring, useMotionValue } from "motion/react"

const x = useMotionValue(0)
const springX = useSpring(x, { stiffness: 300, damping: 30 })

<motion.div style={{ x: springX }} />
```

**useVelocity** - Track velocity of a motion value:

```tsx
import { useVelocity, useMotionValue } from "motion/react";

const x = useMotionValue(0);
const xVelocity = useVelocity(x);
```

**useMotionValueEvent** - Subscribe to motion value events:

```tsx
import { useMotionValueEvent, useMotionValue } from "motion/react";

const x = useMotionValue(0);

useMotionValueEvent(x, "change", (latest) => console.log(latest));
useMotionValueEvent(x, "animationStart", () => console.log("started"));
useMotionValueEvent(x, "animationComplete", () => console.log("done"));
```

**useInView** - Detect when element enters viewport:

```tsx
import { useInView } from "motion/react"

const ref = useRef(null)
const isInView = useInView(ref, { once: true, margin: "-100px" })

<div ref={ref} style={{ opacity: isInView ? 1 : 0 }} />
```

**useReducedMotion** - Respect user's motion preferences:

```tsx
import { useReducedMotion } from "motion/react";

const shouldReduceMotion = useReducedMotion();
const animation = shouldReduceMotion ? { opacity: 1 } : { opacity: 1, y: 0 };
```

### Keyframe Animations

Animate through multiple values:

```tsx
<motion.div
  animate={{
    x: [0, 100, 50, 100],
    opacity: [0, 1, 1, 0],
  }}
  transition={{
    duration: 2,
    times: [0, 0.3, 0.7, 1], // Keyframe positions (0-1)
    ease: ["easeIn", "easeOut", "easeInOut"], // Per-segment easing
  }}
/>
```

### SVG Animations

```tsx
<motion.path
  d="M0 0 L100 100"
  initial={{ pathLength: 0 }}
  animate={{ pathLength: 1 }}
  transition={{ duration: 2, ease: "easeInOut" }}
/>

<motion.circle
  cx="50" cy="50" r="40"
  initial={{ pathLength: 0, pathOffset: 0 }}
  animate={{ pathLength: 1, pathOffset: 0 }}
/>
```

### MotionConfig (Global Defaults)

Set default transition for all children:

```tsx
import { MotionConfig } from "motion/react";

<MotionConfig transition={{ type: "spring", stiffness: 300, damping: 30 }}>
  <motion.div animate={{ x: 100 }} /> {/* Uses spring */}
  <motion.div animate={{ y: 50 }} /> {/* Uses spring */}
</MotionConfig>;
```

**Reduce Motion:**

```tsx
<MotionConfig reducedMotion="user">
  {" "}
  {/* "user" | "always" | "never" */}
  {children}
</MotionConfig>
```

---

## Premium Animation Patterns

### Staggered List Reveal

```tsx
const container = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: { staggerChildren: 0.1 }
  }
}

const item = {
  hidden: { opacity: 0, y: 20 },
  show: { opacity: 1, y: 0 }
}

<motion.ul variants={container} initial="hidden" animate="show">
  {items.map(i => <motion.li key={i} variants={item} />)}
</motion.ul>
```

### Magnetic Hover Effect

```tsx
function MagneticButton({ children }) {
  const x = useMotionValue(0);
  const y = useMotionValue(0);

  const handleMouse = (e: React.MouseEvent) => {
    const rect = e.currentTarget.getBoundingClientRect();
    x.set((e.clientX - rect.left - rect.width / 2) * 0.3);
    y.set((e.clientY - rect.top - rect.height / 2) * 0.3);
  };

  const reset = () => {
    x.set(0);
    y.set(0);
  };

  return (
    <motion.button
      style={{ x, y }}
      onMouseMove={handleMouse}
      onMouseLeave={reset}
      transition={{ type: "spring", stiffness: 150, damping: 15 }}
    >
      {children}
    </motion.button>
  );
}
```

### Scroll-Triggered Parallax

```tsx
function ParallaxSection() {
  const ref = useRef(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"],
  });

  const y = useTransform(scrollYProgress, [0, 1], [100, -100]);
  const opacity = useTransform(scrollYProgress, [0, 0.5, 1], [0, 1, 0]);

  return (
    <section ref={ref}>
      <motion.div style={{ y, opacity }}>Parallax Content</motion.div>
    </section>
  );
}
```

### Page Transition

```tsx
function PageTransition({ children }) {
  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={pathname}
        initial={{ opacity: 0, x: 20 }}
        animate={{ opacity: 1, x: 0 }}
        exit={{ opacity: 0, x: -20 }}
        transition={{ duration: 0.3 }}
      >
        {children}
      </motion.div>
    </AnimatePresence>
  );
}
```

### Expandable Card

```tsx
function ExpandableCard({ id, children }) {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      <motion.div layoutId={`card-${id}`} onClick={() => setIsOpen(true)}>
        <motion.h2 layoutId={`title-${id}`}>Title</motion.h2>
      </motion.div>

      <AnimatePresence>
        {isOpen && (
          <motion.div
            layoutId={`card-${id}`}
            className="fixed inset-0 z-50"
            onClick={() => setIsOpen(false)}
          >
            <motion.h2 layoutId={`title-${id}`}>Title</motion.h2>
            {children}
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
```

---

## Rules of Constraints (React Framework)

### 1. useEffect Usage Policy

#### 1.1 Permitted Use Cases

Use `useEffect` ONLY for:

- External system synchronization (browser APIs, third-party libraries)
- Network requests when combined with external state management
- Event listeners on window/document
- Timers (`setTimeout`, `setInterval`)
- Manual DOM manipulations (when unavoidable)
- Subscriptions (WebSocket, RxJS, etc.)

#### 1.2 Prohibited Use Cases

NEVER use `useEffect` for:

- State derivation from props/other state
- Event handling logic
- Data transformation during render
- Computing next state based on current state
- Synchronizing multiple states together

### Validation Rules

#### Pre-Render Checklist

Before creating a `useEffect`, verify:

1. Is this synchronizing with an external system?
2. Can this logic be moved to an event handler?
3. Can this value be derived during render?
4. Is there a React-native alternative?

Before writing useEffect, ask yourself ONE question:
"Is this syncing with an EXTERNAL system?"

✅ If YES → useEffect is fine
❌ If NO → You probably don't need it

Here are the better alternatives:

📊 Transforming data?
→ Calculate during render (or use useMemo)

🖱️ Handling user events?
→ Use event handlers, not effects

⚡ Expensive calculation?
→ useMemo (not useEffect + setState)

🔄 Resetting state on prop change?
→ Use the `key` prop

📡 Subscribing to external store?
→ useSyncExternalStore

The biggest mistake: Using useEffect to filter data or handle clicks. If you're doing this, there's a better way.

Common anti-patterns to avoid:

- useEffect + setState from props/state (causes extra re-renders)
- useEffect for click/submit handlers (loses event context)
- useEffect to notify parent components (breaks unidirectional data flow)

When useEffect IS appropriate:

- WebSocket connections
- Third-party widget integration
- Measuring DOM elements after render
- Browser API subscriptions with cleanup

### The Bottom Line

**When To Use useEffect:**

- **External System Sync** - Browser APIs, third-party libs
- **Subscriptions** - WebSockets, event listeners
- **Timers** - `setTimeout`/`setInterval` with cleanup
- **Network Requests** - With proper cleanup
- **Manual DOM Manipulation** - When React can't handle it

**When To NEVER Use useEffect:**

- **State Derivation** - Calculate during fucking render
- **Event Handling** - Use event handlers, dumbass
- **Multiple State Sync** - Use reducer or compute together
- **Prop Changes to State** - Usually wrong, rarely right
- **Anything That Can Be Sync** - 90% of your useEffects

---

## When to Activate

- Building new UI components
- Creating landing pages or dashboards
- Refining visual design
- Adding animations and interactions
- Implementing design systems

## Core Principles

### Color Palette

- Avoid generic colors (plain red, blue, green)
- Use curated, harmonious palettes
- HSL-based color systems for consistency
- Dark mode as first-class citizen

```css
/* Example premium palette */
--primary-hue: 250;
--primary: hsl(var(--primary-hue) 60% 55%);
--primary-soft: hsl(var(--primary-hue) 40% 95%);
--surface: hsl(0 0% 98%);
--surface-dark: hsl(0 0% 8%);
```

### Typography

- Modern fonts: Satoshi, Cabinet Grotesk, Clash Display, General Sans
- Clear hierarchy with purposeful weights
- Readable line heights (1.5-1.8 for body)

```css
font-family: "Satoshi", system-ui, sans-serif;
```

### Depth & Elevation

- Layered shadows for realistic depth
- Glassmorphism with backdrop-blur
- Subtle borders for definition

```css
/* Premium shadow */
box-shadow:
  0 1px 2px rgba(0, 0, 0, 0.04),
  0 4px 8px rgba(0, 0, 0, 0.04),
  0 16px 32px rgba(0, 0, 0, 0.06);

/* Glassmorphism */
background: rgba(255, 255, 255, 0.7);
backdrop-filter: blur(20px);
border: 1px solid rgba(255, 255, 255, 0.2);
```

### Micro-animations with Motion

- Smooth transitions (200-400ms)
- Spring physics for natural feel
- Hover states on interactive elements
- Loading states with shimmer/skeleton

```tsx
// Motion for React example
<motion.div
  whileHover={{ scale: 1.02, y: -2 }}
  transition={{ type: "spring", stiffness: 400, damping: 20 }}
>
```

## Component Patterns

### Cards

```tsx
<motion.div
  className="bg-white rounded-2xl p-6 shadow-[0_4px_20px_rgba(0,0,0,0.08)] border border-gray-100"
  whileHover={{ y: -4, shadow: "0 8px 30px rgba(0,0,0,0.12)" }}
  transition={{ type: "spring", stiffness: 300, damping: 25 }}
>
```

### Buttons

```tsx
<motion.button
  className="px-6 py-3 rounded-xl font-medium bg-gradient-to-b from-violet-500 to-violet-600 text-white shadow-lg shadow-violet-500/25"
  whileHover={{ scale: 1.02, boxShadow: "0 20px 40px rgba(139, 92, 246, 0.3)" }}
  whileTap={{ scale: 0.98 }}
  transition={{ type: "spring", stiffness: 400, damping: 17 }}
>
```

### Inputs

```tsx
<motion.input
  className="w-full px-4 py-3 rounded-xl bg-gray-50 border border-gray-200 focus:ring-2 focus:ring-violet-500/20 focus:border-violet-500 transition-colors"
  whileFocus={{ scale: 1.01 }}
/>
```

## Responsive Breakpoints

```css
/* Mobile first */
@media (min-width: 640px) {
  /* sm */
}
@media (min-width: 768px) {
  /* md */
}
@media (min-width: 1024px) {
  /* lg */
}
@media (min-width: 1280px) {
  /* xl */
}
```

## Anti-Patterns (Avoid)

- ❌ Plain, unstyled components
- ❌ Generic system fonts (Inter, Roboto, Arial)
- ❌ Flat designs without depth
- ❌ Missing hover/focus states
- ❌ Harsh color contrasts
- ❌ Placeholder images (generate real assets)
- ❌ Using `framer-motion` (use `motion/react` instead)
- ❌ useEffect for derived state

## Integration

Works best with:

- **Tailwind CSS** - Utility-first styling
- **Motion for React** - `motion/react` for animations
- **Lucide/Heroicons** - Icon sets
- **Fontshare/Google Fonts** - Typography
