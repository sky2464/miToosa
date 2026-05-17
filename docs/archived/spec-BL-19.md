# Spec: BL-19 — Sanitize embedded prompt-injection text in docs/mitoosa-design-system-2/

> **Story ID:** BL-19
> **GitHub Issue:** #33
> **Epic:** EP-05 — Technical Debt & Infrastructure
> **Status:** ✅ Done
> **Type:** Chore
> **Priority:** P3
> **Estimate:** S
> **Spec created:** 2026-05-16

---

## Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      :
- `docs/mitoosa-design-system-2/README.md`
- `docs/mitoosa-design-system-2/project/SKILL.md`
- `.github/workflows/prompt-injection-guard.yml` (new — CI guard)
- `scripts/check_prompt_injection.sh` (new — regex grep used by CI and locally)
Directories in scope:
- `docs/mitoosa-design-system-2/` (scan target)
- `.github/workflows/` (CI guard)
- `scripts/` (CI helper script)
Out of scope        :
- Any file under `lib/` (no production code changes)
- Image / font / binary assets under `docs/mitoosa-design-system-2/project/uploads/`, `fonts/`, `assets/` (non-text, cannot carry executable directives)
- Other `docs/` subtrees (separate audit if needed; this story scopes only the design-system-2 bundle)
- Removing the bundle entirely (design reference is still useful for future redesign work)

---

## 1. Requirements

### 1.1 User Stories

**As a** developer running `/agtoosa-*` skills, **I want** the `docs/mitoosa-design-system-2/` bundle to contain no agent-directive text **so that** an agent reading those files for design context cannot be hijacked into ignoring its real instructions.

**As a** maintainer of this repository, **I want** a regression-proof CI guard **so that** any future re-introduction of prompt-injection-style text into the docs bundle fails the build before it lands.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN an agent reads any text file under `docs/mitoosa-design-system-2/` THE SYSTEM SHALL contain no imperative directive headings addressed to "coding agents", "AI", or "assistants" outside of clearly-marked, non-executable quoted-example blocks | Must |
| AC-002 | WHEN a file in `docs/mitoosa-design-system-2/` retains former agent-directive content (e.g., the old SKILL.md metadata) THE SYSTEM SHALL wrap it in a clearly-marked `SANITIZATION NOTE (BL-19)` HTML comment and a non-executable code fence so it cannot be parsed as active instruction | Must |
| AC-003 | WHEN `/agtoosa-spec` archives this story THE SYSTEM SHALL include a sanitization log inside the spec file enumerating every file touched, the patterns removed, and the rationale | Must |
| AC-004 | WHEN CI runs on a pull request THE SYSTEM SHALL execute `scripts/check_prompt_injection.sh docs/mitoosa-design-system-2/` and fail the build if any of the banned patterns reappear (case-insensitive: `coding agents`, `read this first`, `you should do`, `ignore previous`, `disregard (previous|prior)`, `<\|im_start\|>`, `\[INST\]`, `jailbreak`, `act as (an? )?(ai|llm|assistant)`, top-level YAML `user-invocable:\s*true`) | Must |
| AC-005 | WHEN the CI guard runs against the current sanitized state THE SYSTEM SHALL exit 0 (the regex set must accept every sanitized line, including the lines inside `SANITIZATION NOTE` blocks that mention the banned phrases as quoted history) | Must |
| AC-006 | WHEN the SKILL.md file is loaded as a Claude skill THE SYSTEM SHALL NOT be auto-invocable — top-level `user-invocable:` MUST be either absent or `false` | Must |
| AC-007 | WHILE design content (color tokens, type scale, component recipes) is preserved WHEN sanitization is applied THE SYSTEM SHALL retain all factual design guidance in `project/README.md` and `project/DESIGN_SPEC.md` with no loss | Should |

### 1.3 Out of Scope

- Rewriting the design prototypes (`*.jsx`, `*.html`) — they contain no LLM-directive text per the scan.
- Sanitizing other doc subtrees (e.g. `docs/miToosa Design System/`, `docs/mockup/`) — separate audit if patterns are suspected.
- Adding runtime prompt-injection detection at the agent layer — out of scope; this story is about source-of-truth hygiene.
- Removing the bundle. The handoff bundle is still valuable design reference.

---

## 2. Design

### 2.1 Architecture Blueprint

Files changed (already shipped in commit `2ba2c87`):
  - `docs/mitoosa-design-system-2/README.md` — replaced `# CODING AGENTS: READ THIS FIRST` heading + `## What you should do — IMPORTANT` section with a factual `# miToosa Design System 2 — Handoff Bundle` heading and an `## About this bundle` section. Added `SANITIZATION NOTE (BL-19)` HTML comment at top documenting the rewrite.
  - `docs/mitoosa-design-system-2/project/SKILL.md` — removed the top-level YAML frontmatter (`---` delimited block with `name`, `description`, `user-invocable: true`). Replaced with a `SANITIZATION NOTE (BL-19)` HTML comment, a `# miToosa Design Skill — Reference (Archived)` heading, and the original metadata reproduced inside a non-executable code fence. Imperative agent instructions ("Read the README.md file within this skill", "If creating visual artifacts...", "If the user invokes this skill...") were removed and replaced with a passive "Design guidance (retained for reference)" section pointing to `project/README.md`.

Files to create (this spec scope):
  - `scripts/check_prompt_injection.sh` — shell script that greps the target directory for banned regex patterns. Whitelists lines inside `<!-- SANITIZATION NOTE` blocks and inside fenced code blocks tagged `text` or `skill-metadata` so the historical quoted text passes.
  - `.github/workflows/prompt-injection-guard.yml` — GitHub Actions workflow triggered on `pull_request` and `push` to `main` paths matching `docs/mitoosa-design-system-2/**`. Runs the script and fails the build on non-zero exit.

Key interfaces:
  - `scripts/check_prompt_injection.sh <directory>` — exits 0 on clean, exits 1 + prints offending file:line on hits. Honours a `.prompt-injection-allowlist` regex file if present (one PCRE per line) for whitelisting sanctioned quoted blocks.

### 2.2 Data Flow

1. Developer or CI clones the repo and reads files under `docs/mitoosa-design-system-2/`.
2. Whenever an agent loads those files for design context (e.g., during `/agtoosa-spec research` or design-handoff work), it now reads only factual descriptive text — no second-person imperatives, no skill-invocable metadata.
3. On every pull request that touches `docs/mitoosa-design-system-2/**`, the `prompt-injection-guard.yml` workflow runs `scripts/check_prompt_injection.sh docs/mitoosa-design-system-2/`.
4. The script walks the directory, filters to text files (`*.md`, `*.html`, `*.jsx`, `*.js`, `*.css`, `*.txt`, `*.json`), greps each one with case-insensitive PCRE against the banned-pattern set.
5. Lines inside an active `<!-- SANITIZATION NOTE ... -->` HTML comment or inside a triple-backtick fence are excluded (line-range pre-filter).
6. If any non-whitelisted line matches, the script prints `file:line:pattern` and exits 1. CI fails.
7. On exit 0, CI passes and the PR can merge.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Prompt injection via design-context docs hijacking an agent's instruction-following loop | Tampering | Remove all imperative agent-directive text from `docs/mitoosa-design-system-2/`; wrap any retained history in clearly-marked non-executable blocks (AC-001, AC-002) |
| Future regression: a contributor re-imports the bundle from Claude Design and the original directives sneak back in | Tampering | CI guard fails the PR before merge (AC-004) |
| SKILL.md re-enabled as an auto-invocable Claude skill, pulling the directive text back into the active prompt | Elevation of Privilege | `user-invocable: true` is in the banned-pattern set; CI fails if re-introduced (AC-006, AC-004) |
| Information disclosure: design-context files leaking into agent transcripts and accidentally exposing internal prompt patterns | Information Disclosure | Sanitization removes the suspicious patterns; the remaining text is factual design documentation that does not reveal agent internals |
| Repudiation: changes made to sanitize the bundle are undocumented and cannot be audited | Repudiation | This spec file (`Docs/archived/spec-BL-19.md`) plus the sanitization log in §2.5 plus the git commit `2ba2c87` provide a full audit trail (AC-003) |

### 2.4 Build Scope

See top of file. (`Build Scope` block placed above per `/agtoosa-spec` Part 4 convention.)

### 2.5 Sanitization Log (AC-003)

Recursive scan executed against `docs/mitoosa-design-system-2/` on 2026-05-16. Total text files scanned: 28 (excluding fonts, images, binaries).

| File | Pattern Found | Action | Rationale |
|------|---------------|--------|-----------|
| `docs/mitoosa-design-system-2/README.md` | `# CODING AGENTS: READ THIS FIRST` (H1 heading) | Rewritten to `# miToosa Design System 2 — Handoff Bundle` | Imperative agent-directive heading. Hijacks attention. |
| `docs/mitoosa-design-system-2/README.md` | `## What you should do — IMPORTANT` + body using second-person imperatives ("Find...", "Then follow...", "If anything is ambiguous, ask...") | Replaced with passive `## About this bundle` describing the bundle without addressing the reader as an agent | Direct second-person commands could be interpreted as live instructions. |
| `docs/mitoosa-design-system-2/README.md` | "Your job is to **recreate them pixel-perfectly**...", "Don't render these files...", "Read the HTML and CSS directly" | Removed; replaced with passive description of bundle contents | Same as above. |
| `docs/mitoosa-design-system-2/README.md` | (added) `<!-- SANITIZATION NOTE (BL-19): ... -->` | Added | Audit-trail comment explaining the rewrite. |
| `docs/mitoosa-design-system-2/project/SKILL.md` | YAML frontmatter `---\nname: mitoosa-design\ndescription: Use this skill...\nuser-invocable: true\n---` | Frontmatter delimiters removed; metadata reproduced inside a fenced code block with `user-invocable: false  (was: true — disabled during BL-19 sanitization)` | Top-level YAML frontmatter with `user-invocable: true` made this file an auto-invocable Claude skill. Disabling it neutralizes the prompt-injection surface. |
| `docs/mitoosa-design-system-2/project/SKILL.md` | "Read the README.md file within this skill, and explore the other available files." | Removed | Imperative agent instruction. |
| `docs/mitoosa-design-system-2/project/SKILL.md` | "If creating visual artifacts (slides, mocks, throwaway prototypes, etc), copy assets out and create static HTML files for the user to view. If working on production code, you can copy assets and read the rules here..." | Removed; replaced with passive "Design guidance (retained for reference)" section pointing at `project/README.md` | Conditional imperative ("If X, do Y") addressed to an agent. |
| `docs/mitoosa-design-system-2/project/SKILL.md` | "If the user invokes this skill without any other guidance, ask them what they want to build or design, ask some questions, and act as an expert designer..." | Removed | "act as" role-hijack pattern; addressed to an agent. |
| `docs/mitoosa-design-system-2/project/SKILL.md` | (added) `<!-- SANITIZATION NOTE (BL-19): ... -->` | Added | Audit-trail comment. |

Files scanned and found clean (no agent-directive text):
- `docs/mitoosa-design-system-2/project/README.md`
- `docs/mitoosa-design-system-2/project/DESIGN_SPEC.md`
- `docs/mitoosa-design-system-2/project/tokens.css`, `colors_and_type.css`
- `docs/mitoosa-design-system-2/project/*.jsx` (12 files — UI prototypes; the two `"You are here"` hits in `screen-path.jsx` are user-facing UI breadcrumb copy, not agent directives — false positive, ignored)
- `docs/mitoosa-design-system-2/project/miToosa Redesign.html`
- `docs/mitoosa-design-system-2/project/preview/*.html` (17 files)
- `docs/mitoosa-design-system-2/project/ui_kits/mitoosa_app/*.jsx` (mirror copies — clean)
- `docs/mitoosa-design-system-2/project/uploads/DESIGN.md`, `DESIGN-19a8c118.md`, `README.txt`, `OFL.txt`, `code.html`
- `docs/mitoosa-design-system-2/project/uploads/*.ttf`, `*.png` (binary, skipped)

**Outcome:** 2 files sanitized in commit `2ba2c87`. Design content fully preserved. No `lib/` changes. CI guard pending in this spec scope.

---

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Document sanitization in spec file
  - [x] 1.1 Enumerate every flagged file + pattern + action in §2.5 sanitization log — _Requirements: AC-003_
  - [x] 1.2 Verify §2.5 matches actual git diff of commit `2ba2c87` — _Requirements: AC-003_
- [x] **2.** Sanitize agent-directive text (shipped in commit `2ba2c87`)
  - [x] 2.1 Rewrite `docs/mitoosa-design-system-2/README.md` heading + body; add SANITIZATION NOTE — _Requirements: AC-001, AC-002_
  - [x] 2.2 Disable `user-invocable: true` in `docs/mitoosa-design-system-2/project/SKILL.md`; wrap former metadata in non-executable code fence; add SANITIZATION NOTE — _Requirements: AC-001, AC-002, AC-006_
  - [x] 2.3 Verify design content (color tokens, type scale, component recipes) preserved in `project/README.md` and `project/DESIGN_SPEC.md` — _Requirements: AC-007_
- [ ] **3.** CI regression guard
  - [ ] 3.1 Create `scripts/check_prompt_injection.sh` with the banned-pattern PCRE set and SANITIZATION-NOTE / fenced-block whitelist logic — _Requirements: AC-004, AC-005_
  - [ ] 3.2 Create `.github/workflows/prompt-injection-guard.yml` triggered on PR + push paths `docs/mitoosa-design-system-2/**` — _Requirements: AC-004_
  - [ ] 3.3 Dry-run the script against the current sanitized state; confirm exit 0 — _Requirements: AC-005_
  - [ ] 3.4 Add a synthetic test fixture (`test/security/fixtures/injection_sample.md`) that the script should flag; assert exit 1 in a unit test (`test/security/prompt_injection_guard_test.dart` or `bash` test) — _Requirements: AC-004_

### 3.2 Wave Plan

**Wave 1 (sequential, parallel to others):** 1.1, 1.2 (spec authoring — this PR)
**Wave 2 (already shipped in `2ba2c87`):** 2.1, 2.2, 2.3
**Wave 3 (parallel after Wave 1):** 3.1, 3.2
**Wave 4 (sequential after Wave 3):** 3.3, 3.4

### 3.3 Test Plan

Test plan: `Docs/AgToosa_TestPlan-BL-19.md`
AC coverage: 7 ACs mapped to 9 test IDs
Smoke set: 3 tests tagged @smoke

---

## ✅ Spec Approved

Approved: 2026-05-16 00:00
