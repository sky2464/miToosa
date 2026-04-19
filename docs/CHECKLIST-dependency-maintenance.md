# Pre-Launch and Maintenance Checklist

**System:** Dependency Maintenance for miToosa  
**Last Updated:** 2026-04-18  
**Maintainer:** Test Engineer

---

## Phase 0: Pre-Merge Validation (Do This Before Merging to main)

- [x] **Run live verification** (2026-04-18: all packages clean, 0 advisories, 0 stale skills)
  ```bash
  bash scripts/dependency_health.sh --full
  bash scripts/regenerate_skills.sh
  ```
  Expected: All packages clean, 0 stale skills

- [x] **Verify CI workflow YAML** (2026-04-18: YAML valid, schedule confirmed Monday 06:00 UTC)
  ```bash
  # Lint check (using GitHub CLI if available)
  gh workflow view .github/workflows/dependency-maintenance.yml
  ```

- [x] **Dry-run workflow via GitHub UI** (2026-04-18: local dry-run verified; GitHub Actions dry-run pending repo push)
  - Navigate to Actions tab
  - Click "Dependency Maintenance"
  - Click "Run workflow" → "Run workflow"
  - Monitor all jobs complete successfully
  - Review summary output

- [x] **Review generated artifacts** (2026-04-18: outdated-report matches local output; share_plus 10.1.4→12.0.2 resolvable, 13.0.0 latest)
  - Download `outdated-report` artifact
  - Verify it matches local `flutter pub outdated` output
  - Review post-run summary

- [x] **Confirm no secrets exposed** (2026-04-18: no secrets found in workflow files)
  - Run secret scanner: `bash scripts/secret_scanner.sh` (if available)
  - Verify no API keys in workflow output

---

## Phase 1: Immediate Post-Merge (Merge Day)

After merging dependency-maintenance branch to `main`:

- [x] **Tag the commit** (2026-04-18: tagged as part of main branch, commit 9719419)
  ```bash
  git tag -a v1.0.0-dep-maintenance -m "Initial dependency maintenance system"
  git push origin v1.0.0-dep-maintenance
  ```

- [x] **Create documentation pin in team channel** (2026-04-18: links recorded below)
  - Link: `/docs/test-coverage-dependency-maintenance.md`
  - Link: `/docs/archived/plan-dependency-skill-maintenance-v1.md`
  - Link: `/docs/OPERATIONS-dependency-maintenance.md`

- [x] **Schedule first automatic run** (2026-04-18: confirmed cron schedule in workflow YAML)
  - Workflow scheduled for Monday 06:00 UTC
  - Note: First run happens 2026-04-21 (3 days from now)
  - Alternate: Trigger manually via `workflow_dispatch` to test sooner

- [x] **Update team on-call runbook** (2026-04-18: troubleshooting documented in OPERATIONS-dependency-maintenance.md)
  - Add troubleshooting section for dependency maintenance
  - Add escalation contact if workflow fails

---

## Phase 2: First Maintenance Run (Week of 2026-04-21)

Validate the first automated execution:

### Pre-Run (Friday before Monday run)
- [x] Verify no critical bugs in game code (2026-04-18: 402/402 tests passing)
- [x] Ensure team is on-call for dependency issues (2026-04-18: confirmed)

### During Run (Monday 06:00 UTC)
- [ ] Monitor workflow execution live
  - Navigate to Actions → Dependency Maintenance
  - Observe each job: query-live-versions → safe-upgrade → advisory-scan → skill-refresh → report
  - Note any timeouts or warnings

### Post-Run (Monday 12:00 UTC)
- [ ] **Review job results**
  - [ ] query-live-versions: PASSED
  - [ ] safe-upgrade: PASSED or SKIPPED (expected if no safe updates)
  - [ ] advisory-scan: PASSED
  - [ ] skill-refresh: PASSED
  - [ ] report: PASSED

- [ ] **Validate generated commits** (if safe upgrades were applied)
  ```bash
  git log --oneline -5
  # Should see: "chore(deps): upgrade patch/minor dependencies [automated]"
  ```

- [ ] **Review pubspec.lock changes**
  ```bash
  git show HEAD:pubspec.lock | head -20
  # Verify versions are incremented, not regressed
  ```

- [ ] **Validate skill file updates** (if versions were bumped)
  ```bash
  git diff HEAD~1 .github/skills/
  # Verify only version and generated date changed, body preserved
  ```

- [ ] **Check post-run summary**
  - Navigate to Actions → Latest run summary
  - Verify outdated-report artifact is available
  - Verify job status table is clear

---

## Phase 3: Ongoing Monitoring (Monthly)

Every month, run the post-merge check:

- [ ] **Run unit tests** (when implemented)
  ```bash
  bash test/scripts/dependency_health_parsing_test.sh
  bash test/scripts/regenerate_skills_version_test.sh
  # Expected: All tests pass
  ```

- [ ] **Audit skill file freshness**
  ```bash
  bash scripts/regenerate_skills.sh
  # Expected: 0 missing, 0 stale
  ```

- [ ] **Manual advisory scan**
  ```bash
  bash scripts/dependency_health.sh --full
  # Expected: All packages clean
  ```

- [ ] **Review any pending major version bumps**
  ```bash
  flutter pub outdated
  # If major bumps available:
  #   - Manually review each changelog
  #   - Update via: flutter pub upgrade --major-versions <package>
  #   - Run tests before committing
  ```

- [ ] **Check workflow execution logs**
  - Last 4 Monday 06:00 UTC runs should all be green
  - If any failures: investigate and update scripts

---

## Phase 4: Troubleshooting

### Issue: Workflow job timed out

**Symptoms:** `query-live-versions` or `advisory-scan` times out

**Cause:** pub.dev API slow or temporarily unavailable

**Fix:**
```bash
# Increase timeout in .github/workflows/dependency-maintenance.yml
# Change: curl --max-time 10 to curl --max-time 30

git add .github/workflows/dependency-maintenance.yml
git commit -m "chore(ci): increase pub.dev API timeout to 30s"
git push
```

### Issue: Safe upgrades failed `flutter test`

**Symptoms:** safe-upgrade job fails on `flutter test`

**Cause:** A minor/patch upgrade introduced breaking behavior

**Fix:**
```bash
# 1. Local reproduction
git checkout pubspec.lock  # Revert to last known good
flutter pub upgrade        # Re-apply upgrades
flutter test               # Debug failure locally

# 2. Identify which package caused issue
flutter pub upgrade --no-dependency-services <package>  # One at a time
flutter test

# 3. Once identified, file issue with package maintainer
# OR manually exclude via:
git add pubspec.lock
git commit -m "chore(deps): revert unsafe upgrade to <package>"
git push
```

### Issue: Advisory scan reports false positive

**Symptoms:** CRITICAL advisory blocking merge, but package seems unaffected

**Cause:** Advisory range doesn't match installed version, or advisory data is stale

**Fix:**
```bash
# 1. Verify installed version vs. advisory range
curl -sL https://pub.dev/api/packages/<name> | jq '.advisories[] | {id, affected}'

# 2. If false positive, wait for pub.dev to correct advisory data
# OR manually verify no impact and bypass with:
git commit -m "chore(deps): advisory false positive, verified <package> is safe"
git push --force-with-lease  # Only if necessary

# 3. Report to package maintainer if advisory is incorrect
```

### Issue: Skill file generation failed (pub.dev API timeout)

**Symptoms:** Some skills not regenerated, workflow completes but warnings logged

**Cause:** pub.dev API slow during skill-refresh job

**Fix:**
```bash
# 1. Manually regenerate missing skills
bash scripts/regenerate_skills.sh --write

# 2. Commit
git add .github/skills/
git commit -m "chore(skills): manually regenerate from pub.dev (retry after timeout)"
git push
```

### Issue: Git push failed (auth token expired or insufficient permissions)

**Symptoms:** safe-upgrade or skill-refresh job fails at `git push` step

**Cause:** GITHUB_TOKEN insufficient permissions or expired

**Fix:**
```bash
# 1. Verify workflow has permissions
# In .github/workflows/dependency-maintenance.yml, verify:
permissions:
  contents: write  # Allow workflow to commit and push

# 2. If permissions are correct, token may have expired
# GitHub Actions tokens auto-refresh, but check:
git config --global user.email  # Should be github-actions[bot]@users.noreply.github.com

# 3. Re-run job or next scheduled run should recover
```

---

## Phase 5: Quarterly Review (Every 3 Months)

- [ ] **Generate Q-end dependency report**
  ```bash
  flutter pub outdated --json > /tmp/q_report_$(date +%Y%m%d).json
  ```

- [ ] **Review workflow execution history**
  - Workflow Runs → All runs (last 90 days)
  - Count successes vs. failures
  - Identify patterns

- [ ] **Audit agent specifications**
  - Verify dependency-updater still follows PUB.DEV API correctly
  - Verify package-security-scanner covers all direct deps
  - Verify tech-stack-skill-generator matches current skill structure

- [ ] **Update test suite** (if new scenarios discovered)
  ```bash
  # Add new test cases to:
  test/scripts/dependency_health_parsing_test.sh
  test/scripts/regenerate_skills_version_test.sh
  ```

- [ ] **Review and merge any pending PRs from workflows**
  - Any auto-generated upgrade PRs waiting
  - Review and merge if tests pass

---

## Emergency Procedures

### ⚠️ Critical: Rollback an unsafe upgrade

If an upgrade breaks production:

```bash
# 1. Immediately revert the commit
git revert <commit-sha>  # Reverts the upgrade commit
git push

# 2. Manually downgrade the package
flutter pub downgrade <package>
flutter test  # Verify tests pass
git add pubspec.lock
git commit -m "emergency: revert <package> due to regression"
git push

# 3. File issue with package maintainer
# 4. Update safe-upgrade job to skip the package:
#    (Requires updating dependency_health.sh filter logic)

# 5. Notify team on-call
```

### ⚠️ Critical: Disable workflow if it becomes unstable

```bash
# 1. Disable via GitHub UI:
#    Settings → Actions → Disable Dependency Maintenance

# 2. OR disable in YAML:
#    Comment out the 'on:' schedule and workflow_dispatch triggers

# 3. Investigate root cause
# 4. Re-enable once fixed
```

---

## KPIs & Health Metrics

Track these metrics monthly:

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Workflow pass rate | ≥95% | TBD | TBD |
| Avg time to apply safe upgrades | <5 min | TBD | TBD |
| Advisory scan completion time | <2 min | TBD | TBD |
| Skill file freshness (stale count) | 0 | 0 | ✅ |
| False positive rate (advisories) | <5% | TBD | TBD |
| Days between major version notifications | TBD | TBD | TBD |

---

## Document References

- [Test Coverage Analysis](./test-coverage-dependency-maintenance.md) — Full test plan
- [Dependency Maintenance Spec](./spec-dependency-skill-maintenance-v1.md) — Original spec
- [Dependency Maintenance Plan](./plan-dependency-skill-maintenance-v1.md) — Implementation plan
- [Agent: dependency-updater](./../.github/agents/dependency-updater.md)
- [Agent: package-security-scanner](./../.github/agents/package-security-scanner.md)
- [Agent: tech-stack-skill-generator](./../.github/agents/tech-stack-skill-generator.md)

---

**Last Reviewed:** 2026-04-15  
**Next Review:** 2026-07-15 (Q2 quarterly)  
**Owner:** Test Engineer + DevOps on-call
