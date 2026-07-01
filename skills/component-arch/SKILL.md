---
name: component-arch
description: "Component architecture — composition patterns, prop design, separation of concerns, scalable component trees"
triggers:
  - "component architecture"
  - "how should I structure components"
  - "component design"
  - "composition pattern"
  - "component hierarchy"
---

# Component Architecture — Scalable Frontend Structure

## When to Invoke

Use when building a new feature with multiple components, refactoring a tangled component tree, or establishing patterns for a growing codebase.

## Principles (The 5 Laws)

1. **Single Responsibility** — one component, one job. If you need "and" to describe it, split it.
2. **Composition Over Configuration** — prefer children/slots over 15 boolean props.
3. **Colocation** — keep related code together (styles, tests, types next to the component).
4. **Explicit Dependencies** — props down, events up. No implicit coupling through global state.
5. **Stable Interfaces** — public API (props) changes rarely; internal implementation changes freely.

## Workflow

### Step 1: Identify Component Boundaries

Read the feature requirements and draw boundaries:

```
Feature: User Profile Page
├── ProfileHeader (avatar, name, bio)      ← presentational
├── ProfileStats (followers, posts, likes)  ← data-driven
├── ProfileTabs                             ← behavioral (state)
│   ├── PostsTab                           ← container
│   │   └── PostCard[]                     ← presentational
│   ├── LikesTab                           ← container
│   └── SettingsTab                        ← form
└── ProfileActions (follow, message, share) ← interactive
```

**Boundary heuristics:**
- Different data source → different component
- Reusable elsewhere → extract
- Different update frequency → separate (avoid re-rendering static content)
- Different team ownership → separate

### Step 2: Classify Each Component

| Type | Responsibility | State? | Side Effects? |
|------|---------------|--------|---------------|
| **Presentational** | Render UI from props | No (or local UI state only) | No |
| **Container** | Fetch data, manage state | Yes | Yes |
| **Behavioral** | Add behavior (hover, drag, keyboard) | Internal only | Maybe |
| **Layout** | Structure children spatially | No | No |
| **Compound** | Multiple parts sharing implicit state | Shared context | No |

### Step 3: Design the Props API

**Good props are:**
- Minimal (only what's needed to render)
- Typed (TypeScript interfaces, not `any`)
- Documented by name (no `data`, `info`, `options` generics)
- Defaulted sensibly (optional props have smart defaults)

**Prop patterns:**

```typescript
// Discriminated union for variants
type ButtonProps =
  | { variant: "primary"; loading?: boolean }
  | { variant: "ghost"; icon: ReactNode }
  | { variant: "danger"; confirmText: string }

// Render props for flexible rendering
type ListProps<T> = {
  items: T[]
  renderItem: (item: T, index: number) => ReactNode
  renderEmpty?: () => ReactNode
}

// Compound component pattern
<Select>
  <Select.Trigger />
  <Select.Content>
    <Select.Item value="a">Option A</Select.Item>
  </Select.Content>
</Select>
```

### Step 4: Establish File Structure

```
src/
├── components/
│   ├── ui/              # Primitive UI atoms (Button, Input, Badge)
│   ├── layout/          # Page structure (Sidebar, Header, Grid)
│   ├── features/        # Feature-specific composites
│   │   ├── profile/
│   │   │   ├── ProfileHeader.tsx
│   │   │   ├── ProfileStats.tsx
│   │   │   ├── ProfileTabs.tsx
│   │   │   └── index.ts  # public exports
│   │   └── feed/
│   └── shared/          # Cross-feature reusable composites
├── hooks/               # Shared custom hooks
├── lib/                 # Utilities, API clients
└── types/               # Shared type definitions
```

### Step 5: Validate Architecture

Ask these questions:
- Can I test this component in isolation? (If no → too coupled)
- Can I reuse this component in a different context? (If no and it should be → refactor)
- Can a new developer understand this component in 30 seconds? (If no → too complex)
- If I delete this component, what breaks? (If everything → too central, split)

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| God Component (500+ lines) | Untestable, slow renders | Split by responsibility |
| Prop Drilling (5+ levels) | Fragile, verbose | Context or composition |
| Boolean Soup (`isX && !isY && isZ`) | Unreadable | State machine or discriminated union |
| Copy-Paste Components | Drift, inconsistency | Extract shared, parameterize difference |
| Premature Abstraction | Wrong boundaries | Wait for 3 uses before extracting |

## Output

```markdown
## Component Architecture

**Components**: [count] ([count] presentational, [count] container, [count] behavioral)
**Max depth**: [number] levels
**Shared components**: [list]
**File structure**: [path description]
**Key patterns used**: [compound/render-prop/HOC/hooks]
```

## When NOT to Use This

- Single-file scripts or utilities (no UI)
- Prototypes you'll throw away tomorrow
- Components with < 50 lines that don't need decomposition
