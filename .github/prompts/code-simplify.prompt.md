---
description: Reduce complexity without changing behavior.
argument-hint: Describe the file, component, or change that should be simplified.
agent: agent
---

Use the request in chat as the simplification target.

Follow:

- [Repository instructions](../copilot-instructions.md)
- [code-simplification](../skills/code-simplification/SKILL.md)
- [incremental-implementation](../skills/incremental-implementation/SKILL.md)

Prefer the smallest simplification that improves clarity.

Goals:

1. Remove unnecessary abstraction, duplication, or branching
2. Preserve behavior
3. Keep the diff easy to review and revert
4. Run targeted validation after the simplification

If a larger refactor is warranted, explain why and propose it separately instead of smuggling it into the current change.
