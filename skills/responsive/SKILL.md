---
name: responsive
description: "Responsive design methodology — mobile-first, breakpoint strategy, fluid typography, container queries"
triggers:
  - "responsive design"
  - "mobile responsive"
  - "breakpoints"
  - "mobile first"
  - "make this responsive"
---

# Responsive — Adaptive Design

## When to Invoke

Use when building layouts that need to work across mobile (375px) to desktop (2560px+), or when fixing broken responsive behavior.

## Strategy: Mobile-First

Write base styles for mobile, layer up for larger screens:

```css
/* Base: mobile (375px+) */
.grid { grid-template-columns: 1fr; }

/* Tablet (768px+) */
@media (min-width: 768px) { .grid { grid-template-columns: repeat(2, 1fr); } }

/* Desktop (1024px+) */
@media (min-width: 1024px) { .grid { grid-template-columns: repeat(3, 1fr); } }
```

In Tailwind: write mobile styles first, use `md:` and `lg:` prefixes to override up.

## Breakpoint System

| Name | Width | Target |
|------|-------|--------|
| `sm` | 640px | Large phones landscape |
| `md` | 768px | Tablets |
| `lg` | 1024px | Small laptops |
| `xl` | 1280px | Desktops |
| `2xl` | 1536px | Large desktops |

**Critical widths to test:**
- 375px (iPhone SE/mini)
- 390px (iPhone 14/15)
- 768px (iPad portrait)
- 1024px (iPad landscape / small laptop)
- 1280px (standard laptop)
- 1440px (design standard)
- 1920px (full HD monitor)

## Layout Patterns

### Content Container

```tsx
// Max-width container with responsive padding
<div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
  {children}
</div>
```

### Responsive Grid

```tsx
// Cards that reflow
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6">
  {items.map(item => <Card key={item.id} />)}
</div>
```

### Sidebar Layout

```tsx
// Sidebar collapses to bottom on mobile
<div className="flex flex-col lg:flex-row gap-8">
  <main className="flex-1 order-2 lg:order-1">{content}</main>
  <aside className="w-full lg:w-80 order-1 lg:order-2">{sidebar}</aside>
</div>
```

### Stack to Row

```tsx
// Vertical on mobile, horizontal on desktop
<div className="flex flex-col sm:flex-row items-start sm:items-center gap-4">
  <h2 className="text-2xl">Title</h2>
  <button>Action</button>
</div>
```

## Fluid Typography

```css
/* Scales smoothly between breakpoints */
h1 {
  font-size: clamp(2rem, 5vw + 1rem, 4.5rem);
  line-height: 1.1;
}

/* Tailwind v4 equivalent */
.heading {
  font-size: clamp(theme(fontSize.3xl), 5vw + 1rem, theme(fontSize.6xl));
}
```

| Element | Min (mobile) | Max (desktop) |
|---------|-------------|---------------|
| H1 | 2rem (32px) | 4.5rem (72px) |
| H2 | 1.5rem (24px) | 3rem (48px) |
| Body | 1rem (16px) | 1.125rem (18px) |

## Container Queries (component-level responsive)

```css
/* Parent sets containment */
.card-container {
  container-type: inline-size;
}

/* Child responds to container width, not viewport */
@container (min-width: 400px) {
  .card { flex-direction: row; }
}
```

Use when: component is reused in different-width contexts (sidebar vs main content).

## Common Responsive Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| Horizontal scroll on mobile | Fixed-width element exceeds viewport | `max-w-full overflow-hidden` on parent |
| Text too small on mobile | Desktop font sizes applied at all widths | Mobile-first sizing with `clamp()` |
| Touch targets too small | Desktop-sized buttons | Min 44px height/width on mobile |
| Images overflow | Fixed `width` attribute | `max-w-full h-auto` |
| Navbar breaks | Too many items at small widths | Hamburger menu below `lg:` |
| Hero overflows viewport | `h-screen` on iOS | Use `min-h-[100dvh]` |
| Columns too narrow | Too many columns at tablet | Reduce column count earlier |

## Viewport Stability

```tsx
// NEVER use h-screen (iOS Safari address bar causes jump)
<section className="min-h-[100dvh]" /> // Correct

// Safe area for notch/dynamic island
<body className="pb-[env(safe-area-inset-bottom)]" />
```

## Testing Checklist

- [ ] 375px — nothing overflows, text readable, touch targets 44px+
- [ ] 768px — layout shifts make sense, no orphan columns
- [ ] 1024px — full layout visible, navigation on one line
- [ ] 1440px — content doesn't stretch to full width (max-w container)
- [ ] 1920px+ — no awkward stretching, content remains contained
- [ ] Landscape mobile — height-constrained layouts work
- [ ] Text zoom 200% — no overflow, no hidden content
- [ ] Rotation — layout adapts without reload

## Output

```markdown
## Responsive Implementation

**Strategy**: Mobile-first
**Breakpoints used**: [list]
**Fluid typography**: [yes/no]
**Container queries**: [where used]
**Tested at**: [widths verified]
**Issues found/fixed**: [list]
```
