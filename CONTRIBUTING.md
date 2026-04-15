# Contributing to miToosa

Thank you for helping improve miToosa! This file contains a short, practical guide to make contributing smooth and consistent.

## Quick start

Clone the canonical repository and create a short-lived branch:

```bash
git clone https://github.com/sky2464/miToosa.git
cd miToosa
git fetch origin
git checkout -b feature/your-branch-name origin/main
```

Use branch prefixes to make intent clear:

- `feature/` — new features
- `fix/` — bug fixes
- `chore/` — maintenance (deps, docs, refactors)
- `hotfix/` — urgent production fixes

## Pre-PR checklist

Before opening a PR, run these steps locally (CI will also run checks):

```bash
flutter pub get
# If your change touches `lib/` or `pubspec.yaml` run codegen:
dart pub run build_runner build --delete-conflicting-outputs
dart analyze
flutter test
```

- Ensure any new assets are added to `pubspec.yaml`.
- Avoid `path:` or `git:` dependencies — CI (`.github/workflows/check-pub.yml`) rejects those.

If code generation fails with conflicting outputs, try:

```bash
dart pub run build_runner clean
dart pub run build_runner build --delete-conflicting-outputs
```

If you run into build_runner platform issues, run the generator using the Flutter SDK's Dart:

```bash
/path/to/flutter/bin/dart pub run build_runner build --delete-conflicting-outputs
```

## PRs, titles & merging

- Use a clear PR title and include a conventional prefix (e.g., `feature/`, `fix/`, `chore/`).
- Prefer **Squash & merge** to keep the `main` history clean; delete the branch after merging.

Example PR flow (CLI):

```bash
# push the branch
git push -u origin feature/your-branch-name
# create PR using GH CLI
gh pr create --base main --head feature/your-branch-name --fill
# after approval and CI green, squash-merge via web or:
gh pr merge --squash --delete-branch
```

## Review focus

- If your change includes persistence or migration, include a migration note and tests.
- Note platform-specific considerations (iOS/Android/macOS/web) in the PR description.

## Contacts

For questions or approvals, mention `@sky2464` in the PR.
