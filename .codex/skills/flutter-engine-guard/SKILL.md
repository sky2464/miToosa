---
name: flutter-engine-guard
description: miToosa pure-Dart engine boundary guard — no Flutter/Hive imports, static immutable patterns in lib/core/engine/.
---

# flutter-engine-guard

Project specialist for miToosa game engines. Invoke during `/agtoosa-build` or `/agtoosa-review` when `lib/core/engine/` changes.

## Inputs

- `lib/core/engine/**/*.dart`
- `docs/Master-Architecture.md` §3
- `docs/Context/tech-stack.md` architecture rules

## Run

1. Grep engines for forbidden imports: `flutter/`, `hive`, `riverpod`.
2. Run `dart analyze lib/core/engine/`.
3. Confirm methods are static or pure functions returning immutable state via `copyWith()`.
4. Emit structured evidence block (see `docs/AgToosa_Specialists.md`).

## Validation

```bash
dart analyze lib/core/engine/
! rg -l "package:flutter|package:hive|package:flutter_riverpod" lib/core/engine/
```

## Safety

Read-only. No MCP. No secret paths.
