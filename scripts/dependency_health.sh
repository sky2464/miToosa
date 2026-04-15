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
# Lines with an asterisk (*) have available upgrades outside the constraint range
# Lines without * but with a version in Upgradable column are safe upgrades

SAFE_COUNT=0
MAJOR_COUNT=0

while IFS= read -r line; do
  # Skip header lines and blank lines
  [[ "$line" =~ ^Package|^direct|^dev|^transitive|^[[:space:]]*$ ]] && continue
  [[ -z "$line" ]] && continue

  # A line with * in the Current column means it is constrained
  if echo "$line" | grep -qE '^\s+\S+\s+\*'; then
    MAJOR_COUNT=$((MAJOR_COUNT + 1))
  elif echo "$line" | grep -qE '^\s+\S+\s+[0-9]+\.[0-9]+\.[0-9]+\s+[0-9]+\.[0-9]+\.[0-9]+'; then
    SAFE_COUNT=$((SAFE_COUNT + 1))
  fi
done <<< "$RAW_OUTPUT"

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
    DEPS=$(grep -E '^\s{2}[a-z_]+:' pubspec.yaml \
      | grep -v 'flutter:' \
      | sed 's/://g' \
      | tr -d ' ' \
      | sort -u)

    ADVISORY_FOUND=false

    while IFS= read -r pkg; do
      [[ -z "$pkg" ]] && continue

      RESPONSE=$(curl -sL --max-time 10 "https://pub.dev/api/packages/${pkg}" 2>/dev/null || true)

      # Validate JSON
      if ! echo "$RESPONSE" | jq empty 2>/dev/null; then
        echo "  WARN: Could not fetch metadata for ${pkg}" >&2
        continue
      fi

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
