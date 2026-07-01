---
name: canary
description: "Post-deploy monitoring loop — watches for errors, performance regressions, and page failures"
triggers:
  - "canary"
  - "monitor the deploy"
  - "watch production"
  - "post-deploy check"
---

# Canary — Post-Deploy Monitoring

## When to Invoke

Use immediately after a deploy lands in production. Runs a monitoring loop to catch issues early while the change is still fresh and easy to revert.

## Workflow

### Step 1: Establish Watch Parameters

1. **What to monitor** (auto-detect from project):
   - Production URL(s)
   - Key API endpoints
   - Error tracking dashboard (Sentry, Datadog, etc.)
   - Performance metrics

2. **Duration** — ask user or default to 15 minutes
3. **Check interval** — every 2-3 minutes

### Step 2: Monitoring Loop

For each check cycle:

```markdown
### Check [N] — [timestamp]
- HTTP Status: [200/500/etc]
- Response time: [ms] (baseline: [ms])
- Console errors: [count] (new: [count])
- JS errors: [count]
- API errors: [count]
```

### Step 3: Alert Conditions

**Immediate alert** (stop monitoring, notify user):
- 5xx status codes on main pages
- Response time > 3x baseline
- New unhandled exceptions
- Complete page failure (connection refused, timeout)

**Warning** (continue monitoring, note in report):
- Response time > 1.5x baseline
- New console warnings
- Increased error rate (but not new errors)
- Degraded but functional pages

**Clear** (all good):
- All metrics within normal range
- No new errors
- Response times stable

### Step 4: Report

After monitoring period completes (or on alert):

```markdown
## Canary Report

**Duration**: [start] — [end] ([N] checks)
**Status**: CLEAR / WARNING / ALERT

**Metrics**:
| Check | Status | Response Time | Errors |
|-------|--------|---------------|--------|
| 1 | 200 | 145ms | 0 |
| 2 | 200 | 152ms | 0 |
| ... | | | |

**Verdict**: [Safe to leave / Needs attention / Revert recommended]
**Action taken**: [none / alerted user / suggested revert]
```

## Available Tools

Use what the project has:
- `curl` for HTTP checks
- `gh` for checking deploy status
- Project's health check endpoints
- Error tracking APIs if configured

## When to Recommend Revert

Only recommend revert if:
- Production is DOWN (not degraded — DOWN)
- New errors affecting > 5% of requests
- Critical business flow broken (checkout, auth, etc.)

For everything else, suggest a fix-forward approach.

## Principles

- Early detection saves hours — catch issues in 5 minutes, not 5 hours
- False positives are better than missed issues during canary
- The monitoring loop is finite — don't run forever
- Report clearly: is this safe to walk away from, or does it need attention?
- Never auto-revert — always inform the user and let them decide
