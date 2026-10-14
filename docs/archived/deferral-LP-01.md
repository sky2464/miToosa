# Deferral record — LP-01 local network QR play (#54)

> **Story:** LP-01 — Local network QR play (deferred POC)  
> **Decision date:** 2026-10-14  
> **Launch scope:** Not in v1.5.1 iPhone TestFlight / App Store path (EP-05 experimentation).

## Decision

**Defer full LAN/QR multiplayer POC** until after launch-readiness gates (BL-25 manual TestFlight, BL-26 listing URLs). Do not expand `lib/features/local_play/` in this cycle.

## Rationale

- [spec-LP-01.md](spec-LP-01.md) describes a large surface (WebSocket host/guest sync, scoring, security bounds, integration tests). That is not a **minimal** POC.
- Existing `lib/features/local_play/` already holds experimental UI scaffolding (host/scan screens) from pre-launch exploration; it is **not** wired as a supported player journey and remains gated from primary navigation (see BL-31 launch surfaces).
- v1.5.1 priority stays iPhone solo play, wedge economy, and physical-device QA — not same-WiFi multiplayer.

## What stays in the repo

- Legacy screens under `lib/features/local_play/` remain for future experimentation; no new dependencies or menu exposure in this deferral.
- Canonical requirements remain in [spec-LP-01.md](spec-LP-01.md) and [plan-local-network-qr-play-v1.md](plan-local-network-qr-play-v1.md).

## Reactivation criteria (future cycle)

1. BL-25/BL-26 manual gates closed with evidence on a TestFlight build.
2. Dedicated LP-01 build slice approved with minimal host/guest happy-path only (single level sync), plus NSLocalNetworkUsageDescription and App Store privacy review if iOS camera/LAN is enabled.
3. Unit tests for message models and session lifecycle before any Settings/menu surfacing.

## Owner next action

Product owner schedules LP-01 after Stage 1 premium-quality P0 items (BL-39–BL-42) or explicitly reprioritizes EP-05.
