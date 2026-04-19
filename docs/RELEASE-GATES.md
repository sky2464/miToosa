# Release Gates

Every feature and release must pass through these gates in order. Skipping gates leads to shipping local optimizations instead of a coherent product.

## Gate Sequence

```
  1. IDEA       2. STRATEGY     3. BUILD       4. REVIEW      5. QA
 ┌──────────┐  ┌───────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
 │ /office- │→ │ /plan-ceo │→ │  branch  │→ │ /review  │→ │   /qa    │→ SHIP
 │  hours   │  │  -review  │  │   impl   │  │  on diff │  │ staging  │
 └──────────┘  └───────────┘  └──────────┘  └──────────┘  └──────────┘
```

### Gate 1: `/office-hours`

**When:** Before starting any new feature or monetization idea.

- Write a short design note describing the idea, target audience, and expected outcome.
- Output lives in: `docs/` or as a GitHub Discussion.

### Gate 2: `/plan-ceo-review`

**When:** Before implementation starts.

- Confirm the idea fits the product wedge (free-first, 25 daily games, share bonus).
- Check it doesn't contradict locked decisions in [PRODUCT-WEDGE.md](PRODUCT-WEDGE.md).
- Output lives in: `docs/plan-*.md` or the PR description.

### Gate 3: Branch Implementation

**When:** During development.

- Work on a feature branch, not `main`.
- Follow the build-in-small-increments rule: implement → test → verify → commit.
- All tests must pass before requesting review (`flutter test`).

### Gate 4: `/review`

**When:** Before merging to `main`.

- Code review covers: correctness, readability, architecture, security, performance.
- No PR merges without at least one review pass.
- Output lives in: PR review comments.

### Gate 5: `/qa` on Staging

**When:** Before any release to production.

- Deploy to staging URL and verify in a real browser/device.
- Confirm the feature works end-to-end against real data.
- Output lives in: QA checklist in the release PR.

## Staging URL

<!-- HUMAN-ACTION-REQUIRED: Record the staging URL here once it exists -->
**Status:** Not yet configured. Set up a staging deployment (e.g., Firebase Hosting, Vercel, or TestFlight) and record the URL below.

```
Staging URL: TBD
```

## Release Blockers

These conditions **must** be met before any release:

- [ ] All gates passed in order (1 → 5)
- [ ] `flutter test` passes with zero failures
- [ ] `dart analyze` reports no issues
- [ ] No secrets or credentials in committed code
- [ ] QA sign-off on staging deployment

## Where Gate Outputs Live

| Gate | Output location |
|------|----------------|
| `/office-hours` | `docs/` or GitHub Discussions |
| `/plan-ceo-review` | `docs/plan-*.md` or PR description |
| Branch impl | Feature branch + commit history |
| `/review` | PR review comments |
| `/qa` | QA checklist in release PR |

## Tracing a Feature Through All Gates

Example: "Add streak freeze purchase"

1. **Office hours:** Written design note → `docs/plan-streak-freeze.md`
2. **CEO review:** Confirmed it fits convenience-layer principle → noted in plan doc
3. **Branch:** `feature/streak-freeze-purchase` with incremental commits
4. **Review:** PR #XX reviewed for correctness + security (payment handling)
5. **QA:** Tested on staging — purchase flow works, freeze count updates

Only after all 5 gates: merge to `main` and tag for release.
