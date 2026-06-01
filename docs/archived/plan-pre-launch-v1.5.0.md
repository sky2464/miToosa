# miToosa Development Plan

**Last Updated:** 2026-04-24
**Current Version:** v1.5.0
**Status:** Archived

---

## 🎯 Current State

### ✅ Completed
- **Aetheric Pulse Redesign** — Modern iOS 2026 aesthetic with glassmorphism, dopamine feedback, ADHD-optimized flow (637 tests passing)
- **Product Wedge Definition** — Free-first model: 25 daily games + 40-game share bonus documented in `PRODUCT-WEDGE.md`
- **Core Gameplay Engine** — Preparation → Sequence → Recall loop with 8 puzzle tracks, 23 levels per track
- **Engagement Systems** — Streak rewards, XP progression, achievement framework, daily rewards
- **Local Telemetry** — Hive-based event tracking ready for analytics backend integration
- **Cross-Platform Support** — iOS, Android, Web, macOS builds verified
- **Accessibility** — WCAG AA compliance, 44pt touch targets, semantic labels, Dynamic Type support
- **Release Infrastructure** — Build scripts, release gates documented, privacy policy drafted

### 🚧 In Progress
- **Sprint 1 Active Tasks** (from TASKS.md):
  - Select web host for staging
  - Select analytics backend
  - Manual wedge QA walkthrough
  - Draft and distribute playtest survey
  - Run `/qa` on staging

---

## 📋 Big Topics — Next Development Phases

### 🔴 EPIC: Launch Readiness & Validation
**Priority:** P0 — Blocking all other work
**Goal:** Prove the product works with real users before building new features

#### Feature: Staging Deployment & QA Gate
- **What:** Deploy web build to public staging URL, establish `/qa` review process
- **Why:** Cannot run playtest or validate wedge without accessible staging environment
- **Scope:**
  - Select hosting provider (Firebase Hosting, Vercel, or Netlify)
  - Configure deployment pipeline
  - Document staging URL in `RELEASE-GATES.md` and `CLAUDE.md`
  - Run full `/qa` checklist on staging
- **Blockers:** None — ready to start
- **Estimate:** 1-2 days

#### Feature: Analytics Backend Integration
- **What:** Select and integrate cloud analytics (Firebase Analytics, Amplitude, or Posthog)
- **Why:** Need to measure KPIs (D1 retention, share rate, session completion) to validate wedge
- **Scope:**
  - Evaluate analytics options against requirements in `analytics-events-v1.3.md`
  - Integrate SDK and wire up existing telemetry events
  - Verify at least one event (session_start) appears in dashboard
  - Document analytics setup in operations guide
- **Blockers:** None — local telemetry already instrumented
- **Estimate:** 2-3 days

#### Chore: Manual Wedge QA Walkthrough
- **What:** Human verification of full product loop (onboarding → gameplay → share → streak)
- **Why:** Automated tests pass but no human has verified the wedge works as described
- **Scope:**
  - Fresh install → onboarding completion
  - First game → level completion
  - Share flow → bonus grant verification
  - Streak day 1 → return next day verification
  - Document findings and file bugs for any failures
- **Blockers:** Staging deployment (need accessible URL)
- **Estimate:** 4-6 hours

#### Feature: Playtest Survey & Recruitment
- **What:** Recruit 15-20 testers, distribute survey, capture responses
- **Why:** Zero demand signal exists; need real user feedback to validate product-market fit
- **Scope:**
  - Fill `[STAGING_URL]` in `docs/playtests/SURVEY-TEMPLATE.md`
  - Recruit testers (social media, communities, personal network)
  - Distribute survey and staging link
  - Capture ≥5 responses before sprint close
  - Synthesize findings using `FINDINGS-TEMPLATE.md`
- **Blockers:** Staging deployment, analytics backend (to measure behavior)
- **Estimate:** 1 week (mostly waiting for responses)

---

### 🟠 EPIC: Platform Release Infrastructure
**Priority:** P1 — Required for App Store/Play Store launch
**Goal:** Unblock iOS and Android distribution channels

#### Chore: iOS Provisioning & Signing Setup
- **What:** Configure Apple Developer account, provisioning profiles, signing certificates
- **Why:** Blocking TestFlight beta and App Store submission
- **Scope:**
  - Apple Developer account setup ($99/year)
  - Bundle ID registration (`com.mitoosa.app`)
  - Provisioning profile download
  - Signing certificate (.p8) configuration in Xcode
  - App Store Connect project creation
  - App Store ID assignment (replace placeholder `id0000000000`)
- **Blockers:** Human action required (account signup, payment)
- **Estimate:** 2-3 hours (plus Apple review time)

#### Chore: Android Keystore & Signing Setup
- **What:** Generate release keystore, configure signing properties
- **Why:** Blocking Play Store internal track and production release
- **Scope:**
  - Generate keystore with `keytool` (10,000-day validity)
  - Secure keystore file and passwords
  - Create `signing.properties` with keystore path/credentials
  - Configure `build.gradle.kts` signing config
  - Google Play Developer account setup ($25 one-time)
  - Play Console project creation
- **Blockers:** Human action required (account signup, payment)
- **Estimate:** 2-3 hours

#### Feature: Firebase Project Setup
- **What:** Create Firebase project, integrate Crashlytics and Performance Monitoring
- **Why:** Production monitoring required for launch (crash reporting, performance tracking)
- **Scope:**
  - Firebase project creation
  - Add iOS, Android, Web apps to project
  - Integrate `firebase_crashlytics` SDK
  - Integrate `firebase_performance` SDK
  - Configure alert thresholds (crash rate >1%, latency p95 >3s)
  - Test crash reporting with manual exception
- **Blockers:** None — can start immediately
- **Estimate:** 1 day

---

### 🟡 EPIC: Retention & Monetization Expansion
**Priority:** P2 — Deferred until playtest validates wedge
**Goal:** Build on validated foundation with backend-dependent features

#### Feature: Backend Leaderboard (Real-Time)
- **What:** Server-side leaderboard with live XP rankings
- **Why:** Social motivation signal from playtest; current leaderboard is placeholder
- **Scope:**
  - Select backend (Supabase, Firebase RTDB, or Cloudflare Workers + KV)
  - Design leaderboard schema (player_id, xp, rank, last_updated)
  - Implement sync logic (push XP on level complete, pull top 100)
  - Add leaderboard UI refresh and real-time updates
  - Handle offline/sync conflicts
- **Blockers:** Playtest validation (need D1 ≥40% and social motivation signal)
- **Estimate:** 1 week
- **Decision Gate:** Only proceed if playtest shows strong retention and social engagement

#### Feature: Referral Attribution System
- **What:** Server-side referral tracking with active-play verification
- **Why:** Task 7 deferred — local Hive cannot verify referred player actually played
- **Scope:**
  - Thin server accepting anonymous player IDs
  - Referral link generation with unique codes
  - "Referral completed" webhook when referred player finishes first game
  - Referral tier rewards (capped, abuse-aware)
  - UI for referral progress and tier milestones
- **Blockers:** Backend service (leaderboard backend can be extended)
- **Estimate:** 1 week
- **Decision Gate:** Only proceed if playtest shows share rate ≥20%

#### Feature: VIP / Ad-Free Convenience Pack
- **What:** Optional paid upgrade (ad-free, +10 daily games, streak freeze, early access)
- **Why:** Task 8 deferred — needs playtest willingness-to-pay signal
- **Scope:**
  - Define VIP benefits (one-page product definition)
  - Integrate StoreKit (iOS) and Google Play Billing (Android)
  - Implement entitlement state management
  - Add VIP upgrade prompts (non-blocking, sensible placement)
  - Test purchase flow on TestFlight and internal track
- **Blockers:** Playtest validation (need "would you pay?" ≥30% yes/maybe)
- **Estimate:** 1.5 weeks
- **Decision Gate:** Only proceed if playtest shows willingness-to-pay signal

---

### 🟢 EPIC: User Experience Polish
**Priority:** P3 — Nice-to-have improvements
**Goal:** Refine UX based on playtest feedback

#### Enhancement: First-Session Onboarding Optimization
- **What:** Reduce friction in first 60 seconds (onboarding → first game)
- **Why:** Playtest may reveal confusion or drop-off points
- **Scope:**
  - Analyze playtest session recordings (if available)
  - Identify friction points (unclear copy, confusing navigation, slow loading)
  - Simplify onboarding flow (reduce pages, clearer CTAs)
  - A/B test variations (if backend supports)
- **Blockers:** Playtest findings
- **Estimate:** 3-5 days
- **Decision Gate:** Only proceed if first-session completion <80%

#### Enhancement: Economy Messaging Clarity
- **What:** Improve copy and UI for free-games allowance, share bonus, streak rewards
- **Why:** Playtest may reveal economy confusion
- **Scope:**
  - Review playtest feedback for confusion signals
  - Rewrite unclear copy (allowance display, share CTA, streak milestones)
  - Add tooltips or help modals for complex concepts
  - Test revised messaging with follow-up playtest
- **Blockers:** Playtest findings
- **Estimate:** 2-3 days
- **Decision Gate:** Only proceed if playtest shows economy confusion

#### Enhancement: Accessibility Audit (Physical Devices)
- **What:** Test with TalkBack (Android) and VoiceOver (iOS) on real devices
- **Why:** Deferred from launch checklist — requires physical hardware
- **Scope:**
  - Borrow or purchase test devices (iPhone, Android phone)
  - Run full product flow with screen readers enabled
  - Document accessibility issues (missing labels, incorrect focus order)
  - Fix critical issues (blocking navigation, unreadable content)
  - Run Axe Core audit on deployed web build
- **Blockers:** Physical devices
- **Estimate:** 1 day
- **Decision Gate:** Can proceed anytime after staging deployment

---

### 🔵 EPIC: Technical Debt & Infrastructure
**Priority:** P4 — Ongoing maintenance
**Goal:** Keep codebase healthy and dependencies current

#### Chore: Dependency Maintenance (Automated)
- **What:** Weekly automated dependency health checks and safe upgrades
- **Why:** Already implemented and operational (see `OPERATIONS-dependency-maintenance.md`)
- **Scope:**
  - Monitor weekly GitHub Actions runs (Mondays @ 06:00 UTC)
  - Review auto-generated PRs for safe upgrades
  - Manually handle major version bumps (breaking changes)
  - Update skill files when dependencies change
- **Blockers:** None — already running
- **Estimate:** 1-2 hours/week (ongoing)

#### Chore: Test Coverage Expansion
- **What:** Add integration tests for full workflows (error paths, git operations)
- **Why:** Current coverage is 637 unit/widget tests; integration tests deferred
- **Scope:**
  - Integration tests for dependency health script workflows
  - Error recovery tests (network failures, timeouts)
  - CI workflow validation tests
  - Estimate from test coverage analysis: 6-8 hours
- **Blockers:** None — can start anytime
- **Estimate:** 1 week

#### Enhancement: Web Platform Crypto Hardening
- **What:** Add web-specific encryption shim for localStorage (currently plaintext)
- **Why:** Known decision documented in `docs/decisions/web-platform-crypto.md`
- **Scope:**
  - Design web crypto approach (server-side key endpoint or client-side key derivation)
  - Implement encryption layer for Hive web adapter
  - Test encryption/decryption performance
  - Document security model and limitations
- **Blockers:** Product decision (accept plaintext for now vs. build shim)
- **Estimate:** 1 week
- **Decision Gate:** Revisit after playtest if web is primary platform

---

## 🚦 Decision Gates & Priorities

### Immediate (This Week)
1. **Staging Deployment** — Unblocks playtest and QA
2. **Analytics Backend** — Unblocks KPI measurement
3. **Manual QA Walkthrough** — Validates wedge works
4. **Playtest Launch** — Generates demand signal

### Next (After Playtest)
- **If D1 ≥40% and share rate ≥20%:** Proceed with backend leaderboard, referral system, VIP
- **If D1 <40% or economy confusion:** Focus on first-session optimization, economy messaging clarity, second playtest round

### Platform Release (Parallel Track)
- iOS provisioning and Android keystore setup can proceed in parallel with playtest
- Firebase project setup should happen before App Store/Play Store submission
- TestFlight beta and Play Store internal track testing before public launch

### No New Features Until
- Playtest has ≥5 responses
- Manual wedge QA is green (zero P0 bugs)
- Staging URL is operational

---

## 📊 Success Metrics (KPIs)

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Test Suite | 100% passing | 637/637 ✅ | Green |
| Build Health | Zero errors | ✅ iOS/Android/Web/macOS | Green |
| Staging URL | Live | ❌ Not deployed | Blocked |
| Analytics Events | ≥1 firing | ❌ No backend | Blocked |
| Playtest Responses | ≥5 | 0 | Blocked |
| D1 Retention | ≥40% | Unknown | Awaiting playtest |
| Share Rate | ≥20% | Unknown | Awaiting playtest |
| First-Session Completion | ≥80% | Unknown | Awaiting playtest |

---

## 📁 Key Documentation

- **Product Strategy:** `docs/PRODUCT-WEDGE.md`
- **Release Gates:** `docs/RELEASE-GATES.md`
- **Launch Plan:** `docs/LAUNCH.md`
- **Analytics Events:** `docs/analytics-events-v1.3.md`
- **Build Guide:** `docs/BUILD.md`
- **Operations:** `docs/OPERATIONS-dependency-maintenance.md`
- **Archived Plans:** `docs/archived/` (completed work, historical context)

---

## 🔄 Sprint Cadence

**Current Sprint:** Sprint 1 — Launch Readiness & Validation (Week of 2026-04-22)
**Sprint Length:** 2 weeks
**Sprint Retro:** End of Week 2 — Go/no-go decision on Sprint 2 features

**Sprint 2 Preview (Conditional):**
- If playtest positive: Backend foundation (leaderboard, referral), TestFlight beta
- If playtest negative: First-session redesign, economy overhaul, second playtest

---

## 📞 Questions & Escalation

**For product decisions:** See `PRODUCT-WEDGE.md` locked decisions
**For technical questions:** See `BUILD.md`, `LAUNCH.md`, or `OPERATIONS-dependency-maintenance.md`
**For release gates:** See `RELEASE-GATES.md` gate sequence
**For archived context:** See `docs/archived/` folder

---

**Last Review:** 2026-04-24
**Next Review:** After Sprint 1 closes (playtest responses captured)
