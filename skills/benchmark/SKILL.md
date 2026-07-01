---
name: benchmark
description: "Performance benchmarking — Core Web Vitals baseline, resource sizes, before/after comparison"
triggers:
  - "benchmark this"
  - "check performance"
  - "core web vitals"
  - "is this fast"
  - "performance baseline"
---

# Benchmark — Performance Engineering

## When to Invoke

Use before and after changes to measure performance impact. Establishes baselines, identifies regressions, and tracks improvements over time.

## Workflow

### Step 1: Detect What to Measure

Based on project type:

**Web App (has dev server):**
- Page load time (DOMContentLoaded, Load, LCP)
- First Contentful Paint (FCP)
- Largest Contentful Paint (LCP)
- Cumulative Layout Shift (CLS)
- Total Blocking Time (TBT)
- Bundle size (JS, CSS, images)
- Network requests count and total transfer size

**API/Backend:**
- Response time (p50, p95, p99)
- Throughput (requests/sec)
- Memory usage
- Database query time

**CLI/Library:**
- Execution time
- Memory allocation
- File I/O operations
- Startup time

### Step 2: Establish Baseline

1. Run measurements 3 times (for stability)
2. Take the median of each metric
3. Save baseline to `BENCHMARK.md`:

```markdown
## Baseline — [date]

| Metric | Value | Target |
|--------|-------|--------|
| LCP | 1.8s | < 2.5s |
| FCP | 0.9s | < 1.8s |
| CLS | 0.05 | < 0.1 |
| TBT | 120ms | < 200ms |
| Bundle (JS) | 245KB | < 300KB |
| Bundle (CSS) | 38KB | < 50KB |
```

### Step 3: Measure After Changes

Run the same measurements after code changes:

1. Same 3-run median approach
2. Compare against baseline
3. Flag regressions (any metric > 10% worse)
4. Celebrate improvements (any metric > 10% better)

### Step 4: Report

```markdown
## Benchmark Comparison

| Metric | Before | After | Delta | Status |
|--------|--------|-------|-------|--------|
| LCP | 1.8s | 2.1s | +17% | REGRESSION |
| Bundle | 245KB | 230KB | -6% | improved |

**Regressions requiring action**: [list]
**Improvements**: [list]
**No change**: [list]
```

## Measurement Tools

Use what's available in the project:

- **Lighthouse** (via CLI): `npx lighthouse URL --output json`
- **bundlesize/size-limit**: check package.json for existing config
- **Built-in**: `time` command for CLI tools, `performance.now()` for Node
- **Custom**: write a simple timing script if nothing else fits

## Targets (defaults, adjust per project)

| Metric | Good | Needs Work | Poor |
|--------|------|-----------|------|
| LCP | < 2.5s | 2.5-4s | > 4s |
| FCP | < 1.8s | 1.8-3s | > 3s |
| CLS | < 0.1 | 0.1-0.25 | > 0.25 |
| TBT | < 200ms | 200-600ms | > 600ms |
| JS Bundle | < 200KB | 200-500KB | > 500KB |

## Principles

- Always measure before AND after — gut feelings about performance are wrong
- 3 runs minimum — single measurements are noisy
- Measure in production-like conditions (not dev mode with source maps)
- Bundle size is the easiest win — check for unused dependencies first
- A 10% regression that ships is permanent until someone notices
- Performance budgets prevent death by a thousand cuts
