# Plan: Dependency & Skill Maintenance System

**Spec:** [docs/spec-dependency-skill-maintenance-v1.md](spec-dependency-skill-maintenance-v1.md)  
**Date:** 2026-04-15  
**Status:** Archived

**Implementation note:** This plan is archived after ship and kept only as historical execution context.

---

## Dependency Graph

```
pubspec.yaml / pubspec.lock  (ground truth — read-only, already exists)
        │
        ├── scripts/dependency_health.sh    ← reads live flutter pub outdated
        │         │
        │         └── scripts/regenerate_skills.sh  ← reads pubspec.lock
        │
        ├── .github/agents/dependency-updater.md
        ├── .github/agents/package-security-scanner.md
        ├── .github/agents/tech-stack-skill-generator.md
        │
        ├── .github/skills/flutter-pub-dependency-management/SKILL.md
        ├── .github/skills/pub-dev-api-usage/SKILL.md
        │
        └── .github/workflows/dependency-maintenance.yml  ← orchestrates all of above
                  │
                  └── .github/copilot-instructions.md  ← registers new agents/skills
```

All foundational files were created in the spec phase. The remaining work is **wiring, verification, and hardening**.

---

## Implementation Order

Build from bottom to top — verify each layer before wiring it to the next.

---

## Tasks

### Phase 1 — Verify scripts locally

- [x] **Task 1: Smoke-test `dependency_health.sh` (report mode)**
  - Acceptance: `bash scripts/dependency_health.sh` exits 0 and prints the `flutter pub outdated` table
  - Verify: `bash scripts/dependency_health.sh 2>&1 | grep "=== Done ==="`
  - Files: `scripts/dependency_health.sh` (fix only if failing)

- [x] **Task 2: Smoke-test `dependency_health.sh --full` (advisory scan)**
  - Acceptance: script queries pub.dev for each direct dep and prints per-package status; exits 0 if no HIGH/CRITICAL advisory
  - Verify: `bash scripts/dependency_health.sh --full 2>&1 | grep "=== Done ==="`
  - Files: `scripts/dependency_health.sh`

- [x] **Task 3: Smoke-test `regenerate_skills.sh` (check mode)**
  - Acceptance: prints MISSING/STALE/OK per direct dependency; exits 0
  - Verify: `bash scripts/regenerate_skills.sh 2>&1 | grep "=== Done ==="`
  - Files: `scripts/regenerate_skills.sh`

- [x] **Task 4: Run `regenerate_skills.sh --write`**
  - Acceptance: creates `.github/skills/<package>-usage/SKILL.md` for every direct dependency that lacks one; existing skills not overwritten destructively
  - Verify: `ls .github/skills/ | grep -usage` shows new directories
  - Files: `.github/skills/*/SKILL.md` (generated)

---

### Phase 2 — Apply the current safe upgrades

- [x] **Task 5: Run `--auto` to apply safe upgrades**
  - Acceptance: `flutter pub upgrade` applied, `dart analyze` green, `flutter test` green, `pubspec.lock` updated
  - Verify: `bash scripts/dependency_health.sh --auto` exits 0; `git diff pubspec.lock` shows version bumps
  - Files: `pubspec.lock`
  - Packages: `go_router 17.1.0→17.2.1`, `path_provider_android 2.2.23→2.3.1`, `vm_service 15.0.2→15.1.0`

- [x] **Task 6: Commit safe upgrades**
  - Acceptance: `git log --oneline -1` shows `chore(deps): upgrade patch/minor dependencies`
  - Verify: `git status` is clean after commit
  - Files: `pubspec.lock`

---

### Phase 3 — Document major-version bumps

- [x] **Task 7: Fetch `share_plus` changelog for 10.1.4 → 13.0.0**
  - Acceptance: breaking changes extracted from `https://pub.dev/packages/share_plus/changelog` and recorded in a GitHub issue or PR description draft
  - Verify: file `docs/major-bump-share_plus.md` exists with extracted changelog content
  - Files: `docs/major-bump-share_plus.md` (new)

- [x] **Task 8: Assess other major bumps (`vector_math`, `meta`, `test`, `dart_style`)**
  - Acceptance: for each, determine if it's a transitive dep only (no direct call sites in `lib/`) — if so, note it as lower priority
  - Verify: `grep -r "vector_math\|dart_style" lib/ test/` returns nothing for these (transitive only)
  - Files: no code changes; update the major-bump doc

---

### Phase 4 — CI wiring

- [x] **Task 9: Validate the workflow YAML syntax**
  - Acceptance: `actionlint` or `yaml` lint passes on `.github/workflows/dependency-maintenance.yml`
  - Verify: `cat .github/workflows/dependency-maintenance.yml | python3 -c "import sys,yaml; yaml.safe_load(sys.stdin)"` exits 0
  - Files: `.github/workflows/dependency-maintenance.yml` (fix only if invalid)

- [x] **Task 10: Push and confirm CI job appears in GitHub Actions**
  - Acceptance: workflow appears in the Actions tab; manual `workflow_dispatch` trigger runs without YAML errors
  - Verify: `gh workflow list` shows `Dependency Maintenance`
  - Files: none (push existing)

---

### Phase 5 — Register and document

- [x] **Task 11: Verify `copilot-instructions.md` section is correct**
  - Acceptance: `grep -n "dependency-updater" .github/copilot-instructions.md` returns a match; the three agents and two scripts are listed
  - Verify: `tail -40 .github/copilot-instructions.md` shows the new section
  - Files: `.github/copilot-instructions.md` (already updated; confirm only)

---

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| `flutter pub upgrade` breaks a test | Script auto-reverts `pubspec.lock` on failure; nothing is committed |
| pub.dev API is slow or down | `--max-time 10` on every curl; missing response is a WARN not a FAIL (except for advisory exit) |
| `share_plus` 13.0.0 has many breaking changes | Task 7 explicitly fetches the changelog before any upgrade attempt; major bumps are never auto-applied |
| CI pushes conflict with human PRs | Safe-upgrade commit is squashable and carries `[automated]` in the message |
| `jq` not installed locally | Scripts emit a clear message and skip the advisory step gracefully |

---

## Verification Checkpoint (after all tasks)

```bash
# 1. Full health check
bash scripts/dependency_health.sh --full

# 2. Skills are current
bash scripts/regenerate_skills.sh

# 3. Tests still green
flutter test

# 4. Analysis clean
dart analyze

# 5. CI workflow is valid YAML
python3 -c "import sys,yaml; yaml.safe_load(open('.github/workflows/dependency-maintenance.yml'))"
```

All five must exit 0 before the work is considered done.
