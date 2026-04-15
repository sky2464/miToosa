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