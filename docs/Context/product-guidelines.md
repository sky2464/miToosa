# Product Guidelines

<!-- Last updated: 2026-05-04 — /agtoosa-init -->

## Brand Voice
brand_voice: "Encouraging and playful. Short sentences. ADHD-friendly — no walls of text. Celebrate wins loudly. Soften losses gently. Never shame the player."

## UI Style
ui_style: "Modern iOS 2026 aesthetic. Glassmorphism. Dopamine-optimized visual feedback. Dark-mode first. Rounded corners, vibrant accent colours, smooth animations."

## Error Message Tone
error_tone: "Friendly and actionable. Always suggest the next step. Never blame the user. Example: 'No hearts left — share the app to earn 40 more games, or play a lower level!'"

## Accessibility Standard
accessibility: "WCAG 2.1 AA"
accessibility_requirements:
  - "44pt minimum touch targets on all interactive elements"
  - "Semantic labels on all icons and interactive widgets"
  - "Dynamic Type support (respects system font size)"
  - "Screen-reader compatible (iOS VoiceOver, Android TalkBack)"
  - "Enforced by /agtoosa-review QA Lead"

## Naming Conventions
naming_conventions:
  classes: "PascalCase (e.g., HintButton, GameplayEngine)"
  files: "snake_case (e.g., gameplay_screen.dart, hint_button.dart)"
  functions: "camelCase (e.g., selectOption, useHint)"
  providers: "camelCase ending in Provider (e.g., authProvider, playerProgressProvider)"
  tests: "describe behaviour, not implementation (e.g., 'streak resets after 2-day gap')"
  constants: "lowerCamelCase (Dart idiom)"

## Economy Copy Rules
economy_copy:
  - "All economy copy must match docs/PRODUCT-WEDGE.md exactly — never invent new language"
  - "Top-level unit: 'free games' (not hearts, not energy, not coins)"
  - "Share CTA: friendly, not pressuring — 'Share to unlock 40 more games!'"
  - "Streak messaging: celebrate milestones, soften misses — 'Day 3 streak! Keep it going!'"
  - "VIP framing: convenience only — never 'unlock the full game'"

## Notes
<!-- Design system: custom Flutter widgets with glassmorphism theme -->
<!-- Icon set: Material Icons (use --no-tree-shake-icons build flag if needed) -->
<!-- Fonts: NotoSans, NotoSansSymbols, NotoColorEmoji, Roboto (download via scripts/download_noto_fonts.sh) -->
