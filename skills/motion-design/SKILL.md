---
name: motion-design
description: "Animation system design — Motion/GSAP implementation, easing curves, orchestration, scroll-driven motion, performance"
triggers:
  - "animation"
  - "motion design"
  - "add animations"
  - "make this animate"
  - "gsap"
  - "framer motion"
---

# Motion Design — Animation System

## When to Invoke

Use when adding motion to a project — from micro-interactions to full scroll-driven experiences. This skill ensures animations are purposeful, performant, and accessible.

## The Motivation Test

Before ANY animation, answer: **"What does this communicate?"**

| Valid Reason | Example |
|-------------|---------|
| Hierarchy | Drawing attention to a CTA on page load |
| Storytelling | Revealing content in narrative sequence |
| Feedback | Button press confirmation |
| State transition | Showing data updated |
| Spatial orientation | Where did that panel come from? |
| Delight (sparingly) | A satisfying bounce on success |

**If you can't justify it in one sentence, don't animate it.**

## Library Selection

| Use Case | Library | Import |
|----------|---------|--------|
| UI transitions, layout, gestures | Motion | `import { motion } from "motion/react"` |
| Scroll-pinning, horizontal scroll, complex timelines | GSAP + ScrollTrigger | `gsap` + `gsap/ScrollTrigger` |
| Simple CSS transitions | Native CSS | `transition` property |
| Scroll-reveal (no pin needed) | Motion `whileInView` OR CSS `animation-timeline` | — |
| 3D / WebGL | Three.js | Isolate in dedicated canvas component |

**Rules:**
- Never mix GSAP and Motion in the same component
- GSAP lives in `useEffect` with cleanup: `return () => ctx.revert()`
- Motion components must be in `'use client'` files (Next.js)
- Never use `window.addEventListener('scroll')` — use `useScroll()` or ScrollTrigger

## Easing System

### Standard Easings (use these 90% of the time)

```typescript
const EASE = {
  // Default for enters/exits
  out: [0.16, 1, 0.3, 1],        // fast start, gentle stop
  // Default for hovers/interactions  
  inOut: [0.65, 0, 0.35, 1],     // smooth both ends
  // Bouncy/playful
  spring: { type: "spring", stiffness: 300, damping: 24 },
  // Snappy
  snappy: { type: "spring", stiffness: 500, damping: 30 },
  // Gentle float
  gentle: { type: "spring", stiffness: 100, damping: 20 },
} as const
```

### Duration Scale

| Element Size | Duration |
|-------------|----------|
| Micro (icon, badge) | 150-200ms |
| Small (button, card) | 200-300ms |
| Medium (panel, modal) | 300-500ms |
| Large (page, full-screen) | 500-800ms |
| Scroll-driven | Tied to scroll progress (no fixed duration) |

**Rule: larger elements move slower. Smaller elements are snappy.**

## Animation Patterns

### Entry Animations (elements appearing)

```tsx
// Fade + slide up (most common)
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
/>

// Staggered children
<motion.ul>
  {items.map((item, i) => (
    <motion.li
      key={item.id}
      initial={{ opacity: 0, y: 16 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: i * 0.05, duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
    />
  ))}
</motion.ul>

// Scale in (for modals, popovers)
<motion.div
  initial={{ opacity: 0, scale: 0.95 }}
  animate={{ opacity: 1, scale: 1 }}
  exit={{ opacity: 0, scale: 0.95 }}
  transition={{ duration: 0.2, ease: [0.16, 1, 0.3, 1] }}
/>
```

### Scroll-Reveal (lightweight, no GSAP needed)

```tsx
<motion.section
  initial={{ opacity: 0, y: 30 }}
  whileInView={{ opacity: 1, y: 0 }}
  viewport={{ once: true, amount: 0.3 }}
  transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
/>
```

### Hover Interactions

```tsx
// Scale + shadow lift
<motion.div
  whileHover={{ y: -4, boxShadow: "0 20px 40px rgba(0,0,0,0.1)" }}
  whileTap={{ scale: 0.98 }}
  transition={{ type: "spring", stiffness: 400, damping: 25 }}
/>

// Magnetic button (pointer-following)
// Use useMotionValue — NEVER useState for continuous values
const x = useMotionValue(0)
const y = useMotionValue(0)
```

### Page/Route Transitions

```tsx
// Layout animations (shared elements between routes)
<motion.div layoutId="card-image" />

// Page wrapper
<motion.main
  initial={{ opacity: 0 }}
  animate={{ opacity: 1 }}
  exit={{ opacity: 0 }}
  transition={{ duration: 0.3 }}
/>
```

### Scroll-Driven (GSAP for pinning/scrubbing)

```tsx
// Pin a section and scrub an animation
useEffect(() => {
  const ctx = gsap.context(() => {
    gsap.to(".target", {
      x: -distance,
      ease: "none",
      scrollTrigger: {
        trigger: ".wrapper",
        start: "top top",
        end: `+=${distance}`,
        pin: true,
        scrub: 1,
      },
    })
  }, containerRef)
  return () => ctx.revert()
}, [])
```

## Performance Rules

1. **Only animate `transform` and `opacity`** — they don't trigger layout/paint
2. **Use `will-change: transform`** sparingly (only on elements about to animate)
3. **Avoid animating during scroll** without `requestAnimationFrame` batching (use libraries)
4. **Lazy-load heavy animation libraries** (Three.js, GSAP) below the fold
5. **Test on mobile** — 60fps on desktop means nothing if mobile drops to 20fps
6. **Grain/noise overlays** must be `position: fixed; pointer-events: none` — never on scrolling containers

## Accessibility (mandatory)

```tsx
// Always wrap motion in reduced-motion check
const reduce = useReducedMotion()

<motion.div
  initial={reduce ? false : { opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
/>

// CSS approach
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

## Output

```markdown
## Motion System

**Library**: [Motion / GSAP / CSS / mixed]
**Animations added**: [count]
**Patterns used**: [entry, scroll-reveal, hover, page-transition, scroll-driven]
**Performance**: [60fps verified on mobile?]
**Reduced motion**: [honored?]
**Easing system**: [defined and consistent?]
```
