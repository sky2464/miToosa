---
name: iphone-launch-gate
description: miToosa iPhone launch readiness — run test/release guards and verify LAUNCH.md manual gates for EP-01/EP-02.
---

# iphone-launch-gate

Project specialist for iOS App Store launch stories. Invoke during `/agtoosa-build` or `/agtoosa-ship` for EP-01/EP-02 work.

## Inputs

- `test/release/iphone_launch_readiness_test.dart`
- `test/release/signing_config_test.dart`
- `docs/LAUNCH.md`, `docs/IPHONE-LAUNCH-READINESS.md`, `docs/APP-STORE-METADATA.md`

## Run

1. Run `flutter test test/release/`.
2. Verify bundle ID `dev.atoosa.mitoosa` references in docs/tests.
3. List open `[manual-deferred]` gates from active spec and Master-Plan.
4. Emit structured evidence block with pass/fail per gate.

## Validation

```bash
flutter test test/release/
```

Exit code 0 required unless failure is documented accepted/pre-existing.

## Safety

No App Store Connect or Firebase console mutations. Reference paths only for credentials.
