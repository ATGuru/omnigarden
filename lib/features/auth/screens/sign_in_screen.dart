// lib/features/auth/screens/sign_in_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../providers/auth_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String? _error;
  
  // Remember me
  bool _rememberMe = true;
  
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
    _loadRememberedEmail();
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

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberedEmail = prefs.getString('remembered_email');
    if (rememberedEmail != null) {
      setState(() {
        _emailCtrl.text = rememberedEmail;
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _captchaCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    // SIGNIN ATTEMPT: captcha=$_captchaVerified email=${_emailCtrl.text.trim()}
    if (!_captchaVerified) {
      setState(() => _error = 'Please solve math problem');
      return;
    }
    
    setState(() => _error = null);
    // SIGNIN CALLING NOTIFIER
    try {
      await ref.read(authStateNotifierProvider.notifier).signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      // SIGNIN NOTIFIER RETURNED: isAuthed=${ref.read(authStateNotifierProvider).value?.isAuthenticated}
      
      // Handle remember me
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('remembered_email', _emailCtrl.text.trim());
      } else {
        await prefs.remove('remembered_email');
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      _generateCaptcha(); // Reset captcha on failed sign in
    }
  }

  void _showForgotPassword() {
    final emailCtrl = TextEditingController(text: _emailCtrl.text);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: Text('Reset Password', style: AppTypography.sectionTitle()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your email and we\'ll send a reset link.',
                style: AppTypography.bodyS()),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.cream),
              decoration: InputDecoration(
                hintText: 'Email address',
                hintStyle: TextStyle(color: AppColors.warmGray),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.warmGray)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Supabase.instance.client.auth.resetPasswordForEmail(
                  emailCtrl.text.trim(),
                );
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Reset link sent — check your email')),
                );
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: Text('Send Link', style: TextStyle(color: AppColors.terracotta)),
          ),
        ],
      ),
    );
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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text('Welcome\nback.', style: AppTypography.displayL()),
                const SizedBox(height: 8),
                Text(
                  'Your garden journal is waiting.',
                  style: AppTypography.bodyM(color: AppColors.warmGray),
                ),
                const SizedBox(height: 40),

                // Email
                OGTextField(
                  controller: _emailCtrl,
                  hint: 'Email address',
                  prefixEmoji: '✉',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),

                // Password
                OGTextField(
                  controller: _passwordCtrl,
                  hint: 'Password',
                  prefixEmoji: '🔒',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _signIn(),
                ),
                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPassword,
                    child: Text('Forgot Password?',
                        style: AppTypography.bodyS(color: AppColors.terracotta)),
                  ),
                ),
                const SizedBox(height: 12),

                // Remember me checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (v) => setState(() => _rememberMe = v ?? true),
                      activeColor: AppColors.terracotta,
                    ),
                    Text('Remember me', style: AppTypography.bodyS(color: AppColors.warmGray)),
                  ],
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
                  label: 'Sign In',
                  onPressed: _signIn,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => context.pushReplacement('/sign-up'),
                    child: Text(
                      'Need an account? Create one →',
                      style: AppTypography.bodyS(color: AppColors.leaf),
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
