# Spec: Launch Readiness — Close Out Remaining LAUNCH.md Items

**Date:** April 17, 2026  
**Status:** Archived  
**Scope:** All unchecked `[ ]` items in `docs/LAUNCH.md`

---

## Objective

Close out every remaining TODO in `LAUNCH.md` by either completing the work or explicitly categorising it as a human-gated blocker with clear next-step instructions.

---

## Remaining Items Audit

### Category A — Implementable Now (docs/config in this repo)

| # | Section | Item | Action |
|---|---------|------|--------|
| A1 | Documentation | Release notes prepared | Create `CHANGELOG.md` with v1.2.0 release notes |
| A2 | Documentation | Changelog updated | Same as A1 |
| A3 | Documentation | User onboarding/help docs | Create `docs/USER-GUIDE.md` covering app flow |
| A4 | Security | Privacy policy and ToS | Create `docs/PRIVACY-POLICY.md` (template, not legal) |
| A5 | Security | GDPR/data retention policy | Create `docs/DATA-RETENTION.md` documenting all local data |
| A6 | Security | Rate limiting on auth endpoints | Mark N/A — no backend exists; auth is local UUID in secure storage |
| A7 | Stale data | Test count 256 → 264 | Update all active docs referencing old count |
| A8 | Stale data | v1.3 Next Steps mentions telemetry | Update — telemetry is done in v1.2 |

### Category B — Runnable Verification (commands in this environment)

| # | Section | Item | Action |
|---|---------|------|--------|
| B1 | Performance | App size analysis | Run `flutter build apk --release --analyze-size` and document results |

### Category C — Human-Gated (require external accounts/hardware/infra)

| # | Section | Item | Blocker | Annotate as |
|---|---------|------|---------|-------------|
| C1 | iOS | Provisioning profile + team ID | Apple Developer account | `BLOCKED: requires Apple Developer account` |
| C2 | iOS | App Store ID assigned | App Store Connect project | `BLOCKED: requires App Store Connect` |
| C3 | iOS | AdHoc signing certificate | Same | `BLOCKED: requires Apple Developer account` |
| C4 | Android | Keystore created/secured | Manual keytool + password | `BLOCKED: requires manual keytool generation` |
| C5 | Android | signing.properties | Follows C4 | `BLOCKED: depends on keystore (C4)` |
| C6 | Android | Play Console project | Google Play account | `BLOCKED: requires Play Console account` |
| C7 | Web | Deploy to staging | Hosting provider choice | `BLOCKED: hosting provider not selected` |
| C8 | Web | Production CDN | Same | `BLOCKED: depends on staging (C7)` |
| C9 | Performance | Lighthouse audit | Real browser on deployed site | `BLOCKED: requires deployed web build` |
| C10 | Accessibility | Screen reader tested | Physical device | `BLOCKED: requires physical device testing` |
| C11 | Accessibility | Axe Core audit | Deployed web app | `BLOCKED: requires deployed web build` |
| C12 | Monitoring | Analytics setup | Firebase project | `BLOCKED: requires Firebase project` |
| C13 | Monitoring | Monitoring dashboard | Firebase project | `BLOCKED: requires Firebase project` |
| C14 | Monitoring | Alert thresholds | Monitoring infra | `BLOCKED: requires monitoring infrastructure` |

### Category D — Launch Sign-Off (human ceremony)

Sign-off checkboxes remain unchecked until actual human sign-off occurs. No code change.

---

## Data Stored by miToosa (for Privacy/GDPR docs)

All data is **local-only** on the user's device. Zero network telemetry.

| Store | Box / Key | Data | PII? | Encryption |
|-------|-----------|------|------|------------|
| Hive | `player_progress_box` | XP, coins, streaks, stars, hearts, diamonds, difficulty settings | No (player ID is random UUID) | AES-256 (key in secure storage) |
| Hive | `telemetry_event_box` | Session start/end timestamps, session duration | No | None (no PII) |
| Secure Storage | `mitoosa_active_player_id` | Random UUID v4 | No (pseudonymous) | Platform keychain |
| Secure Storage | `hive_encryption_key_v1` | AES key for Hive | N/A | Platform keychain |
| Secure Storage | `hive_integrity_key_v1` | HMAC key for integrity | N/A | Platform keychain |

**No data leaves the device. No analytics backend. No crash reporting backend (yet).**

---

## Acceptance Criteria

1. `CHANGELOG.md` exists with v1.2.0 release notes
2. `docs/PRIVACY-POLICY.md` exists with data inventory
3. `docs/DATA-RETENTION.md` exists with retention policy
4. `docs/USER-GUIDE.md` exists with basic onboarding help
5. Stale test count (256) updated to 264 in all active docs
6. Rate limiting marked N/A in LAUNCH.md
7. All Category C items annotated with blockers in LAUNCH.md
8. All implementable items checked off `[x]` in LAUNCH.md
9. `flutter test` still passes (264 tests)
10. `dart analyze` still clean
