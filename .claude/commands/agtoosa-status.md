Read @Docs/AgToosa_Status.md and execute the status workflow.

Arguments provided: $ARGUMENTS

Dispatch rules based on arguments:
- No argument → full status dashboard: parse Master-Plan.md, cross-reference git, detect orphans, compute health score, present dashboard.
- `plan` → Master-Plan.md health check only: parse all sections, check cross-section consistency, report findings.
- `git` → git cross-reference only: scan recent commits, find WIP markers, detect unreported progress.
- `orphans` → orphan detection only: find spec files and task IDs not tracked in Master-Plan.md.

CRITICAL: This is a READ-ONLY command. Do NOT modify any files.

If no arguments were given, run the full flow from Docs/AgToosa_Status.md.
