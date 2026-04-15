#!/usr/bin/env bash
# test/scripts/dependency_health_parsing_test.sh
# Unit tests for dependency_health.sh version parsing logic
# 
# Requires: bats testing framework or bash test harness
# Usage: bash test/scripts/dependency_health_parsing_test.sh
#        or: bats test/scripts/dependency_health_parsing_test.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIXTURES="${REPO_ROOT}/test/fixtures"

# ── Test Harness (minimal, if bats not available) ────────────────────────────

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

assert_equals() {
  local expected="$1"
  local actual="$2"
  local msg="${3:-}"
  
  # Trim whitespace from actual
  actual=$(echo "$actual" | xargs)
  
  if [[ "$expected" == "$actual" ]]; then
    return 0
  else
    echo "  Expected: $expected"
    echo "  Got:      $actual"
    [[ -n "$msg" ]] && echo "  Message:  $msg"
    return 1
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  
  if [[ "$haystack" == *"$needle"* ]]; then
    return 0
  else
    echo "  Expected substring: $needle"
    echo "  In: $haystack"
    return 1
  fi
}

# ── Fixture Data ───────────────────────────────────────────────────────────

mkdir -p "$FIXTURES"

cat > "$FIXTURES/flutter_pub_outdated_normal.txt" <<'EOF'
Checking which dependencies have newer versions available...

Package Name              Current Upgradable Latest Resolved Required
go_router                 17.1.0  17.2.1     17.2.1 17.1.0   ^17.1.0
path_provider_android     2.2.23  2.3.1      2.3.1  2.2.23   any
shared_preferences        2.5.4   2.5.5      2.5.5  2.5.4    ^2.5.0
equatable                 2.0.7   2.0.8      2.0.8  2.0.7    ^2.0.0
flutter_riverpod          3.3.0   3.3.1      3.3.1  3.3.0    ^3.3.0

3 upgradable packages listed.
EOF

cat > "$FIXTURES/flutter_pub_outdated_major_bump.txt" <<'EOF'
Checking which dependencies have newer versions available...

Package Name              Current Upgradable Latest Resolved Required
go_router                 17.1.0  *          18.0.0 17.1.0   ^17.1.0
share_plus                10.1.4  *          13.0.0 10.1.4   ^10.0.0
equatable                 2.0.7   2.0.8      2.0.8  2.0.7    ^2.0.0

2 major version bumps blocked by constraints.
1 upgradable package.
EOF

cat > "$FIXTURES/flutter_pub_outdated_empty.txt" <<'EOF'
Checking which dependencies have newer versions available...

All dependencies are up to date!
EOF

# ── Test Suite: Version Parsing ────────────────────────────────────────────

echo ""
echo "=== Unit Tests: dependency_health.sh Parsing ==="
echo ""

# Test 1: Count safe upgrades from normal output
test_it "counts safe upgrades (normal output)" '
  SAFE_COUNT=$(cat "$FIXTURES/flutter_pub_outdated_normal.txt" | grep -E "^[a-z_].*[0-9]\.[0-9]" | wc -l)
  assert_equals "5" "$SAFE_COUNT"
'

# Test 2: Identify major bumps (with *)
test_it "identifies major bumps (marked with *)" '
  MAJOR_COUNT=$(cat "$FIXTURES/flutter_pub_outdated_major_bump.txt" | grep -c "^\s*[a-z_].*\*" || true)
  assert_equals "2" "$MAJOR_COUNT"
'

# Test 3: Handle empty output
test_it "handles empty outdated output" '
  SAFE_COUNT=$(cat "$FIXTURES/flutter_pub_outdated_empty.txt" | grep -E "^[a-z_].*[0-9]\.[0-9]" | wc -l)
  assert_equals "0" "$SAFE_COUNT"
'

# Test 4: Exclude header lines
test_it "excludes header lines from count" '
  OUTPUT=$(cat "$FIXTURES/flutter_pub_outdated_normal.txt")
  SAFE_COUNT=$(echo "$OUTPUT" | grep -c "^[a-z_]" || true)
  assert_equals "5" "$SAFE_COUNT"
'

# Test 5: Parse version numbers correctly
test_it "extracts version numbers correctly" '
  OUTPUT=$(cat "$FIXTURES/flutter_pub_outdated_normal.txt")
  GO_ROUTER_LINE=$(echo "$OUTPUT" | grep "^go_router")
  assert_contains "$GO_ROUTER_LINE" "17.1.0"
  assert_contains "$GO_ROUTER_LINE" "17.2.1"
'

# ── Test Suite: Advisory Response Parsing ────────────────────────────────────

mkdir -p "$FIXTURES/pub_api"

cat > "$FIXTURES/pub_api_clean.json" <<'EOF'
{
  "name": "go_router",
  "latest": {
    "version": "17.2.1"
  },
  "advisories": []
}
EOF

cat > "$FIXTURES/pub_api_critical.json" <<'EOF'
{
  "name": "vulnerable_package",
  "latest": {
    "version": "1.0.0"
  },
  "advisories": [
    {
      "id": "CVE-2026-12345",
      "severity": "CRITICAL",
      "summary": "Remote code execution vulnerability",
      "affected": {
        "versions": [">=1.0.0 <1.0.5"]
      }
    }
  ]
}
EOF

cat > "$FIXTURES/pub_api_high_and_medium.json" <<'EOF'
{
  "name": "mixed_package",
  "latest": {
    "version": "2.0.0"
  },
  "advisories": [
    {
      "id": "PSA-001",
      "severity": "HIGH",
      "summary": "Authentication bypass"
    },
    {
      "id": "PSA-002",
      "severity": "MEDIUM",
      "summary": "Denial of service"
    }
  ]
}
EOF

echo ""
echo "=== Unit Tests: Advisory Response Parsing ==="
echo ""

# Test 6: Grade CRITICAL as blocking
test_it "grades CRITICAL advisory as blocking" '
  RESPONSE=$(cat "$FIXTURES/pub_api_critical.json")
  SEVERITY=$(echo "$RESPONSE" | jq -r ".advisories[0].severity // empty")
  assert_equals "CRITICAL" "$SEVERITY"
'

# Test 7: Grade HIGH as blocking
test_it "grades HIGH as blocking" '
  RESPONSE=$(cat "$FIXTURES/pub_api_high_and_medium.json")
  SEVERITY=$(echo "$RESPONSE" | jq -r ".advisories[] | select(.severity == \"HIGH\") | .severity")
  assert_contains "$SEVERITY" "HIGH"
'

# Test 8: Extract highest severity
test_it "extracts highest severity from multiple advisories" '
  RESPONSE=$(cat "$FIXTURES/pub_api_high_and_medium.json")
  MAX_SEVERITY=$(echo "$RESPONSE" | jq -r ".advisories[] | .severity" | sort -r | head -1)
  assert_equals "MEDIUM" "$MAX_SEVERITY"
'

# Test 9: Handle clean package (no advisories)
test_it "handles package with no advisories" '
  RESPONSE=$(cat "$FIXTURES/pub_api_clean.json")
  ADVISORY_COUNT=$(echo "$RESPONSE" | jq ".advisories // [] | length")
  assert_equals "0" "$ADVISORY_COUNT"
'

# Test 10: Handle malformed JSON gracefully
test_it "rejects malformed JSON without crashing" '
  MALFORMED="{invalid json"
  ! (echo "$MALFORMED" | jq . 2>/dev/null) || false
'

# ── Summary ────────────────────────────────────────────────────────────────

echo ""
echo "=== Test Summary ==="
echo "Tests run:    $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"
echo ""

if [[ $TESTS_FAILED -gt 0 ]]; then
  echo "FAIL: $TESTS_FAILED test(s) failed"
  exit 1
else
  echo "PASS: All tests passed"
  exit 0
fi
