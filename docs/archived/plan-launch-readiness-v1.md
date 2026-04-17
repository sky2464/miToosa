# Plan: Launch Readiness — Close Out Remaining LAUNCH.md Items

**Date:** April 17, 2026  
**Status:** Archived  

---

## Task Breakdown (ordered by dependency)

### Slice 1: Create CHANGELOG.md
- [x] Create `CHANGELOG.md` at repo root with v1.2.0 release notes (content already drafted in LAUNCH.md release notes section)

### Slice 2: Create Privacy Policy
- [x] Create `docs/PRIVACY-POLICY.md` with local-data-only policy, data inventory table, children's privacy note, and contact info placeholder

### Slice 3: Create Data Retention Policy
- [x] Create `docs/DATA-RETENTION.md` documenting Hive boxes, retention periods (telemetry: 500 events max, progress: indefinite), deletion instructions

### Slice 4: Create User Guide
- [x] Create `docs/USER-GUIDE.md` covering onboarding, tracks, gameplay, progress, and settings (all 23 tracks listed)

### Slice 5: Fix stale test counts
- [x] Update `docs/COMPLETION.md` — 256 → 264
- [x] Update `docs/LAUNCH.md` — 256 → 264

### Slice 6: Update LAUNCH.md checklist
- [x] Mark rate limiting as N/A with note (no backend)
- [x] Mark privacy policy `[x]` (created in Slice 2)
- [x] Mark GDPR policy `[x]` (created in Slice 3)
- [x] Mark release notes `[x]` (created in Slice 1)
- [x] Mark changelog `[x]` (created in Slice 1)
- [x] Mark user onboarding docs `[x]` (created in Slice 4)
- [x] Annotate all Category C items with `BLOCKED:` reason
- [x] Update v1.3 Next Steps — telemetry already shipped in v1.2
- [x] Fix track count (10 → 23) in USER-GUIDE and LAUNCH.md
- [x] Remove phantom `onboarding_complete` SharedPreferences from PRIVACY-POLICY and DATA-RETENTION

### Slice 7: Verify
- [x] `flutter test` → 264 pass
- [x] `dart analyze` → no issues
- [ ] Commit all changes
