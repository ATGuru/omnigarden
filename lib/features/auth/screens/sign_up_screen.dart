// lib/features/auth/screens/sign_up_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  String? _error;
  
  // Math captcha
  int _captchaA = 0;
  int _captchaB = 0;
  String _captchaAnswer = '';
  bool _captchaVerified = false;
  final _captchaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  void _generateCaptcha() {
    final random = Random(DateTime.now().millisecondsSinceEpoch);
    setState(() {
      _captchaA = random.nextInt(9) + 1;
      _captchaB = random.nextInt(9) + 1;
      _captchaVerified = false;
      _captchaCtrl.clear();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _captchaCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_captchaVerified) {
      setState(() => _error = 'Please solve the math problem');
      return;
    }
    
    setState(() => _error = null);
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = "Passwords don't match.");
      return;
    }
    if (_passwordCtrl.text.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }
    try {
      await ref.read(authStateNotifierProvider.notifier).signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      _generateCaptcha(); // Reset captcha on failed sign up
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.soil,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.cream),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text('Create your\ngarden.', style: AppTypography.displayL()),
              const SizedBox(height: 8),
              Text(
                'Free to start. No credit card.',
                style: AppTypography.bodyM(color: AppColors.warmGray),
              ),
              const SizedBox(height: 40),

              OGTextField(
                controller: _emailCtrl,
                hint: 'Email address',
                prefixEmoji: '✉',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              OGTextField(
                controller: _passwordCtrl,
                hint: 'Password (8+ characters)',
                prefixEmoji: '🔒',
                obscureText: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              OGTextField(
                controller: _confirmCtrl,
                hint: 'Confirm password',
                prefixEmoji: '🔒',
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _signUp(),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.rust.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.rust.withOpacity(0.4)),
                  ),
                  child: Text(
                    _error!,
                    style: AppTypography.bodyS(color: AppColors.rust),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Math captcha
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: Border.all(color: _captchaVerified ? AppColors.leaf : AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    Text('$_captchaA + $_captchaB = ?',
                        style: AppTypography.labelM(color: AppColors.cream)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _captchaCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final answer = int.tryParse(v);
                          setState(() => _captchaVerified = answer == _captchaA + _captchaB);
                        },
                        decoration: InputDecoration(hintText: 'Answer'),
                      ),
                    ),
                    if (_captchaVerified)
                      const Icon(Icons.check_circle, color: AppColors.leaf)
                    else
                      GestureDetector(
                        onTap: _generateCaptcha,
                        child: const Icon(Icons.refresh, color: AppColors.warmGray),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              OGButton(
                label: 'Create Account →',
                onPressed: _signUp,
                isLoading: isLoading,
              ),
              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => context.pushReplacement('/sign-in'),
                  child: Text(
                    'Already have an account? Sign in',
                    style: AppTypography.bodyS(color: AppColors.leaf),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
