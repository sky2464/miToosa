# Project Coding Standards

## Testing
- Write tests before code (TDD)
- For bugs: write a failing test first, then fix (Prove-It pattern)
- Test hierarchy: unit > integration > e2e (use the lowest level that captures the behavior)
- Run `npm test` after every change

## Code Quality
- Review across five axes: correctness, readability, architecture, security, performance
- Every PR must pass: lint, type check, tests, build
- No secrets in code or version control

## Implementation
- Build in small, verifiable increments
- Each increment: implement → test → verify → commit
- Never mix formatting changes with behavior changes

## Documentation closeout
- After `/build`, `/test`, `/review`, and `/code-simplify`, run a docs sync pass.
- Treat the docs sync pass as the source of truth for checklist state.
- Mark completed checklist items as `[x]` when code and verification confirm they are done.
- If `/test` or `/review` discovers missing work or regressions, unmark the affected items or add new unchecked follow-up items immediately.
- Reconcile the active `docs/spec-*.md` and `docs/plan-*.md` files with the implemented code and verified behavior.
- If a plan is intentionally stale, add a short note explaining the drift instead of leaving a silent mismatch.
- When a spec has shipped, mark the spec and plan as archived, move the finished files into `docs/archived/`, and keep the historical content as read-only reference. Leave active specs and plans in the `docs/` root. Validate the archive state with `bash scripts/verify_docs_archival.sh` so completed docs cannot linger in the root.

## Boundaries
- Always: Run tests before commits, validate user input
- Ask first: Database schema changes, new dependencies
- Never: Commit secrets, remove failing tests, skip verification

## Engineering Skills & Agents
- Use the agents in `.github/agents/` for specialized tasks:
  - `@code-reviewer`: For high-level architectural and quality reviews.
  - `@test-engineer`: For test strategy and coverage analysis.
  - `@security-auditor`: For vulnerability checks and hardening.
- Reference skills in `.github/skills/` for detailed step-by-step workflows.

# Agent Skills

**Production-grade engineering skills for AI coding agents.**

Skills encode the workflows, quality gates, and best practices that senior engineers use when building software. These ones are packaged so AI agents follow them consistently across every phase of development.

```
  DEFINE          PLAN           BUILD          VERIFY         REVIEW          SHIP
 ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐
 │ Idea │ ───▶ │ Spec │ ───▶ │ Code │ ───▶ │ Test │ ───▶ │  QA  │ ───▶ │  Go  │
 │Refine│      │  PRD │      │ Impl │      │Debug │      │ Gate │      │ Live │
 └──────┘      └──────┘      └──────┘      └──────┘      └──────┘      └──────┘
  /spec          /plan          /build        /test         /review       /ship
```

---

## Commands

7 slash commands that map to the development lifecycle. Each one activates the right skills automatically.

| What you're doing | Command | Key principle |
|-------------------|---------|---------------|
| Define what to build | `/spec` | Spec before code |
| Plan how to build it | `/plan` | Small, atomic tasks |
| Build incrementally | `/build` | One slice at a time |
| Prove it works | `/test` | Tests are proof |
| Review before merge | `/review` | Improve code health |
| Simplify the code | `/code-simplify` | Clarity over cleverness |
| Ship to production | `/ship` | Faster is safer |

Skills also activate automatically based on what you're doing — designing an API triggers `api-and-interface-design`, building UI triggers `frontend-ui-engineering`, and so on.

## Agent Workflows and Invocation

- **Purpose:** Use Copilot agents to automate focused engineering tasks (research, planning, reviews, testing, security). Agents encapsulate domain knowledge and can be invoked by the slash commands above or called directly for finer control.

- **Primary agents available:** `code-reviewer`, `test-engineer`, `security-auditor`, `Explore`, `planning-and-task-breakdown`, `incremental-implementation`, `code-simplification`, `spec-driven-development`, `shipping-and-launch`.

- **Slash-command → Agent mapping (recommended):**
  - `/spec`: `Explore` (thorough) to gather context, then `spec-driven-development` to draft a spec.
  - `/plan`: `planning-and-task-breakdown` to produce ordered, testable steps.
  - `/build`: `incremental-implementation` for small, verifiable code slices.
  - `/test`: `test-engineer` to design or run targeted tests.
  - `/review`: `code-reviewer` for multi-axis reviews (correctness, readability, security, performance).
  - `/code-simplify`: `code-simplification` to refactor for clarity.
  - `/ship`: `shipping-and-launch` to prepare deployment and rollout plans.

- **Direct agent invocation (examples):**

  - Invoke `code-reviewer` to review a PR:

    runSubagent({
      prompt: "Review PR #123 for readability, security, and breaking changes; recommend only essential edits.",
      description: "PR review",
      agentName: "code-reviewer"
    })

  - Use `Explore` to scan the repo for API endpoints (quick/medium/thorough):

    runSubagent({
      prompt: "Find all REST/GraphQL API endpoints in the repo and list their handler files.",
      description: "Find API endpoints",
      agentName: "Explore"
    })

  - Ask `test-engineer` to produce failing tests for a bug report:

    runSubagent({
      prompt: "Given this failing behavior: <short bug summary>, create minimal unit tests that reproduce it and suggest a fix plan.",
      description: "Create failing tests for bug",
      agentName: "test-engineer"
    })

- **Prompt guidance when calling agents:**
  - Be explicit: include repo-relative file paths, line ranges, and desired thoroughness (quick/medium/thorough) when relevant.
  - State the expected output format (e.g., checklist, PR-ready patch, failing test file, step-by-step plan).
  - When possible, attach the minimal context needed (code snippet, failing test output, reproduction steps).

- **Example workflow (spec → plan → build → test → review):**
  1. `/spec` (Explore; thorough) — gather domain context and draft spec.
  2. `/plan` (planning-and-task-breakdown) — produce a small set of ordered steps.
 3. `/build` (incremental-implementation) — implement first slice, produce tests.
 4. `/test` (test-engineer) — run and validate tests; produce failing tests if a bug.
 5. `/review` (code-reviewer) — perform multi-axis review before merge.

- **When to call agents vs. human reviewers:**
  - Use agents for repeatable, time-consuming analysis (large diffs, repo scans, test generation).
  - Always pair agent output with a human check for high-risk changes (security, schema migrations, production rollouts).

## Prompt Templates

- Spec template for `Explore`:

  "Survey the repository to produce a concise spec for [feature]. Include: affected modules (file paths), data contracts, open questions, and a minimal acceptance criteria checklist. Use 'thorough' for deep analysis."

- Review template for `code-reviewer`:

  "Review the changes in [PR or diff] for correctness, readability, performance and security. Return: a short summary, 1-3 high-impact change suggestions, and any blocking issues."

## Best Practices

- Always attach concrete artifacts (tests, logs, file paths) to agent requests.
- Start with focused, small prompts — iterate if the agent misses details.
- Use the `Explore` agent with a specified thoroughness when you need repo-wide context.
- Record decisions and final spec artifacts in the repo (`docs/` or ADRs) after agent-assisted work.

---

These guidelines make Copilot agents first-class participants in our workflow — use them to accelerate research, testing, and review while keeping humans in the loop for critical decisions.

---

## Dependency & Skill Maintenance

Agents for keeping packages current and skill files aligned with installed versions.

- `@dependency-updater` (`.github/agents/dependency-updater.md`): Queries live `flutter pub outdated`, applies safe minor/patch upgrades, drafts PR descriptions with extracted changelog notes for major bumps. **Never uses memory for version numbers.**
- `@package-security-scanner` (`.github/agents/package-security-scanner.md`): Scans every direct dependency in `pubspec.yaml` against the pub.dev advisory feed; blocks CI on CRITICAL or HIGH findings.
- `@tech-stack-skill-generator` (`.github/agents/tech-stack-skill-generator.md`): Reads `pubspec.lock` for exact installed versions, fetches pub.dev docs for those versions, regenerates stale or missing skill files under `.github/skills/`.

### Skills

- `.github/skills/flutter-pub-dependency-management/SKILL.md` — how to read `flutter pub outdated`, choose upgrade commands, and follow commit conventions.
- `.github/skills/pub-dev-api-usage/SKILL.md` — verified pub.dev REST endpoints for metadata, changelogs, and advisories.

### Scripts & CI

```bash
bash scripts/dependency_health.sh            # live report
bash scripts/dependency_health.sh --auto     # report + apply safe upgrades
bash scripts/dependency_health.sh --full     # report + advisory scan
bash scripts/regenerate_skills.sh            # check which skills are stale
bash scripts/regenerate_skills.sh --write    # create/update stale skill files
```

**PR Validation** (`.github/workflows/pr-validation.yml`): runs on every pull request targeting `main` — cached Flutter setup, `dart format`, `dart analyze`, `flutter test`, path-filtered `verify_docs_archival.sh` and `check_prompt_injection.sh`. No scheduled CI jobs (see [docs/decisions/remove-expensive-ci-cd.md](../docs/decisions/remove-expensive-ci-cd.md)).

**Dependency maintenance (manual):** run the scripts above locally before upgrading; follow [docs/OPERATIONS-dependency-maintenance.md](../docs/OPERATIONS-dependency-maintenance.md) (workflow removed in BL-21).


# AgToosa — GitHub Copilot Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

Then load all scoped instruction files in `.github/instructions/`.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `scope` · `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast Linear issue capture) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- Your Linear project — Source of truth for project state and backlog
- `Docs/Master-Plan.md` — Workspace mirror of Linear state
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration
- `.github/instructions/*.instructions.md` — scoped coding, testing, security, and changelog rules

Always keep Linear updated first, then mirror the current state in `Docs/Master-Plan.md`.


# AgToosa — GitHub Copilot Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

Then load all scoped instruction files in `.github/instructions/`.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `scope` · `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast Linear issue capture) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- Your Linear project — Source of truth for project state and backlog
- `Docs/Master-Plan.md` — Workspace mirror of Linear state
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration
- `.github/instructions/*.instructions.md` — scoped coding, testing, security, and changelog rules

Always keep Linear updated first, then mirror the current state in `Docs/Master-Plan.md`.


# AgToosa — GitHub Copilot Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

Then load all scoped instruction files in `.github/instructions/`.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `scope` · `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration
- `.github/instructions/*.instructions.md` — scoped coding, testing, security, and changelog rules

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — GitHub Copilot Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

Then load all scoped instruction files in `.github/instructions/`.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `scope` · `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration
- `.github/instructions/*.instructions.md` — scoped coding, testing, security, and changelog rules

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — GitHub Copilot Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

Then load all scoped instruction files in `.github/instructions/`.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `scope` · `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration
- `.github/instructions/*.instructions.md` — scoped coding, testing, security, and changelog rules

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — GitHub Copilot Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

Then load all scoped instruction files in `.github/instructions/`.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `scope` · `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration
- `.github/instructions/*.instructions.md` — scoped coding, testing, security, and changelog rules

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — GitHub Copilot Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

Then load all scoped instruction files in `.github/instructions/`.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` · `tasks` · `to-issues` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration
- `.github/instructions/*.instructions.md` — scoped coding, testing, security, and changelog rules

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — GitHub Copilot Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

Then load all scoped instruction files in `.github/instructions/`.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` · `tasks` · `to-issues` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration
- `.github/instructions/*.instructions.md` — scoped coding, testing, security, and changelog rules

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — GitHub Copilot Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

Then load all scoped instruction files in `.github/instructions/`.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` · `tasks` · `to-issues` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest) · `/agtoosa-status` → Read `Docs/AgToosa_Status.md` (read-only project health dashboard)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration
- `.github/instructions/*.instructions.md` — scoped coding, testing, security, and changelog rules

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — GitHub Copilot Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

Then load all scoped instruction files in `.github/instructions/`.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` · `tasks` · `to-issues` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest) · `/agtoosa-status` → Read `Docs/AgToosa_Status.md` (read-only project health dashboard)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration
- `.github/instructions/*.instructions.md` — scoped coding, testing, security, and changelog rules

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — GitHub Copilot Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

Then load all scoped instruction files in `.github/instructions/`.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` · `tasks` · `to-issues` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest) · `/agtoosa-status` → Read `Docs/AgToosa_Status.md` (read-only project health dashboard)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration
- `.github/instructions/*.instructions.md` — scoped coding, testing, security, and changelog rules

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — GitHub Copilot Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

Then load all scoped instruction files in `.github/instructions/`.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` · `tasks` · `to-issues` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest) · `/agtoosa-status` → Read `Docs/AgToosa_Status.md` (read-only project health dashboard)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration
- `.github/instructions/*.instructions.md` — scoped coding, testing, security, and changelog rules

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.
