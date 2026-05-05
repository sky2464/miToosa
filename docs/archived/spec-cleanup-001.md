# Spec: Repo & Docs Cleanup (cleanup_001)

**Story ID:** S1-05  
**Type:** Chore  
**Epic:** EP-05 — Technical Debt & Infrastructure  
**Priority:** P4  
**Estimate:** XS (< 2h)  
**Created:** 2026-05-04  
**Status:** Todo

---

## Context

As of Sprint 1, `Docs/Master-Plan.md` is the sole source of truth for project management. Several legacy files created before this framework was established are now redundant, stale, or empty. Additionally, `GEMINI.md` is not wired to the AgToosa command framework, unlike `CLAUDE.md` and `AGENTS.md`. This chore removes noise, prevents confusion, and brings all AI config files up to par.

**Pending work from Master-Plan.md is fully tracked** — this chore does not change any sprint scope or backlog items; it only cleans up the documentation layer around them.

---

## Scope

### Archive (move to `docs/archived/`)

| File | Reason |
|------|--------|
| `TASKS.md` (root) | Fully superseded by Master-Plan.md Active Tasks, Blocked, Backlog, and Completed sections. Every item is mirrored. |
| `docs/plan.md` | 14K development plan from Apr 24; all Epics and stories are now in Master-Plan.md. Superseded. |

### Delete

| File | Reason |
|------|--------|
| `docs/firebase.md` | 0 bytes, completely empty. No content to preserve. |

### Update

| File | What changes |
|------|-------------|
| `GEMINI.md` (root) | Add AgToosa command table and key references. Remove emoji headers. Update stale `.claude/` reference to correct paths. Align style with `CLAUDE.md`. |

### Keep (no action)

| File | Reason |
|------|--------|
| `docs/backend-research.md` | Active reference for S1-02 (Analytics Backend Integration). |
| `docs/test-coverage-dependency-maintenance.md` | Referenced by EP-05 scope; CI/CD weekly workflow is live. |
| `docs/CHECKLIST-dependency-maintenance.md` | Companion checklist for the weekly dependency CI run. |
| `docs/OPERATIONS-dependency-maintenance.md` | Operational runbook for the maintenance workflow. |
| `GEMINI.md` | Updated (see above), not archived. |
| All `AgToosa_*.md` files | Active framework — never archive. |
| All `docs/playtests/`, `docs/decisions/`, `docs/qa/` | Active sprint content. |

---

## Acceptance Criteria

| ID | Scenario | Given | When | Then | Priority |
|----|----------|-------|------|------|----------|
| AC-001 `@smoke` | TASKS.md archived | TASKS.md exists in root | Chore runs | File moved to `docs/archived/tasks-sprint-1-pre-masterplan.md`; absent from root | Must |
| AC-002 `@smoke` | docs/plan.md archived | plan.md exists in docs/ | Chore runs | File moved to `docs/archived/plan-pre-launch-v1.5.0.md`; absent from docs/ | Must |
| AC-003 `@smoke` | firebase.md deleted | firebase.md is 0 bytes in docs/ | Chore runs | File no longer exists anywhere in repo | Must |
| AC-004 `@smoke` | GEMINI.md updated | GEMINI.md has no AgToosa refs | Chore runs | GEMINI.md contains AgToosa command table, correct file paths, no emoji headers | Must |
| AC-005 `@smoke` | Master-Plan.md updated | S1-05 not yet in Active Cycle | Chore runs | S1-05 row added to Active Cycle; Update Log entry appended | Must |
| AC-006 `@smoke` | No active content lost | backend-research.md et al. are intact | Chore runs | Keep-list files untouched; `git status` shows no unexpected deletions | Must |

---

## Architecture Blueprint

**Change type:** File operations only — no code, no tests, no dependency changes.

**Execution order** (sequential, all low-risk):
1. Move `TASKS.md` → `docs/archived/tasks-sprint-1-pre-masterplan.md`
2. Move `docs/plan.md` → `docs/archived/plan-pre-launch-v1.5.0.md`
3. Delete `docs/firebase.md`
4. Rewrite `GEMINI.md` with AgToosa wiring
5. Update `docs/Master-Plan.md` — add S1-05 to Active Cycle + Update Log

**Files modified:** `GEMINI.md`, `docs/Master-Plan.md`  
**Files moved:** `TASKS.md`, `docs/plan.md`  
**Files deleted:** `docs/firebase.md`  
**Files created:** `docs/archived/tasks-sprint-1-pre-masterplan.md`, `docs/archived/plan-pre-launch-v1.5.0.md`

---

## STRIDE Threat Model

This chore has no trust boundaries, no code changes, and no external API calls.

| Threat | Assessment |
|--------|-----------|
| Spoofing | N/A |
| Tampering | Low — archiving wrong file would hide active docs. Mitigated by AC-006 (verify keep-list untouched). |
| Repudiation | Low — git history preserves all moved/deleted files. |
| Information Disclosure | N/A — docs contain no secrets or PII. |
| Denial of Service | N/A |
| Elevation of Privilege | N/A |

**Residual risk:** Minimal. All file moves are tracked in git history and reversible via `git checkout`.

---

## Definition of Done

- [ ] AC-001 through AC-006 all pass
- [ ] `git status` shows only expected changes (no unintended deletions)
- [ ] `dart analyze && flutter test` still pass (no code changed, but verify)
- [ ] Master-Plan.md Update Log has new entry for this chore

---

## ✅ Spec Approved

Approved: 2026-05-04 21:45
