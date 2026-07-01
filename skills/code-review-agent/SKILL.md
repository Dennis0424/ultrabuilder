---
name: code-review-agent
description: "Adversarial code review — finds bugs that pass CI, catches production-only failures, auto-fixes obvious issues"
triggers:
  - "review my code"
  - "code review"
  - "find bugs"
  - "review the diff"
  - "is this safe to ship"
---

# Code Review Agent — Adversarial Quality Gate

## When to Invoke

Use after implementation is complete, before shipping. Acts as a staff engineer reviewer who actively tries to find problems — not just style issues, but bugs that would reach production.

## Mindset

**Adversarial, not pedantic.** Look for:
- Bugs that PASS tests but BREAK in production
- Race conditions and timing issues
- Edge cases the developer didn't consider
- Security holes
- Performance traps that emerge at scale

**Don't waste time on:**
- Style preferences (linter handles this)
- Minor naming opinions
- Theoretical concerns unlikely to matter

## Review Process

### Step 1: Understand the Change

1. Read the full diff: `git diff main...HEAD`
2. Understand the goal — what is this change trying to accomplish?
3. Map the change to the system — what does this touch?

### Step 2: Hunt for Bugs (Priority Order)

#### A. Logic Errors
- Off-by-one errors in loops and slices
- Wrong boolean conditions (AND vs OR, inverted checks)
- Null/undefined not handled where data can be missing
- Type coercion surprises (`"0" == false`, etc.)

#### B. Race Conditions
- Concurrent access to shared state without locks
- Async operations that assume ordering
- UI state that can desync with server state
- Multiple rapid clicks triggering multiple actions

#### C. Error Handling Gaps
- What happens when the network fails?
- What happens with empty/null/undefined inputs?
- What happens when the database is slow?
- What happens at extreme values (0, MAX_INT, empty array)?

#### D. Security
- User input used unsanitized (XSS, injection)
- Authorization checks missing (IDOR)
- Secrets in code or logs
- Permissions too broad

#### E. Performance at Scale
- N+1 queries (loop with DB call inside)
- Missing indexes for new queries
- Unbounded data fetching (no pagination)
- Memory leaks (event listeners not cleaned up)
- Expensive computations on every render

### Step 3: Classify Findings

| Severity | Definition | Action |
|----------|-----------|--------|
| **Blocker** | Will break in production | Must fix before ship |
| **Major** | Likely to cause issues under real usage | Should fix before ship |
| **Minor** | Improvement but not dangerous | Can fix in follow-up |
| **Nit** | Style/preference | Ignore (not worth the review time) |

### Step 4: Auto-Fix Obvious Issues

For clear bugs with obvious fixes:
1. Fix the issue
2. Add a test that catches it
3. Commit with descriptive message

For ambiguous issues:
- Report to the user with context
- Explain what could go wrong
- Suggest a fix but let the user decide

### Step 5: Completeness Check

- [ ] Are there missing test cases for the new code?
- [ ] Are there TODO comments left behind?
- [ ] Are there partial implementations (started but not finished)?
- [ ] Are there new dependencies that weren't verified?
- [ ] Does the error handling cover all failure modes?
- [ ] Are database migrations reversible?

## Review Checklist by Change Type

### New API Endpoint
- [ ] Input validation
- [ ] Authentication + authorization
- [ ] Rate limiting
- [ ] Error responses (not leaking internals)
- [ ] Idempotency for mutations
- [ ] Request size limits

### Database Change
- [ ] Migration is reversible
- [ ] Indexes for new queries
- [ ] No N+1 queries introduced
- [ ] Backfill strategy for new non-null columns
- [ ] Transaction boundaries correct

### Frontend Component
- [ ] Loading, empty, and error states
- [ ] Keyboard accessibility
- [ ] Mobile responsive
- [ ] Memory leaks (useEffect cleanup)
- [ ] Re-render performance (unnecessary renders)

### Auth/Permissions Change
- [ ] Cannot escalate privileges
- [ ] Cannot access other users' data
- [ ] Tokens validated on every request
- [ ] Session invalidation works

## Output

```markdown
## Code Review

**Scope**: [files/lines reviewed]
**Findings**:
- **Blockers** ([count]): [list]
- **Major** ([count]): [list]  
- **Minor** ([count]): [list]

**Auto-fixed**: [count] issues
**Needs discussion**: [count] issues
**Verdict**: SHIP / FIX THEN SHIP / NEEDS REWORK
```
