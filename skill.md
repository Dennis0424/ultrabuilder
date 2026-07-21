---
name: ultrabuilder
description: "Advanced full-cycle orchestrator — combines gstack strategy + superpowers execution + premium design into one unified pipeline. From vague idea to shipped, monitored, documented product."
triggers:
  - "ultrabuilder"
  - "full cycle"
  - "end to end"
  - "build everything"
  - "advanced build"
---

# UltraBuilder — Advanced Full-Cycle Pipeline

> gstack strategic thinking + superpowers execution discipline + premium design craft

## Overview

This is the master orchestrator that sequences ALL available skills into a coherent product delivery pipeline. Each phase gates the next. Every skill is optional — skip what doesn't apply.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PHASE 0        PHASE 1         PHASE 2        PHASE 3        PHASE 4
 THINK          PLAN            BUILD          VERIFY         DELIVER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 office-hours   autoplan        writing-plans  build-verify   build-ship
 context-save   build-direction design-explore benchmark      land-and-deploy
 learn(read)    spec            design-html    health         canary
                dx-review       build-execute  qa             document
                                investigate                   diagram
                                                              learn(write)
                                                              context-save
                                                              retro
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 MINDSET:       MINDSET:        MINDSET:       MINDSET:       MINDSET:
 Challenge      Decide          Plan & Execute Validate       Ship & Learn
 everything     precisely       solidly        ruthlessly     confidently
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Phase 0: THINK (Challenge Everything)

**Goal**: Ensure we're building the right thing before investing effort.

### Step 0.1: Restore Context
- Check for existing session state (`/context-save` restore)
- Check learnings (`/learn` read) for relevant past discoveries
- If resuming previous work, skip to wherever we left off

### Step 0.2: Office Hours
- Run `/office-hours` — 6 forcing questions
- Challenge premises, find the real problem
- If the idea doesn't survive scrutiny → STOP (save the user days of wasted work)

### Gate 0→1
Ask: **"Idea survived scrutiny. Ready to plan?"**
- Yes → Phase 1
- Need more thinking → loop back
- Kill it → stop, save learning about why

---

## Phase 1: PLAN (Decide Precisely)

**Goal**: Lock direction, architecture, and scope before writing code.

### Step 1.1: Strategic Review (pick one path)

**Path A — Full manual review** (`/build-direction`):
- CEO Review: Is this worth building? What scope?
- Eng Review: Is the architecture sound?
- Design Review: Will users love this?
- Best for: novel products, high-stakes decisions, exploring unknowns

**Path B — Automated review** (`/autoplan`):
- Auto-resolves routine decisions using 6 principles
- Surfaces only genuine taste calls for human input
- Best for: incremental features, familiar territory, speed

### Step 1.2: Spec (if complex)
- Run `/spec` for complex features
- Vague → precise, with quality gate (blocks if any dimension < 7/10)
- Skip for simple features where direction review is enough

### Step 1.3: DX Review (if developer-facing)
- Run `/dx-review` if building APIs, SDKs, CLIs, or developer tools
- TTHW benchmark, persona tracing, friction mapping
- Skip for pure consumer UI

### Step 1.4: Save checkpoint
- `/context-save` the plan state
- Commit `PLAN.md` / `SPEC.md` / `DIRECTION.md`

### Gate 1→2
Ask: **"Plan locked. Ready to build?"**
- Yes → Phase 2
- Adjust plan → loop back to relevant step
- Park it → save context for later

---

## Phase 2: BUILD (Execute Solidly)

**Goal**: Turn the plan into working software with premium craft.

### Step 2.1: Implementation Plan (`superpowers:writing-plans`)
- Run `superpowers:writing-plans` to decompose the spec/direction into a structured, ordered implementation plan
- Identifies critical files, dependencies between tasks, and architectural trade-offs
- Produces step-by-step plan with clear acceptance criteria per step
- Skip for single-file changes or trivial tasks where `/build-execute` brainstorm is sufficient
- The plan becomes the backbone for Step 2.3's task breakdown — don't re-derive it

### Step 2.2: Design (if UI exists)

**Choose design skills based on project type:**

| Project Type | Primary Skill | Supporting Skills |
|-------------|---------------|-------------------|
| Landing page / marketing | `/design-taste-frontend` | `/imagegen-frontend-web`, `/gpt-taste` |
| Mobile app | `/imagegen-frontend-mobile` | `/design-explore` |
| Dashboard / product UI | `/impeccable` | `/shadcn`, `/high-end-visual-design` |
| Redesign of existing | `/redesign-existing-projects` | `/design-explore` |
| Brand identity needed | `/brandkit` | `/design-explore` |
| Brutalist / editorial | `/industrial-brutalist-ui` or `/minimalist-ui` | — |
| Design system from scratch | `/design-explore` (consultation mode) | — |
| Mockup → code | `/design-html` or `/image-to-code` | — |
| Stitch/agent-friendly | `/stitch-design-taste` | — |

**Design sub-pipeline:**
1. Explore direction → `/design-explore` (variants + taste memory)
2. Generate reference images → appropriate `/imagegen-*` skill
3. Implement → `/design-html` or `/image-to-code`
4. Apply design system → `/shadcn` if using component library
5. Enforce quality → `/full-output-enforcement` (no truncated output)

### Step 2.3: Implementation (`/build-execute`)

1. **Brainstorm** — 3 approaches (fast/balanced/thorough), user picks
2. **Task breakdown** — use the plan from Step 2.1 as backbone; decompose into small, testable, commitable units
3. **TDD loop** per task:
   ```
   RED → GREEN → REFACTOR → COMMIT → NEXT
   ```
4. **Integration check** — full suite passes, feature works end-to-end

### Step 2.4: Debug (if issues arise)
- Run `/investigate` for mysterious bugs
- Iron Law: no fixes without root-cause investigation
- 3-attempt limit before reconsidering approach

### Step 2.5: Continuous checkpoints
- Commit after each meaningful step
- `/context-save` periodically for crash resilience

### Gate 2→3
Ask: **"Implementation complete. Ready for verification?"**
- Yes → Phase 3
- More work needed → continue building
- Pause → save context

---

## Phase 3: VERIFY (Validate Ruthlessly)

**Goal**: Catch everything before it reaches users.

### Step 3.1: Code Health (`/health`)
- Run health score — type safety, lint, tests, dead code, deps
- Must score ≥ 7/10 to proceed
- Fix issues if below threshold

### Step 3.2: Full QA (`/build-verify`)
- Automated test suite (must pass)
- Type checking (must pass)
- Linter (fix auto-fixable, flag rest)
- Manual QA (if UI — golden path + edge cases)
- Code review (staff engineer perspective)

### Step 3.3: Security Audit
- OWASP Top 10 check on the diff
- Only flag issues with confidence ≥ 8/10
- Security findings BLOCK shipping

### Step 3.4: Performance (`/benchmark`)
- Run benchmark before/after comparison
- Flag any metric > 10% worse
- Performance regressions require justification or fix

### Step 3.5: DX Verification (if developer-facing)
- Re-run `/dx-review` in DX POLISH mode
- Verify TTHW hasn't degraded
- Test error messages and examples

### Gate 3→4
Ask: **"Verification passed. Ready to ship?"**
- Yes → Phase 4
- Issues found → loop back to Phase 2 to fix, then re-verify
- Blocked → investigate, ask for help

---

## Phase 4: DELIVER (Ship & Learn)

**Goal**: Get it live, verify it works, document it, capture learnings.

### Step 4.1: Ship (`/build-ship`)
- Pre-ship checklist (tests pass, no uncommitted changes, up to date)
- Push branch, create PR
- Clear description with test plan

### Step 4.2: Deploy (`/land-and-deploy`)
- Merge PR (after approval)
- Wait for CI → deploy → verify production
- If deploy fails → investigate, don't auto-revert

### Step 4.3: Monitor (`/canary`)
- Post-deploy monitoring loop (15 min default)
- Watch for errors, perf regressions, page failures
- Report: CLEAR / WARNING / ALERT

### Step 4.4: Document (`/document`)
- Update existing docs to match changes
- Generate missing docs using Diataxis
- Add `/diagram` for architecture if system changed

### Step 4.5: Retrospective
- What went well? What was harder than expected?
- What would we do differently?
- Time breakdown across phases

### Step 4.6: Capture Learnings (`/learn`)
- Save patterns, pitfalls, preferences discovered
- Update institutional memory
- Save design taste preferences if UI work was done

### Step 4.7: Final Context Save
- `/context-save` with "COMPLETE" status
- Clean up WIP commits if any remain

---

## Invocation Modes

### Full pipeline
```
/ultrabuilder
```
Runs Phase 0 → 4 with gates between each.

### Quick mode (skip Phase 0)
```
/ultrabuilder --quick
```
Starts at Phase 1. Use when you already know what to build.

### Design-heavy mode
```
/ultrabuilder --design
```
Expands Phase 2.1 design sub-pipeline, runs full design exploration.

### Backend-only mode
```
/ultrabuilder --backend
```
Skips all design skills, adds DX review emphasis, skips browser QA.

### Resume mode
```
/ultrabuilder --resume
```
Checks context-save, finds where you left off, continues from there.

---

## Skill Selection Matrix

The orchestrator auto-selects skills based on project detection:

| Signal | Skills Activated |
|--------|-----------------|
| Has `package.json` + React/Vue/Svelte | Design skills + `/shadcn` + browser QA |
| Has API routes / Express / FastAPI | `/dx-review` + API testing |
| Has `tsconfig.json` | Type safety in `/health` |
| Has test runner configured | TDD in `/build-execute` |
| Has CI/CD config | `/land-and-deploy` + `/canary` |
| Has existing docs | `/document` in release mode |
| Is a CLI / SDK / library | Heavy `/dx-review` |
| Has `components.json` (shadcn) | `/shadcn` for component work |
| User mentions "mobile" | `/imagegen-frontend-mobile` |
| User mentions "brand" | `/brandkit` |

---

## Decision Principles (inherited from autoplan)

When making routine decisions within any phase:

1. **Prefer completeness** — full > partial unless 3x cost
2. **Match existing patterns** — continue what the codebase does
3. **Choose reversible** — prefer undoable over permanent
4. **Match past preferences** — check `/learn` memory
5. **Defer ambiguous** — surface to user
6. **Escalate security** — always ask the user

---

## Anti-Patterns (what this pipeline prevents)

| Without Pipeline | With Pipeline |
|-----------------|---------------|
| Build first, ask questions later | Challenge idea before investing |
| Guess at solutions | Investigate root cause |
| Ship without verification | Multi-layer QA gate |
| Forget what we learned | Institutional memory compounds |
| Lose context on crash | Session state preservation |
| Generic AI-looking UI | Premium design skills with taste memory |
| Deploy and pray | Canary monitoring catches issues early |
| Outdated docs | Auto-update on every release |
| Performance regression | Benchmark before/after |
| Same mistakes repeated | Learnings prevent repetition |

---

## Principles

1. **Gates are not bureaucracy** — they prevent expensive mistakes early
2. **Skip what doesn't apply** — not every project needs every skill
3. **The user is always in control** — never auto-advance, always ask
4. **Compound learning** — every cycle makes the next one better
5. **Premium craft** — the design skills exist to prevent generic AI output
6. **Reversibility** — prefer approaches that can be undone
7. **Complete the loop** — retro + learn + context-save = continuous improvement
