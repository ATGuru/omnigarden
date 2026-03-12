import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/services/splash_service.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.1, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    
    // Auto-navigate after 3 seconds
    _navigateToHome();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _navigateToHome() async {
    if (_hasNavigated) return; // Prevent multiple calls
    await Future.delayed(const Duration(seconds: 3));
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authStateNotifierProvider);
    final zone = authAsync.value?.zone ?? 'Zone 6a';
    final stageImage = SplashService.getStageImage(DateTime.now(), zone);
    
    return Scaffold(
      backgroundColor: AppColors.soil,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              stageImage,
              fit: BoxFit.cover,
            ),
          ),
          
          // Dark overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // OmniGarden wordmark with fade-in animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const _WordmarkWidget(),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Tagline with fade-in animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'From seed to harvest, we grow together.',
                        style: AppTypography.monoS(
                          color: Colors.white.withOpacity(0.7),
                        ).copyWith(
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Wordmark widget
class _WordmarkWidget extends StatelessWidget {
  const _WordmarkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'OmniGarden',
      style: AppTypography.displayM().copyWith(
        color: Colors.white.withOpacity(0.9),
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        fontSize: 52,
      ),
    );
  }
}
