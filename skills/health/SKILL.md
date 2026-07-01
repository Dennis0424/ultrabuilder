---
name: health
description: "Code health score — type checker + linter + tests + dead code → weighted 0-10 with trends"
triggers:
  - "health check"
  - "code health"
  - "how healthy is this codebase"
  - "code quality score"
---

# Health — Code Quality Scoring

## When to Invoke

Use to get a quick pulse on codebase health. Produces a single 0-10 score with breakdown across dimensions. Track over time to see trends.

## Dimensions (weighted)

| Dimension | Weight | What it measures |
|-----------|--------|------------------|
| Type Safety | 25% | Type checker errors (tsc, mypy, etc.) |
| Lint | 20% | Linter violations (eslint, ruff, etc.) |
| Tests | 30% | Test suite pass rate + coverage |
| Dead Code | 15% | Unused exports, unreachable code, dead files |
| Dependencies | 10% | Outdated/vulnerable packages |

## Workflow

### Step 1: Detect Tooling

Scan the project for:
- `tsconfig.json` → TypeScript
- `eslint.config.*` / `.eslintrc*` → ESLint
- `package.json` scripts → test runner
- `pyproject.toml` / `setup.cfg` → Python tools
- `Cargo.toml` → Rust tools

### Step 2: Run Each Dimension

**Type Safety:**
```bash
# Run type checker, count errors
npx tsc --noEmit 2>&1 | grep "error TS" | wc -l
```
- 0 errors = 10/10
- 1-5 errors = 8/10
- 6-20 errors = 5/10
- 21+ errors = 2/10

**Lint:**
```bash
# Run linter, count violations
npx eslint . --format json 2>/dev/null | # parse error count
```
- 0 errors, < 5 warnings = 10/10
- 0 errors, 5+ warnings = 8/10
- 1-5 errors = 5/10
- 6+ errors = 3/10

**Tests:**
```bash
# Run test suite
npm test -- --coverage 2>&1
```
- All pass + > 80% coverage = 10/10
- All pass + 50-80% coverage = 7/10
- Some failures = 4/10
- Many failures or no tests = 1/10

**Dead Code:**
- Check for unused exports (`ts-prune` or manual grep)
- Check for files with no imports
- Check for commented-out code blocks
- Score based on ratio of dead to live code

**Dependencies:**
```bash
# Check for vulnerabilities and outdated
npm audit --json 2>/dev/null
npm outdated --json 2>/dev/null
```
- 0 vulnerabilities, all current = 10/10
- 0 critical vulns, some outdated = 7/10
- Any critical vulnerability = 3/10

### Step 3: Calculate Score

```
score = (type_safety * 0.25) + (lint * 0.20) + (tests * 0.30) + (dead_code * 0.15) + (deps * 0.10)
```

### Step 4: Report

```markdown
## Code Health: [X.X]/10

| Dimension | Score | Details |
|-----------|-------|---------|
| Type Safety (25%) | X/10 | [N] errors |
| Lint (20%) | X/10 | [N] errors, [N] warnings |
| Tests (30%) | X/10 | [pass/fail], [coverage]% |
| Dead Code (15%) | X/10 | [N] unused exports |
| Dependencies (10%) | X/10 | [N] vulnerabilities |

**Trend**: [up/down/stable] from last check
**Quick wins**: [top 3 things that would improve score most]
**Biggest risk**: [most concerning finding]
```

### Step 5: Track Trend

If `HEALTH.md` exists in project, append the new score with date. If not, create it:

```markdown
## Health History
| Date | Score | Notes |
|------|-------|-------|
| 2024-01-15 | 7.2 | Initial baseline |
| 2024-01-22 | 7.8 | Fixed type errors |
```

## Principles

- This is a snapshot, not a judgment — all codebases have debt
- The score is for tracking direction, not comparing projects
- Quick wins first — fix the easiest things that improve the score most
- Don't aim for 10/10 — 8+ is healthy, 6-7 needs attention, below 6 is risky
- Run before and after major work to ensure you're improving, not regressing
