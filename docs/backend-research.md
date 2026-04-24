# miToosa Backend Research

**Date:** 2026-04-24

## Bottom Line

For launch, use a Firebase-first stack:

- **Web front end:** Firebase Hosting
- **Analytics:** Google Analytics for Firebase
- **Crash reporting:** Firebase Crashlytics
- **Feature flags / tuning:** Firebase Remote Config
- **Abuse protection:** Firebase App Check
- **Custom backend:** Cloud Run only when you actually need server-side APIs, scheduled jobs, or a shared backend service

Keep the game itself local-first in Hive until there is a clear need for cloud sync, leaderboards, referrals, or other shared state.

## Verified Facts

- Firebase Hosting serves static and single-page web apps over a global CDN and can pair with Cloud Run for dynamic content or microservices. The current no-cost tier includes **10 GB stored** and **10 GB transferred**.
- Google Analytics for Firebase is available at **no charge** and supports unlimited reporting for up to **500 distinct events**.
- Firebase Crashlytics provides realtime crash reporting, issue grouping, alerts, and integration with Google Analytics.
- Firebase Remote Config can change app behavior without shipping a new app update, and the docs describe it as **no-cost for unlimited daily active users**.
- Firebase App Check protects Firebase and custom backends by requiring valid app/device attestation tokens from Apple, Android, or web clients.
- Firebase Authentication supports **anonymous auth** and the current pricing docs show a no-cost Spark tier plus a Blaze free tier of **50,000 monthly active users**.
- Cloud Run bills only for resources used, rounds to the nearest **100 ms**, and has a free tier. It is the right default if miToosa needs a custom backend later.

## Emerging Signals

- The repo already points in the same direction: `docs/plan.md` and `docs/manual.md` both treat Firebase as the launch analytics choice and Cloud Run as optional backend hosting.
- The codebase currently uses a no-op analytics sink, so the app is intentionally backend-neutral until a real service is selected.
- Firebase Cloud Messaging is available if retention features later need push notifications for streak reminders or re-engagement.

## Recommendation

Use this stack for the cheapest practical launch path:

1. **Firebase Hosting** for the Flutter web build.
2. **Google Analytics for Firebase + Crashlytics** for measurement and stability.
3. **Remote Config** for tuning gameplay, onboarding, and feature rollout without app updates.
4. **App Check** to reduce abuse on any Firebase or custom backend endpoints.
5. **Cloud Run** only for custom APIs, scheduled tasks, or future shared features such as leaderboards or referrals.

Only add **Firestore**, **Authentication**, or **Cloud Storage** if the product actually needs cloud saves, identity, or file uploads. That keeps early cost and operational complexity low.

## Sources

- [Firebase Hosting](https://firebase.google.com/docs/hosting) - verified 2026-04-24
- [Google Analytics for Firebase](https://firebase.google.com/docs/analytics) - verified 2026-04-24
- [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics) - verified 2026-04-24
- [Firebase Remote Config](https://firebase.google.com/docs/remote-config) - verified 2026-04-24
- [Firebase App Check](https://firebase.google.com/docs/app-check) - verified 2026-04-24
- [Firebase Authentication](https://firebase.google.com/docs/auth) - verified 2026-04-24
- [Firebase pricing](https://firebase.google.com/pricing) - verified 2026-04-24
- [Cloud Run pricing](https://cloud.google.com/run/pricing) - verified 2026-04-24
