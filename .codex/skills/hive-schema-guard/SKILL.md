---
name: hive-schema-guard
description: Validate miToosa PlayerProgress Hive schema bumps and migration tests when lib/data/player_progress.dart changes.
---

# hive-schema-guard

Project specialist for Hive persistence. Invoke during `/agtoosa-build` or `/agtoosa-review` when player progress schema changes.

## Inputs

- `lib/data/player_progress.dart`
- `test/data/player_progress_test.dart`
- `docs/Master-Architecture.md` §5

## Run

1. Confirm schema version comment incremented when new Hive fields added.
2. Verify adapter migration path for prior schema versions.
3. Run `flutter test test/data/player_progress_test.dart`.
4. Confirm migration test covers upgrade from previous version.
5. Emit structured evidence block.

## Validation

```bash
flutter test test/data/player_progress_test.dart
```

## Safety

Never log encryption keys or Hive box contents. Read-only inspection.
