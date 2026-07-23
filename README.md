# UltraBuilder

**Full-cycle delivery workflow for Claude Code** — from vague idea to shipped product in five composable phases. Inspired by [Matt Pocock's skill design](https://github.com/mattpocock/skills), [gstack](https://github.com/garrytan/gstack) strategic thinking, and [superpowers](https://github.com/obra/superpowers) execution discipline.

```
GRILL  ──→  DECIDE  ──→  BUILD  ──→  VERIFY  ──→  SHIP
 ↑            ↑            ↑           ↑           ↑
 fog          frontier     red/green   parallel    canary
 of war       tickets      tight loop  review axes monitoring
```

## Philosophy

Most AI coding workflows solve one problem. UltraBuilder solves the full chain:

- **Phase 0 (Grill)** — Is this worth building? Challenge everything before investing.
- **Phase 1 (Decide)** — Plan only what you can state precisely. Fog stays as fog.
- **Phase 2 (Build)** — Tight feedback loops. RED → GREEN → REFACTOR → COMMIT.
- **Phase 3 (Verify)** — Parallel review axes that can't contaminate each other.
- **Phase 4 (Ship)** — Ship small, watch closely, learn fast.

Each phase works standalone. Each gates the next via concrete completion criteria. Skip what doesn't apply — but never skip the gate check.

## Key Patterns

**The Grilling Primitive** — A relentless interview loop that precedes all work. 5 sentences that save days of wasted effort.

**Fog of War Planning** — Only create tickets for what can be precisely stated NOW. Everything else stays as fog until its dependencies resolve. Prevents premature decomposition.

**Leading Words** — Dense anchors that recruit the model's pretrained knowledge: *scrutiny*, *frontier*, *tight loop*, *parallel axes*, *canary*.

**Completion Criteria** — Every gate is a concrete checkbox list. Not "do you feel done?" but "can you check these 4 boxes?"

**Context Hygiene** — Explicit rules preventing context exhaustion. Fresh subagent per task. Phases 0-1 stay in one window. Never paste full plans into subagents.

## Quick Start

### Install

```bash
# Clone the repo
git clone https://github.com/Dennis0424/ultrabuilder.git

# macOS/Linux:
cp -r ultrabuilder/skills/* ~/.claude/skills/

# Windows (PowerShell):
.\ultrabuilder\install.ps1
```

### Usage

```
/ultrabuilder              # Full pipeline: grill → decide → build → verify → ship
/ultrabuilder --quick      # Skip Phase 0 (you know what to build)
/ultrabuilder --resume     # Continue from where you left off
/ultrabuilder --backend    # No design skills, DX-focused
/ultrabuilder --design     # Expand design sub-pipeline for UI-heavy work
```

Or invoke any individual skill directly.

---

## All Skills (36)

### Strategy & Grilling

| Skill | What it does |
|-------|-------------|
| `/office-hours` | 6 forcing questions that challenge premises before any plan exists |
| `/autoplan` | Auto-resolved review — surfaces only genuine taste decisions |
| `/build-direction` | Full manual strategic review (CEO → Eng → Design) |
| `/spec` | Vague intent → precise executable spec with quality gate |
| `/dx-review` | Developer experience audit — TTHW benchmarks, persona tracing |
| `/api-design` | REST/GraphQL API architecture — endpoints, errors, versioning |

### Agent Orchestration

| Skill | What it does |
|-------|-------------|
| `/multi-agent` | Parallel subagent orchestration — fan-out, implement+review, generate+judge |
| `/pair-program` | Structured pair programming — driver/navigator, ping-pong TDD |
| `/code-review-agent` | Adversarial code review — finds bugs that pass CI |
| `/test-gen` | AI-driven test generation — unit, integration, e2e from code analysis |

### UI/Frontend Craft

| Skill | What it does |
|-------|-------------|
| `/component-arch` | Component architecture — composition, prop design, file structure |
| `/accessibility` | WCAG audit + fixes — keyboard, screen readers, contrast, ARIA |
| `/responsive` | Mobile-first responsive — breakpoints, fluid type, container queries |
| `/state-management` | State architecture — local vs global, server state, state machines |

### Animation & Motion

| Skill | What it does |
|-------|-------------|
| `/motion-design` | Animation system — Motion/GSAP, easing, orchestration, performance |
| `/scroll-story` | Scroll-driven storytelling — sticky stack, horizontal pan, parallax |
| `/page-transitions` | Route animations — View Transitions API, shared layout, enter/exit |

### Design

| Skill | What it does |
|-------|-------------|
| `/design-explore` | Design system creation, variant exploration, taste memory |
| `/design-html` | Mockup → production HTML, framework-aware |

### Implementation

| Skill | What it does |
|-------|-------------|
| `/build` | Simple 4-phase orchestrator |
| `/build-execute` | Brainstorm → task breakdown → TDD loop |
| `/investigate` | Systematic root-cause debugging (tight feedback loop, 3-attempt limit) |
| `/refactor` | Systematic refactoring — extract, rename, restructure safely |
| `/ai-integration` | LLM features in production — streaming, RAG, structured output |
| `/performance` | Performance optimization — bundle, rendering, network, runtime |

### Verification & Quality

| Skill | What it does |
|-------|-------------|
| `/build-verify` | QA + security audit + code review |
| `/health` | Code quality score → weighted 0-10 |
| `/benchmark` | Core Web Vitals + before/after comparison |

### Deployment & Monitoring

| Skill | What it does |
|-------|-------------|
| `/build-ship` | Push + PR + pre-ship checklist |
| `/land-and-deploy` | Merge PR → CI → deploy → verify production |
| `/canary` | Post-deploy monitoring loop (15 min, CLEAR/WARNING/ALERT) |

### Documentation & Diagrams

| Skill | What it does |
|-------|-------------|
| `/document` | Auto-update/generate docs (Diataxis framework) |
| `/diagram` | English → mermaid diagrams |

### Memory & Persistence

| Skill | What it does |
|-------|-------------|
| `/learn` | Cross-session institutional memory |
| `/context-save` | Save/restore session state |

### Orchestrator

| Skill | What it does |
|-------|-------------|
| `/ultrabuilder` | Master pipeline — five phases with completion criteria gates |

---

## When NOT to Use

- Trivial changes (< 20 lines, clear scope) → just do it
- Pure research / exploration → use `/deep-research`
- Bug fix with known root cause → use `/investigate` directly
- Routine refactor → use `/refactor` directly

The pipeline exists for work where getting it wrong is expensive. If the blast radius is small, skip the ceremony.

---

## Customization

### Adding your own skills

Create `skills/your-skill-name/SKILL.md`:

```yaml
---
name: your-skill-name
description: "One-line description"
triggers:
  - "trigger phrase"
---

# Skill content here
```

### Modifying existing skills

Fork this repo, edit, re-copy to `~/.claude/skills/`.

---

## Credits

Synthesized from:
- **[Matt Pocock's skills](https://github.com/mattpocock/skills)** — grilling primitive, fog of war, leading words, completion criteria, context hygiene
- **[gstack](https://github.com/garrytan/gstack)** by Garry Tan — strategic reviews, autoplan, ship/deploy/canary
- **[superpowers](https://github.com/obra/superpowers)** by Jesse Vincent — execution discipline, TDD, subagent orchestration
- Original craft skills for UI, animation, agents, and AI integration
