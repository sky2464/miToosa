---
description: Define a repo-specific spec before implementation.
argument-hint: Describe the feature, bug, or refactor to specify.
agent: plan
---

Use the request in chat as the change brief.

Follow:

- [Repository instructions](../copilot-instructions.md)
- [spec-driven-development](../skills/spec-driven-development/SKILL.md)
- [context-engineering](../skills/context-engineering/SKILL.md)

Do not write code.

Return a concise spec with:

1. Problem statement
2. Goal and user value
3. Acceptance criteria
4. Affected files or modules
5. Risks, dependencies, and open questions
6. Smallest useful implementation slice to build first

Prefer Flutter/Dart terminology and repository-relative file paths.
