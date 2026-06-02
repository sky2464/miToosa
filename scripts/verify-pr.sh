#!/usr/bin/env bash
# verify-pr.sh — local mirror of .github/workflows/pr-validation.yml
#
# Usage:
#   bash scripts/verify-pr.sh              # diff vs origin/main
#   bash scripts/verify-pr.sh origin/main  # explicit base ref

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

BASE_REF="${1:-origin/main}"

step() {
  echo ""
  echo "=== $1 ==="
}

resolve_base() {
  if git rev-parse --verify "${BASE_REF}" >/dev/null 2>&1; then
    echo "${BASE_REF}"
    return
  fi
  if git rev-parse --verify main >/dev/null 2>&1; then
    echo "main"
    return
  fi
  echo "ERROR: need ${BASE_REF} or main for diff-based guards." >&2
  exit 1
}

changed_files() {
  local base="$1"
  if git merge-base "${base}" HEAD >/dev/null 2>&1; then
    git diff --name-only "${base}...HEAD"
  else
    git diff --name-only "${base}" HEAD
  fi
}

BASE="$(resolve_base)"

step "flutter pub get"
flutter pub get

step "Verify formatting"
dart format --output=none --set-exit-if-changed .

step "Static analysis"
dart analyze

step "Run test suite"
flutter test

if changed_files "${BASE}" | grep -E '^docs/.*\.md$' >/dev/null; then
  step "Docs archival check"
  bash scripts/verify_docs_archival.sh
else
  echo "Skipping docs archival check (no docs/*.md changes vs ${BASE})."
fi

if changed_files "${BASE}" | grep -E '^docs/mitoosa-design-system-2/' >/dev/null; then
  step "Prompt injection guard"
  bash scripts/check_prompt_injection.sh docs/mitoosa-design-system-2
else
  echo "Skipping prompt injection guard (no design doc changes vs ${BASE})."
fi

echo ""
echo "verify-pr: all checks passed (base: ${BASE})."
