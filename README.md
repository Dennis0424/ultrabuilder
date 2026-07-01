# UltraBuilder

**Advanced full-cycle development workflow for Claude Code** - combining gstack-style strategic thinking with superpowers-style execution discipline, plus agent orchestration, premium UI craft, animation systems, and more.

From vague idea to shipped, monitored, documented product - in one unified pipeline. **36 skills.**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PHASE 0         PHASE 1          PHASE 2          PHASE 3          PHASE 4
 THINK           PLAN             BUILD            VERIFY           DELIVER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 office-hours    autoplan         design-explore   build-verify     build-ship
 learn(recall)   build-direction  build-execute    benchmark        land-and-deploy
 context-save    spec             motion-design    health           canary
 pair-program    dx-review        scroll-story     code-review      document
                 api-design       page-transitions test-gen         diagram
                 component-arch   investigate      performance      learn(save)
                                  refactor         accessibility    retro
                                  multi-agent
                                  ai-integration
                                  responsive
                                  state-management
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Challenge       Decide           Execute          Validate         Ship & Learn
 everything      precisely        solidly          ruthlessly       confidently
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Philosophy

Most AI coding workflows solve only one problem:
- **gstack** solves "are we building the right thing?" and "is it really working?"
- **superpowers** solves "are we building it well?"

UltraBuilder combines both — plus agent orchestration for parallel work, premium UI craft skills, animation systems, API design, and AI integration patterns.

## Quick Start

### Install

```bash
# Clone the repo
git clone https://github.com/Dennis0424/ultrabuilder.git

# Copy all skills to your Claude Code skills directory
# macOS/Linux:
cp -r ultrabuilder/skills/* ~/.claude/skills/

# Windows (PowerShell):
.\ultrabuilder\install.ps1
```

### Usage

```
/ultrabuilder          # Full pipeline: think → plan → build → verify → deliver
/ultrabuilder --quick  # Skip thinking phase, start planning
/ultrabuilder --design # Expand design sub-pipeline for UI-heavy work
/ultrabuilder --backend # No design skills, DX-focused
/ultrabuilder --resume # Continue from where you left off
```

Or invoke any individual skill directly.

---

## All Skills (36)

### Strategy & Planning

| Skill | What it does |
|-------|-------------|
| `/office-hours` | 6 forcing questions that challenge premises before any plan exists |
| `/autoplan` | Auto-resolved CEO/Design/Eng review - surfaces only taste decisions |
| `/build-direction` | Full manual strategic review (CEO → Eng → Design) |
| `/spec` | Vague intent → precise executable spec with quality gate |
| `/dx-review` | Developer experience audit - TTHW benchmarks, persona tracing |
| `/api-design` | REST/GraphQL API architecture - endpoints, errors, versioning |

### Agent Orchestration

| Skill | What it does |
|-------|-------------|
| `/multi-agent` | Parallel subagent orchestration - fan-out, implement+review, generate+judge |
| `/pair-program` | Structured pair programming - driver/navigator, ping-pong TDD |
| `/code-review-agent` | Adversarial code review - finds bugs that pass CI |
| `/test-gen` | AI-driven test generation - unit, integration, e2e from code analysis |

### UI/Frontend Craft

| Skill | What it does |
|-------|-------------|
| `/component-arch` | Component architecture - composition, prop design, file structure |
| `/accessibility` | WCAG audit + fixes - keyboard, screen readers, contrast, ARIA |
| `/responsive` | Mobile-first responsive - breakpoints, fluid type, container queries |
| `/state-management` | State architecture - local vs global, server state, state machines |

### Animation & Motion

| Skill | What it does |
|-------|-------------|
| `/motion-design` | Animation system - Motion/GSAP, easing, orchestration, performance |
| `/scroll-story` | Scroll-driven storytelling - sticky stack, horizontal pan, parallax |
| `/page-transitions` | Route animations - View Transitions API, shared layout, enter/exit |

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
| `/investigate` | Systematic root-cause debugging (Iron Law, 3-attempt limit) |
| `/refactor` | Systematic refactoring - extract, rename, restructure safely |
| `/ai-integration` | LLM features in production - streaming, RAG, structured output |
| `/performance` | Performance optimization - bundle, rendering, network, runtime |

### Verification & Quality

| Skill | What it does |
|-------|-------------|
| `/build-verify` | QA + security audit + code review |
| `/health` | Code quality score → weighted 0-10 |
| `/benchmark` | Core Web Vitals + before/after comparison |

### Deployment & Monitoring

| Skill | What it does |
|-------|-------------|
| `/build-ship` | Push + PR + retrospective |
| `/land-and-deploy` | Merge PR → CI → deploy → verify production |
| `/canary` | Post-deploy monitoring loop |

### Documentation & Diagrams

| Skill | What it does |
|-------|-------------|
| `/document` | Auto-update/generate docs (Diataxis framework) |
| `/diagram` | English → mermaid diagrams |

### Memory & Persistence

| Skill | What it does |
|-------|-------------|
| `/learn` | Cross-session institutional memory with confidence scores |
| `/context-save` | Save/restore session state |

### Orchestrator

| Skill | What it does |
|-------|-------------|
| `/ultrabuilder` | Master pipeline combining all phases with gates |

---

## How the Pipeline Works

### Phase 0: THINK
Challenge whether this is worth building. `/office-hours` asks 6 uncomfortable questions. `/pair-program` if you want to think collaboratively.

### Phase 1: PLAN
Lock direction before writing code. `/autoplan` for speed, `/build-direction` for thoroughness. Add `/spec` for complex features, `/dx-review` for developer tools, `/api-design` for backends, `/component-arch` for frontend structure.

### Phase 2: BUILD
Execute with discipline. Design system first (`/design-explore`), then animation (`/motion-design`, `/scroll-story`), then TDD implementation (`/build-execute`). Use `/investigate` for bugs, `/refactor` for cleanup, `/multi-agent` for parallel work, `/ai-integration` for LLM features.

### Phase 3: VERIFY
Catch everything. `/code-review-agent` for adversarial review, `/test-gen` for coverage gaps, `/health` for quality score, `/benchmark` for performance, `/accessibility` for WCAG compliance.

### Phase 4: DELIVER
Ship confidently. `/build-ship` creates the PR, `/land-and-deploy` gets it to production, `/canary` monitors. Then `/document`, run retro, `/learn` to save institutional knowledge.

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
- **[gstack](https://github.com/garrytan/gstack)** by Garry Tan - strategic reviews, autoplan, ship/deploy/canary
- **[superpowers](https://github.com/obra/superpowers)** by Jesse Vincent - execution discipline, TDD, orchestration
- Original craft skills for UI, animation, agents, and AI integration
