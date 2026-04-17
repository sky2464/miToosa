# Major Bump: share_plus 10.1.4 → 13.0.0

**Date:** 2026-04-16  
**Source:** https://pub.dev/packages/share_plus/changelog (fetched live, not from memory)  
**Status:** Awaiting human review — do NOT apply automatically

---

## Summary

Three major versions with breaking changes. The most critical for miToosa is the **API rename** in v11.0.0 (the old `Share` class is deprecated in favour of `SharePlus`) and the **Android build toolchain requirements** in v12.0.0.

Currently blocked by the `^10.1.4` caret constraint in `pubspec.yaml`. The resolvable version is `12.0.2` (within relaxed constraints) but `13.0.0` requires Flutter 3.41.6+ and Dart 3.11.0+.

---

## Breaking Changes Per Version

### v11.0.0 — NEW API (SharePlus class)

> Source: [#3404](https://github.com/fluttercommunity/plus_plugins/issues/3404)

- **BREAKING:** Introduces the new `SharePlus` class with a `share(params)` method.
- The old `Share` class is **deprecated** but still works in v11. It will be removed in a future version.
- See the README section **"Migrating from `Share` to `SharePlus`"** for the migration guide.

**Impact on miToosa:** `lib/features/navigation/world_map_screen.dart:34` calls `Share.share(...)`. This must be migrated to `SharePlus.instance.share(...)`.

**Migration:**
```dart
// Before (deprecated)
final result = await Share.share('text to share');

// After (v11+)
final result = await SharePlus.instance.share(ShareParams(text: 'text to share'));
```

### v12.0.0 — Android build toolchain bump

> Source: [#3671](https://github.com/fluttercommunity/plus_plugins/issues/3671)

- **BREAKING (Android):** Requires:
  - Android Gradle Plugin (AGP) >= 8.12.1
  - Gradle wrapper >= 8.13
  - Kotlin 2.2.0

**Impact on miToosa:** Check `android/build.gradle.kts` and `android/app/build.gradle.kts`. Review current AGP and Kotlin versions before upgrading.

Also: fix for iOS — unable to get the correct result on iOS ([#3660](https://github.com/fluttercommunity/plus_plugins/issues/3660)).

### v13.0.0 — Flutter/Dart/platform minimums + win32 6.0.0

> Source: win32 6.0.0 bump ([#3762](https://github.com/fluttercommunity/plus_plugins/issues/3762))

- **BREAKING:** Minimum requirements raised:
  - Flutter >= 3.41.6
  - Dart >= 3.11.0
  - iOS >= 13.0
  - macOS >= 10.15
- Updates all dependencies to latest possible versions due to win32 6.0.0.

**Impact on miToosa:** Verify Flutter and Dart SDK version before attempting this upgrade. Run `flutter --version` to confirm compatibility.

---

## Non-Breaking Additions (in-between)

| Version | Change |
|---------|--------|
| 11.1.0 | Added `excludedCupertinoActivities` parameter to share call |
| 12.0.1 | Fix: iOS 26 crash when no `sharePositionOrigin` param provided |
| 12.0.2 | Fix: iOS crash in add-to-app scenario during file and text sharing |

---

## Call Sites in miToosa

```
lib/features/navigation/world_map_screen.dart:3   import 'package:share_plus/share_plus.dart';
lib/features/navigation/world_map_screen.dart:34  final result = await Share.share(...)
```

Only one direct call site. The deprecated `Share.share()` must become `SharePlus.instance.share(ShareParams(...))`.

---

## Other Packages in pubspec.yaml Affected

`share_plus_platform_interface` is a transitive dep that also upgrades:
- Current: 5.0.2 → Latest: 7.0.0
- This is managed automatically when `share_plus` is upgraded.

---

## Recommended Upgrade Path

1. **Step 1 (safe, do now):** Upgrade pubspec.yaml constraint to `^12.0.2` (skips v13 Flutter requirement)
   - Check Android AGP/Gradle/Kotlin versions first
   - Migrate `Share.share()` → `SharePlus.instance.share(ShareParams(...))` in `world_map_screen.dart`
   - Run `flutter test` + test on iOS + Android simulator

2. **Step 2 (later, when Flutter 3.41.6+ is installed):** Upgrade to `^13.0.0`
   - No additional Dart API changes — same `SharePlus` API
   - Verify iOS 13.0 and macOS 10.15 minimum targets are set

---

## Decision Checklist

- [ ] Verify Flutter SDK >= 3.41.6 (required for v13 only, not v12)
- [ ] Check `android/build.gradle.kts` AGP version >= 8.12.1
- [ ] Check `android/gradle/wrapper/gradle-wrapper.properties` Gradle >= 8.13
- [ ] Check Kotlin version >= 2.2.0 in Android build files
- [ ] Migrate `Share.share()` → `SharePlus.instance.share(ShareParams(...))` in `world_map_screen.dart`
- [ ] Run `flutter test` after migration
- [ ] Smoke-test share button on iOS simulator
- [ ] Smoke-test share button on Android emulator
- [ ] Open PR with this doc as the description
