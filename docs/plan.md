## Plan: miToosa Sleek iOS Redesign

**TL;DR**
Redesign the current `miToosa` UI (running on localhost:60843) into a modern, sleek iOS game application optimized for ADHD flow. The visual overhaul introduces the "Aetheric Pulse" theme: glassmorphism components, soft blue (`#597AFA`) and pink gradients, fluid spring animations, and visually satisfying dopamine-feedback loops (e.g., "IQ +1!").

**Mockup Links & Variants Generated**
- Project ID: `8116825045928899731`
- Mockup Variant 1 (Dashboard Map): Screen ID `cb2f8947555041b6b1d0a2af0114e940`
- Mockup Variant 2 (Progress/Streak): Screen ID `2db3a9c3f7934ca6ab0497d5adf30351`
- Mockup Variant 3 (Leaderboard): Screen ID `0ba2fc556ebd4b0aa60b551f6330781d`
*(Note: View these directly in your Stitch Design Workspace or studio for full interactive layouts).*

**Steps**
1. **Theme Overhaul**: Update `lib/theme/design_system.dart` to strictly enforce the Aetheric Pulse theme.
   - Inject soft gradients (`LinearGradient`) into backgrounds.
   - Implement `BackdropFilter` for glassmorphic cards and modals.
   - Adjust `borderRadius` constants to a 25px-40px range.
2. **Navigation Shell Refactor**: Update `lib/features/main_app/main_app_shell.dart`.
   - Replace standard Material BottomNavigationBar with a floating, frosted-glass bottom nav bar.
3. **World Map / Dashboard Optimization**:
   - Rework the Track selection interface into a continuous vertical or path-based scrolling map.
   - Add pulsating nodes for unlocked levels to draw visual attention.
4. **Dopamine Feedback Loop Component**:
   - Create a new overlay/toast widget for instantaneous positive reinforcement ("IQ +1!").
   - Tie these to the `flutter_riverpod` state changes upon completing puzzles.
5. **Onboarding & Auth Polish**:
   - Apply sleek transitioning effects to `lib/features/auth/login_screen.dart` with large, rounded Apple-style buttons.

**Relevant files**
- `lib/theme/design_system.dart` — Core palette, typography, and glassmorphic utility classes.
- `lib/features/main_app/main_app_shell.dart` — Floating glassmorphic tab root.
- `lib/features/navigation/world_map_screen.dart` — Path map layout redesign.
- `lib/widgets/feedback_toast.dart` — (New) Real-time dopamine reward popups.

**Verification**
1. Run `flutter run -d iPhone` or via the iOS Simulator to ensure proper glassmorphic rendering (often tricky across platforms).
2. Validate the tap targets are at least 44x44 points for iOS accessibility standards.
3. Test the state transitions with `flutter_riverpod` to ensure feedback popups don't drop frames below 60fps.

**Decisions**
- *Glassmorphism over Flat Design*: Chosen specifically to mimic high-end modern iOS aesthetics, aligning with the 2026 cognitive gaming intent.
- *Strict ADHD Flow*: Animations will maintain short spring curves (200-400ms) to keep engagement high without frustrating delays.

**Further Considerations**
1. Do we want to persist the exact soft blue/pink colors for dark mode, or should we introduce a deeply saturated violet variant for low-light play?
2. Should the haptic feedback (via `flutter_vibrate` or similar) be tied to the new dopamine visual widgets?