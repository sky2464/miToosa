# AgToosa Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versioned per [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Changed
- **BL-21 eng-review follow-up:** `pr-validation.yml` adds `dart format` gate, PR `concurrency`, and a single hoisted `git fetch` for path-filtered guards; repo-wide `dart format` so CI passes; [CLAUDE.md](../CLAUDE.md) CI section synced with BL-21 (manual dependency maintenance).

### Added
- **BL-21 Streamline GitHub Automation and CI/CD**: removed 7 expensive GitHub Actions workflows (`claude.yml`, `claude-code-review.yml`, `daily-health-check.yml`, `dependency-maintenance.yml`, `docs-archival-check.yml`, `prompt-injection-guard.yml`, `web-build.yml`); added unified PR-only `pr-validation.yml` with cached Flutter setup, `dart analyze`, `flutter test`, and path-filtered local guards (`verify_docs_archival.sh`, `check_prompt_injection.sh`). ADR `docs/decisions/remove-expensive-ci-cd.md` (Accepted). Domain dictionary `docs/Context/CONTEXT.md`. **870/870 tests passing.**

_Spec: `docs/archived/spec-BL-21.md` · Test plan: `docs/AgToosa_TestPlan-BL-21.md` · Story: BL-21_

- **S2-01 Aetheric Pulse UI Redesign — partial ship (foundation + 3 screens)**: consolidated Aetheric Pulse design tokens (`lib/theme/design_tokens.dart` `AP` namespace), 11 new shared widgets (`atmosphere`, `stat_pill`, `app_header`, `primary_button`, `ghost_button`, `toggle_switch`, `settings_row`, `skill_radar`, `weekly_bars`, `achievement_card`, `path_constellation`), 26 design assets (8 track icons + 12 avatars + 6 badges in `assets/images/`), and rebuilt Progress + Leaderboard screens with real `playerProgressProvider` wiring. Tracks screen gained a horizontal `StatPill` strip with real streak/energy/stars/XP data. App shell now uses `AppHeader` (sticky avatar ring + brand mark + credits pill) over an animated `Atmosphere` background (radial glow blobs + star field).
- 32 new tests added across `test/theme/design_tokens_test.dart` and `test/widgets/{stat_pill,primary_button,toggle_switch,skill_radar,achievement_card,atmosphere,weekly_bars}_test.dart` — full suite now **721/721 passing**.
- `docs/archived/spec-S2-01.md`, `docs/AgToosa_TestPlan-S2-01.md` (33 test IDs mapped to 14 ACs), `docs/archived/review-S2-01.md` (4-persona audit: Security ✅, Eng 🔴, CEO 🟡, QA 🔴)

_Spec: `docs/archived/spec-S2-01.md` · Review: `docs/archived/review-S2-01.md` · Story: S2-01_

**Shipped with managed exceptions** (user override of review BLOCKED verdict):
- 5 of 10 Must-priority ACs partial/deferred: AC-002 (Tracks polish), AC-003 (Path constellation swap-in), AC-006 (Settings refactor), AC-007 (Game chrome), AC-010 (full provider wiring) — tracked as follow-up stories S2-02/S2-03/S2-04
- `lib/theme/design_system.dart` is 737 lines (over the 500-line rule); pre-existing condition — accepted as documented tech debt
- WCAG 2.1 AA 44pt tap-target violated by `ToggleSwitch`/`GhostButton`/`PrimaryButton` — a11y ticket queued
- 5 `WIP:` commits retained in main history (managed exception per S1-02 precedent)
- 11.3 visual verification on simulator deferred — manual task

- S1-02 analytics backend implementation scaffolding: `firebase_core` + `firebase_analytics` dependencies, `FirebaseAnalyticsSink`, guarded `FIREBASE_ENABLED` provider wiring, conditional Firebase initialization in app bootstrap, and placeholder `lib/firebase_options.dart`
- `docs/ANALYTICS-SETUP.md` manual Firebase/FlutterFire setup runbook
- `docs/AgToosa_TestPlan-S1-02.md` AC-mapped test plan with `@smoke` tags

_Spec: `docs/archived/spec-s1-02.md` · Story: S1-02_

- S1-01 staging deployment & QA gate: conditional Firebase deploy step in `.github/workflows/web-build.yml` (skips gracefully without `FIREBASE_TOKEN`), `scripts/deploy-staging.sh` build+deploy wrapper, `docs/STAGING-SETUP.md` step-by-step Firebase CLI setup runbook, and `docs/RELEASE-GATES.md` Sprint 1 Gate Log row pre-populated. CI passes on all branches; auto-deploys to `hosting:mitoosa-2121b` on main once secret is present.

_Spec: `docs/archived/spec-S1-01.md` · Story: S1-01_

### Changed
- Archived `TASKS.md` (root) and `docs/plan.md` — both superseded by `docs/Master-Plan.md` as project source of truth
- Updated `GEMINI.md` with full AgToosa command table, corrected file paths, and consistent style (no emoji headers) — now consistent with `CLAUDE.md` and `AGENTS.md`
- Removed 2 stale duplicate "AgToosa — Claude Code Instructions" blocks from `CLAUDE.md` (both referenced Linear; canonical block referencing `Master-Plan.md` retained)

### Removed
- `docs/firebase.md` — empty file (0 bytes), no content

_Spec: `docs/archived/spec-cleanup-001.md` · Review: `docs/archived/review-cleanup-001.md` · Story: S1-05_

---

## [2.4.0] — 2026-05-14

### Added
- `/agtoosa-task` command (`Docs/AgToosa_Task.md`): lightweight Linear issue capture for bugs, chores, spikes, and fixes without a full spec cycle; includes type-specific DoD checklists and Discovery Triage origin tracking
- Linear Issue Standard anatomy: canonical title format `[Type]: [description]`, required description sections (Context, Scope, ACs, DoD, Related), Epic→Story→Task hierarchy, Phase Comment Protocol, and Discovery Triage Protocol — all documented in `Docs/AgToosa_Agent.md`
- Epic creation in `/agtoosa-init`: agent creates Linear Epic issues with correct labels/status and records IDs in `Docs/Master-Plan.md`
- Story creation with T-shirt sizing and cycle enrollment in `/agtoosa-spec`: agent creates a Linear Story issue (parent: Epic), records estimate, and enrolls in the active cycle
- Task sub-issue creation in `/agtoosa-build`: agent creates Linear Task issues per build task; transitions Story to `In Progress`; posts "Build 🏗️ Started" phase comment
- Discovery Triage Protocol in `/agtoosa-build`: classify out-of-scope findings, size them, and route to create-issue / expand-scope / ignore
- Status transition protocol: Story moves `Todo → In Progress → In Review → Done` at Build/Review/Ship boundaries; rollback resets to `In Review`
- Phase progress comments on Linear Story issues at every transition: Spec ✅ Approved, Build 🏗️ Started, Task 🟢 N/M, Review 🔍 Started/verdict, Ship 🚀/Rollback 🔙
- Rich `Docs/Master-Plan.md` template: 8-section structured document (Project Charter, Epics, Active Cycle, Active Tasks, Backlog, Blocked, Completed This Cycle, Update Log)

---

## [2.3.0] — 2026-04-27

### Added
- Platform-native command files for Claude Code: `.claude/commands/` (8 slash commands — init, spec, build, qa, review, ship, revert, help), `.claude/settings.json` (Stop / PreToolUse / PostToolUse hooks), `.claude/skills/agtoosa-review.md`
- Platform-native rule files for Cursor: `.cursor/rules/` (7 MDX files — core, spec, build, qa, review, ship, revert)
- Platform-native command files for Gemini CLI: `.gemini/commands/` (8 TOML files)
- Platform-native rule files for Windsurf: `.windsurf/rules/` (7 MD files)
- Platform-native rule files for Roo: `.roo/rules/` (7 MD files)
- Platform-native prompt files for GitHub Copilot: `.github/prompts/` (8 prompt files) and `.github/agents/agtoosa.agent.md`
- Generator expansion: `lib/generate.sh` stages all new platform file sets into `ship/`; `lib/install.sh` installs them into the target project
- `lib/config.sh` — 7 new file-list arrays (`WINDSURF_RULE_FILES`, `ROO_RULE_FILES`, `GEMINI_COMMAND_FILES`, `COPILOT_PROMPT_FILES`, `COPILOT_AGENT_FILES`, `CLAUDE_HOOK_FILES`, `CLAUDE_SKILL_FILES`) and expanded `OPTIONAL_TEMPLATE_FILES`
- `merge_settings_json()` in `lib/copy.sh` — deep-merges AgToosa hooks into an existing `.claude/settings.json` without touching user settings, deduplicating by command string
- 48-test bats suite (up from ~15 at v2.2.0): coverage for all per-platform copy paths, `.claude/settings.json` hook deduplication, dry-run display, `inject_version`, `version_lt`, `backup_file`, `copy_platform_file`, and `merge_platform_file`

### Fixed
- `print_template_files()` no longer emits duplicate paths — removed redundant per-platform arrays already covered by `OPTIONAL_TEMPLATE_FILES`; CI template validation now passes (DEV-160)
- `AGTOOSA_VERSION` correctly set to `2.3.0` (regression from `2.2.0` → `2.1.1` in post-release commit) (DEV-161)

---

## [2.2.0] — 2026-04-27

### Added
- Smart merge/append for platform entry-point files (DEV-156): `inject_version()` wraps content in AgToosa START/END delimiters; `merge_platform_file()` handles 4 cases — new file, in-place block update, old-format migration, and append-to-user-file
- `.bak` backup creation and "✅ (up to date)" no-skip messaging for `merge_platform_file` (DEV-157)
- `/agtoosa-qa` slash command and `AgToosa_QA.md` workflow file
- Sub-command architecture across all four main AgToosa commands (`/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-review`, `/agtoosa-ship`)
- Gemini CLI / Jules platform support (`AGENTS.md`, `template/AGENTS.md`, `GEMINI.md`)
- OpenCode platform support (`template/OPENCODE.md`)
- `lib/config.sh` — extracted file-list arrays and `print_usage` / `print_template_files` helpers
- `lib/version.sh` — extracted `inject_version`, `extract_version`, and `version_lt` helpers
- CI workflow updates: shellcheck action version bump, non-portable `grep -P` fix (DEV-114)

### Fixed
- 12 generator bugs (DEV-128–139): template pollution, dotfile copy, version badge, security versions, and related issues
- Consistency fixes across README phase clarity, ship revert wording, and platform file alignment (DEV-124–126)
- `/agtoosa-build` test sub-command scope and removed broken TDD guard external link (DEV-118–119)
- Replaced bare `/plan` `/build` `/test` `/review` with `/agtoosa-*` throughout `SECURITY.md` (DEV-116)
- Defined canonical approval and review artifacts for ship readiness gate (DEV-113)
- Bug report template updated to reference `--version` flag correctly

### Changed
- ~20% token reduction across all workflow markdown files (verbosity pass)
- Linear set as canonical source of truth for all project tracking
- `Master-Plan.md` updated to reflect Linear project state and backlog management

---

## [2.1.0] — 2026-04-01

### Added
- Initial AgToosa framework: `agtoosa.sh` interactive generator
- Core workflow files: `AgToosa_Agent.md`, `AgToosa_Spec.md`, `AgToosa_Build.md`, `AgToosa_Review.md`, `AgToosa_Ship.md`, `AgToosa_Init.md`
- Platform entry points: `CLAUDE.md`, `.cursorrules`, `.windsurfrules`, `.github/copilot-instructions.md`, `AGENTS.md`
- `--force`, `--dry-run`, `--version`, `--help` flags
- `install.sh` deprecated stub directing users to `agtoosa.sh`
