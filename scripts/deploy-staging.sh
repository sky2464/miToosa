#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter is required but not installed or not on PATH"
  exit 1
fi

if ! command -v firebase >/dev/null 2>&1; then
  echo "firebase-tools CLI is required. Install with: npm install -g firebase-tools"
  exit 1
fi

flutter build web --no-tree-shake-icons --release
firebase deploy --only hosting:mitoosa-staging
