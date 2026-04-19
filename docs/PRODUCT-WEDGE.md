# Product Wedge — miToosa

**Status:** Active — canonical source of truth  
**Last updated:** 2026-04-18

---

## Audience

Mobile puzzle / brain-game players who play short sessions (3–5 minutes).

## One-paragraph product story

miToosa is a free-first cognitive puzzle game. Every player gets **25 free games daily** — no sign-up paywall, no forced ads. Sharing the app with a friend unlocks a **40-game share bonus**. Optional upgrades (VIP / ad-free) exist only as a convenience layer for engaged players who want extras like streak protection or bonus daily games. The product proves its value before asking for money.

## Active offer (test wedge)

| Element | Value |
|---------|-------|
| Daily free games | 25 |
| Share bonus | +40 games per successful share (once per day, anti-abuse enforced) |
| Top-level currency | Free games (replaces hearts as user-facing economy) |
| Session mechanics | Hearts and diamonds remain as internal session-level mechanics |
| Upgrade path | VIP / ad-free convenience pack (optional, not a gate) |

## Economy rules

1. **Free games** are the single top-level user-facing allowance. They reset daily.
2. **Hearts** (❤) and **diamonds** (💎) are session-level mechanics that manage hint usage and in-round recovery. They do not compete with the free-games allowance.
3. **Sharing** grants a daily share bonus (40 additional games). Anti-abuse guardrails (one share reward per day) remain.
4. **Streaks** reward consecutive daily play with meaningful milestone bonuses. Missing one day does not destroy all progress.
5. **Referrals** count only when the referred player actually plays. Tiers are capped and abuse-aware.
6. **VIP / ad-free** is a convenience upgrade: ad removal, extra daily games, streak protection, or early access. Locking basic play behind VIP is not allowed.

## Locked decisions

These are decided unless a future review explicitly overturns them:

- Free-first is the default business model.
- No forced paywall before value.
- 25 daily free games + 40-game share bonus is the current test wedge.
- Daily streak rewards → referral tiers → VIP/ad-free is the correct expansion order.
- The product must prove repeat usage before aggressive monetization.
- All future feature work must pass through the planning/review/QA gates.

## Expansion order

1. Free-games allowance model (Task 4 in update.md)
2. Share bonus replaces share-for-heart (Task 5)
3. Streak reward ladder (Task 6)
4. Referral tiers (Task 7)
5. VIP / ad-free pack (Task 8)

## What this replaces

This document is the canonical reference for product economy language. Any conflicting copy in older docs, dry-run artifacts, or marketing drafts should defer to this file. See `docs/update.md` for the full task list and rationale.
