---
name: build-ship
description: "Phase 4: Ship and reflect — create PR, push, and run retrospective"
triggers:
  - "ship this"
  - "create pr"
  - "push and ship"
  - "we're done"
---

# Build Ship — Delivery Phase

## When to Invoke

Use after `/build-verify` confirms the work is ready, or when the user says to ship. This is the "get it out the door and learn from it" phase.

## Workflow

### Step 1: Pre-Ship Checklist

Before shipping, verify:

- [ ] All tests passing
- [ ] No uncommitted changes (or commit them now)
- [ ] Branch is up to date with main (rebase if needed)
- [ ] No merge conflicts
- [ ] Commit history is clean and readable

If any item fails, fix it before proceeding.

### Step 2: Ship

1. **Push the branch** to remote (with `-u` for tracking)
2. **Create a Pull Request** using `gh pr create`:
   - Title: concise, under 70 chars
   - Body: Summary bullets + test plan
   - Reference any related issues
3. **Report the PR URL** to the user

### Step 3: Retrospective

After shipping, reflect on the build cycle:

1. **What went well?** — things to repeat
2. **What was harder than expected?** — hidden complexity discovered
3. **What would you do differently?** — process improvements
4. **Time breakdown estimate**:
   - Direction: X%
   - Execution: X%
   - Verification: X%
   - Shipping: X%

Present this as a brief summary (not a long document).

### Step 4: Capture Learnings

If anything surprising was discovered during the build:

1. Save project-relevant learnings to memory
2. Update any project documentation if the architecture changed
3. Note any technical debt introduced (with justification)

## Output

```markdown
## Shipped

**PR**: [URL]
**Branch**: [name]
**Commits**: [count]
**Retro highlights**: [1-2 key learnings]
```

## Principles

- Ship small, ship often
- PRs should be reviewable in one sitting
- The retro is not optional — learning compounds
- Don't merge your own PR without the user's explicit approval
- If CI fails after push, investigate and fix before reporting success
