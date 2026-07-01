---
name: autoplan
description: "Automated planning pipeline — runs CEO/Design/Eng review with 6 decision principles, surfaces only taste decisions"
triggers:
  - "autoplan"
  - "plan this automatically"
  - "quick plan"
  - "auto review"
---

# Autoplan — Automated Review Pipeline

## When to Invoke

Use when you want the full strategic review (CEO → Design → Eng) but don't want to answer 15-30 questions manually. Autoplan resolves routine decisions automatically and only surfaces genuine "taste calls" that need human judgment.

## The 6 Decision Principles

When facing a planning decision, auto-resolve using these rules (in priority order):

1. **Prefer completeness** — when choosing between partial and full implementation, choose full unless cost is > 3x
2. **Match existing patterns** — if the codebase already does something a certain way, continue that way
3. **Choose reversible options** — prefer decisions that can be undone easily over permanent commitments
4. **Match user's past decisions** — if the user has chosen similarly before (check memory/history), follow that precedent
5. **Defer ambiguous items** — if a decision could go either way with good arguments, mark it for human review
6. **Escalate security** — any decision with security implications always goes to the user

## Workflow

### Phase 1: CEO Review (auto-resolved)

1. Read the requirement/feature/idea
2. Auto-assess:
   - Is there clear user pain? → if unclear, **surface to user**
   - Is the scope reasonable for the team/timeline? → auto-resolve with principle 1 or 3
   - Does this conflict with existing direction? → check existing plans/memory, auto-resolve with principle 2
3. Output: BUILD/REDUCE/DEFER with rationale

### Phase 2: Design Review (auto-resolved)

1. Rate the 7 design dimensions mentally
2. For scores 8+: auto-pass
3. For scores 5-7: auto-resolve using principle 2 (match existing patterns)
4. For scores < 5: **surface to user** — "This design choice needs your input: [specific question]"

### Phase 3: Eng Review (auto-resolved)

1. Identify architecture decisions
2. For each decision:
   - Does an existing pattern apply? → auto-resolve (principle 2)
   - Is one option clearly more reversible? → auto-resolve (principle 3)
   - Security implication? → **surface to user** (principle 6)
   - Genuinely ambiguous? → **surface to user** (principle 5)

### Phase 4: Human Gate

Present only the unresolved decisions:

```markdown
## Autoplan needs your input on [N] decisions:

### Decision 1: [title]
**Context**: [why this matters]
**Options**: 
- A: [option and tradeoff]
- B: [option and tradeoff]
**My lean**: [which one and why]

### Decision 2: ...
```

Use AskUserQuestion for each decision. Max 5 decisions surfaced — if more than 5 can't be auto-resolved, the requirement is too vague and needs `/office-hours` first.

### Phase 5: Finalize Plan

After human input, produce the complete plan:

```markdown
## Autoplan Complete

**Verdict**: BUILD
**Auto-resolved**: [N] decisions (using principles [list which])
**Human-resolved**: [N] decisions
**Architecture**: [key choices]
**Scope**: [in/out]
**Ready for**: /build-execute or /spec
```

## When NOT to Use Autoplan

- Brand new product with no existing patterns (use `/office-hours` + `/build-direction` instead)
- Highly controversial decisions (use full manual review)
- When the user explicitly wants to think through every decision

## Output

Save to `PLAN.md` in project root (or `context/PLAN.md`).

## Principles

- Automation saves time ONLY when decisions are routine — don't auto-resolve genuinely hard choices
- Transparency: always show which principles were used for each auto-resolution
- The user can override any auto-resolved decision by asking
- If more than 5 decisions can't be resolved, the input is too vague — push back
