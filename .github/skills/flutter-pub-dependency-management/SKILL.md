---
name: flutter-pub-dependency-management
description: Canonical how-to for any agent performing Flutter dependency work in miToosa. Covers live version querying, safe vs. major upgrades, advisory scanning, and commit conventions. Read this before touching pubspec.yaml or pubspec.lock.
---

# Flutter Pub Dependency Management

## The One Rule

**Never use memory for version numbers.** Always run `flutter pub outdated` or query pub.dev at runtime.

---

## Reading `flutter pub outdated` Output

```
Package Name     Current   Upgradable  Resolvable  Latest
go_router        17.1.0    17.2.1      17.2.1      17.2.1
share_plus       10.1.4    10.1.4      12.0.2      13.0.0
```

| Column | Meaning |
|--------|---------|
| **Current** | Version in `pubspec.lock` right now |
| **Upgradable** | Highest version allowed by the current `pubspec.yaml` constraint (within `^`) |
| **Resolvable** | Highest version the whole dependency graph can resolve to |
| **Latest** | Absolute latest on pub.dev — may require constraint relaxation |

### Buckets

- **SAFE:** `Upgradable` > `Current` → run `flutter pub upgrade`
- **MAJOR:** `Latest` > `Resolvable` → caret constraint blocks it; requires manual `pubspec.yaml` edit
- **ADVISORY:** package has a known advisory → treat as blocking regardless of version

---

## Choosing the Right Upgrade Command

| Situation | Command |
|-----------|---------|
| Upgrade within caret constraints | `flutter pub upgrade` |
| Preview what would change | `flutter pub upgrade --dry-run` |
| Relax constraints to allow major bumps | `flutter pub upgrade --major-versions` |
| Edit constraint manually then resolve | Edit `pubspec.yaml`, then `flutter pub get` |

**Never run `flutter pub upgrade --major-versions` without first reviewing the CHANGELOG.**

---

## After Any Upgrade

Always run both gates:

```bash
dart analyze        # must exit 0
flutter test        # must exit 0
```

If either fails, revert:

```bash
git checkout pubspec.lock
flutter pub get
```

---

## Commit Convention

```
chore(deps): upgrade patch/minor dependencies

- <package>: <old> → <new>
- <package>: <old> → <new>
```

Major-version bumps go in a separate commit:

```
chore(deps)!: upgrade share_plus 10.1.4 → 13.0.0

BREAKING: <summary extracted from CHANGELOG>
See: https://pub.dev/packages/share_plus/changelog
```

---

## Checking for Advisories

Query pub.dev for each direct dependency:

```bash
curl -sL --max-time 10 "https://pub.dev/api/packages/<name>" \
  | jq '.advisories // [] | length'
```

If the result is > 0, read the advisory detail and compare the affected version range against `pubspec.lock`.

---

## pubspec.yaml Constraint Style

miToosa uses `^` (caret) constraints. This allows minor and patch upgrades automatically.

```yaml
go_router: ^17.1.0   # allows 17.x.x, blocks 18.0.0
```

When relaxing a constraint for a major upgrade:

```yaml
share_plus: ^13.0.0  # update after verifying no breaking impact
```

---

## Key Files

| File | Purpose |
|------|---------|
| `pubspec.yaml` | Version constraints (ranges) |
| `pubspec.lock` | Exact installed versions (source of truth for agents) |
| `scripts/dependency_health.sh` | One-shot health check + safe auto-upgrade |
| `scripts/regenerate_skills.sh` | Refreshes skill files to match installed versions |
| `.github/workflows/dependency-maintenance.yml` | Weekly CI job |
