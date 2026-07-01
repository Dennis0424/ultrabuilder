---
name: state-management
description: "State architecture decisions — local vs global, server state, state machines, when to use what"
triggers:
  - "state management"
  - "how to manage state"
  - "zustand vs context"
  - "global state"
  - "state machine"
---

# State Management — Architecture Decisions

## When to Invoke

Use when setting up state for a new feature/app, or when existing state is tangled and causing bugs. The goal is to pick the right tool for each type of state.

## The State Classification Matrix

Every piece of state falls into one of these categories:

| Type | Scope | Persistence | Example | Tool |
|------|-------|-------------|---------|------|
| **UI State** | Component | None | isOpen, activeTab, hoverPosition | `useState` / `useReducer` |
| **Form State** | Form scope | Session | input values, validation errors | React Hook Form / `useState` |
| **Client State** | App-wide | Session | theme, sidebar collapsed, user preferences | Zustand / Jotai / Context |
| **Server State** | App-wide | Cache | user data, posts, API responses | TanStack Query / SWR |
| **URL State** | App-wide | Permalink | search params, filters, pagination | `useSearchParams` / nuqs |
| **Persistent State** | App-wide | Disk | auth tokens, draft content | localStorage + Zustand `persist` |
| **Real-time State** | App-wide | Connection | WebSocket messages, presence | Dedicated real-time lib |

## Decision Tree

```
Is this data from an API?
├── YES → TanStack Query (server state)
└── NO → Does multiple components need it?
    ├── NO → useState (local UI state)
    └── YES → Does it need to survive refresh?
        ├── YES → Zustand with persist (or URL state)
        └── NO → Is it complex with many transitions?
            ├── YES → useReducer or state machine (XState)
            └── NO → Zustand (simple global)
```

## Implementation Patterns

### Local UI State (default — start here)

```tsx
// Simple toggle
const [isOpen, setIsOpen] = useState(false)

// Multiple related states → useReducer
type State = { status: "idle" | "loading" | "error" | "success"; data: Item[] | null; error: string | null }
type Action = { type: "fetch" } | { type: "success"; data: Item[] } | { type: "error"; error: string }

const [state, dispatch] = useReducer(reducer, { status: "idle", data: null, error: null })
```

### Server State (TanStack Query)

```tsx
// Fetch + cache + background refresh
const { data, isLoading, error } = useQuery({
  queryKey: ["users", userId],
  queryFn: () => fetchUser(userId),
  staleTime: 5 * 60 * 1000, // 5 min before refetch
})

// Mutations with optimistic update
const mutation = useMutation({
  mutationFn: updateUser,
  onMutate: async (newData) => {
    await queryClient.cancelQueries({ queryKey: ["users", userId] })
    const prev = queryClient.getQueryData(["users", userId])
    queryClient.setQueryData(["users", userId], newData)
    return { prev }
  },
  onError: (err, vars, context) => {
    queryClient.setQueryData(["users", userId], context?.prev)
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ["users", userId] })
  },
})
```

### Global Client State (Zustand)

```tsx
// Store definition
import { create } from "zustand"

interface AppStore {
  sidebarOpen: boolean
  toggleSidebar: () => void
  theme: "light" | "dark"
  setTheme: (theme: "light" | "dark") => void
}

export const useAppStore = create<AppStore>((set) => ({
  sidebarOpen: true,
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
  theme: "light",
  setTheme: (theme) => set({ theme }),
}))

// Usage — select specific slices to avoid unnecessary re-renders
const sidebarOpen = useAppStore((s) => s.sidebarOpen)
```

### URL State (nuqs or useSearchParams)

```tsx
// Type-safe URL state with nuqs
import { useQueryState, parseAsInteger } from "nuqs"

const [page, setPage] = useQueryState("page", parseAsInteger.withDefault(1))
const [search, setSearch] = useQueryState("q", { defaultValue: "" })
```

### State Machine (for complex flows)

```tsx
// When you have: loading → loaded → editing → saving → saved/error
// And invalid transitions must be impossible

type State =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "loaded"; data: User }
  | { status: "editing"; data: User; draft: Partial<User> }
  | { status: "saving"; data: User }
  | { status: "error"; error: string; retry: () => void }
```

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Everything in global state | Unnecessary re-renders, complexity | Default to local, lift only when needed |
| useState for server data | No cache, no background refresh, manual loading | TanStack Query |
| useEffect for data fetching | Race conditions, no dedup | TanStack Query or server components |
| useState for continuous values | Re-render per frame (mouse, scroll) | `useMotionValue` or refs |
| Syncing state between stores | Source of truth unclear, desync bugs | Single source + derived values |
| Prop drilling 5+ levels | Fragile, verbose | Context (for static) or Zustand (for dynamic) |

## Output

```markdown
## State Architecture

**State types identified**:
- UI state: [count] pieces (useState)
- Server state: [count] queries (TanStack Query)
- Global client: [count] slices (Zustand)
- URL state: [count] params
- Complex flows: [count] (state machine)

**Key decisions**:
- [decision and rationale]
```
