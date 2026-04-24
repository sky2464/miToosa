# miToosa Deployment & Operations Manual

**Last Updated:** April 23, 2026  
**Status:** Sprint 1 Launch Preparation  
**Owner:** Engineering Team

---

## 1. Deployment & Analytics Infrastructure Setup

### Overview

Before Sprint 1 closes, the team must:
- ✅ **Required**: Submit to App Stores (iOS/Android) — **FREE** via App Store Connect & Google Play Console
- ✅ **Required**: Set up analytics (Firebase) — **FREE** up to 100K events/month
- ✅ **Required**: Run QA & playtesting before launch
- ⚠️ **Optional**: Backend hosting (Cloud Run) — Only if deploying web version or custom backend services

**Key insight:** iOS and Android game distribution costs nothing to host (Apple & Google provide free CDN). You only pay one-time developer account fees (~$100/yr total). Cloud Run is optional.

This manual provides decision frameworks, step-by-step setup guides, and verification checklists for each component.

---

## 2. Distribution & Backend Infrastructure Decision

### CRITICAL: iOS/Android Game Distribution is FREE

**iOS Distribution (Apple App Store):**
- ✅ **Hosting:** FREE — Apple hosts your app on their CDN
- 💰 **Dev Account Fee:** One-time ~$99/year (not per-game, not hosting)
- Submit via: [App Store Connect](https://appstoreconnect.apple.com/)

**Android Distribution (Google Play Store):**
- ✅ **Hosting:** FREE — Google hosts your app on their CDN
- 💰 **Dev Account Fee:** One-time ~$25 (not per-app, not hosting)
- Submit via: [Google Play Console](https://play.google.com/console/)

**Result:** Your game is distributed globally with zero hosting costs. You pay ~$124 total for developer accounts, not for hosting.

---

### When You DO Need Backend Hosting (Optional)

Backend hosting is **only required** if you need:

1. **Web version** of miToosa (Flutter Web frontend)
2. **Backend API** for server-side analytics collection (vs. local Hive storage)
3. **Staging/QA environment** on the cloud (pre-release testing)
4. **Real-time services** (leaderboards, multiplayer, live events)

**For Sprint 1:** If using local Hive storage + Firebase (free tier), **you may not need backend hosting at all**.

---

### Backend Hosting Option: Google Cloud Run (If Needed)

**Why Cloud Run for miToosa backend:**
- ✅ **Cost-efficient**: Pay only when code runs. Free tier: 240K vCPU-seconds/month, 450K GiB-seconds/month
- ✅ **Serverless**: No infrastructure management. Scale from 0 to millions automatically
- ✅ **Flutter Web support**: Native support for Dart/Flutter backends
- ✅ **Global distribution**: Deploy across 20+ regions in one command
- ✅ **DevOps simplicity**: `gcloud run deploy` from CI/CD or CLI

**Cost (if needed):** $0–$50/month for typical backend traffic (<100K requests/month)

### Backend Hosting Alternatives

| Platform | Pros | Cons | Best For |
|----------|------|------|----------|
| **Cloud Run** | Serverless, free tier, simple | GCP learning curve | Dart/Flutter backend |
| **Vercel** | Excellent Flutter Web hosting | Less backend flexibility | Web frontend focus |
| **Netlify** | Full-stack with Functions | Similar to Vercel | Jamstack sites |
| **AWS GameLift** | Enterprise multiplayer | Extremely complex, expensive | Multiplayer at 10K+ scale |

### Decision Matrix for miToosa Sprint 1

| Scenario | Hosting Needed? | Cost | Recommended |
|----------|---|---|---|
| **iOS + Android apps only** | ❌ No | ~$124/yr (dev fees) | ✅ **App Stores** |
| **iOS + Android + Web version** | ✅ Yes | ~$124/yr + $0–50/mo | App Stores + Cloud Run |
| **iOS + Android + Multiplayer** | ✅ Yes | ~$124/yr + variable | App Stores + Cloud Run + GameLift |

**miToosa is single-player → Use App Stores only (no backend hosting needed)**

---

## 3. App Store Submission: iOS & Android (REQUIRED for Sprint 1)

### Step 1: Register Developer Accounts

**iOS - Apple Developer Program:**
1. Go to [developer.apple.com](https://developer.apple.com)
2. Sign up for Apple Developer Program (~$99/year)
3. Complete identity verification
4. Set up App Store Connect account

**Android - Google Play Console:**
1. Go to [play.google.com/console](https://play.google.com/console)
2. Create a Google Play Developer account (~$25, one-time)
3. Set up payment method
4. Complete company verification

### Step 2: Prepare App for Submission

**iOS:**
- Build release version: `flutter build ios --release`
- Add app icons and screenshots (required)
- Create privacy policy
- Define app metadata (description, keywords, rating)

**Android:**
- Build release version: `flutter build appbundle --release`
- Sign release build with keystore
- Add app icons and screenshots (required)
- Create privacy policy
- Define app metadata

### Step 3: Submit to App Stores

**iOS Submission:**
1. Open App Store Connect
2. Create new app
3. Upload build via Xcode or Transporter
4. Fill metadata, screenshots, privacy policy
5. Submit for review (~24–48 hours)

**Android Submission:**
1. Open Google Play Console
2. Create new app
3. Upload AAB (Android App Bundle)
4. Fill metadata, screenshots, privacy policy
5. Submit for review (~24–48 hours, sometimes instant)

### Verification

- [ ] App Store Connect account active
- [ ] Google Play Console account active
- [ ] iOS build signed and ready
- [ ] Android AAB generated
- [ ] Privacy policy created
- [ ] Screenshots uploaded (required)
- [ ] Both apps submitted for review

---

## 3b. Optional: Web Host Setup via Google Cloud Run (For Web Version / Backend Services)

**⚠️ This section is OPTIONAL and only needed if you're deploying a web version or backend API.**

### Prerequisites (If Adding Web Version)
- GCP account (sign up at https://console.cloud.google.com/freetrial)
- $300 free credits (expires after 90 days)
- `gcloud` CLI installed (`brew install google-cloud-sdk` on macOS)
- Flutter Web build ready (`flutter build web`)

### Step 1: Create GCP Project

```bash
# Authenticate
gcloud auth login

# Create a new project
gcloud projects create mitoosa-prod --name="miToosa"

# Set as active project
gcloud config set project mitoosa-prod

# Enable Cloud Run API
gcloud services enable run.googleapis.com
```

### Step 2: Build Flutter Web for Deployment

```bash
cd /path/to/mitoosa
flutter clean
flutter pub get
flutter build web --release
```

Output location: `build/web/`

### Step 3: Create Dockerfile (if custom runtime needed)

For most cases, Cloud Run can deploy the web assets directly. If you need a custom backend service:

```dockerfile
# Dockerfile (optional, for custom Dart backend)
FROM google/dart:latest

WORKDIR /app
COPY . .

RUN dart pub get

EXPOSE 8080
CMD ["dart", "run", "bin/server.dart"]
```

### Step 4: Deploy to Cloud Run

```bash
# Deploy Flutter Web assets
gcloud run deploy mitoosa-web \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars FLUTTER_ENV=production

# Verify deployment
gcloud run services describe mitoosa-web --region us-central1
```

Output will include your staging URL: `https://mitoosa-web-[hash].a.run.app`

### Step 5: Configure Custom Domain (Optional)

```bash
# Map custom domain to Cloud Run service
gcloud run domain-mappings create \
  --service=mitoosa-web \
  --domain=staging.mitoosa.com \
  --region=us-central1
```

Follow GCP's DNS setup instructions to add CNAME records.

### Step 6: Enable HTTPS & Security Headers

Cloud Run auto-provisions HTTPS. Add security headers in your Dart backend or web server:

```dart
// Example Dart backend (if applicable)
response.headers['X-Content-Type-Options'] = 'nosniff';
response.headers['X-Frame-Options'] = 'SAMEORIGIN';
response.headers['Strict-Transport-Security'] = 'max-age=31536000';
```

### Verification

- [ ] Cloud Run service deployed: `gcloud run services list`
- [ ] Staging URL accessible (no 404)
- [ ] HTTPS certificate valid
- [ ] Web app loads on real device (iOS, Android, Web)
- [ ] No console errors in DevTools

---

## 4. Analytics Backend Decision Framework

### Recommended: Firebase (Google Analytics + Crashlytics)

**Why Firebase for miToosa:**
- ✅ **Free tier sufficient for launch**: No payment required to get started
- ✅ **Native Flutter integration**: Official Firebase packages for Dart
- ✅ **Real-time dashboards**: See events flowing live
- ✅ **Crash reporting**: Automatic error tracking (Crashlytics)
- ✅ **GDPR-compliant**: Local-first option with export controls
- ✅ **Linked to GCP**: Cost consolidation if using Cloud Run

**Startup cost:** $0 (free tier includes 100K events/month)

### Alternatives Considered

| Platform | Pros | Cons | Best For |
|----------|------|------|----------|
| **Firebase** | Free, native Flutter, real-time | Limited advanced analytics | Early-stage games, quick launch |
| **Amplitude** | Excellent product analytics (funnels, cohorts) | Paid ($995+/month), overkill now | Post-launch, post-PMF analytics |
| **Custom BigQuery** | Full control, unlimited queries | Complex setup, requires infrastructure | Post-launch, mature game |
| **Datadog/Sentry** | Crash reporting, error tracking | Not full analytics, $$ | Optional supplement to Firebase |

### Decision Criteria

Choose **Firebase** if:
- ✅ Need quick launch (< 1 week to configure)
- ✅ Team already using GCP
- ✅ Focus on crash reporting + basic event tracking now
- ✅ Defer advanced analytics (cohorts, funnels) to post-launch

Choose **Amplitude** if:
- ✅ Budget allows ($1K+/month)
- ✅ Require sophisticated cohort analysis before launch
- ✅ Want superior D1/D7 retention tracking

---

## 5. Analytics Backend Setup: Firebase (Step-by-Step)

### Prerequisites
- GCP project created (from Web Host Setup, Step 1)
- Flutter app created with Riverpod (already in miToosa)
- Existing telemetry event schema (`docs/analytics-events-v1.3.md`)

### Step 1: Create Firebase Project

```bash
# Authenticate Firebase CLI
firebase login

# Initialize Firebase in your project
firebase init

# Select: "Hosting" and "Analytics"
# Link to existing GCP project: "mitoosa-prod"
```

Alternatively, use Firebase Console: https://console.firebase.google.com

### Step 2: Add Firebase to Flutter App

Update `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^1.24.0
  firebase_analytics: ^11.0.0
  firebase_crashlytics: ^3.3.0
```

Update `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Enable Crashlytics
  FirebaseCrashlytics.instance.recordFlutterError(
    FlutterErrorDetails(exception: e, stack: st),
  );
  
  runApp(const MyApp());
}
```

### Step 3: Override analyticsSinkProvider in Riverpod

Create a new file: `lib/features/telemetry/firebase_telemetry_sink.dart`

```dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mitoosa/data/telemetry_event.dart';

final firebaseTelemetrySinkProvider = Provider<void>((ref) {
  final analytics = FirebaseAnalytics.instance;
  
  // When a TelemetryEvent is created, forward it to Firebase
  ref.listen(telemetryEventProvider, (previous, next) {
    _forwardEventToFirebase(analytics, next);
  });
});

void _forwardEventToFirebase(
  FirebaseAnalytics analytics,
  TelemetryEvent event,
) {
  switch (event.eventType) {
    case 'level_complete':
      analytics.logEvent(
        name: 'level_complete',
        parameters: {
          'track_id': event.properties['track_id'] ?? '',
          'level_index': event.properties['level_index'] ?? 0,
          'stars': event.properties['stars'] ?? 0,
          'coin_reward': event.properties['coin_reward'] ?? 0,
        },
      );
      break;
    
    case 'streak_update':
      analytics.logEvent(
        name: 'streak_update',
        parameters: {
          'streak_count': event.properties['streak_count'] ?? 0,
          'result': event.properties['result'] ?? 'unknown',
        },
      );
      break;
    
    case 'achievement_unlocked':
      analytics.logEvent(
        name: 'achievement_unlocked',
        parameters: {
          'achievement_id': event.properties['achievement_id'] ?? '',
          'coin_reward': event.properties['coin_reward'] ?? 0,
        },
      );
      break;
    
    case 'session_start':
      analytics.logEvent(
        name: 'session_start',
        parameters: {'source': event.properties['source'] ?? 'unknown'},
      );
      break;
    
    case 'session_end':
      analytics.logEvent(
        name: 'session_end',
        parameters: {
          'duration_ms': event.properties['duration_ms'] ?? 0,
          'source': event.properties['source'] ?? 'unknown',
        },
      );
      break;
    
    default:
      // Log custom event
      analytics.logEvent(
        name: event.eventType,
        parameters: event.properties,
      );
  }
}
```

### Step 4: Test Event Flow

1. **Run app in debug mode**:
   ```bash
   flutter run -d chrome  # Test on Web
   # or
   flutter run            # Test on mobile simulator
   ```

2. **Trigger events manually**:
   - Complete a puzzle level
   - Claim a daily reward
   - Check streaks
   - Share the app

3. **Verify in Firebase Console**:
   - Open https://console.firebase.google.com
   - Select "mitoosa-prod" project
   - Go to **Analytics** → **Real-time**
   - You should see events flowing in real-time

### Step 5: Set Up Dashboards

In Firebase Console:

1. **Create a "Core Metrics" dashboard**:
   - D1 Retention (Day 1 return rate)
   - D7 Retention (Day 7 return rate)
   - Session completion rate
   - Daily free games allowance depletion

2. **Set up alerts**:
   - Crash rate > 5%
   - Session errors > 10% of sessions

### Verification

- [ ] Firebase initialized in app (no crashes on startup)
- [ ] Manual gameplay triggers events
- [ ] Firebase Console shows events in real-time
- [ ] Crash reporting works (test with `throw Exception('test')`)
- [ ] Dashboard displays retention metrics

---

## 6. Pre-Launch QA & Playtesting

### Phase A: Manual QA Checklist

Reference: [docs/qa/wedge-qa-checklist.md](../qa/wedge-qa-checklist.md)

**Critical flows to test:**

1. **Onboarding**
   - [ ] First-time app launch (no user data)
   - [ ] User ID generated and stored securely
   - [ ] Tutorials display correctly

2. **Gameplay**
   - [ ] Level difficulty adapts based on star rating
   - [ ] Hints work and consume hearts correctly
   - [ ] Streak system detects continuation/gap/break correctly
   - [ ] Allowance refills daily at midnight UTC
   - [ ] Share bonus claims only once per day

3. **Analytics**
   - [ ] `level_complete` event fires after puzzle solved
   - [ ] `streak_update` event fires on daily check
   - [ ] `session_start` / `session_end` logged
   - [ ] Crashes are reported to Firebase Crashlytics

4. **Platforms (Test on all)**
   - [ ] iOS simulator
   - [ ] Android emulator
   - [ ] Web (Chrome/Safari)
   - [ ] macOS desktop

5. **Performance**
   - [ ] App startup time < 3 seconds
   - [ ] No jank during gameplay (smooth 60fps)
   - [ ] Memory usage stable (no leaks over 10+ sessions)

6. **Security**
   - [ ] User ID not exposed in logs
   - [ ] Hive encryption key stored securely (Keychain/Keystore)
   - [ ] No API keys in source code

### Phase B: Playtester Recruitment

**Goal:** 5–10 external playtesters who represent target audience

**Where to recruit:**
- Flutter Discord (#games channel)
- Reddit: r/IndieGaming, r/gamedev
- Twitter/X: #gamedev, #indiedev hashtags
- Friends / family network
- Local game dev meetups

**Playtester onboarding:**
1. Send download link (TestFlight for iOS, Google Play Beta for Android, web link)
2. Distribute [docs/playtests/SURVEY-TEMPLATE.md](../playtests/SURVEY-TEMPLATE.md)
3. Request feedback over 3–5 days (5–10 play sessions each)
4. Collect survey responses

**Survey template sections:**
- Onboarding clarity (1–5 scale)
- Gameplay difficulty (too easy / just right / too hard)
- Engagement (would you play again? 1–5 scale)
- Bug reports (crashes, missing features)
- Retention concern: Did daily allowance feel fair? (1–5 scale)

### Phase C: Analytics Validation

**Verify these KPIs in Firebase:**

| Metric | Target | How to Check |
|--------|--------|-------------|
| **D1 Retention** | >30% | Users who return day 2 / total day 1 users |
| **D7 Retention** | >10% | Users who return day 7 / total day 1 users |
| **Session completion rate** | >60% | Sessions with ≥1 level completed / total sessions |
| **Allowance depletion** | >50% | Users reaching 0 allowance / active users |
| **Share bonus claims** | >20% | Users claiming share bonus / active users |
| **Crash rate** | <2% | Crashed sessions / total sessions |

**If metrics are below target:**
- Review gameplay difficulty (too hard → frustration → drop-off)
- Check allowance balance (too generous → no monetization signal; too stingy → friction)
- Analyze crash logs to fix stability issues

---

## 7. Sprint 1 Closeout Checklist

### REQUIRED (Must Complete Before Launch)

**App Store Submission (iOS & Android):**
- [ ] Developer accounts created (~$99/yr iOS, ~$25 Android)
- [ ] App icons designed (1024×1024px minimum)
- [ ] Screenshots taken (≥2 per platform)
- [ ] Privacy policy published
- [ ] iOS build signed (release certificate + provisioning profile)
- [ ] Android AAB generated (signed with keystore)
- [ ] iOS app submitted to App Store Connect
- [ ] Android app submitted to Google Play Console
- [ ] Both apps approved (pending review 24–48 hours)

**Analytics Configuration (Firebase):**
- [ ] Firebase project created
- [ ] Firebase initialized in Flutter app
- [ ] `analyticsSinkProvider` implemented in Riverpod
- [ ] Manual gameplay triggers events in Firebase console
- [ ] Dashboards created for core KPIs (D1 retention, session completion)

**Manual QA Completed:**
- [ ] All flows from [docs/qa/wedge-qa-checklist.md](../qa/wedge-qa-checklist.md) passed
- [ ] Tested on iOS, Android, macOS, Web
- [ ] Performance validated (startup < 3s, 60fps gameplay)
- [ ] Security audit passed (no secrets in logs, encryption working)

**Playtester Feedback Collected:**
- [ ] ≥5 external playtesters recruited
- [ ] [docs/playtests/SURVEY-TEMPLATE.md](../playtests/SURVEY-TEMPLATE.md) distributed
- [ ] Feedback collected over 3–5 days
- [ ] Critical bugs logged and fixed
- [ ] Survey responses analyzed

**KPI Validation:**
- [ ] D1 retention ≥30% (from Firebase)
- [ ] Session completion ≥60%
- [ ] Crash rate <2% (from Crashlytics)
- [ ] No showstopper bugs in playtester feedback

---

### OPTIONAL (Can Postpone to Sprint 2)

**Web Version & Backend Hosting (Only if web deployment needed):**
- [ ] Decide whether web version required for Sprint 1
- [ ] If yes: Cloud Run service created
- [ ] If yes: Staging URL accessible
- [ ] If yes: Staging URL filled in [docs/RELEASE-GATES.md](../RELEASE-GATES.md#gate-5-qa-on-staging)
- [ ] If yes: Health check endpoint returns 200
- [ ] If yes: App loads on real Web browsers (Chrome, Safari)

---

## 8. Troubleshooting

### Cloud Run Deployment Issues

**Problem:** `gcloud run deploy` fails with authentication error

```bash
# Solution: Re-authenticate
gcloud auth login
gcloud auth application-default login
```

**Problem:** Staging URL returns 404

```bash
# Check service status
gcloud run services describe mitoosa-web --region us-central1

# View logs
gcloud run services logs read mitoosa-web --region us-central1 --limit 50
```

**Problem:** Cold start times > 5 seconds

- Increase min instances: `gcloud run deploy ... --min-instances=1`
- Reduce app bundle size (tree-shake unused code)

### Firebase Analytics Issues

**Problem:** Events not appearing in real-time dashboard

1. Verify Firebase initialization in `main.dart`
2. Check that `analyticsSinkProvider` is being watched by a consumer
3. Manually trigger events and wait 1–2 minutes (real-time has slight latency)
4. Verify event names match Firebase custom event naming rules (lowercase, underscores only)

**Problem:** Crashes not reported in Crashlytics

```dart
// Ensure FlutterError handler is set
FlutterError.onError = (FlutterErrorDetails details) {
  FirebaseCrashlytics.instance.recordFlutterFatalError(details);
};
```

### Playtester Recruitment

**Problem:** Hard to find playtesters

- Offer incentive: free VIP upgrade for 1 month
- Post in multiple Discord servers (not just one)
- Leverage personal network first (friends, family, colleagues)
- Offer gift cards ($5–$10) for detailed feedback

---

## 9. Post-Launch Next Steps

After Sprint 1 closes and launch is live:

1. **Monitor analytics** daily (Week 1)
   - Track D1/D7 retention in real-time
   - Watch crash rate closely
   - Respond to urgent bugs within hours

2. **Iterate on difficulty**
   - If D1 retention < 25%, reduce difficulty
   - If session completion < 50%, review level progression

3. **Plan analytics expansion** (Post-launch)
   - Export Firebase events to BigQuery for deeper analysis
   - Set up cohort analysis for A/B testing
   - Consider Amplitude for advanced retention funnel analysis

4. **Scale infrastructure** (When > 10K concurrent users)
   - Consider multi-region deployment
   - Evaluate load balancing strategy
   - Plan for Game Center / Game Services integration

---

## Contact & References

- **Firebase Docs:** https://firebase.flutter.dev/
- **Cloud Run Docs:** https://cloud.google.com/run/docs
- **Google Analytics SDK:** https://support.google.com/analytics/answer/12159447
- **miToosa Product Wedge:** [docs/PRODUCT-WEDGE.md](../PRODUCT-WEDGE.md)
- **Analytics Events Schema:** [docs/analytics-events-v1.3.md](../analytics-events-v1.3.md)
- **Release Gates:** [docs/RELEASE-GATES.md](../RELEASE-GATES.md)

---

**Last Updated:** April 23, 2026  
**Next Review:** After Sprint 1 launch (May 2026)
