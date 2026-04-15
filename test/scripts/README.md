# Test Suite for Dependency Maintenance System

**Status:** ✅ Unit tests implemented and passing (22 tests)  
**Coverage:** Bash script parsing, version logic, API response handling  
**Last Updated:** 2026-04-15

---

## Quick Start

### Run All Tests

```bash
cd /Users/chicademy/Documents/Code/miToosa

# Run both test suites
bash test/scripts/dependency_health_parsing_test.sh
bash test/scripts/regenerate_skills_version_test.sh

# Or run all at once:
bash test/scripts/dependency_health_parsing_test.sh && \
bash test/scripts/regenerate_skills_version_test.sh
```

Expected output:
```
✓ PASS: All tests passed
```

### Run Individual Test Suite

```bash
# Test dependency_health.sh parsing logic
bash test/scripts/dependency_health_parsing_test.sh

# Test regenerate_skills.sh version checking
bash test/scripts/regenerate_skills_version_test.sh
```

---

## Test Coverage

### dependency_health_parsing_test.sh (10 tests)

Tests version parsing and advisory scanning logic from `dependency_health.sh`:

| # | Test Name | What It Verifies |
|---|-----------|------------------|
| 1 | counts safe upgrades (normal output) | Correctly identifies packages with safe minor/patch updates |
| 2 | identifies major bumps (marked with *) | Detects major version bumps blocked by constraints |
| 3 | handles empty outdated output | Returns 0 when no upgrades available |
| 4 | excludes header lines from count | Regex correctly ignores headers/metadata |
| 5 | extracts version numbers correctly | Parses version strings from flutter pub outdated output |
| 6 | grades CRITICAL advisory as blocking | CRITICAL severity → exit code 1 |
| 7 | grades HIGH as blocking | HIGH severity → exit code 1 |
| 8 | extracts highest severity from multiple advisories | Reports highest severity when package has multiple advisories |
| 9 | handles package with no advisories | Handles clean packages correctly |
| 10 | rejects malformed JSON without crashing | Gracefully skips invalid API responses |

**Test Fixtures:** `test/fixtures/flutter_pub_outdated_*.txt`, `test/fixtures/pub_api_*.json`

### regenerate_skills_version_test.sh (12 tests)

Tests version freshness checking and skill file generation from `regenerate_skills.sh`:

| # | Test Name | What It Verifies |
|---|-----------|------------------|
| 1 | extracts exact version from pubspec.lock | Correctly reads installed version for each package |
| 2 | extracts version field from SKILL.md | Parses frontmatter YAML for version field |
| 3 | detects stale skill (version mismatch) | Reports STALE when skill version ≠ installed version |
| 4 | confirms skill is current (versions match) | Reports OK when skill version matches |
| 5 | skips SDK dependencies (flutter, dart) | Correctly identifies and skips SDK entries |
| 6 | handles SKILL.md with missing version field | Handles malformed skill files gracefully |
| 7 | can update version field in SKILL.md | sed command correctly updates version line |
| 8 | can update source URL when version changes | Updates source field when version changes |
| 9 | preserves SKILL.md body when updating version | Only updates metadata, preserves documentation body |
| 10 | recognizes semantic versions (X.Y.Z format) | Validates semantic versioning pattern |
| 11 | detects missing SKILL.md file | Correctly identifies when skill file doesn't exist |
| 12 | extracts package names from pubspec.yaml format | Parses dependencies list correctly |

**Test Fixtures:** `test/fixtures/pubspec_lock_excerpt.txt`, `test/fixtures/SKILL_*.md`

---

## Test Levels Explained

### Level 1: Unit Tests (✅ Implemented)

**What's tested:** Low-level parsing and logic  
**Files:** `test/scripts/dependency_health_parsing_test.sh`, `test/scripts/regenerate_skills_version_test.sh`  
**Tools:** Bash test harness (no external dependencies)  
**Result:** 22 tests, all passing

**Not yet tested:**
- Error path handling (file I/O failures, network timeouts)
- Full script execution with mocks
- Git operations (commit, push)

### Level 2: Integration Tests (🔄 Planned)

**What should be tested:** Full workflow cycle (query → upgrade → test → commit)  
**Approach:** Mock Flutter environment, test complete scripts in temp directory  
**Status:** Not yet implemented (Recommended for Phase 1, see test-coverage-dependency-maintenance.md)

### Level 3: CI Workflow Tests (🔄 Planned)

**What should be tested:** GitHub Actions YAML execution  
**Approach:** Act Framework or workflow-validator tool  
**Status:** Not yet implemented (Recommended for Phase 2)

### Level 4: Agent Integration (🔄 Planned)

**What should be tested:** Agent specifications are implementable  
**Approach:** Mock API responses, test changelog extraction, advisory grading  
**Status:** Not yet implemented (Recommended for Phase 3)

### Level 5: Skill Freshness Validation (✅ Partial)

**What should be tested:** All 36 skill files match installed versions  
**Approach:** Automated audit run  
**Status:** Partially tested via test #1-4 in regenerate_skills_version_test.sh

---

## Adding New Tests

### Template: New Unit Test

```bash
# Add to test/scripts/dependency_health_parsing_test.sh or 
#    test/scripts/regenerate_skills_version_test.sh

test_it "describes the behavior being tested" '
  # Arrange: set up test data
  TEST_INPUT="some input"
  
  # Act: run the logic being tested
  RESULT=$(echo "$TEST_INPUT" | grep something)
  
  # Assert: verify result
  assert_equals "expected" "$RESULT"
'
```

### Example: Add a new test for error handling

```bash
# In dependency_health_parsing_test.sh, add:

test_it "handles malformed version string gracefully" '
  MALFORMED="abc.def.ghi"
  # Should not match semantic version pattern
  ! [[ "$MALFORMED" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || return 1
'
```

---

## Fixing Failing Tests

### Common Issues

**Issue:** Test fails with "Expected: 5, Got: 4"  
**Cause:** Regex pattern doesn't match fixture output  
**Fix:** Inspect fixture file, adjust regex, re-run

```bash
# Debug: see fixture content
cat test/fixtures/flutter_pub_outdated_normal.txt | head -10

# Test the regex
cat test/fixtures/flutter_pub_outdated_normal.txt | grep -E "^[a-z_]"

# Count results
cat test/fixtures/flutter_pub_outdated_normal.txt | grep -E "^[a-z_]" | wc -l
```

**Issue:** jq command not found  
**Cause:** jq not installed  
**Fix:** Install jq

```bash
brew install jq  # macOS
apt-get install jq  # Linux
```

---

## Integration with CI

### Add to GitHub Actions workflow (not yet implemented)

To run these tests in CI, add to `.github/workflows/dependency-maintenance.yml`:

```yaml
  test-scripts:
    name: Test Scripts
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install jq
        run: sudo apt-get install -y jq
      
      - name: Run unit tests
        run: |
          bash test/scripts/dependency_health_parsing_test.sh
          bash test/scripts/regenerate_skills_version_test.sh
```

---

## Test Maintenance

### When to Update Tests

- ✅ **After changing script logic** — add test for new behavior
- ✅ **When fixing a bug** — add test that reproduces the bug first (Prove-It pattern)
- ✅ **When adding a new flag/option** — add tests for that code path
- ❌ **When internal implementation changes** — avoid testing implementation details

### How to Keep Tests Current

1. Run tests before every merge:
   ```bash
   bash test/scripts/dependency_health_parsing_test.sh
   bash test/scripts/regenerate_skills_version_test.sh
   ```

2. Review test output for failures
3. Investigate and fix failures before committing
4. Add new test cases for new behavior

---

## Next Steps

See [test-coverage-dependency-maintenance.md](../test-coverage-dependency-maintenance.md) for:
- Full test plan (Levels 1-5)
- Integration test examples
- CI workflow test strategy
- Production deployment recommendations

---

**Last Updated:** 2026-04-15  
**Status:** Ready for use  
**Maintainer:** Test Engineer
