---
description: Implement the next approved slice with validation.
argument-hint: Describe the approved slice or reference the current plan item.
agent: agent
---

Use the request in chat as the approved implementation slice.

Follow:

- [Repository instructions](../copilot-instructions.md)
- [incremental-implementation](../skills/incremental-implementation/SKILL.md)
- [source-driven-development](../skills/source-driven-development/SKILL.md)
- [test-driven-development](../skills/test-driven-development/SKILL.md)

Implement only the next approved slice.

Requirements:

1. Read the relevant files before editing.
2. Keep the change minimal and scoped.
3. If the change touches framework-specific behavior, verify the pattern against official docs before coding.
4. Run the smallest relevant validation command after the edit.
5. Report files changed, validation performed, and the next recommended slice.

Do not refactor unrelated areas “while you are here.”
