# Tasks

## Active

- [ ] **Select web host for staging** - Firebase Hosting, Vercel, or Netlify; record URL in `docs/RELEASE-GATES.md` and `CLAUDE.md`; due Sprint 1 Week 1
- [ ] **Select analytics backend** - Firebase, Amplitude, or Posthog; integrate SDK; confirm one event (session start) appears in dashboard; due Sprint 1 Week 1
- [ ] **Manual wedge QA walkthrough** - fresh install → onboarding → first game → share → streak; check every manual-check box in `docs/update.md`; due Sprint 1 Week 1
- [ ] **Draft and distribute playtest survey** - fill `[STAGING_URL]` in `docs/playtests/SURVEY-TEMPLATE.md`; recruit 15–20 testers; due Sprint 1 Week 1
- [ ] **Run `/qa` on staging and log gate** - update Gate Log row in `docs/RELEASE-GATES.md` with pass/fail; due Sprint 1 Week 2

## Waiting On

- [ ] **Staging URL** - waiting on hosting decision (task above) since 2026-04-22
- [ ] **Playtest responses** - target ≥5 before sprint retro; gates Sprint 2 scope since 2026-04-22
- [ ] **Apple Developer account provisioning** - human action required; blocks TestFlight beta since 2026-04-22
- [ ] **Android keystore creation** - human action required; blocks Play Store internal track since 2026-04-22

## Someday

- [ ] **Backend leaderboard** - scope after playtest shows D1 ≥40% and social motivation signal
- [ ] **Referral tiers (Task 7)** - needs server-side attribution; unblock after backend service exists
- [ ] **VIP / IAP (Task 8)** - needs playtest willingness-to-pay signal + StoreKit/Google Play Billing
- [ ] **Landing page capture flow (Task 9)** - needs external web infrastructure
- [ ] **Web platform encryption shim** - server-side key endpoint; revisit when backend exists; see `docs/decisions/web-platform-crypto.md`

## Done

- [x] ~~Normalize product/monetization source of truth (Task 1)~~ (2026-04-18)
- [x] ~~Define KPI dashboard and event taxonomy (Task 2)~~ (2026-04-18)
- [x] ~~Simplify first-session entry (Task 3)~~ (2026-04-22)
- [x] ~~Implement free-games allowance model (Task 4)~~ (2026-04-22)
- [x] ~~Replace share-for-heart with share bonus (Task 5)~~ (2026-04-22)
- [x] ~~Upgrade streak system into reward ladder (Task 6)~~ (2026-04-22)
- [x] ~~Aetheric Pulse redesign — all P1–P8 items~~ (2026-04-24)
- [x] ~~Archive local-network QR play spec~~ (2026-04-22)
- [x] ~~Update docs/plan.md — archive redesign, add Sprint 1 spec~~ (2026-04-22)
- [x] ~~Create docs/RELEASE-GATES.md gate log + web build command~~ (2026-04-22)
- [x] ~~Create docs/decisions/web-platform-crypto.md~~ (2026-04-22)
- [x] ~~Create docs/playtests/SURVEY-TEMPLATE.md~~ (2026-04-22)
- [x] ~~Create docs/playtests/FINDINGS-TEMPLATE.md~~ (2026-04-22)
