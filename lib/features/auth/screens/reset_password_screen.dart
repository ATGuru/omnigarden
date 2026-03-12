import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;

  Future<void> _submit() async {
    if (_newCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newCtrl.text.trim()),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Password updated — please sign in')),
        );
        context.go('/sign-in');
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoal,
      appBar: AppBar(
        backgroundColor: AppColors.bark,
        title: Text('Reset Password', style: AppTypography.displayM(color: AppColors.cream)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _newCtrl,
              obscureText: true,
              style: const TextStyle(color: AppColors.cream),
              decoration: InputDecoration(
                hintText: 'New password',
                hintStyle: TextStyle(color: AppColors.warmGray),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmCtrl,
              obscureText: true,
              style: const TextStyle(color: AppColors.cream),
              decoration: InputDecoration(
                hintText: 'Confirm new password',
                hintStyle: TextStyle(color: AppColors.warmGray),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Update Password', style: AppTypography.labelM(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
