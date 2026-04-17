# Product profitability execution plan

## Purpose

This dry-run repo is a control plane, not the shipping product. The point of this document is to capture learnings and next concrete tasks so the content can be copied into the main codebase and handed to developers as the operating plan.

This is not a speculative brainstorm. It is the result of a full dry run across the planning loop: product framing, CEO review, engineering review, design review, developer workflow review, landing-page work, playtest design, and monetization loop design.

## Inputs reviewed

- Dry-run artifacts and planning notes (design, test plans, recruitment packs, surveys)
- Previous high-level plan and supporting docs
- Playtest templates and marketing copy for the landing page
- Core app surface areas and libraries (persistence, navigation, onboarding, gameplay, UI widgets)

## What the previous dry-run already completed

The previous dry-run work focused on infrastructure and alignment, not profitability. It successfully completed:

- workspace alignment around the real app
- reusable starter-pack generation and local developer setup
- documentation and smoke validation for the bridge between planning and execution

That work is done. It should not be the focus of app developers now.

## Full synthesis

### 1) Office-hours verdict

- The product is still **pre-product**.
- There is **no validated demand** yet.
- The target audience is currently too broad. The first wedge should target mobile puzzle/brain-game users who play short sessions.
- The recommended wedge is:
    - a **3-minute cognitive loop**
    - **25 free games daily**
    - a **40-game share bonus**
    - **optional upgrades only after value is proven**

### 2) CEO review verdict

- The product becomes real only if it is a **habit loop**, not just “another puzzle game.”
- The profitable path is:
    1. free-first usage
    2. repeat play
    3. social spread
    4. convenience-based monetization
- The product should not pressure users into buying on day one.

### 3) Design review verdict

- The first 30 seconds must answer three questions clearly: what this is, what is free, and what sharing or VIP unlocks.
- Avoid competing economy concepts; choose one top-level economy and subordinate the rest.

### 4) Engineering review verdict

There is already useful infrastructure in the app (progress tracking, persistence, sharing hooks, UI elements). What is missing is **product coherence**:

- no proper **free-games allowance model** yet
- no real **referral attribution** yet
- no **VIP/ad-free product definition** yet
- no **analytics / KPI instrumentation** yet
- no verified **staging URL + QA gate** yet
- no single source of truth for the economy across app, landing page, and playtest docs

### 5) DevEx / workflow review verdict

reference: https://github.com/garrytan/gstack

The operating flow should be mandatory:

1. `/office-hours` for new product or monetization ideas
2. `/plan-ceo-review` before implementation starts
3. implementation on a branch
4. `/review` on the branch diff
5. deploy to staging
6. `/qa` on the staging URL

If the team skips steps 1, 2, 4, or 6, they will ship local optimizations instead of a coherent product.

## Locked decisions

These should be treated as decided unless a future review explicitly overturns them:

- **Free-first is the default business model.**
- **No forced paywall before value.**
- **25 daily free games + 40-game share bonus** is the current test wedge.
- **Daily streak rewards, referral tiers, then VIP/ad-free** is the correct expansion order.
- **The product must prove repeat usage before aggressive monetization.**
- **All future feature work must pass through the planning/review/QA gates.**

## Current blockers and contradictions

1. **Economy mismatch** — multiple competing reward systems exist; decide whether session-only mechanics remain internal or get folded into the top-level allowance.

2. **Artifact drift** — different artifacts contain conflicting copy; consolidate to a single source of truth.

3. **No demand proof** — no validated acquisition, retention, or willingness-to-pay signal yet.

4. **No release gate** — no clearly defined staging URL and browser QA requirement recorded in the shipping workflow.

## Non-negotiable operating rules

- No new feature starts without `/office-hours` or an equivalent written design note.
- No monetization feature starts without `/plan-ceo-review`.
- No code branch merges without `/review`.
- No release goes live without `/qa` on staging.
- No one adds a new currency, reward, or gate without first showing how it fits the existing economy.
- The team optimizes for **repeat play and real usage**, not decorative complexity.

## Architecture decisions for the main app

**Decision 1: choose one top-level economy.**
Recommendation: free games become the user-facing top-level allowance, while session-only mechanics remain internal if still needed.

**Decision 2: sharing must reward real behavior.**
Recommendation: keep anti-abuse logic, but evolve the reward into a product-level share bonus aligned with the free-first promise.

**Decision 3: VIP is a convenience layer, not a toll booth.**
Recommendation: ad-free, extra daily games, streak protection, or early access are acceptable. Locking basic play behind VIP is not.

**Decision 4: measure before scaling.**
Recommendation: instrument the wedge before building the full economy expansion.

## Task List

### Phase 1: Source of truth and measurement foundation

#### Task 1: Normalize the product and monetization source of truth

**Description:**
Create one canonical document in the main app repo that defines the current product wedge, audience, free-first promise, share bonus, and upgrade logic. Remove stale language from dry-run artifacts and app-adjacent docs so the team stops working from contradictory versions.

**Acceptance criteria:**
- [ ] A single source-of-truth doc exists in the main repo.
- [ ] The active offer is clearly stated as 25 free games daily + 40-game share bonus + optional upgrades.
- [ ] Older conflicting copy is removed or marked stale.

**Verification:**
- [ ] Search the repo for outdated economy language and confirm the active wording is consistent.
- [ ] Human review confirms the product story can be explained in one paragraph.

**Dependencies:** None

**Areas likely touched:**
- README and top-level product docs
- docs and product-plan files
- marketing/landing-page copy

**Estimated scope:** Medium

#### Task 2: Define KPI dashboard and event taxonomy

**Description:**
Define the exact events and metrics that decide whether the wedge is working. Include first-session comprehension, daily return, share behavior, and upgrade intent.

**Acceptance criteria:**
- [ ] Event list exists for acquisition, gameplay, sharing, streaks, and upgrade intent.
- [ ] Success metrics are explicit: D1, D7, share rate, upgrade interest, and session frequency.
- [ ] Developers know where each event will be emitted from in the app.

**Verification:**
- [ ] Metrics can be mapped to specific UI actions and state changes.
- [ ] A sample playtest can be scored with the defined metrics.

**Dependencies:** Task 1

**Areas likely touched:**
- Analytics/spec doc and event-emitter locations in the app

**Estimated scope:** Small

### Checkpoint: Product truth locked

- [ ] Product wedge is documented.
- [ ] Economy language is consistent.
- [ ] Metrics exist before feature expansion starts.

### Phase 2: Make the first-session wedge real

#### Task 3: Simplify first-session entry and surface the free-first promise

**Description:**
Reduce first-use friction so the player understands the game and the free offer immediately. The first-time experience must get the player to a real round fast and clearly show what is free.

**Acceptance criteria:**
- [ ] First session reaches playable content quickly.
- [ ] The player sees the free allowance without hunting for it.
- [ ] The onboarding and login path does not overshadow gameplay.

**Verification:**
- [ ] Manual check: a first-time user can reach gameplay in under 60 seconds.
- [ ] Manual check: the free allowance is visible in the first session.

**Dependencies:** Task 1

**Areas likely touched:**
- Onboarding and first-session flows in the app
- Login and main navigation surfaces

**Estimated scope:** Medium

#### Task 4: Implement the free-games allowance model

**Description:**
Introduce the real product economy for the wedge: 25 daily free games plus a share-based bonus. Build on the existing persistence model instead of creating another disconnected state system.

**Acceptance criteria:**
- [ ] Daily free-game allowance exists and resets correctly.
- [ ] The allowance is visible in the player-facing UI.
- [ ] The model does not create a second confusing top-level energy system.

**Verification:**
- [ ] Persistence test confirms daily reset behavior.
- [ ] Manual check confirms the allowance updates correctly after use.
- [ ] Regression tests pass for affected persistence/state code.

**Dependencies:** Task 2, Task 3

**Areas likely touched:**
- Persistence and player progress state
- Gameplay state and allowance model
- UI components that surface allowances and energy

**Estimated scope:** Large, break further if it exceeds 5 files of real logic changes

#### Task 5: Replace share-for-heart with share bonus logic

**Description:**
Evolve the existing sharing mechanic into a product-level share bonus, preserving abuse guardrails.

**Acceptance criteria:**
- [ ] Sharing grants the new bonus, not just a one-heart refill.
- [ ] Daily abuse protection remains intact.
- [ ] UI copy matches the new share reward.

**Verification:**
- [ ] Manual check confirms share success changes the bonus state.
- [ ] Manual check confirms repeated shares do not grant duplicate daily bonuses.

**Dependencies:** Task 4

**Areas likely touched:**
- Sharing UI and share-handling code
- Persistence of share-related bonus state

**Estimated scope:** Medium

### Checkpoint: Wedge exists in the product

- [ ] First-session promise is visible.
- [ ] Daily free allowance works.
- [ ] Share bonus works.
- [ ] Product copy and product behavior match.

### Phase 3: Retention and monetization loops

#### Task 6: Upgrade the existing streak system into a real reward ladder

**Description:**
Turn passive streak display into a reward ladder with meaningful milestones while avoiding punitive resets.

**Acceptance criteria:**
- [ ] Streak rewards exist at meaningful milestones.
- [ ] Missing one day does not create an absurdly punitive experience.
- [ ] The next streak reward is clearly visible.

**Verification:**
- [ ] Manual check confirms streak reward messaging appears correctly.
- [ ] Persistence/state test confirms streak progression and reset logic.

**Dependencies:** Task 4

**Areas likely touched:**
- Progress and streak-related state and UI

**Estimated scope:** Medium

#### Task 7: Implement referral tiers based on active referrals

**Description:**
Add referral tiers that reward real player acquisition; a referral counts only when the referred player actually plays.

**Acceptance criteria:**
- [ ] Referral progress is tracked against real player activity.
- [ ] Tier rewards are capped and abuse-aware.
- [ ] Both sides of a successful referral can be rewarded if desired.

**Verification:**
- [ ] Manual test simulates referral completion and reward unlock.
- [ ] The product team can explain the tier ladder in one short sentence.

**Dependencies:** Task 5

**Areas likely touched:**
- Referral handling and attribution surfaces
- Progress and referral-related UI

**Estimated scope:** Large

#### Task 8: Ship a VIP / ad-free pack as an optional convenience upgrade

**Description:**
Define and implement the first paid path for engaged users as a clear convenience upgrade.

**Acceptance criteria:**
- [ ] VIP/ad-free benefits are clearly defined.
- [ ] The free version remains fun without VIP.
- [ ] The upgrade is shown only in sensible places.

**Verification:**
- [ ] Human review confirms the pack is understandable in one sentence.
- [ ] Manual flow confirms the upgrade UI does not block normal play.

**Dependencies:** Task 4, Task 6

**Areas likely touched:**
- Settings, purchase UI, and entitlement state

**Estimated scope:** Large

### Checkpoint: Retention and money loops are coherent

- [ ] Streak rewards are real.
- [ ] Referral tiers reward actual use.
- [ ] VIP/ad-free is optional and understandable.
- [ ] The economy still feels like one system, not four unrelated coupons.

### Phase 4: Demand proof and release discipline

#### Task 9: Put the landing page and recruitment funnel behind a real capture flow

**Description:**
Replace placeholder capture with a real signup or waitlist flow that matches the in-app offer exactly.

**Acceptance criteria:**
- [ ] Public landing page has a real signup or waitlist flow.
- [ ] The capture flow records responses for playtesting.
- [ ] Landing copy matches the current in-app offer.

**Verification:**
- [ ] Browser check confirms the form works.
- [ ] One real test signup is captured successfully.

**Dependencies:** Task 1, Task 2

**Areas likely touched:**
- Landing page capture and marketing copy
- Playtest capture templates and result storage

**Estimated scope:** Medium

#### Task 10: Run the 15–20 person playtest and publish the findings

**Description:**
Run a playtest, capture responses, and write a short findings memo that drives the next go/no-go decisions.

**Acceptance criteria:**
- [ ] 15–20 testers are recruited.
- [ ] Survey responses are captured in the agreed format.
- [ ] A summary memo exists with conclusions and next actions.

**Verification:**
- [ ] Response sheet contains real data.
- [ ] Findings memo explicitly answers whether the wedge is working.

**Dependencies:** Task 9

**Areas likely touched:**
- Playtest response templates and findings memos in product docs

**Estimated scope:** Medium, but operationally important

#### Task 11: Make the release gates real in the main repo

**Description:**
Move the dry-run workflow into the actual app team process: new ideas start with `/office-hours`, strategy goes through `/plan-ceo-review`, code branches go through `/review`, and releases go through `/qa` on a real staging URL.

**Acceptance criteria:**
- [ ] The main repo documents the required gate sequence.
- [ ] A staging URL exists and is recorded.
- [ ] Branch review and staging QA are release blockers.

**Verification:**
- [ ] A sample feature can be traced through all four gates.
- [ ] The team can explain where outputs from each gate live.

**Dependencies:** Task 1

**Areas likely touched:**
- Repo workflow docs and release gating documentation

**Estimated scope:** Small

### Final checkpoint: Ready for developers to execute

- [ ] Product wedge is documented and consistent.
- [ ] First-session free-first model exists in the app.
- [ ] Retention loops are ordered correctly.
- [ ] Monetization is optional and coherent.
- [ ] Demand proof plan is real.
- [ ] Release and QA gates are operational in the main repo.

## Priority order for the team

1. **Task 1** — normalize the source of truth
2. **Task 2** — define metrics and events
3. **Task 3** — fix first-session friction
4. **Task 4** — build the daily free allowance
5. **Task 5** — replace share-for-heart with share bonus
6. **Task 10** — run real playtests
7. **Task 6** — meaningful streak rewards
8. **Task 7** — referral tiers
9. **Task 8** — VIP/ad-free pack
10. **Task 11** — lock in release discipline

## Risks and mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Multiple reward systems cause confusion | High | Choose one top-level economy before implementation |
| Landing page and in-app offer drift again | High | Make Task 1 the source-of-truth gate |
| No analytics means no real product learning | High | Make Task 2 mandatory before economy expansion |
| Referral rewards get spammy | Medium | Require active referral completion and cap weekly rewards |
| VIP feels like a fake free product | High | Keep VIP optional and convenience-based |
| The team ships without staging QA | High | Make Task 11 a release blocker |

## Open questions

- Should session-only mechanics remain, or should free games fully replace them?
- What staging URL should `/qa` target?
- What analytics backend should own the KPI dashboard?
- Where should product findings live in the main repo after each playtest round?
- Should VIP launch as monthly only, lifetime only, or not at all until retention is proven?

## Copy-note for main repo

When this document is moved into the main codebase, preserve these three sections unchanged:

1. **Locked decisions**
2. **Task List**
3. **Priority order for the team**

Those are the parts developers should focus on; the rest is supporting rationale and context.
