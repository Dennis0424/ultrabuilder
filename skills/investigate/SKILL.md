---
name: investigate
description: "Systematic root-cause debugging — no fixes without investigation, stops after 3 failed attempts"
triggers:
  - "investigate this"
  - "debug this"
  - "why is this broken"
  - "find the root cause"
  - "this doesn't work"
---

# Investigate — Systematic Debugging

## When to Invoke

Use when something is broken and you don't know why. This is NOT for known bugs with obvious fixes — it's for mysteries that need investigation.

## The Iron Law

**No fixes without investigation.** 

Do not:
- Guess at solutions
- Try random changes
- "Just try restarting"
- Apply Stack Overflow answers without understanding

Do:
- Observe the actual behavior
- Form a hypothesis
- Test the hypothesis
- Only then fix (if hypothesis confirmed)

## Workflow

### Step 1: Observe

1. **Reproduce the bug** — get it to fail consistently
2. **Capture the exact error** — message, stack trace, logs
3. **Identify what changed** — git log, recent deploys, config changes
4. **Narrow the scope** — which component, which layer, which input

### Step 2: Hypothesize

Form 2-3 hypotheses about the root cause. For each:

```markdown
**Hypothesis**: [what you think is wrong]
**Evidence for**: [what supports this]
**Evidence against**: [what contradicts this]
**Test**: [how to confirm/deny without changing code]
```

### Step 3: Test (non-destructively)

For each hypothesis, test WITHOUT making changes:
- Add logging/print statements
- Read the code path carefully
- Check state at each step
- Use debugger breakpoints if available
- Query the database/API directly

### Step 4: Trace Data Flow

Follow the data through the system:

```
Input → [where does it enter?]
  → [what transforms it?]
  → [where does it diverge from expected?]
  → [what's the actual vs expected state at that point?]
```

The bug lives at the divergence point.

### Step 5: Fix (only after root cause confirmed)

1. **State the root cause** explicitly before writing any fix
2. **Write a test that reproduces the bug** (this test should fail)
3. **Apply the minimal fix** — change as little as possible
4. **Verify the test passes**
5. **Check for other instances** — is this pattern repeated elsewhere?

## The 3-Attempt Rule

If you've tried 3 fixes and none work:

**STOP.**

You are likely:
- Fixing a symptom, not the cause
- Working from a wrong mental model
- Missing context about how the system actually works

At this point:
1. State what you've tried and why it failed
2. Question your assumptions about how the code works
3. Read the actual implementation (don't trust your mental model)
4. Ask the user for context you might be missing

## Output

```markdown
## Investigation Complete

**Symptom**: [what was observed]
**Root Cause**: [what was actually wrong]
**Evidence**: [how we confirmed]
**Fix Applied**: [what changed]
**Regression Test**: [test that catches this]
**Related Risk**: [other places this could happen]
```

## Principles

- Understanding > fixing. A fix without understanding will break again.
- The bug is never where you first look
- Logs lie (they show what code DOES, not what it SHOULD do)
- The most recent change is usually the cause, but not always
- "Works on my machine" means the environment IS the bug
- If you can't reproduce it, you can't fix it
