---
name: accessibility
description: "WCAG compliance audit and fixes — keyboard nav, screen readers, contrast, focus management, ARIA"
triggers:
  - "accessibility"
  - "a11y"
  - "wcag"
  - "screen reader"
  - "keyboard navigation"
  - "make this accessible"
---

# Accessibility — WCAG Compliance

## When to Invoke

Use when building new UI, auditing existing pages for accessibility, or fixing reported a11y issues. This is not optional — accessibility is a requirement, not a feature.

## Quick Audit (run on any page)

### 1. Keyboard Navigation
- [ ] Tab through the entire page — can you reach every interactive element?
- [ ] Is focus visible on every focused element? (no `outline: none` without replacement)
- [ ] Can you activate buttons/links with Enter/Space?
- [ ] Can you close modals with Escape?
- [ ] Is tab order logical (matches visual order)?
- [ ] No keyboard traps (can always tab out)?

### 2. Screen Reader
- [ ] All images have meaningful `alt` text (or `alt=""` for decorative)
- [ ] Headings form a logical hierarchy (h1 → h2 → h3, no skips)
- [ ] Form inputs have associated `<label>` elements
- [ ] Dynamic content changes are announced (`aria-live`)
- [ ] Custom components have correct ARIA roles

### 3. Visual
- [ ] Text contrast ratio ≥ 4.5:1 (body) / 3:1 (large text 18px+)
- [ ] UI component contrast ≥ 3:1 against adjacent colors
- [ ] Information not conveyed by color alone
- [ ] Text resizable to 200% without breaking layout
- [ ] No content lost at 320px viewport width

### 4. Motion
- [ ] `prefers-reduced-motion` respected for all animations
- [ ] No auto-playing video/animation without pause control
- [ ] No content that flashes more than 3 times per second

## Fix Patterns

### Focus Management

```tsx
// Focus trap for modals
import { FocusTrap } from "@radix-ui/react-focus-trap"

// Return focus after close
const triggerRef = useRef<HTMLButtonElement>(null)
const onClose = () => {
  setOpen(false)
  triggerRef.current?.focus()
}

// Skip link
<a href="#main" className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4">
  Skip to content
</a>
```

### ARIA Patterns

```tsx
// Tabs
<div role="tablist">
  <button role="tab" aria-selected={active === 0} aria-controls="panel-0">Tab 1</button>
</div>
<div role="tabpanel" id="panel-0" aria-labelledby="tab-0">Content</div>

// Live region for dynamic updates
<div aria-live="polite" aria-atomic="true">
  {statusMessage}
</div>

// Loading state
<button aria-busy={loading} aria-disabled={loading}>
  {loading ? "Saving..." : "Save"}
</button>
```

### Color Contrast

```
WCAG AA minimums:
- Body text (< 18px): 4.5:1
- Large text (≥ 18px bold or ≥ 24px): 3:1
- UI components and graphical objects: 3:1

Tools: check with browser devtools (Chrome > Inspect > color picker shows ratio)
```

### Semantic HTML (prefer over ARIA)

| Instead of... | Use... |
|--------------|--------|
| `<div onclick>` | `<button>` |
| `<div role="navigation">` | `<nav>` |
| `<div role="main">` | `<main>` |
| `<span role="link">` | `<a href>` |
| `<div role="heading">` | `<h1>`-`<h6>` |

**First rule of ARIA:** don't use ARIA if a native HTML element does the job.

## Testing

### Automated (catches ~30% of issues)
```bash
# axe-core via CLI
npx @axe-core/cli http://localhost:3000

# In tests
import { axe } from 'jest-axe'
const { container } = render(<MyComponent />)
expect(await axe(container)).toHaveNoViolations()
```

### Manual (catches the rest)
1. Unplug your mouse — navigate entire flow with keyboard only
2. Turn on VoiceOver (Mac: Cmd+F5) or NVDA (Windows) — listen to the page
3. Zoom to 200% — check nothing breaks
4. Set `prefers-reduced-motion: reduce` — check animations stop
5. Use high-contrast mode — check content still visible

## WCAG Levels

| Level | Meaning | Target |
|-------|---------|--------|
| A | Minimum — site is usable | Must meet |
| AA | Standard — site is accessible | Default target |
| AAA | Enhanced — site is optimal | Where feasible |

**Target AA for everything. Reach for AAA on critical paths (forms, checkout, auth).**

## Output

```markdown
## Accessibility Audit

**WCAG Level**: [A / AA / AAA]
**Issues Found**: [count] ([critical], [serious], [moderate])
**Keyboard**: PASS / [issues]
**Screen Reader**: PASS / [issues]
**Contrast**: PASS / [issues]
**Motion**: PASS / [issues]
**Fixed**: [count] issues
**Remaining**: [count] issues (with remediation plan)
```
