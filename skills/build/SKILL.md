---
name: build
description: "Master orchestrator — runs the full build lifecycle: direction → execute → verify → ship"
triggers:
  - "build from scratch"
  - "full build cycle"
  - "build end to end"
---

# Build — Full Lifecycle Orchestrator

## When to Invoke

Use when the user wants to run the complete build cycle from idea to shipped PR. This orchestrates all four phases in sequence, with gates between each.

## Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                     /build (orchestrator)                     │
├──────────────┬──────────────┬──────────────┬────────────────┤
│  DIRECTION   │   EXECUTE    │   VERIFY     │     SHIP       │
│              │              │              │                │
│ CEO Review   │ Brainstorm   │ Test Suite   │ Push           │
│ Eng Review   │ Task Break   │ Manual QA    │ Create PR      │
│ Design Review│ TDD Loop     │ Security     │ Retrospective  │
│              │ Integration  │ Code Review  │ Learnings      │
├──────────────┼──────────────┼──────────────┼────────────────┤
│   gstack     │ superpowers  │   gstack     │    gstack      │
│  thinking    │  executing   │  verifying   │   delivering   │
└──────────────┴──────────────┴──────────────┴────────────────┘
```

## How It Works

### Gate 1: Direction → Execute

After direction review completes, ask the user:

> **Direction review complete. Ready to start building?**
> - Yes, proceed with execution
> - Adjust the plan first (loops back to direction)
> - Stop here for now

### Gate 2: Execute → Verify

After execution completes, ask:

> **Implementation complete. Ready for verification?**
> - Yes, run full QA
> - I want to test manually first (pause)
> - Skip verification, go straight to ship

### Gate 3: Verify → Ship

After verification passes, ask:

> **Verification passed. Ready to ship?**
> - Yes, push and create PR
> - Fix something first (loops back)
> - Not shipping yet (stop)

## Usage Modes

### Full cycle
```
/build
```
Runs direction → execute → verify → ship with gates between each.

### Skip direction (you already know what to build)
```
/build-execute
```
Jumps straight to execution. Use when direction is already clear.

### Skip to verification (already built, need QA)
```
/build-verify
```
Jumps to QA/review. Use after manual implementation.

### Just ship (everything's ready)
```
/build-ship
```
Just pushes, creates PR, and runs retro.

## Principles

- Each phase is independently invocable — you don't have to run the full cycle
- Gates exist so the user stays in control — never auto-advance without asking
- The orchestrator's job is sequencing and gating, not doing the work itself
- If the user says "skip" at any gate, respect it immediately
- Track overall progress across phases so the user always knows where they are
