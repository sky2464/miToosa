# Major Version Bumps Available

**Date:** 2026-04-15  
**Updated:** 2026-04-16 — transitive-only status verified; share_plus migration doc created  
**Status:** Archived  
**Archived:** April 18, 2026

---

## Summary

Current miToosa has 2 major-version bumps blocked by caret constraints. `share_plus` is a direct dependency with a deprecated API call that requires migration. All others (`vector_math`, `meta`, `test`, `dart_style`) are **confirmed transitive-only** — verified by `grep -rn "vector_math\|dart_style\|meta\|package:test" lib/ test/` returning zero results.

---

## Detailed Analysis

### 1. share_plus: 10.1.4 → 13.0.0

**Source:** https://pub.dev/packages/share_plus/changelog (fetched live 2026-04-16)  
**Full migration doc:** [docs/major-bump-share_plus.md](major-bump-share_plus.md)

**Affected:** 
- Direct dependency: `lib/features/navigation/world_map_screen.dart:34` calls `Share.share()` (deprecated in v11.0.0)
- Transitive: `share_plus_platform_interface` (5.0.2 → 7.0.0)

**Breaking Changes Summary (from live changelog):**
- **v11.0.0:** New `SharePlus` class + `share(ShareParams(...))` method replaces deprecated `Share.share()`. Migration required.
- **v12.0.0:** Android requires AGP >= 8.12.1, Gradle >= 8.13, Kotlin 2.2.0.
- **v13.0.0:** Requires Flutter >= 3.41.6, Dart >= 3.11.0, iOS >= 13.0, macOS >= 10.15.

**Action:**
See [docs/major-bump-share_plus.md](major-bump-share_plus.md) for full checklist and code migration example.

**Priority:** MEDIUM — affects share dialog UX; one call site to update

---

### 2. vector_math: 2.2.0 → 2.3.0

**Affected:** 
- **CONFIRMED transitive-only** — zero direct imports in `lib/` or `test/` (verified 2026-04-16)
- Used indirectly by Flutter rendering engine

**Breaking Changes Expected:** 
Unlikely to affect game code directly — no call sites to migrate.

**Action:**
- Safe to apply with `flutter pub upgrade --major-versions vector_math` once Flutter engine supports it

**Priority:** LOW — transitive only, zero migration effort

---

### 3. meta: 1.17.0 → 1.18.2

**Affected:** 
- **CONFIRMED transitive-only** — zero direct `package:meta` imports in `lib/` or `test/` (verified 2026-04-16)

**Priority:** LOW — transitive, safe to upgrade with no migration effort

---

### 4. test: 1.30.0 → 1.31.0 & test_api, test_core

**Affected:** 
- Dev dependencies only

**Action:**
- Safe to upgrade; verify all 256 tests still pass after upgrade

**Priority:** MEDIUM — affects test reliability

---

## Recommendation

1. **Immediate:** Upgrade dev-only transitive deps (`meta`, `test`, `test_api`, `test_core`) — lowest risk
2. **This Sprint:** Review and upgrade `share_plus 13.0.0` with manual testing on both platforms
3. **Backlog:** `vector_math` upgrade (monitor for Flutter compatibility notes)

---

## Next Steps

To apply a specific major-version bump:

```bash
# Option 1: Manual constraint edit + resolve
edit pubspec.yaml
# Change: share_plus: ^10.1.4 → share_plus: ^13.0.0
flutter pub get

# Option 2: Auto-upgrade with explicit flag
flutter pub upgrade --major-versions <package-name>
```

Always run:
```bash
dart analyze
flutter test
```

after any major-version upgrade.
