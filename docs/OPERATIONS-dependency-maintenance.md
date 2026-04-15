# Dependency Maintenance Operations Guide

**Date:** 2026-04-15  
**Status:** Live  
**Maintainer:** GitHub Actions + Flutter team

---

## Overview

This document defines the canonical operational procedures for miToosa's automated dependency maintenance system. All scripts, workflows, and agents follow these principles.

### Core Principles

🔴 **Live data always.** Never use cached or memory-based version information.  
🔴 **Fail fast.** Block CI immediately on CRITICAL/HIGH security advisories.  
🔴 **Human review for major changes.** Safe (minor/patch) upgrades auto-apply. Major-version bumps require manual approval.  
🔴 **Skills stay current.** Package skill files are regenerated after every upgrade to keep agent knowledge synchronized.

---

## Architecture

### System Components

```
pubspec.yaml / pubspec.lock (ground truth)
        │
        ├─ scripts/dependency_health.sh       (query + categorize)
        ├─ scripts/regenerate_skills.sh       (keep docs current)
        ├─ .github/workflows/dependency-maintenance.yml  (orchestration)
        └─ .github/agents/
            ├─ dependency-updater.md          (safe upgrade logic)
            ├─ package-security-scanner.md    (advisory scan)
            └─ tech-stack-skill-generator.md  (doc generation)
```

### Data Flow

1. **Query** (`dependency_health.sh`) → `flutter pub outdated` → parsed into SAFE/MAJOR/ADVISORY buckets
2. **Security Check** (independent) → pub.dev advisories → fails CI on CRITICAL/HIGH
3. **Auto-Upgrade** (SAFE only) → `flutter pub upgrade` → tests + analysis → PR
4. **Documentation** → `regenerate_skills.sh` → read pubspec.lock → fetch pub.dev docs → update `.github/skills/`

---

## Command Reference

### Local Development

```bash
# See what needs updating
bash scripts/dependency_health.sh

# Apply safe upgrades + test + commit
bash scripts/dependency_health.sh --auto

# Full check including security scan
bash scripts/dependency_health.sh --full

# Check skill file staleness
bash scripts/regenerate_skills.sh

# Update stale/missing skills
bash scripts/regenerate_skills.sh --write
```

### CI Workflow

**Trigger:** Monday 06:00 UTC (or manual `workflow_dispatch`)

**Jobs:**
1. `query-live-versions` — extract package status
2. `safe-upgrade` — apply minor/patch updates if available
3. `advisory-scan` — security check (independent)
4. `skill-refresh` — regenerate docs
5. `report` — post summary to GitHub Actions UI

**Outcomes:**
- ✅ All green: PR created with safe upgrades (if any)
- ❌ Advisory blocked: CI fails, manual intervention required
- ⏭️ No updates: workflow completes with no changes

---

## Categorization: SAFE vs. MAJOR vs. ADVISORY

### SAFE (Auto-Apply)

**Indicator:** Upgradable version exists and fits within `^` constraint in pubspec.yaml

**Example:** `flutter pub outdated` shows:
```
go_router    17.1.0    ✓ 17.2.1    17.2.1
```

**Action:**
```bash
flutter pub upgrade
dart analyze && echo "✅ Analysis passed"
flutter test && echo "✅ Tests passed"
git commit -m "chore(deps): upgrade patch/minor dependencies"
```

**Never blocked by tests passing:** If tests fail, revert and report the conflict.

### MAJOR (Human Review)

**Indicator:** Latest version > Resolvable version; marked with `*` in output

**Example:** `flutter pub outdated` shows:
```
share_plus    10.1.4    ✓ 10.1.4    13.0.0 *
```

**Action:**
1. Fetch changelog: `https://pub.dev/packages/share_plus/changelog`
2. Extract breaking changes between current (10.1.4) and target (13.0.0)
3. Draft a GitHub issue or PR description with extracted changes
4. Require human review before auto-applying `flutter pub upgrade --major-versions`

### ADVISORY (Blocks CI)

**Indicator:** pub.dev advisory feed reports CRITICAL or HIGH severity affecting installed version

**Example:**
```bash
curl -sL "https://pub.dev/api/packages/some_package" | jq '.advisories'
# Returns:
# [
#   {
#     "id": "CVE-2024-1234",
#     "severity": "HIGH",
#     "affected": { "versions": ["1.2.0", "1.2.1"] },
#     "summary": "Authentication bypass"
#   }
# ]
```

**Action:**
- ❌ CI blocks immediately
- Operator must manually upgrade the package to a patched version
- Re-run the security scan to confirm the fix

---

## Common Scenarios

### Scenario 1: Scheduled Run with Safe Upgrades Available

1. Workflow runs Monday 06:00 UTC
2. `query-live-versions` discovers 3 safe upgrades
3. `safe-upgrade` applies `flutter pub upgrade`, tests pass
4. PR created: `chore(deps): safe dependency upgrades available`
5. Team reviews and merges PR

### Scenario 2: Manual Test of Workflow

```bash
# Trigger manually via GitHub CLI
gh workflow run dependency-maintenance.yml

# Or via GitHub UI: Actions → Dependency Maintenance → Run workflow
```

### Scenario 3: Advisory Detected

1. `advisory-scan` job queries all direct dependencies
2. Finds HIGH advisory in transitive dependency
3. `advisory-scan` job fails → CI blocks
4. Operator manually upgrades affected package
5. `advisory-scan` re-runs and passes

### Scenario 4: Skills Become Stale After Upgrade

1. Safe upgrade is applied (e.g., `go_router 17.1.0 → 17.2.1`)
2. `regenerate_skills.sh --write` detects stale skill file
3. Fetches `https://pub.dev/packages/go_router/versions/17.2.1`
4. Updates `.github/skills/go_router-usage/SKILL.md` with new version
5. Commits changes: `chore(skills): regenerate package skills for updated versions`

---

## Boundaries & Constraints

### Always
- Query `flutter pub outdated` at runtime (never assume versions)
- Read `pubspec.lock` for ground truth (not `pubspec.yaml` ranges)
- Validate pub.dev API responses with `jq` before acting
- Run `dart analyze` and `flutter test` after applying upgrades
- Report all advisory findings (even MEDIUM/LOW)

### Ask First
- Manual edits to `pubspec.yaml` version constraints
- Upgrading packages with documented breaking changes
- Deleting an existing skill file (prefer updating)
- Adding skills for transitive (non-direct) dependencies

### Never
- Commit without green tests and analysis
- Hard-code version numbers in scripts or documentation
- Treat memory as authoritative for package versions
- Skip a package in the advisory scan
- Use cached advisory data
- Auto-merge major-version bumps (always require human review)

---

## Troubleshooting

### Problem: `flutter pub outdated` timeout or rate limit

**Symptom:** Workflow `query-live-versions` job fails with network error

**Solution:**
1. Check pub.dev status: https://status.pub.dev
2. Wait 1 hour, manually re-trigger via `workflow_dispatch`
3. If persistent, increase curl `--max-time` in scripts

### Problem: Advisory scan finds CRITICAL advisory

**Symptom:** `advisory-scan` job fails, CI blocks

**Solution:**
1. Identify the affected package: check GitHub Actions UI job output
2. Fetch pub.dev page for that package
3. Upgrade to a patched version: `flutter pub upgrade <package>`
4. Manually re-trigger `advisory-scan` via workflow_dispatch

### Problem: Test fails after safe upgrade

**Symptom:** `safe-upgrade` job fails at "Verify: flutter test"

**Solution:**
1. Check the error output in GitHub Actions
2. Identify which package caused the regression
3. File a GitHub issue with reproduction steps
4. Temporarily pin that package to the previous version in `pubspec.yaml`
5. Re-run the workflow

### Problem: Skill file not regenerated after upgrade

**Symptom:** `.github/skills/` directory is unchanged after `skill-refresh` job

**Solution:**
1. Manually run: `bash scripts/regenerate_skills.sh --write`
2. Check for errors (missing `jq`, network timeout, etc.)
3. Commit changes: `git add .github/skills/ && git commit -m "chore(skills): regenerate ..."`
4. Push to verify CI passes

---

## Performance Notes

- **Query live versions:** ~5 seconds
- **Advisory scan (10 packages):** ~30 seconds (1 curl per package)
- **Flutter test suite:** ~1 minute
- **Total CI workflow:** ~3-4 minutes

All jobs run in parallel except `skill-refresh` (depends on `safe-upgrade`).

---

## Related Documentation

- **Agent Specs:** See `.github/agents/` for detailed role definitions
  - `dependency-updater.md` — safe upgrade logic
  - `package-security-scanner.md` — advisory grading
  - `tech-stack-skill-generator.md` — skill file generation

- **Skill Files:** See `.github/skills/*/SKILL.md` for package-specific guidance
  - `flutter-pub-dependency-management/SKILL.md` — how to use pub upgrade
  - `pub-dev-api-usage/SKILL.md` — how to query pub.dev correctly

---

## Key Files

| File | Purpose |
|------|---------|
| `scripts/dependency_health.sh` | Query + categorize + optionally upgrade |
| `scripts/regenerate_skills.sh` | Sync skill files with installed versions |
| `.github/workflows/dependency-maintenance.yml` | CI orchestration |
| `.github/agents/dependency-updater.md` | Upgrade logic definition |
| `.github/agents/package-security-scanner.md` | Advisory scanning definition |
| `.github/agents/tech-stack-skill-generator.md` | Skill generation definition |
| `pubspec.yaml` | Package constraints (ground truth) |
| `pubspec.lock` | Exact installed versions (ground truth) |

---

## Maintenance Schedule

| Task | Frequency | Owner |
|------|-----------|-------|
| Dependency health check | Weekly (Monday 06:00 UTC) | Workflow (automated) |
| Advisory scan | Weekly (Monday 06:00 UTC) | Workflow (automated) |
| Skill file regeneration | Weekly (Monday 06:00 UTC) + after manual upgrades | Workflow + manual script |
| Review & merge upgrade PRs | As needed | Flutter team |
| Major-version bump assessment | As needed (reported by workflow) | Flutter team |

---

**Last Updated:** 2026-04-15  
**Next Review:** 2026-05-15
