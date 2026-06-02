import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/design_system.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  /// BL-07: total page count — single source of truth for the page-indicator
  /// dots and the "Next vs. Get Started" CTA logic. Bumped 3 → 4 to add the
  /// first-session expectation-setting page.
  static const int _kPageCount = 4;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // PageView with 3 pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                // BL-07 First-Session Onboarding Optimisation:
                // 4-page flow that ends with an explicit "what happens next"
                // expectation-setting page. Reduces first-session anxiety by
                // telling players up-front: 5 puzzles, ~2 minutes, no penalty
                // for being wrong. This is what playtest is expected to ask
                // for; shipping it now lets the playtest validate vs. baseline.
                children: const [
                  _OnboardingPage(
                    icon: '🧩',
                    title: 'Welcome to miToosa',
                    description:
                        'A puzzle game designed to train your pattern recognition and spatial reasoning skills.',
                  ),
                  _OnboardingPage(
                    icon: '⭐',
                    title: 'Earn Stars & XP',
                    description:
                        'Complete levels to earn stars and XP. Improve your scores by solving puzzles faster and with fewer mistakes.',
                  ),
                  _OnboardingPage(
                    icon: '🎁',
                    title: '25 Free Games Daily',
                    description:
                        'Play 25 games every day for free — no catch. Share with a friend to unlock 40 bonus games. Optional upgrades come later, only if you want them.',
                  ),
                  _OnboardingPage(
                    icon: '🚀',
                    title: "Here's what happens next",
                    description:
                        'Your first session is 5 quick puzzles — about 2 minutes. Wrong answers don\'t cost a thing. Pick any track you like; we\'ll adapt the difficulty to you.',
                  ),
                ],
              ),
            ),
            // Indicators & Navigation
            Padding(
              padding: const EdgeInsets.all(MiToosaTheme.spacingLg),
              child: Column(
                children: [
                  // Skip button
                  if (_currentPage < _kPageCount - 1)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _completeOnboarding(ref),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Page indicators (dots)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _kPageCount,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: MiToosaTheme.spacingLg),
                  // Buttons
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Text('Back'),
                          ),
                        ),
                      if (_currentPage > 0)
                        const SizedBox(width: MiToosaTheme.spacingMd),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (_currentPage < _kPageCount - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              // Mark onboarding as complete
                              _completeOnboarding(ref);
                            }
                          },
                          child: Text(
                            _currentPage < _kPageCount - 1
                                ? 'Next'
                                : 'Get Started',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _completeOnboarding(WidgetRef ref) {
    widget.onComplete();
  }
}

class _OnboardingPage extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 96)),
          const SizedBox(height: MiToosaTheme.spacingLg),
          Text(
            title,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MiToosaTheme.spacingMd),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MiToosaTheme.spacingXl,
            ),
            child: Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
