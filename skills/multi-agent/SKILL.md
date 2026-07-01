---
name: multi-agent
description: "Multi-agent orchestration — parallel subagents for research, implementation, review, and testing"
triggers:
  - "multi agent"
  - "parallel agents"
  - "fan out"
  - "subagents"
  - "orchestrate agents"
---

# Multi-Agent — Parallel Orchestration

## When to Invoke

Use when a task has independent parts that can run in parallel, when you need multiple perspectives on the same problem, or when the work is too large for one context window.

## Patterns

### 1. Fan-Out/Fan-In (research)

```
            ┌── Agent A: Search codebase for pattern X
Dispatcher ─┼── Agent B: Search docs for approach Y
            └── Agent C: Check dependencies for conflicts
                    │
                    ▼
              Synthesize findings into recommendation
```

**Use when:** You need information from multiple sources before making a decision.

**Implementation:**
- Spawn 2-4 agents in parallel via the Agent tool
- Each agent has a focused question
- Collect results, synthesize, present to user

### 2. Implement + Review (quality gate)

```
Agent A: Implement the feature
            │
            ▼
Agent B: Review the implementation (adversarial — try to find bugs)
            │
            ▼
Agent A: Fix issues found
```

**Use when:** High-stakes code that needs a second set of eyes.

### 3. Parallel Implementation (independent components)

```
            ┌── Agent A: Build Component X (worktree isolation)
Dispatcher ─┼── Agent B: Build Component Y (worktree isolation)
            └── Agent C: Build Component Z (worktree isolation)
                    │
                    ▼
              Integration: Merge components, verify they work together
```

**Use when:** Multiple independent components can be built simultaneously.

**Rules:**
- Components MUST be independent (no shared mutable state)
- Use worktree isolation if agents modify files
- Integration step is always needed after parallel implementation

### 4. Multi-Perspective Review

```
            ┌── Agent A: Review for bugs (correctness lens)
Code ───────┼── Agent B: Review for security (security lens)
            └── Agent C: Review for performance (performance lens)
                    │
                    ▼
              Merge findings, deduplicate, prioritize
```

**Use when:** You want thorough review coverage across different dimensions.

### 5. Generate + Judge (best-of-N)

```
            ┌── Agent A: Approach 1 (fast, simple)
Problem ────┼── Agent B: Approach 2 (balanced)
            └── Agent C: Approach 3 (thorough)
                    │
                    ▼
Judge Agent: Score each approach, recommend the best
```

**Use when:** The solution space is wide and you're unsure which approach is best.

### 6. Test Generation (parallel coverage)

```
            ┌── Agent A: Happy path tests
Feature ────┼── Agent B: Edge case tests
            └── Agent C: Error/failure tests
                    │
                    ▼
              Merge test suites, remove duplicates, run all
```

**Use when:** You want comprehensive test coverage generated quickly.

## Orchestration Rules

1. **Independent work only** — never parallelize dependent tasks
2. **Clear scope per agent** — each agent gets a focused brief, not "do everything"
3. **Synthesis step** — always have a step that combines parallel results
4. **Deduplication** — parallel agents often find overlapping things; merge before acting
5. **Budget awareness** — each agent costs tokens; don't fan out for trivial work
6. **Worktree isolation** — if agents write to the same files, they MUST use isolated worktrees

## When NOT to Multi-Agent

- Task is small (< 5 minutes of work)
- Tasks are sequential (B depends on A's output)
- The overhead of coordination > time saved
- The user wants to be involved at each step (use `/pair-program` instead)

## Agent Prompting Best Practices

```markdown
Good agent prompt:
"Search the codebase for all places where we make HTTP requests.
For each one, report: file path, line number, the URL pattern, and whether it has error handling.
Return as a JSON array."

Bad agent prompt:
"Look at the code and find anything interesting about how we do networking."
```

- Specific task, not vague exploration
- Define the output format
- One clear deliverable per agent
- Include enough context for the agent to work independently

## Output

```markdown
## Multi-Agent Orchestration

**Pattern**: [fan-out / implement+review / parallel / multi-perspective / generate+judge]
**Agents spawned**: [count]
**Results**:
- Agent A: [summary]
- Agent B: [summary]
- Agent C: [summary]
**Synthesis**: [combined finding/recommendation]
**Action taken**: [what was decided/implemented based on results]
```
