# Test Plan: DX-01 — gstack /plan-tune setup

> **Spec reference:** [docs/archived/spec-DX-01-gstack-plan-tune.md](archived/spec-DX-01-gstack-plan-tune.md)
> **Coverage target:** Every Must AC mapped to ≥1 test.

---

## AC Coverage Table

| AC | Description | Test IDs | Category |
|----|-------------|----------|----------|
| AC-001 | `question_tuning` set to `true` | T-001 | Manual |
| AC-002 | Five `declared.*` keys + `declared_at` in profile JSON | T-002 | Manual |
| AC-003 | `gstack-developer-profile --profile` matches approved table | T-003, T-006 | Manual |
| AC-004 | `docs/Context/agent-preferences.md` exists, no secrets | T-004 | Manual |
| AC-005 | v1 observational — no false auto-adapt claims in docs | T-005 | Manual |

---

## Test Details

| ID | Test Name | AC | @smoke |
|----|-----------|-----|--------|
| T-001 | `question_tuning_enabled` — `gstack-config get question_tuning` returns `true`. | AC-001 | @smoke |
| T-002 | `declared_profile_persisted` — `~/.gstack/developer-profile.json` contains five declared keys and ISO `declared_at`. | AC-002 | @smoke |
| T-003 | `profile_cli_matches` — `gstack-developer-profile --profile` JSON matches approved values (0.5, 0.5, 0.85, 0.5, 0.5). | AC-003 | @smoke |
| T-004 | `agent_preferences_doc` — File exists; grep for `api_key`, `secret`, `password` returns no real credentials. | AC-004 | |
| T-005 | `v1_observational_documented` — `agent-preferences.md` states v1 observational; no claim of full skill auto-adapt. | AC-005 | |
| T-006 | `question_log_ready` — Project log path exists or is creatable; optional sample log line via `gstack-question-log` after setup. | AC-003 | |

---

## Repo verification gates (docs change)

| Gate | Command | Expected |
|------|---------|----------|
| Analyze | `dart analyze` | No issues |
| Tests | `flutter test` | All pass (unchanged app code) |
