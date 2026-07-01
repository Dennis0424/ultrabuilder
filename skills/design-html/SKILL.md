---
name: design-html
description: "Turn mockups/descriptions into production HTML — responsive, dynamic layout, framework-aware"
triggers:
  - "design to html"
  - "build this ui"
  - "implement this design"
  - "code this mockup"
---

# Design HTML — Mockup to Production Code

## When to Invoke

Use when you have a design (mockup, screenshot, description, or Figma reference) and need to turn it into production-quality frontend code.

## Workflow

### Step 1: Detect Context

1. **Framework detection** — scan project for:
   - React (Next.js, Vite, CRA)
   - Vue (Nuxt, Vite)
   - Svelte (SvelteKit)
   - Plain HTML/CSS
   - Component library (shadcn, MUI, Chakra, etc.)
2. **Styling approach** — Tailwind, CSS modules, styled-components, vanilla CSS
3. **Existing patterns** — look at 2-3 existing components to match conventions

### Step 2: Analyze the Design

1. **Break into components** — identify repeating patterns, containers, atoms
2. **Identify responsive breakpoints** — what changes at mobile/tablet/desktop?
3. **Map interactions** — hover states, focus states, transitions, animations
4. **Extract design tokens** — colors, spacing, fonts, border-radius, shadows

### Step 3: Route by Design Type

Different designs need different approaches:

**Landing Page** — hero sections, CTAs, testimonials
- Focus: visual impact, scroll behavior, CTA prominence
- Dynamic: content-length-aware sections, auto-flowing testimonials

**Dashboard** — data display, charts, tables
- Focus: information density, scanability, responsive tables
- Dynamic: resize-aware layouts, collapsible sidebars

**Form/Input** — multi-step, validation, submission
- Focus: progressive disclosure, clear errors, accessible labels
- Dynamic: conditional fields, validation state transitions

**Chat/Feed** — messages, infinite scroll, real-time
- Focus: message grouping, auto-scroll, loading states
- Dynamic: variable-height messages, virtualized lists

### Step 4: Implement

1. **Structure first** — semantic HTML, proper heading hierarchy, ARIA where needed
2. **Layout second** — flexbox/grid, responsive behavior, spacing
3. **Style third** — colors, typography, borders, shadows
4. **Interaction last** — hover/focus/active states, transitions, animations

### Step 5: Dynamic Layout Rules

Avoid the "static CSS with hardcoded heights" trap:

- **Never hardcode heights** for text containers — use min-height + auto
- **Content-aware spacing** — margins/padding relative to content, not fixed
- **Reflow on resize** — test at multiple widths, ensure nothing breaks
- **Variable content** — design for empty state, one item, many items, overflow

### Step 6: Verify

1. Start dev server
2. Check at 3 widths: mobile (375px), tablet (768px), desktop (1280px)
3. Check with long/short content
4. Check keyboard navigation
5. Check color contrast (WCAG AA minimum)

## Output

```markdown
## Design Implementation Complete

**Components created**: [list with paths]
**Framework**: [detected/used]
**Responsive**: [breakpoints tested]
**Accessibility**: [ARIA labels, focus management, contrast]
**Dynamic layout**: [what reflows/adapts]
```

## Principles

- Match existing project patterns exactly — don't introduce new conventions
- Semantic HTML first, visual styling second
- If the design is ambiguous, ask rather than guess
- Test with real content, not lorem ipsum
- Accessibility is not optional — every interactive element needs keyboard + screen reader support
- Performance matters — lazy load images, minimize layout shifts
