---
name: learn
description: "Cross-session institutional memory — capture patterns, pitfalls, and preferences with confidence scores"
triggers:
  - "learn this"
  - "remember this pattern"
  - "save this learning"
  - "what have we learned"
  - "show learnings"
---

# Learn — Institutional Memory

## When to Invoke

Use to capture, retrieve, or manage cross-session learnings. These are patterns, pitfalls, and preferences discovered during work that should inform future decisions.

## Commands

### Save a Learning

When you discover something worth remembering:

```markdown
## Learning: [short title]

**Type**: pattern | pitfall | preference | discovery
**Confidence**: [1-5] (1 = hunch, 5 = proven multiple times)
**Context**: [when this applies]
**Detail**: [what was learned]
**Source**: [how we discovered this — specific session/incident]
```

Save to project memory file or `context/LEARNINGS.md`.

### Search Learnings

When the user asks "what do we know about X":

1. Search existing learnings for keyword matches
2. Return relevant findings with confidence scores
3. Flag any learnings that might be outdated (older than 30 days, low confidence)

### Review Learnings

Periodically (or on request), review all learnings:

1. List all learnings sorted by confidence
2. Flag stale ones (old, never reinforced)
3. Ask user: keep, update, or remove each flagged item
4. Merge duplicates

### Prune Learnings

Remove learnings that are:
- Contradicted by new evidence
- So old they're likely stale
- Duplicated by newer, more precise learnings
- Too specific to be useful again

## Learning Types

### Pattern (how things work here)
```
"In this project, API routes follow /api/v1/[resource]/[action] convention"
"The team prefers explicit error handling over try-catch wrapping"
```

### Pitfall (what to avoid)
```
"Don't use ORM eager loading with the users table — it pulls 50+ columns"
"The staging DB is 2 versions behind prod — test migrations against prod schema"
```

### Preference (how the user likes it)
```
"User prefers single bundled PRs for refactors over many small ones"
"User wants verbose commit messages with context, not just 'fix bug'"
```

### Discovery (something surprising found)
```
"The auth service has a 5-second timeout that's not configurable"
"Performance degrades 10x when more than 1000 items are in the sidebar"
```

## Auto-Learn

During normal work, automatically capture learnings when:

- A debugging session reveals a non-obvious root cause
- The user corrects an assumption you made
- A build/deploy fails for a surprising reason
- A pattern emerges across multiple tasks

Save silently — don't interrupt work to announce "I've learned something."

## Integration with Other Skills

- `/investigate` should save pitfalls when root causes are found
- `/build-verify` should save patterns when QA reveals consistent issues
- `/build-ship` retro should surface potential learnings
- `/autoplan` should check learnings before making decisions

## Output

When showing learnings:
```markdown
## Project Learnings ([N] total)

### Patterns ([N])
- [confidence ★★★★★] [learning]
- [confidence ★★★☆☆] [learning]

### Pitfalls ([N])
- [confidence ★★★★☆] [learning]

### Preferences ([N])
- [confidence ★★★★★] [learning]

### Discoveries ([N])
- [confidence ★★☆☆☆] [learning]
```

## Principles

- Learnings compound — a 30-entry knowledge base makes every future session better
- Confidence scores prevent low-quality learnings from influencing decisions
- Prune aggressively — 20 high-confidence learnings > 100 uncertain ones
- Context matters — a learning without "when it applies" is useless
- This is NOT for code patterns (those belong in linter rules) — it's for project-specific institutional knowledge
