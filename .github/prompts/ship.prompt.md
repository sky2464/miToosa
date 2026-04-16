---
description: Run the final release checklist and prepare a clean handoff.
argument-hint: Describe what is ready to ship or what branch/change should be checked.
agent: agent
---

Use the request in chat as the release scope.

Follow:

- [Repository instructions](../copilot-instructions.md)
- [shipping-and-launch](../skills/shipping-and-launch/SKILL.md)
- [documentation-and-adrs](../skills/documentation-and-adrs/SKILL.md)

Before calling something “ready,” verify:

1. Required generated code is up to date
2. Formatting, analysis, and tests were run
3. User-facing or workflow docs changed alongside the code when needed
4. Risks, rollout notes, and follow-up items are documented

Return a ship checklist, validation summary, and any blockers. Do not claim deployment happened unless you actually performed it.
