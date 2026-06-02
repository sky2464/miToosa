#!/usr/bin/env bash
# test/scripts/verify_pr_workflow_test.sh
# Static checks for PR validation parity (verify-pr.sh ↔ pr-validation.yml).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORKFLOW="${REPO_ROOT}/.github/workflows/pr-validation.yml"
VERIFY_SCRIPT="${REPO_ROOT}/scripts/verify-pr.sh"

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

test_it() {
  local name="$1"
  local cmd="$2"
  TESTS_RUN=$((TESTS_RUN + 1))
  if eval "$cmd" 2>/dev/null; then
    echo "✓ PASS: $name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "✗ FAIL: $name"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_file_contains() {
  local file="$1"
  local pattern="$2"
  grep -qE "$pattern" "$file"
}

test_it "verify-pr.sh exists and is executable" '
  [[ -f "$VERIFY_SCRIPT" ]] && [[ -x "$VERIFY_SCRIPT" ]]
'

test_it "pr-validation.yml runs dart format check" '
  assert_file_contains "$WORKFLOW" "dart format --output=none --set-exit-if-changed"
'

test_it "pr-validation.yml runs dart analyze" '
  assert_file_contains "$WORKFLOW" "dart analyze"
'

test_it "pr-validation.yml runs flutter test" '
  assert_file_contains "$WORKFLOW" "flutter test"
'

test_it "pr-validation.yml uses Flutter action cache" '
  assert_file_contains "$WORKFLOW" "cache: true"
'

test_it "pr-validation.yml triggers on pull_request to main" '
  assert_file_contains "$WORKFLOW" "pull_request:" &&
  assert_file_contains "$WORKFLOW" "main"
'

test_it "pr-validation.yml supports workflow_dispatch" '
  assert_file_contains "$WORKFLOW" "workflow_dispatch"
'

test_it "verify-pr.sh mirrors format, analyze, and test" '
  assert_file_contains "$VERIFY_SCRIPT" "dart format --output=none --set-exit-if-changed" &&
  assert_file_contains "$VERIFY_SCRIPT" "dart analyze" &&
  assert_file_contains "$VERIFY_SCRIPT" "flutter test"
'

test_it "verify-pr.sh runs conditional doc guards" '
  assert_file_contains "$VERIFY_SCRIPT" "verify_docs_archival.sh" &&
  assert_file_contains "$VERIFY_SCRIPT" "check_prompt_injection.sh"
'

echo ""
echo "Results: ${TESTS_PASSED}/${TESTS_RUN} passed, ${TESTS_FAILED} failed"
[[ "$TESTS_FAILED" -eq 0 ]]
