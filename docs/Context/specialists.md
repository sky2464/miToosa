# Project Specialists — miToosa

> **Approved:** 2026-07-11 via `/agtoosa-init` Phase E  
> **Contract:** `docs/AgToosa_Specialists.md`

## Roster

| id | trigger | phase_hooks | purpose | validation |
|----|---------|-------------|---------|------------|
| `flutter-engine-guard` | Changes under `lib/core/engine/` | build, review | Enforce pure-Dart engine boundary (no Flutter/Hive), static/immutable patterns | `dart analyze lib/core/engine/` + forbidden-import grep |
| `wedge-economy-auditor` | Economy/copy UI; EP-01/EP-03 stories | spec, review | Verify player-facing copy matches `docs/PRODUCT-WEDGE.md` | Wedge checklist + forbidden-term grep |
| `iphone-launch-gate` | `test/release/*`, launch docs; EP-01/EP-02 | build, ship | Run iOS launch readiness guards and cross-check manual gates | `flutter test test/release/` + doc link audit |
| `hive-schema-guard` | `lib/data/player_progress.dart`, Hive migrations | build, review | Validate schema version bumps and migration test coverage | `flutter test test/data/player_progress_test.dart` |

## Platform files

| id | Codex | Claude | Copilot | Cursor | Gemini |
|----|-------|--------|---------|--------|--------|
| flutter-engine-guard | `.codex/skills/flutter-engine-guard/` | `.claude/skills/flutter-engine-guard.md` | `.github/agents/flutter-engine-guard.md` | `.cursor/rules/flutter-engine-guard-specialist.mdc` | `.gemini/commands/flutter-engine-guard-specialist.toml` |
| wedge-economy-auditor | `.codex/skills/wedge-economy-auditor/` | `.claude/skills/wedge-economy-auditor.md` | `.github/agents/wedge-economy-auditor.md` | `.cursor/rules/wedge-economy-auditor-specialist.mdc` | `.gemini/commands/wedge-economy-auditor-specialist.toml` |
| iphone-launch-gate | `.codex/skills/iphone-launch-gate/` | `.claude/skills/iphone-launch-gate.md` | `.github/agents/iphone-launch-gate.md` | `.cursor/rules/iphone-launch-gate-specialist.mdc` | `.gemini/commands/iphone-launch-gate-specialist.toml` |
| hive-schema-guard | `.codex/skills/hive-schema-guard/` | `.claude/skills/hive-schema-guard.md` | `.github/agents/hive-schema-guard.md` | `.cursor/rules/hive-schema-guard-specialist.mdc` | `.gemini/commands/hive-schema-guard-specialist.toml` |

## Safety

- **tools/MCP:** none — read-only file tools and terminal validation commands only.
- **secrets:** reference paths only (`docs/ANALYTICS-SETUP.md`, `.env.example` if present); never copy credential values into specialist output.

## Update Log

| Date | id | Decision |
|------|-----|----------|
| 2026-07-11 | flutter-engine-guard | Approve |
| 2026-07-11 | wedge-economy-auditor | Approve |
| 2026-07-11 | iphone-launch-gate | Approve |
| 2026-07-11 | hive-schema-guard | Approve |
