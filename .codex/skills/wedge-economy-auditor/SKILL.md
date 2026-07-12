---
name: wedge-economy-auditor
description: Audit player-facing economy copy against docs/PRODUCT-WEDGE.md for miToosa free-games wedge compliance.
---

# wedge-economy-auditor

Project specialist for miToosa economy copy. Invoke during `/agtoosa-spec` or `/agtoosa-review` for EP-01/EP-03 stories or UI string changes.

## Inputs

- `docs/PRODUCT-WEDGE.md` (canonical — do not edit)
- `docs/qa/wedge-qa-checklist.md`
- Changed UI files under `lib/features/`, `lib/widgets/`

## Run

1. Read wedge doc for allowed terms: "free games", share bonus (+40), VIP as convenience-only.
2. Flag forbidden framing: paywall-before-value, "hearts/energy/coins" as top-level unit, "unlock the full game".
3. Cross-check changed strings against wedge rules.
4. Emit structured evidence block.

## Validation

Manual checklist pass against `docs/qa/wedge-qa-checklist.md` + grep for forbidden economy terms in diff scope.

## Safety

Do not modify `docs/PRODUCT-WEDGE.md` without explicit user approval.
