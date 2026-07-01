---
name: dx-review
description: "Developer experience audit — TTHW benchmarks, persona tracing, friction mapping for APIs/SDKs/CLIs"
triggers:
  - "dx review"
  - "developer experience"
  - "is this easy to use"
  - "onboarding review"
  - "tthw"
---

# DX Review — Developer Experience Audit

## When to Invoke

Use when building anything developers consume: APIs, SDKs, CLIs, libraries, documentation, or developer tools. Also useful for internal tools and platform teams.

## Three Modes

Ask the user which mode:

- **DX Expansion** — full audit with 20+ questions, discovers unknown friction
- **DX Polish** — focused pass on known rough edges, 10 questions
- **DX Triage** — quick scan, rank top 3 friction points, action plan

## TTHW Benchmark (Time To Hello World)

For any developer-facing surface, measure:

1. **Time from zero to first success** — how many steps from `npm install` (or equivalent) to seeing it work?
2. **Concepts required** — how many things must a developer understand before they can start?
3. **Failure modes** — what happens when they get something wrong? Are errors helpful?
4. **Copy-paste-ability** — can they copy an example and have it work?

Target: under 5 minutes to first success for any SDK/API/CLI.

## Persona Tracing

Evaluate from 3 developer perspectives:

### 1. The Beginner (day 1 with your tool)
- Can they find where to start?
- Is the happy path obvious?
- Are error messages actionable?
- Do examples work as-is?

### 2. The Builder (using it daily for a week)
- Are common patterns ergonomic?
- Is there good IDE support (types, autocomplete)?
- Are the docs searchable and cross-referenced?
- Can they debug issues without reading source?

### 3. The Expert (pushing the boundaries)
- Can they extend/customize without forking?
- Are internals documented for power users?
- Is performance predictable?
- Can they contribute back easily?

## Friction Mapping

For each interaction point, rate:

| Dimension | 1 (terrible) | 5 (fine) | 10 (delightful) |
|-----------|--------------|----------|------------------|
| Discovery | Can't find it | Google works | Obvious from context |
| Setup | 30+ min | 5 min | Zero config |
| First use | Confusing | Followable | Intuitive |
| Error recovery | Cryptic | Readable | Self-healing |
| Iteration speed | Rebuild everything | Hot reload | Instant |

## Output

```markdown
## DX Review Complete

**TTHW**: [time estimate, step count]
**Top 3 Friction Points**:
1. [highest impact friction]
2. [second]
3. [third]

**Per Persona**:
- Beginner: [score /10, key issue]
- Builder: [score /10, key issue]  
- Expert: [score /10, key issue]

**Quick Wins** (fix in < 1 hour):
- [list]

**Structural Issues** (need design work):
- [list]
```

## Principles

- Developers are users too — apply UX thinking
- The best DX is no DX (zero configuration, obvious defaults)
- Error messages are UI — they should tell you what to do, not what went wrong
- If it needs documentation to understand, the API design might be wrong
- Test with real humans when possible, not just analysis
