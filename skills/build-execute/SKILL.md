---
name: build-execute
description: "Phase 2: Execution — brainstorm, task breakdown, TDD, and implementation using subagent-driven development"
triggers:
  - "build this"
  - "execute the plan"
  - "start building"
  - "implement this"
---

# Build Execute — Implementation Phase

## When to Invoke

Use after `/build-direction` has approved the work (or when the user wants to skip straight to building). This is the "execute solidly" phase.

## Workflow

### Step 1: Brainstorm Refinement

1. **Read context**: Check for `DIRECTION.md` or `context/DIRECTION.md` — if it exists, use it as input
2. **Generate 3 implementation approaches** (vary by complexity/speed tradeoff):
   - Fastest: minimum viable, cut corners on non-essentials
   - Balanced: solid implementation, pragmatic choices
   - Thorough: production-grade, handles edge cases
3. **Present via AskUserQuestion** with clear tradeoffs
4. User picks one (or mixes)

### Step 2: Task Breakdown

1. **Decompose** the chosen approach into discrete tasks
2. Each task should be:
   - Completable in one focused session
   - Independently testable
   - Small enough for a single commit
3. **Create tasks** using TaskCreate for tracking
4. **Order by dependency** — what blocks what

### Step 3: TDD Loop (per task)

For each task, follow this strict cycle:

```
RED:    Write a failing test that defines the expected behavior
GREEN:  Write minimum code to make the test pass
REFACTOR: Clean up without changing behavior, tests still pass
```

Rules:
- Never write implementation before the test
- One test at a time, not a batch
- Run tests after every change
- If a test is hard to write, the interface design is wrong — redesign first

### Step 4: Implementation

For each task:

1. Mark task as `in_progress`
2. Write the failing test (RED)
3. Implement until green (GREEN)
4. Refactor if needed (REFACTOR)
5. Run full test suite — ensure no regressions
6. Commit with clear message
7. Mark task as `completed`
8. Move to next task

### Step 5: Integration Check

After all tasks complete:

1. Run full test suite
2. Check for type errors
3. Verify the feature works end-to-end (start dev server if applicable)
4. List any remaining edge cases or known limitations

## Subagent Usage

For parallel-safe work, dispatch subagents:
- Independent component implementations
- Test writing for already-designed interfaces
- Documentation generation

Do NOT parallelize:
- Dependent tasks
- Database migrations
- Shared state changes

## Output

When execution is complete:

```markdown
## Execution Complete

**Tasks completed**: X/Y
**Test coverage**: [summary]
**Commits**: [list of commits with messages]
**Ready for verification**: YES / NO
**Known limitations**: [list if any]
```

## Principles

- Tests drive design, not the other way around
- Small commits > big commits
- Working software > comprehensive documentation
- If stuck for more than 3 attempts on one approach, step back and reconsider the design
- Never skip tests to "move faster" — the tests ARE the speed
