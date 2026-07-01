---
name: context-save
description: "Session state preservation — save and restore working context across crashes and context switches"
triggers:
  - "save context"
  - "context save"
  - "save my progress"
  - "context restore"
  - "restore context"
  - "where was I"
---

# Context Save/Restore — Session State Preservation

## When to Invoke

Use when:
- Ending a session mid-task and wanting to resume later
- About to do something risky and wanting a checkpoint
- Resuming after a crash or context window limit
- Switching between multiple workstreams

## Save Mode

### What to Capture

When the user says "save context" or you detect a session ending:

1. **Current goal** — what are we trying to accomplish?
2. **Progress** — what's done, what's in progress, what's next?
3. **Key decisions made** — architectural choices, approach selections
4. **Open questions** — unresolved ambiguities
5. **Active files** — which files are we working in?
6. **Branch state** — current branch, uncommitted changes, recent commits
7. **Failed approaches** — what we tried that didn't work (so we don't repeat)
8. **Mental model** — how does the relevant part of the system work?

### Save Format

Write to `context/sessions/[timestamp]-[slug].md`:

```markdown
# Session Context: [goal summary]

**Saved**: [timestamp]
**Branch**: [branch name]
**Status**: [in-progress / blocked / pausing]

## Goal
[What we're building/fixing/investigating]

## Progress
- [x] [completed step]
- [x] [completed step]
- [ ] [next step — IN PROGRESS]
- [ ] [future step]
- [ ] [future step]

## Decisions
- [decision]: [rationale]
- [decision]: [rationale]

## Open Questions
- [question that needs answering]
- [blocker or ambiguity]

## Working Files
- `path/to/file.ts` — [what we're doing here]
- `path/to/other.ts` — [what we're doing here]

## Failed Approaches
- [approach]: [why it didn't work]

## Mental Model
[Brief description of how the relevant system works, so future-you doesn't have to re-derive it]

## Resume Instructions
[What to do first when picking this back up]
```

### Auto-Save Triggers

Consider auto-saving when:
- Context window is getting long (many back-and-forth turns)
- The user says "let me think about this" or "I'll come back to this"
- About to attempt something destructive
- Switching to a different topic/task

## Restore Mode

When the user says "restore context" or "where was I":

1. **List available saves** — show recent session saves with timestamps and goals
2. **User picks one** (or most recent by default)
3. **Restore state**:
   - Read the saved context file
   - Verify branch still exists and files are in expected state
   - Report any drift ("since last session, these files changed: ...")
   - Present the "Resume Instructions" section
4. **Confirm readiness** — "Restored context for [goal]. Next step was: [X]. Ready to continue?"

## Continuous Checkpoint Mode

For long/risky sessions, offer continuous checkpointing:

1. After each meaningful step, auto-commit with `WIP: [description]`
2. The commit message includes structured context:
   ```
   WIP: implement user auth flow
   
   [context]
   decisions: JWT over sessions, bcrypt for passwords
   next: add refresh token rotation
   blocked: none
   [/context]
   ```
3. Before shipping, squash WIP commits into clean ones

## Output

**On save:**
```markdown
Context saved to `context/sessions/[file]`
Resume with: /context-save (then select restore)
```

**On restore:**
```markdown
## Restored: [goal]
**Last active**: [timestamp]
**Branch**: [name] — [status]
**Next step**: [what to do]
**Drift detected**: [any changes since save, or "none"]
```

## Principles

- Save is cheap — do it often rather than losing context
- The save file should be enough for a cold start — no implicit knowledge
- Failed approaches are as valuable as successes — record both
- Drift detection prevents acting on stale assumptions
- The resume instructions should be actionable — "do X" not "think about Y"
