import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

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
                children: [
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
                    icon: '❤️',
                    title: 'Manage Your Hearts',
                    description:
                        'You have 5 hearts. Each wrong guess costs 1 heart. Refuel by completing levels, playing daily, or with diamonds.',
                  ),
                ],
              ),
            ),
            // Indicators & Navigation
            Padding(
              padding: const EdgeInsets.all(MiToosaTheme.spacingLg),
              child: Column(
                children: [
                  // Page indicators (dots)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withValues(alpha: 0.3),
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
                            if (_currentPage < 2) {
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
                            _currentPage < 2 ? 'Next' : 'Get Started',
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
    // For now, just pop back. In a real app, this would mark onboarding
    // as complete in the persistence layer
    Navigator.of(context).pop();
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
          Text(
            icon,
            style: const TextStyle(fontSize: 96),
          ),
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
