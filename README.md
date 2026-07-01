# UltraBuilder

**Advanced full-cycle development workflow for Claude Code** - combining gstack-style strategic thinking with superpowers-style execution discipline.

From vague idea to shipped, monitored, documented product - in one unified pipeline.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PHASE 0         PHASE 1          PHASE 2          PHASE 3          PHASE 4
 THINK           PLAN             BUILD            VERIFY           DELIVER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 office-hours    autoplan         design-explore   build-verify     build-ship
 learn(recall)   build-direction  build-execute    benchmark        land-and-deploy
 context-save    spec             investigate      health           canary
                 dx-review                                          document
                                                                    diagram
                                                                    learn(save)
                                                                    retro
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Challenge       Decide           Execute          Validate         Ship & Learn
 everything      precisely        solidly          ruthlessly       confidently
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Philosophy

Most AI coding workflows solve only one problem:
- **gstack** solves "are we building the right thing?" and "is it really working?"
- **superpowers** solves "are we building it well?"

UltraBuilder combines both - strategic rigor before code, disciplined execution during code, and thorough verification after code.

## Quick Start

### Install (copy skills to your Claude Code)

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/ultrabuilder.git

# Copy all skills to your Claude Code skills directory
cp -r ultrabuilder/skills/* ~/.claude/skills/
```

### Usage

```
/ultrabuilder          # Full pipeline: think → plan → build → verify → deliver
/ultrabuilder --quick  # Skip thinking phase, start planning
/ultrabuilder --design # Expand design sub-pipeline for UI-heavy work
/ultrabuilder --backend # No design skills, DX-focused
/ultrabuilder --resume # Continue from where you left off
```

Or invoke any individual skill directly:

```
/office-hours       # Challenge your idea before committing
/autoplan           # Quick automated plan review
/build-execute      # Jump straight to TDD implementation
/investigate        # Systematic debugging
/health             # Code quality score
```

## All Skills (21)

### Strategy & Planning

| Skill | What it does |
|-------|-------------|
| `/office-hours` | 6 forcing questions that challenge premises before any plan exists |
| `/autoplan` | Auto-resolved CEO/Design/Eng review - surfaces only taste decisions |
| `/build-direction` | Full manual strategic review (CEO → Eng → Design) |
| `/spec` | Vague intent → precise executable spec with quality gate |
| `/dx-review` | Developer experience audit - TTHW benchmarks, persona tracing |

### Execution

| Skill | What it does |
|-------|-------------|
| `/build` | Simple 4-phase orchestrator |
| `/build-execute` | Brainstorm → task breakdown → TDD loop |
| `/investigate` | Systematic root-cause debugging (Iron Law: no fix without investigation) |
| `/design-explore` | Design system creation, variant exploration, taste memory |
| `/design-html` | Mockup/description → production HTML |

### Verification

| Skill | What it does |
|-------|-------------|
| `/build-verify` | QA + security audit + code review |
| `/health` | Code quality score (type/lint/test/dead code) → 0-10 |
| `/benchmark` | Core Web Vitals baseline + before/after comparison |

### Delivery

| Skill | What it does |
|-------|-------------|
| `/build-ship` | Push + PR + retrospective |
| `/land-and-deploy` | Merge PR → CI → deploy → verify production |
| `/canary` | Post-deploy monitoring loop |
| `/document` | Auto-update/generate docs using Diataxis framework |
| `/diagram` | English → mermaid diagrams |

### Memory & Persistence

| Skill | What it does |
|-------|-------------|
| `/learn` | Cross-session institutional memory with confidence scores |
| `/context-save` | Save/restore session state across crashes |

### Orchestrator

| Skill | What it does |
|-------|-------------|
| `/ultrabuilder` | Master pipeline combining all phases with gates |

## How the Pipeline Works

### Phase 0: THINK
Challenge whether this is worth building. `/office-hours` asks 6 uncomfortable questions. If the idea doesn't survive, you just saved days of work.

### Phase 1: PLAN
Lock direction before writing code. Choose between full manual review (`/build-direction`) or automated review (`/autoplan`). Add `/spec` for complex features, `/dx-review` for developer-facing tools.

### Phase 2: BUILD
Execute with discipline. Design first (if UI), then TDD implementation. Each task follows RED → GREEN → REFACTOR → COMMIT. Use `/investigate` when bugs are mysterious.

### Phase 3: VERIFY
Catch everything before users see it. Run `/health` for code quality, `/build-verify` for QA + security, `/benchmark` for performance. Nothing ships with known issues.

### Phase 4: DELIVER
Ship confidently. `/build-ship` creates the PR, `/land-and-deploy` gets it to production, `/canary` monitors for 15 minutes after. Then document, run retro, and save learnings for next time.

## Gates Between Phases

The pipeline never auto-advances. At each gate, you decide:
- **Proceed** → move to next phase
- **Loop back** → fix something in the current phase
- **Stop** → save context for later

## Customization

### Adding your own skills

Create a new directory under `skills/` with a `SKILL.md` file:

```yaml
---
name: your-skill-name
description: "One-line description"
triggers:
  - "trigger phrase 1"
  - "trigger phrase 2"
---

# Your Skill Name

## When to Invoke
[when to use this]

## Workflow
[step by step]
```

### Modifying existing skills

Fork this repo, edit any `SKILL.md`, and re-copy to `~/.claude/skills/`.

## Credits

This workflow synthesizes ideas from:
- **[gstack](https://github.com/garrytan/gstack)** by Garry Tan - strategic review patterns, autoplan, ship/deploy/canary
- **[superpowers](https://github.com/obra/superpowers)** by Jesse Vincent (obra) - execution discipline, TDD, subagent orchestration

## License

MIT - use it, fork it, adapt it to your workflow.
