---
name: document
description: "Documentation automation — update docs to match code changes, generate missing docs using Diataxis framework"
triggers:
  - "document this"
  - "update the docs"
  - "write documentation"
  - "generate docs"
  - "docs are outdated"
---

# Document — Documentation Automation

## When to Invoke

Use after shipping changes that affect documentation, or when docs are missing/outdated. Follows the Diataxis framework for structured documentation.

## Two Modes

### Mode 1: Document Release (update existing)

After code changes ship:

1. **Identify what changed** — `git diff main...HEAD --name-only`
2. **Map changes to docs** — which documentation files reference the changed code?
3. **Update affected docs** — rewrite sections to match new behavior
4. **Check for orphans** — docs that reference removed features
5. **Verify accuracy** — read the code, then read the doc, ensure they match

### Mode 2: Document Generate (create missing)

For undocumented features:

1. **Scan for doc gaps** — features/APIs with no corresponding documentation
2. **Prioritize by usage** — document the most-used things first
3. **Generate using Diataxis** — categorize each doc by type (see below)
4. **Review for accuracy** — never document what you haven't verified in code

## The Diataxis Framework

All documentation falls into 4 categories:

| Type | Purpose | Format |
|------|---------|--------|
| **Tutorial** | Learning-oriented | Step-by-step lesson, hand-holding, specific outcome |
| **How-to Guide** | Task-oriented | Steps to solve a specific problem, assumes knowledge |
| **Reference** | Information-oriented | Dry, accurate, complete — API docs, config options |
| **Explanation** | Understanding-oriented | Why things work this way, background, context |

### When to write which:

- "I'm new and want to learn" → **Tutorial**
- "I know what I want to do but not how" → **How-to Guide**
- "I need the exact API/config/options" → **Reference**
- "I want to understand why" → **Explanation**

## Coverage Map

After documenting, produce a coverage assessment:

```markdown
## Documentation Coverage

| Feature | Tutorial | How-to | Reference | Explanation |
|---------|----------|--------|-----------|-------------|
| Auth | yes | yes | yes | no |
| API | no | yes | yes | no |
| Deploy | no | no | partial | no |
```

## Writing Rules

1. **Active voice** — "Run the command" not "The command should be run"
2. **Present tense** — "This returns" not "This will return"
3. **Specific** — "Set `timeout` to 30" not "Configure the timeout appropriately"
4. **Tested** — every code example must actually work (run it to verify)
5. **Short** — one concept per section, no walls of text
6. **No filler** — cut "In order to", "It should be noted that", "Basically"

## Output

```markdown
## Documentation Updated

**Files modified**: [list]
**Files created**: [list]
**Coverage before**: [X]%
**Coverage after**: [X]%
**Diataxis breakdown**: [N] tutorials, [N] how-tos, [N] references, [N] explanations
```

## Principles

- Docs are code — they have bugs, they go stale, they need maintenance
- If the doc doesn't match the code, the doc is wrong (update it)
- Good docs are short — if you need 3 paragraphs to explain a config option, the API design might be the problem
- Code examples must be copy-pasteable and runnable
- Never document internal implementation details that users don't need
