# Test Plan — BL-24 Interactive How-To Demos

> **Spec:** [spec-BL-24.md](archived/spec-BL-24.md)  
> **Coverage target:** 80% (per `docs/Context/workflow.md`)  
> **Created:** 2026-06-14

## AC Coverage Matrix

| AC | Test ID | Category | Description | Smoke |
|----|---------|----------|-------------|-------|
| AC-001 | T-001 | Integration | First track entry shows `HowToPlayModal` with demo panel | @smoke |
| AC-002 | T-002 | Widget | Correct demo tap shows success + enables CTA | @smoke |
| AC-003 | T-003 | Widget | Incorrect demo tap shows retry; modal stays open | @smoke |
| AC-004 | T-004 | Integration | CTA calls `markTutorialSeen` and continues to difficulty sheet | @smoke |
| AC-005 | T-005 | Integration | Second entry skips modal when track in `seenTutorialWorlds` | @smoke |
| AC-006 | T-006 | Widget | Gameplay `?` reopens demo without `markTutorialSeen` | |
| AC-007 | T-007 | Unit | `TutorialDemoPanel` has no `GameplayViewModel` / timer imports | |
| AC-008 | T-008 | Unit | `TutorialDemoContent.forTrack` deterministic for `track_1`, `track_7`, `track_20` | @smoke |
| AC-009 | T-009 | Widget | Modal scrollable at 320×568 without overflow | |
| AC-010 | T-010 | Widget | Settings row opens demo for featured track | |
| AC-011 | T-011 | Widget | Demo options expose `Semantics` labels | |

## Negative / Edge Scenarios

| Test ID | Scenario |
|---------|----------|
| T-003 | Double wrong tap still does not enable CTA |
| T-005 | Empty `seenTutorialWorlds` always shows demo on first tap |
| T-006 | `?` on already-seen track does not duplicate `seenTutorialWorlds` entry |
| T-008 | Different track ids produce different demo puzzles |
| T-009 | Long math prompt in demo does not overflow (text-based rule track) |

## Verification Commands

```bash
dart analyze
flutter test test/core/tutorial_demo_content_test.dart
flutter test test/widgets/tutorial_demo_panel_test.dart
flutter test test/widgets/how_to_play_modal_test.dart
flutter test test/features/navigation/track_detail_tutorial_test.dart
flutter test
```

## RED / GREEN Evidence Log

_(Populated during `/agtoosa-build` per task.)_
