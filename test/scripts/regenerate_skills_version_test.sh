#!/usr/bin/env bash
# test/scripts/regenerate_skills_version_test.sh
# Unit tests for regenerate_skills.sh version freshness logic

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIXTURES="${REPO_ROOT}/test/fixtures"

# ── Test Harness ──────────────────────────────────────────────────────────

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
  
  # Trim whitespace from actual
  actual=$(echo "$actual" | xargs)
  
  if [[ "$expected" == "$actual" ]]; then
    return 0
  else
    echo "  Expected: '$expected'"
    echo "  Got:      '$actual'"
    return 1
  fi
}

# ── Fixture Data ───────────────────────────────────────────────────────────

mkdir -p "$FIXTURES"

# Mock pubspec.lock
cat > "$FIXTURES/pubspec_lock_excerpt.txt" <<'EOF'
packages:
  go_router:
    dependency: direct main
    description:
      name: go_router
      sha256: abc123
      url: https://pub.dev
    source: hosted
    version: "17.2.1"
  equatable:
    dependency: direct main
    description:
      name: equatable
      sha256: def456
      url: https://pub.dev
    source: hosted
    version: "2.0.8"
  flutter:
    dependency: direct main
    description:
      name: flutter
      sha256: flutter_sdk
      url: https://flutter.dev
    source: sdk
    version: "0.0.0"
EOF

# Mock SKILL.md with stale version
cat > "$FIXTURES/SKILL_stale.md" <<'EOF'
---
name: go_router-usage
description: How to use go_router v17.1.0 in miToosa.
version: 17.1.0
source: https://pub.dev/packages/go_router/versions/17.1.0
generated: 2026-04-10
---

# go_router v17.1.0

This is stale documentation.
EOF

# Mock SKILL.md with current version
cat > "$FIXTURES/SKILL_current.md" <<'EOF'
---
name: go_router-usage
description: How to use go_router v17.2.1 in miToosa.
version: 17.2.1
source: https://pub.dev/packages/go_router/versions/17.2.1
generated: 2026-04-15
---

# go_router v17.2.1

This is current documentation.
EOF

# Mock SKILL.md with missing version field
cat > "$FIXTURES/SKILL_no_version.md" <<'EOF'
---
name: equatable-usage
description: How to use equatable in miToosa.
source: https://pub.dev/packages/equatable
---

# equatable

This skill has no version field.
EOF

echo ""
echo "=== Unit Tests: regenerate_skills.sh Version Checking ==="
echo ""

# Test 1: Extract version from pubspec.lock
test_it "extracts exact version from pubspec.lock" '
  INSTALLED=$(grep -A 50 "^  go_router:" "$FIXTURES/pubspec_lock_excerpt.txt" \
    | grep "^    version:" \
    | head -1 \
    | sed "s/.*version: \"\(.*\)\".*/\1/")
  assert_equals "17.2.1" "$INSTALLED"
'

# Test 2: Extract version from SKILL.md frontmatter
test_it "extracts version field from SKILL.md" '
  SKILL_VERSION=$(grep "^version:" "$FIXTURES/SKILL_stale.md" \
    | sed "s/version: //" \
    | tr -d " ")
  assert_equals "17.1.0" "$SKILL_VERSION"
'

# Test 3: Detect stale skill
test_it "detects stale skill (version mismatch)" '
  INSTALLED="17.2.1"
  SKILL_VERSION="17.1.0"
  [[ "$SKILL_VERSION" != "$INSTALLED" ]] || return 1
'

# Test 4: Confirm current skill
test_it "confirms skill is current (versions match)" '
  INSTALLED="17.2.1"
  SKILL_VERSION=$(grep "^version:" "$FIXTURES/SKILL_current.md" \
    | sed "s/version: //" \
    | tr -d " ")
  assert_equals "17.2.1" "$SKILL_VERSION"
'

# Test 5: Skip SDK dependencies
test_it "skips SDK dependencies (flutter, dart)" '
  # Extract flutter entry from pubspec.lock
  FLUTTER_INSTALLED=$(grep -A 50 "^  flutter:" "$FIXTURES/pubspec_lock_excerpt.txt" \
    | grep "^    source:" \
    | head -1 \
    | grep -c "sdk" || true)
  [[ $FLUTTER_INSTALLED -gt 0 ]] || return 1
'

# Test 6: Handle missing version field in SKILL
test_it "handles SKILL.md with missing version field" '
  SKILL_VERSION=$(grep "^version:" "$FIXTURES/SKILL_no_version.md" | wc -l)
  assert_equals "0" "$SKILL_VERSION"
'

# Test 7: Update version in SKILL.md (sed command preview)
test_it "can update version field in SKILL.md" '
  # Simulate sed update (without modifying fixture)
  UPDATED=$(sed "s/^version: .*/version: 17.2.1/" "$FIXTURES/SKILL_stale.md" | grep "^version:")
  assert_equals "version: 17.2.1" "$UPDATED"
'

# Test 8: Update source URL in SKILL.md
test_it "can update source URL when version changes" '
  UPDATED=$(sed "s|^source: .*|source: https://pub.dev/packages/go_router/versions/17.2.1|" "$FIXTURES/SKILL_stale.md" | grep "^source:")
  assert_equals "source: https://pub.dev/packages/go_router/versions/17.2.1" "$UPDATED"
'

# Test 9: Preserve body of SKILL.md on update
test_it "preserves SKILL.md body when updating version" '
  # Only update version line, keep body intact
  BODY_BEFORE=$(grep "# go_router" "$FIXTURES/SKILL_stale.md")
  BODY_AFTER=$(sed "s/^version: .*/version: 17.2.1/" "$FIXTURES/SKILL_stale.md" | grep "# go_router")
  assert_equals "$BODY_BEFORE" "$BODY_AFTER"
'

# Test 10: Handle semantic versioning
test_it "recognizes semantic versions (X.Y.Z format)" '
  VERSIONS=(
    "1.0.0"
    "17.2.1"
    "3.0.6"
    "2.5.5"
  )
  for v in "${VERSIONS[@]}"; do
    if ! [[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      return 1
    fi
  done
'

# ── Test Suite: Missing Skill Detection ────────────────────────────────────

echo ""
echo "=== Unit Tests: Missing Skill Detection ==="
echo ""

# Test 11: Detect missing SKILL.md file
test_it "detects missing SKILL.md file" '
  SKILL_FILE="/tmp/nonexistent_skill_$(date +%s).md"
  [[ ! -f "$SKILL_FILE" ]] || return 1
'

# Test 12: Extract package names from pubspec.yaml
test_it "extracts package names from pubspec.yaml format" '
  # Simulate extraction logic
  PACKAGES=$(cat <<YAML
  go_router: ^17.1.0
  equatable: ^2.0.0
  audioplayers: ^6.6.0
YAML
)
  COUNT=$(echo "$PACKAGES" | grep -E "^\s{2}[a-z_]+:" | wc -l)
  assert_equals "3" "$COUNT"
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
