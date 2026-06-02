# Agent preferences (gstack developer profile)

> **Story:** DX-01 · **Last updated:** 2026-06-01  
> **Live state:** `~/.gstack/developer-profile.json` on the developer machine (not in git).  
> **Tune:** `/plan-tune` or `tune: never-ask` / `tune: always-ask` in your message (user-origin only).

## Purpose

This file mirrors the **declared** gstack developer profile so AgToosa agents (Cursor, Claude Code, etc.) can align tone and decision style without reading machine-local gstack files.

**v1 is observational:** gstack logs questions and honors per-question `never-ask` / `always-ask` prefs. Skills do **not** yet auto-change behavior from these five dimensions alone.

## Declared dimensions

| Dimension | Value | Plain English |
|-----------|-------|---------------|
| scope_appetite | 0.5 | Balanced — neither always minimal slices nor always full boil-the-ocean |
| risk_tolerance | 0.5 | Balanced — neither reckless speed nor excessive caution by default |
| detail_preference | **0.85** | **High** — include tradeoffs, reasoning, and context in explanations |
| autonomy | 0.5 | Balanced — mix of consultation and delegation |
| architecture_care | 0.5 | Balanced — neither “ship now” nor “design forever” as a fixed bias |

## Implications for AgToosa work

- Prefer **clear, complete sentences** and explicit tradeoffs when proposing plans or reviews.
- Default scope and architecture decisions stay **balanced** unless the story spec says otherwise.
- For terse output, the user can say “be brief” or set gstack `explain_level: terse` locally.
- One-way or destructive choices (deploy, delete data, force-push) still require explicit confirmation regardless of profile.

## What not to put here

- No API keys, tokens, or `~/.gstack` JSON dumps in this repo.
- No PII. Update this table only when the user re-runs `/plan-tune` setup and asks to sync docs.

## Related

- Spec: [docs/archived/spec-DX-01-gstack-plan-tune.md](../archived/spec-DX-01-gstack-plan-tune.md)
- Test plan: [docs/AgToosa_TestPlan-DX-01.md](../AgToosa_TestPlan-DX-01.md)
- Workflow gates: [workflow.md](workflow.md)
