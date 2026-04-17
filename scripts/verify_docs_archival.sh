#!/usr/bin/env bash
# verify_docs_archival.sh
# Fails if completed specs/plans remain in docs/ root or archived docs lose their Archived status.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

extract_status() {
  local file="$1"
  grep -m1 -E '^\*\*Status:\*\*' "$file" | sed -E 's/^\*\*Status:\*\* *//' || true
}

fail=0

echo "=== Docs Archival Check ==="

for file in docs/spec-*.md docs/plan-*.md; do
  [[ -f "$file" ]] || continue

  status="$(extract_status "$file")"
  if [[ "$status" == Complete* || "$status" == Archived* ]]; then
    echo "ERROR: $file is still in docs/ with status '$status'." >&2
    echo "       Move completed specs/plans to docs/archived/ before shipping." >&2
    fail=1
  fi
done

for file in docs/archived/spec-*.md docs/archived/plan-*.md; do
  [[ -f "$file" ]] || continue

  status="$(extract_status "$file")"
  if [[ -n "$status" && "$status" != Archived* ]]; then
    echo "ERROR: $file is in docs/archived/ but its status is '$status'." >&2
    echo "       Archived docs should use 'Status: Archived'." >&2
    fail=1
  fi
done

if [[ "$fail" -eq 0 ]]; then
  echo "Docs archival state: OK"
else
  echo "Docs archival state: FAIL" >&2
  exit 1
fi
