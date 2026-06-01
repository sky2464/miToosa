# ADR: Streamline GitHub Automation and CI/CD

**Status**: Accepted
**Date**: 2026-05-20
**Deciders**: AI agent + human review

## Context

The current GitHub Actions setup for `miToosa` features 7 parallel workflows:
1. `claude-code-review.yml` (expensive LLM execution)
2. `claude.yml` (expensive LLM execution)
3. `daily-health-check.yml` (scheduled runner hours)
4. `dependency-maintenance.yml` (scheduled runner hours)
5. `docs-archival-check.yml` (redundant check)
6. `prompt-injection-guard.yml` (redundant path-filtered check)
7. `web-build.yml` (deploys to Firebase staging, requiring secrets exposure on remote runner)

These actions are consuming a significant amount of runner compute hours and API billing for Claude LLM tokens. To optimize budget efficiency and safeguard deployment keys, we need a streamlined automation structure.

## Decision

We decide to adopt **Option A (Streamlined CI/CD via PR-only Guard)**:
1. Delete all expensive/interactive Claude workflows and cron schedules.
2. Remove production staging deployment secrets from CI environments.
3. Consolidate validation into a single lightweight, cached, pull-request-only verification workflow (`pr-validation.yml`).
4. Retain all local verification and deployment scripts (`scripts/deploy-staging.sh`, `scripts/check_prompt_injection.sh`, `scripts/verify_docs_archival.sh`) fully operational for local development use.

## Rationale

Option A provides the ideal balance between budget efficiency, deployment security, and code quality enforcement:
- **Cost Minimization**: Consolidating to PR-only runs eliminates high LLM token bills and scheduled compute minute consumption.
- **Improved Security**: Staging deployments require developer intervention via local shell script execution (`scripts/deploy-staging.sh`), which keeps API tokens/keys strictly within secure local dev machines.
- **Fast Developer Feedback**: Leveraging Actions caching in `pr-validation.yml` minimizes runner compute time to less than 3 minutes, giving contributors rapid validation feedback.
- **Zero Regression**: Pre-commit / PR-level gates continue to enforce static analysis (`dart analyze`), unit/widget tests (`flutter test`), and path-based doc validation.

## Consequences

### Positive
- Zero external LLM token bill costs from GitHub Actions.
- Drastic reduction (estimated >80% savings) in Actions compute minutes.
- Firebase deployment keys are removed from GitHub environments, eliminating secrets exfiltration risk.
- Fast, unified feedback cycle for all incoming PRs.

### Negative
- Developers must run `scripts/deploy-staging.sh` manually from their machines to push to staging.
- Security and dependency audits will be run on-demand locally instead of daily on cron schedules.

## Alternatives Considered

| Option | Rejected because |
|--------|-----------------|
| Option B (Keep scheduled crons, delete Claude) | Scheduled crons still consume runner compute minutes and do not address the staging deploy credentials exposure risk. |
| Option C (Remove CI/CD entirely) | Eliminating CI entirely removes the safeguard against failing tests or format violations landing in `main`. |
