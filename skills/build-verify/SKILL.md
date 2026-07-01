---
name: build-verify
description: "Phase 3: Verification — QA testing, bug fixing, security audit, and browser validation"
triggers:
  - "verify this"
  - "qa this"
  - "test the app"
  - "is this ready"
---

# Build Verify — Verification Phase

## When to Invoke

Use after `/build-execute` completes implementation, or anytime you need to validate that something works correctly. This is the "is it actually working?" gate.

## Workflow

### Step 1: Automated QA

1. **Run the full test suite** — capture all failures
2. **Run type checking** (tsc, mypy, etc. depending on project)
3. **Run linter** — fix auto-fixable issues, flag the rest
4. **Check for regressions** — compare against the test baseline

If any failures: fix them, commit, re-run. Loop until green.

### Step 2: Manual QA (if UI exists)

1. **Start the dev server**
2. **Test the golden path** — the primary user flow works end-to-end
3. **Test edge cases**:
   - Empty states
   - Error states
   - Boundary values
   - Rapid interactions (double-click, fast navigation)
4. **Test responsiveness** if applicable (mobile, tablet, desktop)
5. **Document findings** — screenshots or descriptions of any issues

### Step 3: Security Audit (lightweight)

Review for OWASP Top 10 concerns relevant to the changes:

1. **Injection** — are inputs sanitized?
2. **Auth** — are endpoints protected?
3. **Data exposure** — are sensitive fields hidden?
4. **CSRF/XSS** — are tokens and escaping in place?

Only flag issues with confidence 8/10 or higher. No false-positive noise.

### Step 4: Code Review

Act as a staff engineer reviewing the diff:

1. **Read the full diff** (`git diff main...HEAD` or equivalent)
2. **Check for**:
   - Bugs that pass tests but break in production (race conditions, missing error handling at boundaries)
   - Performance issues (N+1 queries, unnecessary re-renders, missing indexes)
   - Completeness gaps (TODO comments left behind, partial implementations)
3. **Auto-fix** obvious issues (typos, missing null checks)
4. **Flag** non-obvious issues to the user with explanation

### Step 5: Fix Loop

For each issue found:

1. Fix the issue
2. Write a regression test for it
3. Commit with descriptive message
4. Re-verify the fix didn't break something else

## Output

```markdown
## Verification Complete

**Test suite**: PASS / FAIL (X tests, Y passing)
**Type check**: PASS / FAIL
**Lint**: PASS / FAIL
**Manual QA**: [findings]
**Security**: [findings or CLEAR]
**Code review**: [findings or CLEAN]
**Issues fixed this phase**: [count]
**Ready to ship**: YES / NO (with blockers)
```

## Principles

- Find bugs, fix them, verify the fix — complete the loop
- Every fix gets a regression test
- Don't ship with known bugs — either fix them or explicitly defer with the user's agreement
- Security findings always block shipping
- "It works on my machine" is not verification
