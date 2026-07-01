---
name: spec
description: "Turn vague intent into precise executable specification with quality gate and deduplication"
triggers:
  - "write a spec"
  - "spec this out"
  - "what exactly should this do"
  - "make this precise"
---

# Spec — Precise Specification Authoring

## When to Invoke

Use when you have a vague idea, feature request, or user story that needs to become precise enough to implement without ambiguity. Bridges the gap between "roughly what we want" and "exactly what to build."

## Five Phases

### Phase 1: Capture Intent

1. Read the user's input (message, issue, brief, or DIRECTION.md)
2. Identify: What's stated vs. what's implied vs. what's missing
3. Ask up to 5 clarifying questions (one at a time) about gaps

### Phase 2: Define Boundaries

Produce explicit scope:

```markdown
## IN SCOPE
- [things this spec covers]

## OUT OF SCOPE  
- [things explicitly excluded]

## ASSUMPTIONS
- [things we're taking as given]
```

### Phase 3: Specify Behavior

For each feature/behavior, define:

- **Given** [precondition]
- **When** [action/trigger]
- **Then** [expected outcome]
- **Edge cases**: [list unusual inputs/states]
- **Error cases**: [what happens when things go wrong]

Use Given/When/Then format for testable behaviors. Each behavior should be independently verifiable.

### Phase 4: Quality Gate

Rate the spec on:

| Dimension | Score |
|-----------|-------|
| Completeness — are all behaviors specified? | /10 |
| Testability — can each statement be verified? | /10 |
| Clarity — could a different developer implement this identically? | /10 |
| Feasibility — is this buildable with current constraints? | /10 |

**Block if any dimension < 7/10.** Identify what's missing and loop back to fill gaps.

### Phase 5: Deduplicate

Check if this overlaps with existing work:
1. Search for related files, tests, or issues in the project
2. Flag any overlap with "This partially exists in [file/location]"
3. Clarify: are we replacing, extending, or duplicating?

## Output

Write the spec to `SPEC.md` in the project root (or the path the user specifies):

```markdown
# Spec: [Feature Name]

## Summary
[1-2 sentences]

## Scope
[IN/OUT/ASSUMPTIONS from Phase 2]

## Behaviors
[Given/When/Then blocks from Phase 3]

## Quality Scores
[Table from Phase 4]

## Overlap
[Dedup findings from Phase 5]

## Ready to execute: YES / NO
```

## Execute Mode

If the user says "spec and execute" or "spec --execute":
1. Complete the spec as above
2. If quality gate passes, immediately invoke `/build-execute` with the spec as input
3. The spec becomes the source of truth for task breakdown

## Principles

- Precision over prose — every sentence should be testable
- If you can't specify it, you can't build it
- Ambiguity is a bug in the spec, not a feature for flexibility
- The spec is a contract — changes after this point are scope changes
- Redact secrets/credentials if they appear in the input — never include them in the spec file
