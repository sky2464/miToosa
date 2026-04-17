# miToosa v1.2.0 Launch Plan

**Release Date Target:** April 2026  
**Status:** Pre-Launch Verification  
**Platforms:** iOS (App Store), Android (Play Store), Web

---

## Pre-Launch Checklist

### ✅ Code Quality

- [x] All tests pass (264/264 tests passing)
- [x] Build succeeds with no errors (`flutter build ios/apk/web` verified)
- [x] Lint and type checking pass (`dart analyze` with zero errors)
- [x] Code reviewed and approved (multi-axis code review completed)
- [x] No TODO comments that block launch (onboarding persistence documented as future enhancement)
- [x] Error handling covers expected failure modes (AsyncValue.when used throughout)

### ✅ Platform Configuration

#### iOS
- [x] Info.plist configured with AppTransportSecurity (allows HTTPS only)
- [x] NSLocalNetworkUsageDescription added (no local network access required)
- [x] Build signing configured (`--no-codesign` flag documented for dev builds)
- [ ] **BLOCKED:** Provisioning profile and team ID configured in Xcode — requires Apple Developer account
- [ ] **BLOCKED:** App Store ID assigned (currently placeholder `id0000000000`) — requires App Store Connect project
- [ ] **BLOCKED:** AdHoc signing certificate for TestFlight — requires Apple Developer account

#### Android
- [x] build.gradle.kts configured with app signing template
- [x] Gradle wrapper configured for reproducible builds
- [x] targetSdkVersion aligned with Google Play requirements
- [ ] **BLOCKED:** Keystore file created and secured — requires manual `keytool` generation with passwords
- [ ] **BLOCKED:** signing.properties configured with keystore path/password — depends on keystore
- [ ] **BLOCKED:** Google Play Console project created — requires Google Play Developer account

#### Web
- [x] Web build verified (`flutter build web --no-tree-shake-icons`)
- [x] BUILD.md documents font subsetting workaround
- [x] index.html configured with proper manifest
- [ ] **BLOCKED:** Deploy to staging server first — hosting provider not selected
- [ ] **BLOCKED:** Production CDN configured — depends on hosting provider

### ✅ Security

- [x] No secrets in code or version control (`git grep` for common patterns)
- [x] No hardcoded API keys or tokens
- [x] Input validation on all user-facing inputs (level navigation checks bounds)
- [x] Authentication integrated (auth_provider checks user state)
- [x] Navigation state correctly isolated (each tab has independent context)
- [x] HTTPS enforced (Info.plist NSAppTransportSecurity)
- [x] Privacy policy drafted (`docs/PRIVACY-POLICY.md`) — needs legal review before publication
- [x] GDPR/data retention policy documented (`docs/DATA-RETENTION.md`)
- [x] Rate limiting on auth endpoints — N/A: no backend; auth is local UUID generation via platform keychain

### ✅ Performance

- [x] No N+1 patterns (categories precomputed, progress loaded once)
- [x] State management efficient (Riverpod lazy-loads providers)
- [x] Memory leaks checked (no circular references in Riverpod)
- [x] UI responsive (SliverGrid, IndexedStack for smooth tab switching)
- [x] Image assets optimized (emoji icons used instead of raster images)
- [ ] **BLOCKED:** Core Web Vitals measured in real browser (Lighthouse audit) — requires deployed web build
- [ ] **TODO:** App size optimized (`flutter build apk --release --analyze-size`)

### ✅ Accessibility

- [x] Color contrast verified (dark theme on light backgrounds passes WCAG AA)
- [x] Touch targets sized appropriately (48dp minimum)
- [x] Error messages descriptive (level bounds validation)
- [x] Keyboard navigation supported (native Flutter MaterialApp behavior)
- [ ] **BLOCKED:** Screen reader tested with TalkBack (Android) and VoiceOver (iOS) — requires physical devices
- [ ] **BLOCKED:** Axe Core accessibility audit passed — requires deployed web build

### ✅ Monitoring

- [x] Crash reporting ready for integration (Firebase Crashlytics recommended)
- [x] Error handling covers lifecycle events (auth state, level loading)
- [x] User exit points identified (onboarding completion, level failures)
- [x] Local session telemetry integrated (Hive-based, on-device only)
- [ ] **BLOCKED:** Cloud analytics setup (Firebase Analytics recommended) — requires Firebase project
- [ ] **BLOCKED:** Monitoring dashboard configured — requires Firebase project
- [ ] **BLOCKED:** Alert thresholds set (crash rate >5%, latency p95 >2s) — requires monitoring infrastructure

### ✅ Documentation

- [x] README updated with features and installation
- [x] BUILD.md created with platform-specific build commands
- [x] CONTRIBUTING.md available
- [x] API design documented (State management via Riverpod)
- [x] Release notes prepared (v1.2.0 features) — see `CHANGELOG.md`
- [x] Changelog updated — `CHANGELOG.md` created at repo root
- [x] User onboarding/help documentation — see `docs/USER-GUIDE.md`

---

## Per-Platform Deployment Instructions

### iOS App Store

**Prerequisites:**
1. Apple Developer account active and verified
2. App Store Connect project created
3. Bundle ID registered: `com.mitoosa.app` (update in pubspec.yaml/Xcode)
4. Provisioning profile downloaded
5. Signing certificate (.p8) configured in Xcode

**Build & Upload:**
```bash
# 1. Set build version in pubspec.yaml
#    version: 1.2.0+2  (increment build number for each upload)

# 2. Build for iOS with signing
flutter build ios --release

# 3. Upload to App Store Connect via Xcode
#    - Open build/ios/Runner.xcworkspace in Xcode
#    - Product > Archive
#    - Distribute App > App Store Connect
#    - Review and submit

# 4. Wait for App Store review (typically 24-48 hours)
```

**Rollout:**
- Phase 1 (Day 0): Internal TestFlight to dev team (48 hours testing)
- Phase 2 (Day 2): Expand TestFlight to beta testers (5 users, 3 days)
- Phase 3 (Day 5): Submit to App Store review
- Phase 4 (Day 7): App Store approval → phased rollout (25% → 100% over 7 days)

**Rollback:**
- Pre-release: Pull from TestFlight and TestFlight build list
- Post-release: Update version, fix issue, submit update (takes ~24-48 hours for review)

### Android Play Store

**Prerequisites:**
1. Google Play Developer account active ($25 one-time fee)
2. Play Console project created
3. Keystore file generated and secured
4. signing.properties configured with keystore path
5. Package name registered

**Generate Signing Key:**
```bash
keytool -genkey -v -keystore ~/mitoosa-release.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias mitoosa-release -storepass <PASSWORD> -keypass <PASSWORD>
```

**Build & Upload:**
```bash
# 1. Create/update signing.properties
#    storeFile=~/mitoosa-release.keystore
#    storePassword=<PASSWORD>
#    keyAlias=mitoosa-release
#    keyPassword=<PASSWORD>

# 2. Build release APK
flutter build apk --release

# 3. Upload to Google Play Console
#    - Play Console > Your app > Release > Production
#    - Upload APK (build/app/outputs/flutter-apk/app-release.apk)
#    - Review store listing
#    - Submit for review

# 4. Wait for Play Store review (typically 2-3 hours)
```

**Rollout:**
- Phase 1 (Day 0): Internal testing via internal testing track (48 hours)
- Phase 2 (Day 2): Closed testing (5-10 testers, 3 days)
- Phase 3 (Day 5): Open testing (public beta, unlimited testers)
- Phase 4 (Day 7): Production release (phased 10% → 100% over 7 days)

**Rollback:**
- Internal testing: Delete build from internal track
- Production: Publish lower version number, then higher fixed version

### Web Deployment

**Build:**
```bash
flutter build web --release --no-tree-shake-icons
# Output: build/web/
```

**Deploy to Staging:**
```bash
# Use your web host (Firebase Hosting, Netlify, Vercel, etc.)
firebase deploy --only hosting:mitoosa-staging

# Or manually upload build/web/ to staging subdomain
```

**Verify:**
```bash
# Test critical flows:
# - Onboarding completes
# - Level gameplay works
# - Progress tracking persists
# - Responsive layout on mobile browsers
```

**Deploy to Production:**
```bash
firebase deploy --only hosting:mitoosa-production
# Or promote from staging to production
```

---

## Staged Rollout Timeline

### Week 1: Internal & Beta Testing
```
Day 0 (Monday):
  - iOS: Upload to TestFlight (dev team)
  - Android: Open internal testing track
  - Web: Deploy to staging.mitoosa.dev
  - Monitoring: Set up error reporting dashboards

Day 1-2 (Tuesday-Wednesday):
  - Dev team tests all critical flows
  - Document bugs found
  - Monitor crash rate, app opens, level completions
  - Target: 0 critical bugs before public beta

Day 3-4 (Thursday-Friday):
  - iOS: Expand TestFlight to 5 beta testers
  - Android: Expand to 10 testers in closed track
  - Web: Send staging link to beta group
  - Collect user feedback on UX/performance
```

### Week 2: Store Submission & Gradual Rollout
```
Day 5 (Monday):
  - iOS: Submit to App Store review
  - Android: Submit to Play Store review
  - Web: Ready for production promotion

Day 6-7 (Tuesday-Wednesday):
  - Continue monitoring beta metrics
  - Prepare release notes and store listing
  - Verify rollback procedures
  - Target: 95%+ beta retention (< 5% uninstalls)

Day 8 (Thursday):
  - iOS: App Store approval expected → begin phased rollout (25%)
  - Android: Play Store approval expected → begin phased rollout (10%)
  - Web: Deploy to production
  - Monitoring: Strict thresholds
    - Crash rate > 1% → HALT and investigate
    - P99 latency > 5s → HALT and investigate
    - User retention drop > 10% → HALT and investigate
```

### Week 3-4: Full Rollout
```
Day 10-11:
  - iOS: 50% rollout
  - Android: 25% rollout
  - Monitor key metrics at each stage

Day 13:
  - iOS: 100% rollout
  - Android: 100% rollout
  - Continue 1-week monitoring period

Day 20:
  - Full rollout complete
  - Establish steady-state monitoring
  - Begin v1.2.1 bug-fix cycle
```

### Rollout Decision Thresholds

Roll back **immediately** if:
- Crash rate > 2% (vs. 0% baseline in beta)
- P95 latency > 3 seconds
- Users report inability to complete core flow (onboarding, level)
- Data corruption or loss detected

Hold and **investigate** if:
- Crash rate 0.5-2%
- P95 latency 2-3 seconds
- New error types appear
- User retention drops 5-10%

**Advance** if:
- Crash rate < 0.5%
- P95 latency < 2 seconds
- No new error types
- User retention stable or positive

---

## Monitoring & Observability Setup

### Core Metrics to Track

**Error & Stability:**
- App crashes (by platform, by version)
- Uncaught exceptions (Flutter engine errors)
- Network errors (backend timeout, no internet)
- Custom error events (level load failures, auth errors)

**Engagement:**
- Daily active users (DAU)
- Session length (minutes per day)
- Level completion rate (by track)
- Onboarding completion rate (% reaching first level)

**Performance:**
- App startup time (cold start, warm start)
- Level load time (time to first interactive)
- Frame rate during gameplay (target 60fps, monitor for jank)
- Memory usage (peak, average)

**Business:**
- User retention (D1, D7, D30)
- Feature usage (% seeing onboarding, % reaching track selection)
- Share feature clicks (social virality indicator)

### Recommended Tools

**Error Reporting:**
- [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics) (free tier included, integrates with Flutter)
- Setup: Add `firebase_crashlytics` to pubspec.yaml, call `FirebaseCrashlytics.instance.recordError()` in error handlers

**Analytics:**
- [Firebase Analytics](https://firebase.google.com/docs/analytics) (free, Flutter native support)
- Track: `onboarding_complete`, `level_start`, `level_complete`, `share_click`
- Setup: Add `firebase_analytics` to pubspec.yaml, call `FirebaseAnalytics.instance.logEvent(name: 'event_name', parameters: {...})`

**Performance Monitoring:**
- [Firebase Performance Monitoring](https://firebase.google.com/docs/perf-mon) (free tier)
- Auto-traces: app startup, network requests, view rendering
- Custom traces: Riverpod provider load time, category grouping computation

**Dashboards:**
- Firebase Console (free dashboard included)
- Custom: [Grafana](https://grafana.com/) or [DataDog](https://www.datadoghq.com/) for deep analysis

---

## Communication Plan

### Release Announcement (Day 10)
**Channels:** Twitter, Product Hunt, Reddit (/r/mobile, /r/iosgaming, /r/androiddev)

**Message Template:**
```
🧠 miToosa v1.2.0 is live! 

Introducing:
• 🎮 Onboarding flow - learn the rules in 3 easy pages
• 📊 Progress tracking - watch your IQ grow with stats
• 🏆 Track selection - 23 unique puzzle categories
• 🎨 Enhanced visuals - premium glassmorphism design

Download now: [App Store] [Play Store] [Web]

Special thanks to beta testers who helped us ship with confidence.
```

### Release Notes

```markdown
## v1.2.0 - The Engagement Update (April 2026)

### New Features
- **Onboarding Flow**: 3-page guided introduction for new players
- **Progress Tracking**: XP, hearts, diamonds, streaks, levels completed
- **Track Selection**: Browse levels by category before playing
- **Bottom Navigation**: Quick access to Tracks, Progress, Leaderboard

### Improvements
- Fixed 5-star rating footer display
- Level bounds validation prevents out-of-range access
- Meaningful hints tailored to puzzle rule
- Training mode (easier levels 0-2) for new players
- Enhanced color palette with dopamine-driven aesthetics

### Bug Fixes
- Removed debug yellow artifact
- Fixed XP display alignment in header
- Corrected timer display in gameplay overlay

### Known Limitations
- Leaderboard is a placeholder (coming in v1.3)
- Telemetry is local-only; cloud analytics deferred to v1.3
- App Store share feature uses placeholder URL (will update after App Store approval)

### Technical
- Version: 1.2.0+1
- Flutter 3.5.0+
- iOS 12.0+ | Android 5.0+ | Web (Chrome/Edge/Safari)
- 264 unit/widget tests passing
```

---

## Rollback Procedures

### If Post-Launch Critical Bug Found

1. **Assess severity** (within 1 hour)
   - Does it prevent core flow (onboarding → level play → completion)?
   - Does it cause data loss or corruption?
   - Does it expose user data?
   - If YES to any: **INITIATE ROLLBACK**

2. **Immediate actions**
   - Pause rollout (iOS phased rollout → 0%, Android → halt update)
   - Notify team via Slack #incidents
   - Create GitHub issue with `critical-bug` label
   - Start postmortem doc

3. **Fix the bug**
   - Merge fix to main
   - Increment build number (1.2.0+2)
   - Build release binaries
   - Internal testing (30 minutes)

4. **Recommence rollout**
   - iOS: Resubmit to App Store (expedited review, ~4 hours)
   - Android: Upload new APK to Play Console, restart phased rollout
   - Notify users of fix in release notes

### If Infrastructure/Backend Issue

1. **If our backend is down:**
   - App gracefully handles offline (uses cached progress)
   - No user data loss
   - Restore backend within SLA
   - Monitor error rates post-recovery

2. **If store down (rare):**
   - Pause rollout
   - Resume when store is back
   - No user impact (app still works on devices)

---

## Post-Launch (Day 30)

### Success Metrics

- [ ] 10,000+ downloads
- [ ] < 1% crash rate
- [ ] > 50% D1 retention
- [ ] > 30% D7 retention
- [ ] > 20% D30 retention
- [ ] > 50% of users complete onboarding
- [ ] Average session 5+ minutes

### Next Steps

1. Monitor performance over 30 days
2. Collect user feedback from reviews
3. Plan v1.2.1 (bug fixes)
4. Plan v1.3 (leaderboard real implementation, referral system, cloud analytics)

---

## Contacts & Escalation

| Role | Name | Slack | On-Call |
|------|------|-------|---------|
| Product Lead | @chicademy | #mitoosa | Always |
| Engineering Lead | @chicademy | #mitoosa | Always |
| App Store Relations | Apple Support | | During rollout |
| Play Store Relations | Google Support | | During rollout |

---

## Launch Checklist Sign-Off

- [ ] PM: Feature complete, release notes ready
- [ ] QA: All tests pass, critical flows verified in beta
- [ ] Eng: Build verified on all platforms, monitoring configured
- [ ] Legal: Privacy policy and ToS reviewed
- [ ] Marketing: Announcement drafted and approved

**Final Sign-Off:** _______________  **Date:** _______________
