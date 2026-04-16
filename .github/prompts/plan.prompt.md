---
description: Break an approved spec into small, testable implementation slices.
argument-hint: Paste or summarize the approved spec or task.
agent: plan
---

Use the request in chat as the approved spec or task.

Follow:

- [Repository instructions](../copilot-instructions.md)
- [planning-and-task-breakdown](../skills/planning-and-task-breakdown/SKILL.md)
- [incremental-implementation](../skills/incremental-implementation/SKILL.md)

Do not implement.

Produce an ordered plan that:

1. Uses small vertical slices
2. Names the files likely to change in each slice
3. Includes the validation command for each slice
4. Calls out generated-code steps when `build_runner` is required
5. Separates must-do work from optional follow-ups

Use markdown checklists so the plan can be updated inline during implementation.
