---
name: build-direction
description: "Phase 1: Strategic review — CEO, engineering, and design review to validate direction before building"
triggers:
  - "review this plan"
  - "is this worth building"
  - "check the direction"
  - "strategic review"
---

# Build Direction — Strategic Review Phase

## When to Invoke

Use this skill when you have a feature idea, requirement, or plan and need validation before committing to implementation. This is the "should we build this?" and "is the architecture sound?" gate.

## Workflow

Run these three reviews in sequence. Each produces structured output that feeds the next.

### Step 1: CEO Review (Is this worth building?)

Act as a CEO/founder evaluating the product decision:

1. **Read the requirement** — from the user's message, a spec file, or issue
2. **Ask 4 forcing questions** (via AskUserQuestion, one at a time):
   - What's the user's actual pain? (not what they asked for — the underlying need)
   - What does the 10-star version look like? (ideal outcome, no constraints)
   - What's the simplest version that delivers 80% of the value?
   - What's the cost of NOT building this?
3. **Produce a verdict**: BUILD / REDUCE SCOPE / DEFER / KILL
4. If BUILD or REDUCE SCOPE, write a one-paragraph product brief

### Step 2: Engineering Review (Is the architecture sound?)

Act as a senior engineering manager:

1. **Evaluate the brief** from Step 1
2. **Identify**:
   - Data model changes required
   - API surface changes
   - Dependencies and integrations
   - Performance implications
   - Migration complexity
3. **Flag hidden assumptions** — things that seem obvious but aren't
4. **Ask the user** about any ambiguous technical decisions (max 3 questions)
5. **Produce**: Architecture decision summary with diagrams (mermaid if helpful)

### Step 3: Design Review (Does the design pass?)

Act as a senior product designer:

1. **Rate these dimensions 0-10**:
   - Clarity: Can users understand what to do without instructions?
   - Speed: Can they complete the task in minimum steps?
   - Delight: Is there anything that makes this feel good?
   - Consistency: Does it match existing patterns in the app?
2. For any dimension below 7, explain what a 10 looks like
3. **Ask the user** one design choice via AskUserQuestion
4. **Produce**: Design notes with specific recommendations

## Output

After all 3 reviews, produce a structured summary:

```markdown
## Direction Review Complete

**Verdict**: [BUILD / REDUCE SCOPE / DEFER]
**Product Brief**: [1 paragraph]
**Architecture**: [key decisions]
**Design Notes**: [recommendations]
**Ready for execution**: YES / NO (with blockers)
```

Save this to a file called `DIRECTION.md` in the project root (or `context/DIRECTION.md` if context/ exists) so the execution phase can reference it.

## Principles

- Be ruthlessly honest — kill ideas early if they don't pass muster
- One AskUserQuestion at a time, never batch 4 questions into one prompt
- The user makes all final decisions; you provide analysis
- If the user says "skip" on any step, move to the next
