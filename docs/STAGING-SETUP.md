# Staging Setup (Firebase Hosting)

This document covers the manual Firebase steps required for S1-01.

## Prerequisites

- Node.js + npm installed
- Flutter SDK installed
- Access to GitHub repository settings
- Firebase account

## Steps

1. Open <https://console.firebase.google.com> and create a project named `mitoosa`.
2. Enable Google Analytics in the Firebase project (required later for S1-02).
3. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```
4. Authenticate Firebase CLI:
   ```bash
   firebase login
   ```
5. Initialize Firebase Hosting at repo root:
   ```bash
   firebase init hosting
   ```
   Use these selections:
   - Project: `mitoosa`
   - Public directory: `build/web`
   - Single-page app rewrite: `Yes`
   - GitHub automated builds: `No` (CI workflow handles deploy)
6. Generate CI token:
   ```bash
   firebase login:ci
   ```
   Copy the token value.
7. Add `FIREBASE_TOKEN` in GitHub:
   - Repo Settings -> Secrets and variables -> Actions -> New repository secret
   - Name: `FIREBASE_TOKEN`
   - Value: token from step 6
8. Run first deploy and record URL:
   ```bash
   ./scripts/deploy-staging.sh
   ```
   Copy the generated `*.web.app` or `*.firebaseapp.com` URL into `docs/RELEASE-GATES.md`.

## Verification

- `flutter build web --no-tree-shake-icons --release` succeeds
- `firebase deploy --only hosting:mitoosa-staging` succeeds
- Staging URL loads the app in browser
