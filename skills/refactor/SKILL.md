---
name: refactor
description: "Systematic refactoring — extract, rename, restructure without breaking behavior. Safe transformations."
triggers:
  - "refactor this"
  - "clean this up"
  - "restructure"
  - "extract"
  - "this code is messy"
---

# Refactor — Systematic Code Transformation

## When to Invoke

Use when code works but is hard to understand, modify, or extend. Refactoring changes structure without changing behavior — tests pass before and after.

## The Iron Rule

**Tests must pass after every transformation.** If you don't have tests, write them first (characterization tests that capture current behavior).

## Workflow

### Step 1: Identify the Smell

| Smell | Signal | Refactoring |
|-------|--------|-------------|
| Long function (> 30 lines) | Hard to name what it does | Extract functions |
| Long parameter list (> 4 params) | Hard to call correctly | Introduce parameter object |
| Duplicated code | Same logic in 3+ places | Extract shared function |
| Deep nesting (> 3 levels) | Hard to follow | Early returns, extract |
| God class/module | Does everything | Split by responsibility |
| Feature envy | Accesses another module's data heavily | Move method to where data lives |
| Shotgun surgery | One change touches 10 files | Consolidate related logic |
| Primitive obsession | Strings/numbers where a type would help | Introduce value objects |
| Dead code | Unused functions, imports, variables | Delete |

### Step 2: Ensure Safety Net

Before refactoring:
1. Run existing tests — all pass? (If not, fix first)
2. If no tests exist for the area being refactored:
   ```typescript
   // Characterization test: captures CURRENT behavior (even if wrong)
   test("processOrder returns expected output for standard case", () => {
     const result = processOrder(sampleInput)
     expect(result).toMatchSnapshot() // or specific assertions
   })
   ```
3. Commit current state (clean baseline to revert to)

### Step 3: Apply Transformation (one at a time)

**Extract Function:**
```typescript
// Before
function processOrder(order) {
  // 15 lines of validation
  // 20 lines of calculation
  // 10 lines of formatting
}

// After
function processOrder(order) {
  const validated = validateOrder(order)
  const calculated = calculateTotals(validated)
  return formatResponse(calculated)
}
```

**Introduce Parameter Object:**
```typescript
// Before
function createUser(name, email, role, team, startDate, manager) { ... }

// After
interface CreateUserParams {
  name: string
  email: string
  role: Role
  team: string
  startDate: Date
  manager?: string
}
function createUser(params: CreateUserParams) { ... }
```

**Replace Conditional with Polymorphism:**
```typescript
// Before
function getPrice(type: string) {
  if (type === "basic") return 10
  if (type === "pro") return 25
  if (type === "enterprise") return 100
}

// After
const PRICING: Record<Plan, number> = {
  basic: 10,
  pro: 25,
  enterprise: 100,
}
function getPrice(plan: Plan): number {
  return PRICING[plan]
}
```

**Early Return (flatten nesting):**
```typescript
// Before
function process(input) {
  if (input) {
    if (input.isValid) {
      if (input.data.length > 0) {
        return doWork(input.data)
      }
    }
  }
  return null
}

// After
function process(input) {
  if (!input) return null
  if (!input.isValid) return null
  if (input.data.length === 0) return null
  return doWork(input.data)
}
```

### Step 4: Verify After Each Transformation

After EACH individual transformation:
1. Run tests — still pass?
2. Run type checker — no new errors?
3. Run the feature — still works?
4. Commit (one commit per transformation = easy to revert)

### Step 5: Review the Result

After all transformations:
- Is the code easier to understand? (Show to fresh eyes)
- Is the code easier to modify? (Imagine adding a feature)
- Did we introduce any abstraction that isn't justified yet?
- Are the function/module names accurate?

## Refactoring Moves (Safe Transformations)

| Move | Guaranteed Safe? | Notes |
|------|-----------------|-------|
| Rename variable/function | Yes | IDE rename, not find-replace |
| Extract function | Yes | If pure (no hidden side effects) |
| Inline function | Yes | If only one caller |
| Move function to another file | Yes | Update imports |
| Extract constant | Yes | Named constant for magic values |
| Remove dead code | Yes | If truly unreachable |
| Add types | Yes | Types don't change runtime behavior |
| Reorder function parameters | NO | Breaks all callers — coordinate |
| Change return type | NO | Breaks all consumers — coordinate |
| Merge two functions | Maybe | Only if semantically identical |

## Anti-Patterns (Don't Do This)

- **Refactor AND add features at the same time** — separate commits
- **Refactor without tests** — you'll break things silently
- **Premature abstraction** — wait for 3 instances before extracting
- **Rename everything at once** — do it in stages so reviewers can follow
- **"Clean up" code you don't understand** — understand first, then refactor

## Output

```markdown
## Refactoring Complete

**Smells addressed**: [list]
**Transformations applied**: [count]
**Tests**: [all passing?]
**Files changed**: [count]
**Lines before**: [X] → **Lines after**: [Y]
**Commits**: [one per transformation]
**Breaking changes**: [none / list]
```
