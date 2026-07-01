---
name: land-and-deploy
description: "Full deployment pipeline — merge PR, wait for CI, deploy, verify production health"
triggers:
  - "land and deploy"
  - "merge and deploy"
  - "ship to production"
  - "deploy this"
---

# Land and Deploy — PR to Production

## When to Invoke

Use after a PR is approved and ready to merge. Takes you from "approved PR" to "verified in production" in one command.

## Workflow

### Step 1: Pre-merge Checks

1. **Verify PR is approved** — `gh pr view --json reviewDecision`
2. **Verify CI is passing** — `gh pr checks`
3. **Verify no merge conflicts** — `gh pr view --json mergeable`
4. **Verify branch is up to date** with base branch

If any check fails, report the issue and stop.

### Step 2: Merge

1. **Merge the PR** — `gh pr merge --squash` (or merge strategy configured in repo)
2. **Verify merge succeeded** — check for error output
3. **Delete the branch** — `gh pr merge` handles this with `--delete-branch`

### Step 3: Wait for CI/Deploy

1. **Find the deploy workflow** — check `.github/workflows/` or ask the user which action deploys
2. **Monitor the run** — `gh run watch` or poll `gh run list`
3. **Report progress** — "CI running...", "Deploying...", "Deploy complete"

If deploy fails:
- Show the error logs
- Do NOT auto-revert — ask the user what to do
- Suggest: retry, revert, or investigate

### Step 4: Verify Production

After deploy succeeds:

1. **Health check** — hit the production URL, verify 200 response
2. **Smoke test** — test the specific feature that was deployed
3. **Check for errors** — if the project has error tracking (Sentry, etc.), check for new errors in the last 5 minutes
4. **Performance spot-check** — is response time reasonable?

### Step 5: Report

```markdown
## Deployment Complete

**PR**: [URL] — merged via [squash/merge/rebase]
**Deploy**: [workflow run URL]
**Production URL**: [URL]
**Health**: [status]
**Verification**: [what was checked]
**Time**: [total from merge to verified]
```

## Rollback Plan

If production verification fails:

1. **Assess severity** — is the site down, or is it a minor issue?
2. **If critical**: suggest `git revert` + new PR + fast-track merge
3. **If minor**: suggest a follow-up fix PR
4. **Never force-push main** — always revert via new commit

## Configuration

The skill adapts to the project's deploy setup:
- **Vercel/Netlify** — auto-detects from config, uses preview URLs
- **GitHub Actions** — watches workflow runs
- **Manual deploy** — asks user to confirm deploy is complete
- **No CI/CD** — walks user through manual steps

## Principles

- Never merge without passing CI — no exceptions
- Always verify after deploy — "it merged" is not "it works"
- Failed deploys are NOT emergencies unless the site is down — stay calm, investigate
- The user decides whether to revert or fix forward
- Keep the user informed at every stage — silence during deploy is anxiety
