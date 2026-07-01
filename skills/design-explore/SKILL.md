---
name: design-explore
description: "Design exploration — generate multiple design variants, compare approaches, build design systems from scratch"
triggers:
  - "explore designs"
  - "design system"
  - "design variants"
  - "what should this look like"
  - "design consultation"
---

# Design Explore — Design System and Variant Generation

## When to Invoke

Use when you need to establish visual direction, build a design system from scratch, or explore multiple design approaches before committing to one.

## Two Modes

### Mode 1: Design Consultation (build from scratch)

For projects without an established visual language:

1. **Research the landscape** — what do competitors/similar products look like?
2. **Propose 3 directions** varying in:
   - Conservative (safe, proven patterns)
   - Modern (current trends, slightly bold)
   - Experimental (creative risk, distinctive)

3. For each direction, define:
   ```markdown
   **Typography**: [font pairing, scale]
   **Color**: [palette with specific hex values]
   **Spacing**: [system — 4px/8px grid, scale]
   **Motion**: [animation philosophy — none/subtle/expressive]
   **Layout**: [approach — dense/spacious, grid system]
   **Personality**: [one word that captures the feel]
   ```

4. Present to user via AskUserQuestion with previews if possible
5. Write chosen system to `DESIGN.md` or equivalent

### Mode 2: Design Shotgun (variant exploration)

For a specific component or page:

1. **Generate 3-6 variants** that solve the same problem differently:
   - Vary layout (horizontal vs vertical, card vs list, etc.)
   - Vary density (minimal vs information-rich)
   - Vary interaction model (click vs hover vs scroll)

2. For each variant, produce:
   - A description of the approach and its tradeoff
   - HTML/CSS implementation (if the user wants code)
   - Rationale: who does this serve best?

3. Let the user pick, mix, or request more variants

## Taste Memory

Track user preferences over time:
- When user approves a design, note what they liked
- When user rejects, note what didn't work
- Use this to bias future suggestions

Store in project memory:
```markdown
## Design Preferences
- Prefers: [patterns/styles consistently chosen]
- Avoids: [patterns/styles consistently rejected]
- Last updated: [date]
```

## Design Principles to Apply

1. **Hierarchy** — what should the eye see first, second, third?
2. **Consistency** — same thing always looks and works the same way
3. **Feedback** — every action has a visible response
4. **Forgiveness** — make it easy to undo mistakes
5. **Efficiency** — minimize steps for frequent actions

## Output

```markdown
## Design Exploration Complete

**Direction chosen**: [name/description]
**Design system**: [file path if created]
**Key decisions**:
- [typography choice and why]
- [color approach and why]
- [layout system and why]
**Variants explored**: [count]
**User preference notes**: [what to remember for next time]
```

## Principles

- Show, don't describe — produce actual visual implementations when possible
- Design is hypothesis — you're testing whether something works, not declaring it correct
- The user's taste is ground truth — never argue with preference, learn from it
- Constraints breed creativity — small screens, limited colors, and tight timelines produce focused design
- Every design decision should have a reason, even if the reason is "it looks better"
