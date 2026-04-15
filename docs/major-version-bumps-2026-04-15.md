# Major Version Bumps Available

**Date:** 2026-04-15  
**Status:** Awaiting human review before applying

---

## Summary

Current miToosa has 2 major-version bumps blocked by caret constraints. Both are transitive dependencies (no direct call sites in `lib/`), so prioritization is lower than production-critical packages.

---

## Detailed Analysis

### 1. share_plus: 10.1.4 → 13.0.0

**Source:** https://pub.dev/packages/share_plus/versions/13.0.0

**Affected:** 
- Direct dependency: `lib/features/menu/screens/menu_screen.dart` uses `share_plus` for "Share" functionality
- Transitive: `share_plus_platform_interface` (5.0.2 → 7.0.0)

**Breaking Changes Expected:** 
Share Plus 13.0.0 includes major platform-specific improvements. Requires review of:
- API changes in share dialog
- Platform-specific implementations (iOS/Android)
- Return type or signature changes

**Action:**
1. Fetch full CHANGELOG from pub.dev
2. Identify API breaking changes
3. Update call sites in `lib/features/menu/screens/menu_screen.dart`
4. Test on iOS and Android simulators
5. Open PR with migration notes

**Priority:** MEDIUM — affects share dialog UX

---

### 2. vector_math: 2.2.0 → 2.3.0

**Source:** https://pub.dev/packages/vector_math/versions/2.3.0

**Affected:** 
- Transitive dependency only (no direct imports in `lib/`)
- Used indirectly by Flutter rendering engine

**Breaking Changes Expected:** 
Unlikely to affect game code directly, but may require engine recompilation.

**Action:**
1. Fetch CHANGELOG
2. If only internal fixes: safe to upgrade
3. If API changes: check if Flutter has adapted

**Priority:** LOW — transitive only

---

### 3. meta: 1.17.0 → 1.18.2

**Affected:** 
- Transitive dev dependency

**Breaking Changes Expected:** 
Unlikely — `meta` is a stable annotation library. Usually backwards-compatible.

**Action:**
- Safe to upgrade with `flutter pub upgrade --major-versions`

**Priority:** LOW

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
