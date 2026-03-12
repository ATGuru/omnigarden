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
  bool _guestLoading = false;

  Future<void> _continueAsGuest() async {
    setState(() => _guestLoading = true);
    await ref.read(authStateNotifierProvider.notifier).continueAsGuest();
    setState(() => _guestLoading = false);
    if (mounted) context.go(AppRoutes.zipEntry);
  }

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),

                // Hero emoji
                const Center(
                  child: Text('🌱', style: TextStyle(fontSize: 80)),
                ),
                const SizedBox(height: 28),

                // Headlines
                Text(
                  'Stop Googling\n"when to plant\njalapeños."',
                  style: AppTypography.displayXL(color: AppColors.cream),
                ),
                const SizedBox(height: 16),
                Text(
                  'OmniGarden combines a plant encyclopedia, hyper-local frost calendar, and personal garden journal — built for real gardeners.',
                  style: AppTypography.bodyM(
                    color: AppColors.cream.withOpacity(0.65),
                  ),
                ),
                const Spacer(flex: 2),

                // CTA buttons
                OGButton(
                  label: 'Create Account',
                  icon: '✉',
                  onPressed: () => context.push(AppRoutes.signUp),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push(AppRoutes.signIn),
                  child: Text(
                    'Sign In',
                    style: AppTypography.button(color: AppColors.cream),
                  ),
                ),
                const SizedBox(height: 20),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.white.withOpacity(0.15)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'or',
                        style: AppTypography.bodyS(
                          color: AppColors.warmGray,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.white.withOpacity(0.15)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Guest mode
                Center(
                  child: _guestLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppColors.warmGray),
                          strokeWidth: 2,
                        )
                      : TextButton(
                          onPressed: _continueAsGuest,
                          child: Text(
                            'Skip for now — Guest mode',
                            style: AppTypography.bodyS(
                              color: AppColors.warmGray,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
