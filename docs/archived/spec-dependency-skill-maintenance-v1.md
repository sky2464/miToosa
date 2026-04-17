# Spec: Autonomous Dependency & Skill Maintenance System

**Status:** Archived

**Date:** 2026-04-15  

**Implementation note:** This spec is archived after ship and retained as historical context for the dependency and skill maintenance system.

---

## Assumptions

State these now. Correct any before approving.

1. Live package data is always fetched at runtime via `flutter pub outdated` or the pub.dev REST API — agent memory of version numbers is **never** used as a source of truth.
2. Skills are Markdown files at `.github/skills/<name>/SKILL.md`; agents at `.github/agents/<name>.md`.
3. `flutter pub upgrade` (minor/patch) and `flutter pub upgrade --major-versions` (semver-breaking) are the upgrade mechanisms.
4. `pubspec.yaml` uses `^` (caret) constraints — upgrading within a caret range is a safe non-breaking operation.
5. Security advisory data comes from pub.dev's Advisories endpoint (`https://pub.dev/api/packages/<name>`) and the Dart security advisory database.
6. The CI workflow runs on GitHub Actions (see `.github/workflows/`).
7. The system does **not** auto-merge major-version upgrades; those are always flagged for human review.

---

## Objective

Build an automated dependency health and knowledge-management system for miToosa that:

- **Always queries live package versions** from `flutter pub outdated` or pub.dev — never from cached memory.
- **Classifies every outdated dependency** as: safe-upgrade, major-version-bump, or security-advisory.
- **Auto-upgrades safe (minor/patch)** dependencies without human intervention.
- **Generates a PR / report** for major-version bumps with a diff of changelogs and breaking changes.
- **Generates or updates Copilot skill files** for the latest version of each key library so agent knowledge stays current.
- **Registers custom sub-agents** (dependency updater, security scanner, skill generator) into `.github/agents/`.
- **Runs on a schedule** (weekly, or on demand via `workflow_dispatch`) in CI.

**Success looks like:** Running `bash scripts/dependency_health.sh` (or triggering the CI job) produces a categorized report, applies safe upgrades automatically, and emits actionable issues/PRs for anything it can't auto-resolve.

---

## Tech Stack (live as of 2026-04-15)

| Package | Pinned | Latest Resolvable | Absolute Latest |
|---|---|---|---|
| go_router | 17.1.0 | 17.2.1 ✅ safe | 17.2.1 |
| share_plus | 10.1.4 | 10.1.4 | **13.0.0** ⚠️ major |
| path_provider_android | 2.2.23 | 2.3.1 ✅ safe | 2.3.1 |
| vm_service | 15.0.2 | 15.1.0 ✅ safe | 15.1.0 |
| vector_math | 2.2.0 | 2.2.0 | **2.3.0** ⚠️ major |
| meta | 1.17.0 | 1.17.0 | **1.18.2** ⚠️ major |
| test | 1.30.0 | 1.30.0 | **1.31.0** ⚠️ major |
| dart_style | 3.1.3 | 3.1.3 | **3.1.8** ⚠️ major |

> Note: this table was produced by `flutter pub outdated` on 2026-04-15. The spec itself does not hard-code versions — the tooling always re-queries at runtime.

---

## Commands

```bash
# Query live dependency status (never uses cached memory)
bash scripts/dependency_health.sh

# Apply only safe (minor/patch) upgrades
flutter pub upgrade

# Interactive review of major-version bumps
flutter pub upgrade --major-versions   # manual step, requires human approval

# Run full analysis including security scan
bash scripts/dependency_health.sh --full

# Regenerate skills for updated packages
bash scripts/regenerate_skills.sh

# CI trigger (all of the above, produces GitHub Actions summary)
gh workflow run dependency-maintenance.yml
```

---

## Project Structure

```
.github/
  agents/
    code-reviewer.md          (existing)
    security-auditor.md       (existing)
    test-engineer.md          (existing)
    dependency-updater.md     ← NEW: applies safe upgrades, opens PRs
    package-security-scanner.md  ← NEW: scans advisories, CVEs
    tech-stack-skill-generator.md  ← NEW: generates skills from pub.dev docs
  skills/
    flutter-pub-dependency-management/
      SKILL.md                ← NEW: canonical how-to for pub upgrade workflows
    pub-dev-api-usage/
      SKILL.md                ← NEW: how to query pub.dev REST API correctly
    (existing skills remain unchanged)
  workflows/
    dependency-maintenance.yml  ← NEW: scheduled CI job
scripts/
  dependency_health.sh        ← NEW: live query + categorised report
  regenerate_skills.sh        ← NEW: fetches latest CHANGELOG and updates skills
docs/
  spec-dependency-skill-maintenance-v1.md  (this file)
  plan-dependency-skill-maintenance-v1.md  (to be created after approval)
```

---

## Component Specifications

### 1. `scripts/dependency_health.sh`

**Purpose:** Single entry point for human and CI use. Always calls `flutter pub outdated` at runtime.

**Behaviour:**

```
Run flutter pub outdated --json
Parse output into three buckets:
  SAFE:     resolvable >= current (minor/patch within caret range)
  MAJOR:    absolute latest > resolvable (caret constraint blocks it)
  ADVISORY: package appears in pub.dev advisory feed

Print summary table.
If --auto flag: run `flutter pub upgrade` for SAFE bucket.
If --full flag: also fetch advisories from pub.dev REST API.
Exit 1 if any ADVISORY is found (blocks CI).
```

**Security:** Never exec user-supplied package names directly. Validate all pub.dev API responses before use. Use `--json` flag only; do not parse free-text terminal output.

---

### 2. `.github/agents/dependency-updater.md`

**Role:** Staff-level Flutter engineer who owns dependency hygiene.

**Capabilities:**
- Run `flutter pub outdated` via terminal to get current live data.
- Apply `flutter pub upgrade` for safe upgrades; commit with `chore: upgrade patch/minor dependencies`.
- For major bumps: fetch the CHANGELOG from `https://pub.dev/packages/<name>/changelog`, extract breaking-change section, and write a summary issue/PR description.
- Never upgrade a package without first running `flutter test` and `dart analyze` to confirm the tree is green.

**Invocation prompt template:**
```
"Run dependency_health.sh, apply all safe upgrades, run tests, and draft a PR description for each major-version bump with extracted breaking changes from the pub.dev changelog."
```

---

### 3. `.github/agents/package-security-scanner.md`

**Role:** Security engineer focused exclusively on supply-chain risk.

**Capabilities:**
- Query `https://pub.dev/api/packages/<name>` for each direct dependency to detect advisories.
- Cross-reference against the Dart vulnerability database (`https://storage.googleapis.com/pub-packages/advisories/`).
- Produce a risk-graded report: CRITICAL / HIGH / MEDIUM / LOW.
- Never skip a package because "it's probably fine" — scan every direct dependency.

**Invocation prompt template:**
```
"Scan all packages in pubspec.yaml against pub.dev advisories. Report any vulnerabilities graded HIGH or above as blocking. Include CVE identifiers where available."
```

---

### 4. `.github/agents/tech-stack-skill-generator.md`

**Role:** Documentation engineer that keeps Copilot skills aligned with the installed package versions.

**Capabilities:**
- Read `pubspec.lock` to determine the **exact installed version** of each package (not pubspec.yaml ranges).
- For each package with a skill file, fetch the pub.dev README and CHANGELOG for that exact version from `https://pub.dev/packages/<name>/versions/<version>`.
- Diff the fetched docs against the existing skill content.
- If the skill is stale (version mismatch), rewrite the "Version & Key API" section with accurate current information.
- If no skill exists for a package, generate a new one from the template.

**Skill generation template:**
```markdown
---
name: <package-name>-usage
description: How to use <package-name> v<version> correctly in this project.
version: <exact version from pubspec.lock>
source: https://pub.dev/packages/<name>/versions/<version>
---

# <package-name> v<version> Usage

## Install
[exact pubspec.yaml entry]

## Key APIs (verified against pub.dev docs for this version)
[fetched from pub.dev, not from memory]

## Common Patterns in miToosa
[project-specific examples]

## Migration Notes
[extracted from CHANGELOG if version changed]
```

**Invocation prompt template:**
```
"Read pubspec.lock for exact versions. For each direct dependency, check if a skill exists and is up to date. Regenerate any stale or missing skills by fetching docs from pub.dev for the exact installed version."
```

---

### 5. `.github/skills/flutter-pub-dependency-management/SKILL.md`

**Purpose:** Canonical reference for any agent performing Flutter dependency work.

**Covers:**
- How to read `flutter pub outdated` output correctly (JSON format preferred).
- The difference between "upgradable" (within caret range) and "resolvable" (with constraint relaxation) and "latest" (absolute).
- When to use `flutter pub upgrade` vs. `flutter pub upgrade --major-versions` vs. manually editing `pubspec.yaml`.
- How to check for pub.dev advisories via the REST API.
- The commit message convention for dependency changes: `chore(deps): upgrade <package> to <version>`.

---

### 6. `.github/skills/pub-dev-api-usage/SKILL.md`

**Purpose:** Teach agents how to query pub.dev correctly without hallucinating endpoints.

**Covers:**
- Verified REST endpoints (fetched from `https://pub.dev/api` — not assumed from memory).
- How to fetch package metadata, changelogs, and advisories.
- Rate limits and caching behaviour.
- How to parse semantic versions from the API response.

---

### 7. `.github/workflows/dependency-maintenance.yml`

**Purpose:** Weekly automated run of the full dependency health pipeline.

**Jobs:**
1. `query-live-versions` — runs `flutter pub outdated --json`, uploads artifact.
2. `safe-upgrade` — applies `flutter pub upgrade`, runs `flutter test` + `dart analyze`, commits if green.
3. `advisory-scan` — hits pub.dev advisory API for each direct dep; fails the job if CRITICAL found.
4. `skill-refresh` — invokes tech-stack-skill-generator agent to update stale skills.
5. `report` — posts a step summary to GitHub Actions with the full categorised report.

**Triggers:** `schedule: cron: '0 6 * * 1'` (every Monday at 06:00 UTC) + `workflow_dispatch`.

---

## Code Style

Follow existing Bash conventions in `scripts/`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Always use flutter pub outdated --json for machine-readable output
RAW=$(flutter pub outdated --json)
SAFE=$(echo "$RAW" | jq '[.packages[] | select(.upgradable != null)]')

echo "=== Safe upgrades ==="
echo "$SAFE" | jq -r '.[] | "\(.package): \(.current.version) → \(.upgradable.version)"'
```

- No hard-coded version strings in scripts.
- All pub.dev API calls use `curl -sL` with explicit timeout (`--max-time 10`).
- Validate JSON responses with `jq` before use.

---

## Testing Strategy

| Layer | What to test | Tool |
|---|---|---|
| Unit | JSON parsing logic in scripts | `bats` (Bash test framework) or a Dart test |
| Integration | `dependency_health.sh` against a real `flutter pub outdated` call | Run in CI with real network |
| Contract | pub.dev API responses match expected shape | Snapshot test with `jq` schema check |
| Smoke | Skill generator produces valid Markdown with correct version string | `grep` / `diff` check |

Run tests:

```bash
# Dart/Flutter tests (unchanged)
flutter test

# Script smoke test
bash scripts/dependency_health.sh --dry-run
```

---

## Security Boundaries

- **Always:** Validate every pub.dev API response shape before using it. Run `dart analyze` after any upgrade.
- **Ask first:** Editing `pubspec.yaml` constraints manually (changes contract for all contributors). Merging a major-version upgrade. Adding a new direct dependency.
- **Never:** Execute package names as shell commands. Commit without passing `flutter test`. Treat agent memory of package versions as authoritative — always re-query.

---

## Success Criteria

1. `flutter pub outdated` output drives all decisions — no version strings appear in agent prompts or script logic.
2. After running `bash scripts/dependency_health.sh --auto`, all "safe" packages in the table above are upgraded and tests remain green.
3. `share_plus 13.0.0` upgrade produces a PR with breaking-change notes extracted from its pub.dev CHANGELOG — not written from memory.
4. The `tech-stack-skill-generator` agent regenerates a skill for `go_router` that references the exact installed version from `pubspec.lock`.
5. CI fails (exit 1) if any direct dependency has a HIGH or CRITICAL advisory.
6. All new agents and skills are discoverable from `.github/copilot-instructions.md`.

---

## Open Questions

1. **Skill format ownership:** Should skill files be auto-committed to `main`, or always go through a PR? (Recommendation: PR for traceability.)
2. **Advisory database freshness:** pub.dev advisories can have latency. Should we also mirror the OSV feed (`https://osv.dev`) as a secondary source?
3. **Major-version automation ceiling:** Is the rule "never auto-merge major versions" firm, or should we auto-merge if a package has no published breaking changes?
4. **copilot-instructions.md update:** New agents/skills must be registered there. Should the skill generator do this automatically, or flag it for human addition?
5. **`bats` dependency:** Adding `bats` to the dev toolchain requires a new dev dependency — confirm before proceeding.
