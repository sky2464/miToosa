---
mode: agent
description: "AgToosa: read-only health dashboard — Master-Plan parsing, git cross-ref, orphan detection"
tools: [codebase, terminal, githubRepo]
---

Read Docs/AgToosa_Status.md and execute the status workflow.

Sub-command dispatch:
- No argument → full status dashboard
- `plan` → Master-Plan.md health check only
- `git` → git cross-reference only
- `orphans` → orphan detection only

CRITICAL: This is a READ-ONLY command. Do NOT modify any files.
