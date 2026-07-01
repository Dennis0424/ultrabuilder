---
name: test-gen
description: "AI-driven test generation — unit, integration, e2e tests from code analysis. Coverage-aware, edge-case focused."
triggers:
  - "generate tests"
  - "write tests"
  - "add test coverage"
  - "test this"
  - "missing tests"
---

# Test Generation — Comprehensive Coverage

## When to Invoke

Use when code exists but tests are missing, when coverage needs to increase, or when you want tests generated from code analysis rather than writing them manually.

## Workflow

### Step 1: Detect Test Setup

Scan the project for:
- Test runner: Vitest, Jest, Pytest, Go test, etc.
- Test location: `__tests__/`, `*.test.ts`, `*.spec.ts`, `tests/`
- Test utilities: Testing Library, MSW, Supertest, fixtures
- Coverage tool: c8, istanbul, coverage.py

If no test setup exists, set one up first (suggest appropriate runner).

### Step 2: Analyze Code Under Test

For each function/component/module:

1. **Inputs**: What parameters does it take? What types? What ranges?
2. **Outputs**: What does it return? What side effects does it have?
3. **Branches**: What conditions exist? What paths?
4. **Dependencies**: What does it call? (These need mocking or test doubles)
5. **Edge cases**: What are the boundary values? What can be null/empty/huge?

### Step 3: Generate Tests by Category

#### Unit Tests (isolated logic)

```typescript
describe("calculateTotal", () => {
  // Happy path
  it("calculates total with items and tax", () => {
    const result = calculateTotal([{ price: 10, qty: 2 }, { price: 5, qty: 1 }], 0.1)
    expect(result).toBe(27.5) // (20 + 5) * 1.1
  })

  // Edge cases
  it("returns 0 for empty cart", () => {
    expect(calculateTotal([], 0.1)).toBe(0)
  })

  it("handles zero tax rate", () => {
    expect(calculateTotal([{ price: 10, qty: 1 }], 0)).toBe(10)
  })

  // Boundary values
  it("handles very large quantities", () => {
    expect(calculateTotal([{ price: 1, qty: Number.MAX_SAFE_INTEGER }], 0)).toBe(Number.MAX_SAFE_INTEGER)
  })

  // Error cases
  it("throws for negative prices", () => {
    expect(() => calculateTotal([{ price: -5, qty: 1 }], 0.1)).toThrow()
  })
})
```

#### Integration Tests (component + dependencies)

```typescript
describe("UserProfile page", () => {
  it("loads and displays user data", async () => {
    // Mock API
    server.use(
      http.get("/api/users/1", () => HttpResponse.json({ name: "Alice", email: "alice@test.com" }))
    )

    render(<UserProfile userId="1" />)

    // Loading state
    expect(screen.getByRole("progressbar")).toBeInTheDocument()

    // Loaded state
    await waitFor(() => {
      expect(screen.getByText("Alice")).toBeInTheDocument()
      expect(screen.getByText("alice@test.com")).toBeInTheDocument()
    })
  })

  it("shows error state on API failure", async () => {
    server.use(
      http.get("/api/users/1", () => HttpResponse.error())
    )

    render(<UserProfile userId="1" />)

    await waitFor(() => {
      expect(screen.getByText(/failed to load/i)).toBeInTheDocument()
    })
  })
})
```

#### E2E Tests (full user flows)

```typescript
test("user can sign up, create a post, and publish it", async ({ page }) => {
  await page.goto("/signup")
  await page.fill('[name="email"]', "test@example.com")
  await page.fill('[name="password"]', "SecurePass123!")
  await page.click('button[type="submit"]')

  await expect(page).toHaveURL("/dashboard")

  await page.click("text=New Post")
  await page.fill('[name="title"]', "My First Post")
  await page.fill('[role="textbox"]', "Hello world content")
  await page.click("text=Publish")

  await expect(page.getByText("Published")).toBeVisible()
})
```

### Step 4: Coverage Analysis

After generating tests, check what's still uncovered:

```bash
npx vitest --coverage
# Look at uncovered lines/branches
```

Prioritize covering:
1. Business-critical paths (payments, auth, data mutations)
2. Complex conditional logic
3. Error handling branches
4. Edge cases that have caused bugs before

### Step 5: Test Quality Check

Generated tests must:
- [ ] Actually test behavior (not just call the function)
- [ ] Have clear, descriptive names
- [ ] Be independent (no test depends on another test's state)
- [ ] Run fast (mock external dependencies)
- [ ] Not test implementation details (test WHAT, not HOW)
- [ ] Cover the important edge cases (empty, null, max, duplicate)

## Test Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Testing implementation | Breaks on refactor | Test behavior/output only |
| One giant test | Hard to debug failures | One assertion per test |
| Testing framework code | Wasted effort | Trust the framework |
| Snapshot everything | Brittle, no one reads diffs | Snapshot only stable output |
| No assertions | Test always passes | Assert specific expectations |
| Flaky tests | Undermine trust | Fix or delete immediately |

## Output

```markdown
## Tests Generated

**Framework**: [Vitest / Jest / Pytest / etc.]
**Tests written**: [count]
- Unit: [count]
- Integration: [count]
- E2E: [count]

**Coverage before**: [X]%
**Coverage after**: [X]%
**Edge cases covered**: [list key ones]
**All passing**: YES / NO
```
