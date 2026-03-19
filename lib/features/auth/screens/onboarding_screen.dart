// lib/features/auth/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _guestLoading = false;

  static const _pages = [
    _OnboardingPage(
      emoji: '🌱',
      title: 'Your Garden,\nSmarter.',
      subtitle: 'OmniGarden combines everything a real gardener needs — plant knowledge, local calendars, and a personal journal — in one app.',
    ),
    _OnboardingPage(
      emoji: '📚',
      title: '1,700+ Plants\nAt Your Fingertips.',
      subtitle: 'Full growing guides for vegetables, herbs, fruits, and flowers. Soil tips, watering schedules, pest alerts, harvesting guides, and more.',
    ),
    _OnboardingPage(
      emoji: '🗓️',
      title: 'Planting Calendars\nFor Your Exact Zone.',
      subtitle: 'Enter your ZIP code and get personalized planting dates based on your USDA hardiness zone and local frost dates.',
    ),
    _OnboardingPage(
      emoji: '📔',
      title: 'Track Every\nGarden Moment.',
      subtitle: 'Log journal entries with photos, plan your garden layout, and track what you planted, when you planted it, and how it grew.',
    ),
  ];

  Future<void> _continueAsGuest() async {
    setState(() => _guestLoading = true);
    await ref.read(authStateNotifierProvider.notifier).continueAsGuest();
    setState(() => _guestLoading = false);
    if (mounted) context.go(AppRoutes.zipEntry);
  }

  void _nextPage() {
    if (_currentPage < _pages.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.fern, Color(0xFF2A3D1F), AppColors.soil],
            stops: [0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          child: PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              // Feature pages
              ..._pages.map((page) => _FeaturePage(
                page: page,
                onNext: _nextPage,
                onSkip: () => _pageController.animateToPage(
                  _pages.length,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                ),
              )),

              // Sign up / sign in page
              _AuthPage(
                guestLoading: _guestLoading,
                onGuest: _continueAsGuest,
              ),
            ],
          ),
        ),
      ),
      bottomSheet: isLastPage
          ? null
          : Container(
              color: Colors.transparent,
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length + 1,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _currentPage ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? AppColors.leaf
                          : AppColors.warmGray.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
  final String emoji;
  final String title;
  final String subtitle;
}

class _FeaturePage extends StatelessWidget {
  const _FeaturePage({
    required this.page,
    required this.onNext,
    required this.onSkip,
  });
  final _OnboardingPage page;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skip button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                'Skip',
                style: AppTypography.bodyS(color: AppColors.warmGray),
              ),
            ),
          ),

          const Spacer(flex: 2),

          // Emoji
          Center(
            child: Text(page.emoji, style: const TextStyle(fontSize: 90)),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            style: AppTypography.displayXL(color: AppColors.cream),
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            page.subtitle,
            style: AppTypography.bodyM(
              color: AppColors.cream.withOpacity(0.70),
            ),
          ),

          const Spacer(flex: 3),

          // Next button
          OGButton(
            label: 'Next',
            onPressed: onNext,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _AuthPage extends StatelessWidget {
  const _AuthPage({
    required this.guestLoading,
    required this.onGuest,
  });
  final bool guestLoading;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),

          const Center(
            child: Text('🌿', style: TextStyle(fontSize: 80)),
          ),
          const SizedBox(height: 28),

          Text(
            'Stop Googling\n"when to plant\njalapeños."',
            style: AppTypography.displayXL(color: AppColors.cream),
          ),
          const SizedBox(height: 16),
          Text(
            'Create a free account to save your gardens, journal entries, and planting calendars across devices.',
            style: AppTypography.bodyM(
              color: AppColors.cream.withOpacity(0.65),
            ),
          ),

          const Spacer(flex: 2),

          OGButton(
            label: 'Create Account',
            icon: '✉',
            onPressed: () => context.push(AppRoutes.signUp),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: BorderSide(color: AppColors.cream.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
            onPressed: () => context.push(AppRoutes.signIn),
            child: Text(
              'Sign In',
              style: AppTypography.button(color: AppColors.cream),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text('or', style: AppTypography.bodyS(color: AppColors.warmGray)),
              ),
              Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
            ],
          ),
          const SizedBox(height: 16),

          Center(
            child: guestLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.warmGray),
                    strokeWidth: 2,
                  )
                : TextButton(
                    onPressed: onGuest,
                    child: Text(
                      'Skip for now — Guest mode',
                      style: AppTypography.bodyS(color: AppColors.warmGray),
                    ),
                  ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
