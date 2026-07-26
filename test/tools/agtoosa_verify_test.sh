#!/usr/bin/env bash
# BL-27 — fixture tests for docs/agtoosa-verify.sh project-ID parsing.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VERIFIER="$ROOT/docs/agtoosa-verify.sh"

if [[ ! -f "$VERIFIER" ]]; then
  echo "FAIL: missing verifier at $VERIFIER" >&2
  exit 1
fi

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

pass_count=0
fail_count=0

assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    pass_count=$((pass_count + 1))
    echo "  PASS  $label"
  else
    fail_count=$((fail_count + 1))
    echo "  FAIL  $label (expected=$expected actual=$actual)" >&2
  fi
}

json_finding_ids() {
  local json="$1"
  python3 - <<'PY' "$json"
import json, sys
doc = json.loads(sys.argv[1])
for item in doc.get("findings", []):
    print(item.get("id", ""))
PY
}

has_finding() {
  local json="$1" fid="$2"
  json_finding_ids "$json" | grep -Fxq "$fid"
}

write_context_stubs() {
  local docs_dir="$1"
  mkdir -p "$docs_dir/Context"
  for name in product.md tech-stack.md workflow.md; do
    cat >"$docs_dir/Context/$name" <<EOF
# $name

Project context stub for verifier fixtures.
EOF
  done
}

write_story_artifacts() {
  local docs_dir="$1" story_id="$2"
  mkdir -p "$docs_dir/archived"
  cat >"$docs_dir/archived/spec-${story_id}.md" <<EOF
# Spec: ${story_id}

## 1. Requirements

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the fixture runs THE SYSTEM SHALL discover ${story_id}. | Must |

## 2. Design

### 2.3 Threat Model (STRIDE)

| Threat | Mitigation |
|--------|------------|
| Spoofing | Fixture-only scope. |

## 3. Tasks

### 3.2 Wave Plan

**Wave 1:** 1.1

## ✅ Spec Approved

Approved: 2026-07-14
EOF
  cat >"$docs_dir/AgToosa_TestPlan-${story_id}.md" <<EOF
# Test Plan — ${story_id}

| AC ID | Test ID |
|-------|---------|
| AC-001 | T-001 |

RED evidence — 1.1
Command: bash test/tools/agtoosa_verify_test.sh
Exit code: 1
Failure excerpt: fixture RED placeholder
EOF
}

write_master_plan() {
  local docs_dir="$1"
  local body="$2"
  cat >"$docs_dir/Master-Plan.md" <<EOF
# Master-Plan

## Project Charter

| Field | Value |
|-------|-------|
| Product | Fixture project |

${body}

## Blocked

*(empty)*

## Backlog

*(empty)*

## Update Log

| Date | Event | By |
|------|-------|-----|
| 2026-07-14 | fixture | test |
EOF
}

run_verifier_json() {
  local fixture_root="$1"
  bash "$VERIFIER" --root "$fixture_root" --format json 2>/dev/null
}

setup_ep_bl_fixture() {
  local fixture_root="$TMP_ROOT/ep-bl"
  local docs="$fixture_root/docs"
  mkdir -p "$docs/archived"
  write_context_stubs "$docs"
  write_story_artifacts "$docs" "BL-25"
  write_master_plan "$docs" "$(cat <<'PLAN'
## Active Cycle

| ID | Title | Type | Estimate | Status | Tasks Done |
|----|-------|------|----------|--------|-----------|
| BL-25 | Fixture story | Feature | S | 🟦 Todo | 0/1 |

## Active Tasks

### BL-25 — Fixture story

- [ ] **1.** Fixture task

## Epics

| ID | Title | Stories | Status |
|----|-------|---------|--------|
| EP-01 | Launch | 1 / 1 | In Progress |
PLAN
)"
  echo "$fixture_root"
}

setup_dev_fixture() {
  local fixture_root="$TMP_ROOT/dev"
  local docs="$fixture_root/docs"
  mkdir -p "$docs/archived"
  write_context_stubs "$docs"
  write_story_artifacts "$docs" "DEV-001"
  write_master_plan "$docs" "$(cat <<'PLAN'
## Active Cycle

| ID | Title | Type | Estimate | Status | Tasks Done |
|----|-------|------|----------|--------|-----------|
| DEV-001 | Legacy story | Chore | XS | 🟦 Todo | 0/1 |

## Active Tasks

### DEV-001 — Legacy story

- [ ] **1.** Fixture task

## Epics

| ID | Title | Stories | Status |
|----|-------|---------|--------|
| DEV-001 | Legacy epic | 1 / 1 | In Progress |
PLAN
)"
  echo "$fixture_root"
}

setup_invalid_fixture() {
  local fixture_root="$TMP_ROOT/invalid"
  local docs="$fixture_root/docs"
  mkdir -p "$docs/archived"
  write_context_stubs "$docs"
  write_master_plan "$docs" "$(cat <<'PLAN'
## Active Cycle

| ID | Title | Type | Estimate | Status | Tasks Done |
|----|-------|------|----------|--------|-----------|
| bl-25 | lowercase id | Feature | S | 🟦 Todo | 0/1 |
| BL-abc | bad suffix | Feature | S | 🟦 Todo | 0/1 |
| 2026-07-14 | date token | Feature | S | 🟦 Todo | 0/1 |

## Active Tasks

*(none)*

## Epics

| ID | Title | Stories | Status |
|----|-------|---------|--------|
| EP-01 | Valid epic | 1 / 1 | In Progress |

Prose reference BL-25 must not be discovered as an active story.
PLAN
)"
  echo "$fixture_root"
}

echo "agtoosa_verify_test.sh — BL-27 fixtures"

# T-001 / T-005 — EP-* and BL-* recognition (no G2-epics / G3-idle)
ep_bl_root="$(setup_ep_bl_fixture)"
ep_bl_json="$(run_verifier_json "$ep_bl_root")"
if has_finding "$ep_bl_json" "G2-epics"; then
  assert_eq "T-001 EP-01 epic recognized (no G2-epics)" "no" "yes"
else
  assert_eq "T-001 EP-01 epic recognized (no G2-epics)" "no" "no"
fi
if has_finding "$ep_bl_json" "G3-idle"; then
  assert_eq "T-002 BL-25 active story discovered (no G3-idle)" "no" "yes"
else
  assert_eq "T-002 BL-25 active story discovered (no G3-idle)" "no" "no"
fi

# T-005 — DEV-* backward compatibility
dev_root="$(setup_dev_fixture)"
dev_json="$(run_verifier_json "$dev_root")"
if has_finding "$dev_json" "G2-epics" || has_finding "$dev_json" "G3-idle"; then
  assert_eq "T-005 DEV-001 compatibility (no prefix findings)" "ok" "fail"
else
  assert_eq "T-005 DEV-001 compatibility (no prefix findings)" "ok" "ok"
fi

# T-004 — invalid first-column tokens are not active stories
invalid_root="$(setup_invalid_fixture)"
invalid_json="$(run_verifier_json "$invalid_root")"
if has_finding "$invalid_json" "G3-idle"; then
  assert_eq "T-004 invalid IDs ignored (G3-idle when no valid active IDs)" "yes" "yes"
else
  assert_eq "T-004 invalid IDs ignored (G3-idle when no valid active IDs)" "yes" "no"
fi
if has_finding "$invalid_json" "G3-spec-missing-BL-25"; then
  assert_eq "T-004 prose BL-25 not discovered as active story" "no" "yes"
else
  assert_eq "T-004 prose BL-25 not discovered as active story" "no" "no"
fi

# Real project — AC-005 smoke (no prefix-parser findings)
real_json="$(bash "$VERIFIER" --root "$ROOT" --format json 2>/dev/null || true)"
if has_finding "$real_json" "G2-epics" || has_finding "$real_json" "G3-idle"; then
  assert_eq "T-003/AC-005 real project (no G2-epics/G3-idle from prefix parser)" "ok" "fail"
else
  assert_eq "T-003/AC-005 real project (no G2-epics/G3-idle from prefix parser)" "ok" "ok"
fi

echo ""
echo "Summary: $pass_count passed, $fail_count failed"
if [[ $fail_count -gt 0 ]]; then
  exit 1
fi
