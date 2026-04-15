#!/usr/bin/env bash
# dependency_health.sh
# Live dependency health check for miToosa.
# Always queries flutter pub outdated at runtime — never uses cached version data.
#
# Usage:
#   bash scripts/dependency_health.sh            # report only
#   bash scripts/dependency_health.sh --auto     # report + apply safe upgrades
#   bash scripts/dependency_health.sh --full     # report + advisory scan
#   bash scripts/dependency_health.sh --auto --full  # everything

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

AUTO=false
FULL=false
ADVISORY_EXIT=0

for arg in "$@"; do
  case "$arg" in
    --auto) AUTO=true ;;
    --full) FULL=true ;;
    *) echo "Unknown flag: $arg" >&2; exit 1 ;;
  esac
done

# ── 1. Query live package status ───────────────────────────────────────────────
echo ""
echo "=== miToosa Dependency Health Check ==="
echo "Date: $(date -u '+%Y-%m-%d %H:%M UTC')"
echo ""

# Capture raw text output (flutter pub outdated --json is not yet stable across versions)
RAW_OUTPUT=$(flutter pub outdated 2>&1)
echo "$RAW_OUTPUT"
echo ""

# ── 2. Parse output into buckets ───────────────────────────────────────────────
# Count lines that have version numbers. A * in the Current column indicates major bump blocked.
# If Upgradable < Latest with a *, it's a MAJOR bump.

SAFE_COUNT=$(echo "$RAW_OUTPUT" | grep -c '^\s*[a-z_].*[0-9]\.[0-9].*[0-9]\s\+[0-9]\.[0-9]' || true)
MAJOR_COUNT=$(echo "$RAW_OUTPUT" | grep -c '^\s*[a-z_].*\*[0-9]' || true)

echo "--- Summary ---"
echo "Safe (minor/patch) upgrades available: $SAFE_COUNT"
echo "Major-version bumps available (blocked by constraint): $MAJOR_COUNT"
echo ""

# ── 3. Apply safe upgrades if --auto ──────────────────────────────────────────
if [ "$AUTO" = true ]; then
  if [ "$SAFE_COUNT" -gt 0 ]; then
    echo "=== Applying safe upgrades (flutter pub upgrade) ==="
    flutter pub upgrade

    echo ""
    echo "=== Running analysis gate ==="
    dart analyze
    echo "dart analyze: PASSED"

    echo ""
    echo "=== Running test gate ==="
    flutter test
    echo "flutter test: PASSED"

    echo ""
    echo "Safe upgrades applied and verified. Commit with:"
    echo "  git add pubspec.lock && git commit -m 'chore(deps): upgrade patch/minor dependencies'"
  else
    echo "No safe upgrades to apply."
  fi
fi

# ── 4. Advisory scan if --full ────────────────────────────────────────────────
if [ "$FULL" = true ]; then
  echo ""
  echo "=== Advisory Scan ==="

  if ! command -v jq &>/dev/null; then
    echo "WARNING: jq not found — skipping advisory scan. Install with: brew install jq" >&2
  else
    # Extract direct dependency names from pubspec.yaml
    # Read between "dependencies:" and "dev_dependencies:" for dependencies
    # Read between "dev_dependencies:" and "flutter:" for dev dependencies
    DEPS=$(sed -n '/^dependencies:/,/^dev_dependencies:/p' pubspec.yaml \
      | grep -E '^\s{2}[a-z_]+:\s' \
      | sed 's/:.*//' \
      | sed 's/^[[:space:]]*//' \
      | sort -u)

    ADVISORY_FOUND=false

    while IFS= read -r pkg; do
      [[ -z "$pkg" ]] && continue

      # Fetch with HTTP code validation
      RESPONSE=$(curl -sL --max-time 10 -w "\n%{http_code}" "https://pub.dev/api/packages/${pkg}" 2>&1)
      HTTP_CODE=$(echo "$RESPONSE" | tail -1)
      BODY=$(echo "$RESPONSE" | sed '$d')

      # Check HTTP status (critical for detecting rate limits and network issues)
      if [[ "$HTTP_CODE" != "200" ]]; then
        echo "  ERROR: $pkg returned HTTP $HTTP_CODE (rate limited? network issue?)" >&2
        ADVISORY_EXIT=1
        continue
      fi

      # Validate JSON
      if ! echo "$BODY" | jq empty 2>/dev/null; then
        echo "  ERROR: Malformed JSON response for ${pkg}" >&2
        ADVISORY_EXIT=1
        continue
      fi

      RESPONSE="$BODY"

      COUNT=$(echo "$RESPONSE" | jq '(.advisories // []) | length')

      if [ "$COUNT" -gt 0 ]; then
        SUMMARY=$(echo "$RESPONSE" | jq -r '(.advisories // [])[] | "  ADVISORY [\(.severity // "UNKNOWN")] \(.id // "no-id"): \(.summary // "no summary")"')
        echo "  $pkg: $COUNT advisory(ies) found"
        echo "$SUMMARY"
        ADVISORY_FOUND=true

        SEVERITY=$(echo "$RESPONSE" | jq -r '(.advisories // [])[] | .severity // "LOW"' | sort | tail -1)
        if [[ "$SEVERITY" == "CRITICAL" || "$SEVERITY" == "HIGH" ]]; then
          ADVISORY_EXIT=1
        fi
      else
        echo "  $pkg: clean"
      fi
    done <<< "$DEPS"

    if [ "$ADVISORY_FOUND" = false ]; then
      echo "All scanned packages: no advisories found."
    fi
  fi
fi

echo ""
echo "=== Done ==="

if [ "$ADVISORY_EXIT" -eq 1 ]; then
  echo "FAIL: CRITICAL or HIGH advisory detected. Fix before proceeding." >&2
  exit 1
fi
