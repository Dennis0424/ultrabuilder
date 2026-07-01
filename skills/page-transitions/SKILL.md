---
name: page-transitions
description: "Route transitions — shared layout animations, page enters/exits, view transitions API, SPA navigation"
triggers:
  - "page transitions"
  - "route animation"
  - "page animation"
  - "view transitions"
  - "navigation animation"
---

# Page Transitions — Route Animations

## When to Invoke

Use when navigation between pages/routes should feel smooth rather than jarring. Applies to SPAs, Next.js apps, and progressive enhancement with View Transitions API.

## Approaches (pick one per project)

### 1. View Transitions API (modern, progressive)

Native browser API. Works cross-document (MPA) and same-document (SPA). Best for simple crossfades and shared elements.

```tsx
// Next.js App Router — wrap navigation
import { useRouter } from "next/navigation"

function useViewTransition() {
  const router = useRouter()

  return (href: string) => {
    if (!document.startViewTransition) {
      router.push(href)
      return
    }
    document.startViewTransition(() => {
      router.push(href)
    })
  }
}

// CSS for the transition
::view-transition-old(root) {
  animation: fade-out 200ms ease-out;
}
::view-transition-new(root) {
  animation: fade-in 200ms ease-in;
}

// Shared element (same view-transition-name on both pages)
.hero-image {
  view-transition-name: hero;
}
```

**Pros:** Zero JS for basic transitions, works cross-document, native performance.
**Cons:** Limited browser support (Chrome/Edge/Safari 18+), limited choreography control.

### 2. Motion Layout Animations (React SPAs)

Shared layout animations using Motion's `layoutId`. Element morphs smoothly between positions.

```tsx
// List page
<motion.div layoutId={`card-${id}`}>
  <img src={thumbnail} />
  <h3>{title}</h3>
</motion.div>

// Detail page (same layoutId = element morphs between them)
<motion.div layoutId={`card-${id}`}>
  <img src={fullImage} />
  <h1>{title}</h1>
  <p>{description}</p>
</motion.div>
```

**Pros:** Rich control, works everywhere React works, gesture-interruptible.
**Cons:** Same-document only, requires careful layoutId management.

### 3. AnimatePresence (page enter/exit)

Wrap route content to animate mount/unmount.

```tsx
// layout.tsx
"use client"
import { AnimatePresence, motion } from "motion/react"
import { usePathname } from "next/navigation"

export function PageTransition({ children }: { children: React.ReactNode }) {
  const pathname = usePathname()

  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={pathname}
        initial={{ opacity: 0, y: 8 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: -8 }}
        transition={{ duration: 0.3, ease: [0.16, 1, 0.3, 1] }}
      >
        {children}
      </motion.div>
    </AnimatePresence>
  )
}
```

**`mode="wait"`** — old page exits fully before new page enters (clean, no overlap).
**`mode="sync"`** — both animate simultaneously (faster, can feel chaotic).

### 4. GSAP Page Transitions (full control)

For complex choreography — elements flying to new positions, curtain wipes, etc.

```tsx
// Transition out before navigation
async function navigateTo(href: string) {
  const tl = gsap.timeline()
  tl.to(".page-content", { opacity: 0, y: -20, duration: 0.3 })
  tl.to(".nav", { y: -80, duration: 0.2 }, "-=0.2")
  await tl.play()
  router.push(href)
}

// Transition in on mount
useEffect(() => {
  gsap.from(".page-content", { opacity: 0, y: 20, duration: 0.4, delay: 0.1 })
}, [])
```

## Transition Patterns

| Pattern | Feel | Use For |
|---------|------|---------|
| Crossfade | Subtle, professional | Most apps (default) |
| Slide left/right | Spatial, directional | Forward/back navigation |
| Scale + fade | Zoom effect | Card → detail expansion |
| Shared morph | Continuous, delightful | List → detail with shared image |
| Curtain/wipe | Dramatic | Portfolio, creative sites |
| None | Instant | Data-heavy apps where speed > delight |

## Rules

1. **Duration: 200-400ms max** — page transitions must be fast. Users are navigating, not watching a show.
2. **Exit before enter** (`mode="wait"`) is cleaner for most apps. Overlap only when spatial direction matters.
3. **Never block navigation** — if the animation bugs out, the page still loads.
4. **Shared elements need SAME layoutId** on both pages — mismatched IDs break the morph.
5. **Reduced motion** — collapse all transitions to instant (`duration: 0`) or simple crossfade.
6. **Loading states** — if the next page needs data, show a skeleton immediately (don't hold the transition).

## Output

```markdown
## Page Transitions

**Approach**: [View Transitions API / Motion layout / AnimatePresence / GSAP / None]
**Pattern**: [crossfade / slide / shared morph / curtain]
**Duration**: [ms]
**Shared elements**: [list of layoutIds if applicable]
**Reduced motion**: [fallback behavior]
**Loading strategy**: [skeleton / placeholder / hold]
```
