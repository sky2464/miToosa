---
description: Design, write, or run the right tests for the current change.
argument-hint: Describe the behavior, bug, or files that need verification.
agent: test-engineer
---

Use the request in chat as the verification target.

Follow:

- [Repository instructions](../copilot-instructions.md)
- [test-driven-development](../skills/test-driven-development/SKILL.md)

Prefer the lowest test level that captures the behavior.

If this is a bug:

1. Reproduce the bug with a failing test first.
2. Explain what the failing test proves.
3. Only then suggest or validate the fix.

Return:

- Recommended test level
- Specific test cases to add or run
- Commands to execute
- Coverage gaps or regression risks worth addressing
