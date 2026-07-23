---
name: ultrabuilder
description: "Full-cycle delivery — from vague idea to shipped product. Grill → Decide → Build → Verify → Ship. Each phase gates the next."
triggers:
  - "ultrabuilder"
  - "full cycle"
  - "end to end"
  - "build everything"
  - "advanced build"
---

# UltraBuilder

Five composable phases. Each works standalone. Each gates the next via completion criteria. Skip what doesn't apply — but never skip the gate check.

```
GRILL  ──→  DECIDE  ──→  BUILD  ──→  VERIFY  ──→  SHIP
 ↑            ↑            ↑           ↑           ↑
 fog          frontier     red/green   parallel    canary
 of war       tickets      tight loop  review axes monitoring
```

---

## Phase 0: GRILL

**Leading word:** *scrutiny*

The single highest-leverage thing you can do is challenge the idea before investing. Most wasted work happens because nobody asked "why?" hard enough.

**The Grilling Primitive** (use this verbatim):

> Interview me relentlessly about every aspect of this until we reach a shared understanding. Walk down each branch of the decision tree, resolving dependencies one-by-one. For each question, provide your recommended answer. Ask questions one at a time. If a fact can be found by exploring the environment, look it up rather than asking me. The decisions, though, are mine.

Run this until you can state the goal in one sentence without hedging.

**Completion criteria (all must be true):**
- [ ] Goal stated in one sentence
- [ ] Who benefits and how — named specifically
- [ ] What this is NOT (explicit anti-scope)
- [ ] Kill condition identified ("we'd stop if...")
- [ ] Surviving premises: none of the original assumptions collapsed

If the idea dies here → good. Save the learning. Time saved: days to weeks.

**Gate:** "The goal is [X]. The anti-scope is [Y]. Still worth building?"

---

## Phase 1: DECIDE

**Leading word:** *frontier*

Plan only what you can state precisely. Everything else is fog — it graduates into tickets as preceding decisions resolve. Resist the pull to "just start building." That impulse = you've reached the edge of what you understand.

### 1.1 Map the fog

List what you know vs. what's still unclear:
- **Known:** decisions already made (from Phase 0)
- **Frontier:** questions you can answer right now
- **Fog:** things you sense are coming but can't yet specify

Only frontier items become tickets. Fog stays as fog until its dependencies resolve.

### 1.2 Decide architecture

Pick ONE path based on complexity:

| Signal | Path |
|--------|------|
| Simple feature, familiar territory | Brainstorm 3 approaches → pick → go |
| Complex feature, unknowns | `/spec` → quality gate (all dimensions ≥ 7/10) |
| Novel system, high stakes | `/build-direction` (CEO + Eng + Design review) |
| Developer-facing (API/CLI/SDK) | Add `/dx-review` (TTHW benchmark) |

### 1.3 Design It Twice (if architecture unclear)

Spawn 3 parallel explorations with different constraints:
1. Minimize interface (fewest entry points)
2. Maximize flexibility (most extensible)
3. Optimize for the most common caller

Compare on: depth, locality, seam placement. Pick the winner. Graft best ideas from runners-up.

**Completion criteria:**
- [ ] Architecture documented (one paragraph or diagram, not a novel)
- [ ] All frontier questions resolved — new fog may have graduated
- [ ] No decision depends on another unresolved decision
- [ ] Spec/direction committed (if produced)

**Gate:** "Decisions locked. Ready to build?"

---

## Phase 2: BUILD

**Leading word:** *tight loop*

The tighter your feedback loop, the faster you converge. Every task must have a pass/fail signal you can run before moving on.

### 2.1 Decompose

Use `superpowers:writing-plans` to produce an ordered task list. Each task:
- Has one clear deliverable
- Ends with a runnable verification (test, typecheck, visual confirm)
- Can be reviewed independently

Skip this for single-file changes. Go straight to red/green.

### 2.2 Execute

Use `superpowers:subagent-driven-development` for multi-task plans. Each task follows:

```
RED → GREEN → REFACTOR → COMMIT
```

Rules:
- Fresh subagent per task (no context pollution between tasks)
- Review after each task (spec compliance + code quality, two verdicts)
- If blocked for >3 attempts → stop. The plan is wrong, not the execution.
- Commit after each green. Never batch commits.

### 2.3 Design (if UI)

| Project Type | Primary Skill |
|-------------|---------------|
| Marketing / landing | `/design-taste-frontend` |
| Product UI / dashboard | `/impeccable` + `/shadcn` |
| Mobile | `/imagegen-frontend-mobile` |
| Redesign | `/redesign-existing-projects` |
| Mockup → code | `/design-html` or `/image-to-code` |

### 2.4 Debug (if stuck)

Run `/investigate`. Iron law: no fixes without root cause. If you catch yourself hypothesizing without a failing test — STOP. Construct the feedback loop first.

**Completion criteria:**
- [ ] All tasks green (tests pass)
- [ ] Feature works end-to-end (not just unit tests — drive the real flow)
- [ ] No TODO/FIXME left in new code
- [ ] Committed and clean working tree

**Gate:** "Implementation complete. Ready for verification?"

---

## Phase 3: VERIFY

**Leading word:** *parallel axes*

Review on multiple dimensions simultaneously. A single-axis review has blind spots. Run independent checks that can't contaminate each other.

### 3.1 Parallel review (run concurrently)

**Axis 1 — Standards:** Does the code meet engineering standards?
- Type safety (mypy/tsc must pass)
- Lint clean (auto-fix what's fixable)
- Test coverage on new code
- No dead code, no unused imports

**Axis 2 — Spec compliance:** Does it actually do what was decided?
- Every requirement from Phase 1 has a corresponding implementation
- Nothing extra was built (YAGNI violation)
- Edge cases from the grilling are handled

**Axis 3 — Security:** (if applicable)
- OWASP Top 10 on the diff
- Only flag with confidence ≥ 8/10
- Security findings block shipping

### 3.2 Performance (if applicable)

Run `/benchmark` before/after. Flag any metric >10% worse. Regressions require justification or fix.

### 3.3 Integration check

Run the full test suite. If it takes >5 minutes, run the subset touching changed files first — but the full suite must pass before shipping.

**Completion criteria:**
- [ ] Standards axis: clean
- [ ] Spec axis: all requirements covered, nothing extra
- [ ] Security: no blockers
- [ ] Full test suite: green
- [ ] Performance: no regressions (or justified)

**Gate:** "Verification passed. Ready to ship?"

---

## Phase 4: SHIP

**Leading word:** *canary*

Ship small, watch closely, learn fast.

### 4.1 Deliver

- Commit message: imperative mood, one line, says WHY not WHAT
- Push branch, create PR with test plan
- Or commit directly to main if solo + tests pass + change is small

### 4.2 Monitor (if deployed)

Post-deploy: watch for 15 minutes. Errors, latency spikes, page failures. Report: CLEAR / WARNING / ALERT.

### 4.3 Learn

Capture only what was surprising or non-obvious:
- What assumption was wrong?
- What took 3x longer than expected and why?
- What pattern worked that you'd repeat?

Save to memory. Don't document the obvious.

**Completion criteria:**
- [ ] Code pushed and merged (or PR created)
- [ ] No regressions in production (if deployed)
- [ ] Learnings captured (if any were surprising)

---

## Context Hygiene

These rules prevent the #1 failure mode: context exhaustion.

| Rule | Why |
|------|-----|
| Phases 0-1 stay in ONE context window | Cumulative thinking builds on itself |
| Each BUILD task starts a fresh subagent | Prevents pollution between tasks |
| Never paste full plan into a subagent | Hand it a brief file; exact values live there |
| Compact before VERIFY, not during | Review needs full diff context |
| Handoff (not compact) when switching focus | Preserve decision rationale |

---

## Invocation Modes

```
/ultrabuilder              Full pipeline (Phase 0→4)
/ultrabuilder --quick      Skip Phase 0 (you know what to build)
/ultrabuilder --resume     Check context-save, continue where you left off
/ultrabuilder --backend    Skip design skills, add DX review emphasis
/ultrabuilder --design     Expand design sub-pipeline in Phase 2
```

---

## Decision Principles

When making routine choices within any phase:

1. **Existing patterns win** — continue what the codebase does
2. **Reversible over permanent** — prefer undoable choices
3. **Simple over clever** — three similar lines > premature abstraction
4. **Defer ambiguous** — surface to user, don't guess
5. **Escalate security** — always ask
6. **No-op test** — if removing this decision changes nothing, don't make it

---

## When NOT to Use

- Trivial changes (< 20 lines, clear scope) → just do it
- Pure research / exploration → use `/deep-research`
- Bug fix with known root cause → use `/investigate` directly
- Routine refactor → use `/refactor` directly

The pipeline exists for work where getting it wrong is expensive. If the blast radius is small, skip the ceremony.
