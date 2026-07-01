---
name: performance
description: "Performance optimization — bundle analysis, rendering, network, runtime profiling, quick wins"
triggers:
  - "performance optimization"
  - "make this faster"
  - "why is this slow"
  - "bundle size"
  - "optimize"
  - "core web vitals"
---

# Performance — Optimization Engineering

## When to Invoke

Use when the app feels slow, bundles are large, Core Web Vitals are failing, or before shipping a major feature. Goes deeper than `/benchmark` (which measures) — this skill actually fixes.

## The Performance Stack

```
┌─────────────────────────────────────────┐
│ Network (reduce what's downloaded)      │  ← Biggest impact
├─────────────────────────────────────────┤
│ Bundle (reduce what's parsed/compiled)  │
├─────────────────────────────────────────┤
│ Rendering (reduce what's painted)       │
├─────────────────────────────────────────┤
│ Runtime (reduce what's computed)        │  ← Smallest impact
└─────────────────────────────────────────┘
```

Fix top-down. Network wins beat runtime micro-optimizations every time.

## Quick Wins (do these first)

### 1. Images (usually the biggest win)

```tsx
// Next.js: automatic optimization
import Image from "next/image"
<Image src="/hero.jpg" width={1200} height={800} priority /> // hero = priority

// Manual: modern formats + lazy loading
<picture>
  <source srcset="/hero.avif" type="image/avif" />
  <source srcset="/hero.webp" type="image/webp" />
  <img src="/hero.jpg" loading="lazy" decoding="async" />
</picture>
```

- Use AVIF/WebP (50-80% smaller than JPEG)
- Lazy-load below-the-fold images
- Size images to display size (not 4000px for a 400px thumbnail)
- Priority-load hero/LCP image

### 2. Bundle Size

```bash
# Analyze what's in the bundle
npx @next/bundle-analyzer  # Next.js
npx vite-bundle-visualizer # Vite
npx source-map-explorer dist/main.js # Generic
```

Common wins:
- Replace `moment.js` (300KB) with `date-fns` (tree-shakeable) or `dayjs` (2KB)
- Replace `lodash` (72KB) with individual imports or native methods
- Dynamic import heavy libs: `const Chart = dynamic(() => import("chart.js"))`
- Check for duplicate dependencies (`npm ls react` — should be one version)

### 3. Code Splitting

```tsx
// Route-based (automatic in Next.js/Remix)
// Component-based (manual)
const HeavyEditor = dynamic(() => import("./Editor"), {
  loading: () => <EditorSkeleton />,
  ssr: false, // if it needs browser APIs
})

// Library-based
const { Chart } = await import("chart.js/auto")
```

### 4. Font Loading

```tsx
// Next.js (optimal)
import { Geist } from "next/font/google"
const geist = Geist({ subsets: ["latin"], display: "swap" })

// Manual (fallback)
<link rel="preload" href="/fonts/geist.woff2" as="font" type="font/woff2" crossOrigin="" />
```

- Use `font-display: swap` (never block rendering for fonts)
- Subset fonts to needed character ranges
- Self-host for performance (no DNS lookup to Google)

## Rendering Performance

### React-Specific

```tsx
// Avoid re-renders with proper state structure
// BAD: one state object triggers re-render of everything
const [state, setState] = useState({ name: "", email: "", age: 0, bio: "" })

// GOOD: separate states, or Zustand slices with selectors
const name = useStore(s => s.name)  // only re-renders when name changes

// Memo expensive computations
const sorted = useMemo(() => items.sort(compareFn), [items])

// Virtualize long lists (don't render 10,000 DOM nodes)
import { useVirtualizer } from "@tanstack/react-virtual"
```

### CSS Performance

- Avoid `*` selectors in CSS (universal match is expensive)
- Avoid layout thrashing (read-write-read-write pattern on DOM measurements)
- Use `content-visibility: auto` for off-screen sections
- Animate only `transform` and `opacity` (GPU-composited)

### DOM Size

- Keep DOM nodes under 1,500 (Chrome warns at 1,500+)
- Virtualize lists over 50 items
- Lazy-render tabs/accordions (don't mount hidden content)

## Network Performance

### Caching Strategy

```
# Static assets (fonts, images, built JS/CSS)
Cache-Control: public, max-age=31536000, immutable

# API responses (stale-while-revalidate)
Cache-Control: public, max-age=60, stale-while-revalidate=300

# HTML pages (always revalidate)
Cache-Control: public, max-age=0, must-revalidate
```

### Prefetching

```tsx
// Prefetch likely next navigations
<Link href="/dashboard" prefetch={true} />

// Preload critical resources
<link rel="preload" href="/api/user" as="fetch" crossOrigin="" />

// DNS prefetch for third-party domains
<link rel="dns-prefetch" href="//cdn.example.com" />
```

## Measurement

```bash
# Lighthouse (CLI, automated)
npx lighthouse http://localhost:3000 --output=json --output-path=./lighthouse.json

# Web Vitals in code
import { onLCP, onINP, onCLS } from "web-vitals"
onLCP(console.log)
onINP(console.log)
onCLS(console.log)
```

### Targets

| Metric | Good | Needs Work | Poor |
|--------|------|-----------|------|
| LCP | < 2.5s | 2.5-4s | > 4s |
| INP | < 200ms | 200-500ms | > 500ms |
| CLS | < 0.1 | 0.1-0.25 | > 0.25 |
| TTFB | < 800ms | 800-1800ms | > 1800ms |
| Bundle (JS) | < 200KB | 200-500KB | > 500KB |

## Optimization Checklist

- [ ] Images optimized (AVIF/WebP, lazy-loaded, properly sized)
- [ ] Bundle analyzed (no bloat, tree-shaking working)
- [ ] Code split by route (heavy pages don't block light ones)
- [ ] Fonts preloaded with `display: swap`
- [ ] Third-party scripts deferred or lazy-loaded
- [ ] Lists virtualized if > 50 items
- [ ] No layout shifts (CLS < 0.1)
- [ ] LCP element prioritized (preload, no lazy)
- [ ] Caching headers set correctly
- [ ] No unnecessary re-renders (React Profiler checked)

## Output

```markdown
## Performance Optimization

**Before**: LCP [X]s, Bundle [X]KB, Lighthouse [X]
**After**: LCP [X]s, Bundle [X]KB, Lighthouse [X]
**Wins applied**: [list]
**Remaining opportunities**: [list]
```
