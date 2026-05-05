# Spec: S1-04 — Playtest Survey & Recruitment

**Story ID:** S1-04
**Epic:** EP-01 — Launch Readiness & Validation
**Status:** Draft
**Date:** 2026-05-04
**Author:** AgToosa

---

## Context

`docs/playtests/SURVEY-TEMPLATE.md` has 18 questions across 6 sections measuring the core success
metrics: D1 retention intent, free-games model comprehension, share prompt reaction, and
willingness-to-pay signal. `docs/playtests/FINDINGS-TEMPLATE.md` exists for aggregating results.

Target: 15–20 testers for a minimum viable signal. Minimum viable: 5+ responses (enough for
directional insight on D1 intent and economy comprehension).

The survey distribution URL will be `[STAGING_URL]` (from S1-01). While staging is pending, the
Google Form can be created and the URL slot pre-staged. A `flutter run -d chrome` localhost link can
serve as a temporary substitute for early internal testers.

---

## Scope

1. Create a Google Form from `docs/playtests/SURVEY-TEMPLATE.md` (all 18 questions, verbatim copy)
2. Set the play link in Section 1 to `[STAGING_URL]` (or localhost if staging not yet live)
3. Record the Google Form share link in `docs/playtests/SURVEY-TEMPLATE.md` under a new `## Form Link` section
4. Create `docs/playtests/findings-sprint1.md` from `FINDINGS-TEMPLATE.md`
5. Recruit 15–20 testers; document outreach channels used in findings doc
6. Collect responses; note when ≥ 5 are in (minimum viable signal)

---

## Survey Distribution Design

**Platform:** Google Forms (free, no sign-in required for respondents, auto-collects responses)
**Alternative:** Typeform (better UX but requires account)

**Tester message template:**
```
Hey! Quick favour — I'm playtesting a mobile puzzle game called miToosa.
Takes ~5 minutes to play + a short survey. All feedback is genuinely helpful.

Play here: [STAGING_URL]
Survey: [GOOGLE_FORM_LINK]

No sign-in needed. Thanks!
```

**Recruitment channels (priority order):**
1. Personal network (friends, family who play mobile games)
2. r/indiegaming, r/androidgaming, r/iosgaming — post with brief pitch + links
3. Discord servers: indie-game dev communities, Flutter/Dart communities
4. Any existing beta contacts from prior iToosa testing rounds

---

## Acceptance Criteria

| ID | Scenario | Given | When | Then | Priority |
|----|----------|-------|------|------|----------|
| AC-001 | Form has all 18 questions | SURVEY-TEMPLATE.md | Google Form reviewed | All 18 questions present verbatim, in section order (Q1–Q18) | Must |
| AC-002 | Play URL is in Section 1 | Form created | Tester opens form | Play link is in the instructions at the top of Section 1 | Must |
| AC-003 | No sign-in required | Form share link used | Anyone opens link | Form is fillable without a Google account | Must |
| AC-004 | Form link recorded | Form created | `docs/playtests/SURVEY-TEMPLATE.md` opened | `## Form Link` section present with the share URL | Must |
| AC-005 | Findings doc ready | FINDINGS-TEMPLATE.md exists | S1-04 ships | `docs/playtests/findings-sprint1.md` exists and is pre-populated with section headers | Must |
| AC-006 | Minimum viable signal | Form distributed | Sprint 1 closes | ≥ 5 completed survey responses in Google Form | Should |
| AC-007 | Recruitment target | Outreach complete | Sprint 1 closes | 15–20 testers have received the play link + survey link | Should |
| AC-008 | Economy comprehension tracked | Responses collected | Results reviewed | Q7 (free games per day) open-text and Q8 (awareness) results surfaced in findings doc | Must |

---

## Success Signals (from `docs/Context/product.md`)

Review responses against these targets after playtest:

| Metric | Target | Survey question |
|--------|--------|----------------|
| D1 return intent | ≥ 40% "very likely" | Q10 |
| Free-games model comprehension | ≥ 80% understand it | Q7, Q8 |
| Share prompt positive/neutral | ≥ 60% | Q9 |
| Would pay for VIP | ≥ 30% yes/maybe | Q13 |
| Time-to-first-game ≤ 60s | ≥ 80% | Q3 |

---

## Definition of Done

- [ ] Google Form created with all 18 questions from SURVEY-TEMPLATE.md
- [ ] Form share link recorded in `docs/playtests/SURVEY-TEMPLATE.md`
- [ ] `docs/playtests/findings-sprint1.md` created (pre-populated, ready for data)
- [ ] Testers contacted; at least 5 confirmed responses or outreach documented
- [ ] T-04 status updated to Done in Master-Plan.md
