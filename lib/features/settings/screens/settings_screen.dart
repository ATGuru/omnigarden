import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/utils/notification_service.dart';
import '../utils/export_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final authAsync = ref.watch(authStateNotifierProvider);
    final location  = authAsync.value?.location ?? 'your area';
    final zip       = authAsync.value?.zip ?? '—';
    final email     = authAsync.value?.user?.email ?? 'Guest';

    return Scaffold(
      backgroundColor: isDark ? AppColors.soil : AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.bark,
        leading: BackButton(color: AppColors.cream),
        title: Text('Settings', style: AppTypography.displayM(color: AppColors.cream)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // ── Account ───────────────────────────────────────
          _SectionHeader(label: 'Account'),
          _ActionRow(emoji: '👤', label: 'Signed in as', value: email),
          const SizedBox(height: 8),
          _InfoRow(emoji: '📍', label: 'Location', value: location),
          const SizedBox(height: 8),
          _InfoRow(emoji: '🗺️', label: 'ZIP', value: zip),
          const SizedBox(height: 8),
          _ActionRow(
            emoji: '🗺️',
            label: 'Change ZIP / Zone',
            onTap: () => context.push('/zip-entry'),
          ),
          const SizedBox(height: 8),
          _ActionRow(
            emoji: '🔑',
            label: 'Change Password',
            onTap: () => _showChangePassword(context),
          ),
          const SizedBox(height: 8),
          _ActionRow(
            emoji: '📧',
            label: 'Change Email',
            onTap: () => _showChangeEmail(context),
          ),
          const SizedBox(height: 24),

          // ── Appearance ────────────────────────────────────
          _SectionHeader(label: 'Appearance'),
          _ToggleRow(
            emoji: isDark ? '☀️' : '🌑',
            label: 'Dark Mode',
            value: isDark,
            onChanged: (_) => ref.read(themeMode_Provider.notifier).toggle(),
          ),
          const SizedBox(height: 24),

          // ── Notifications ─────────────────────────────────
          _SectionHeader(label: 'Notifications'),
          const _NotificationSettings(),
          const SizedBox(height: 24),

          // ── Export ────────────────────────────────────────
          _SectionHeader(label: 'Export'),
          _ActionRow(
            emoji: '📦',
            label: 'Export All Data',
            onTap: () => ExportService().exportAllData(),
          ),
          const SizedBox(height: 8),
          _ActionRow(
            emoji: '🗺️',
            label: 'Export Garden Plans as PDF',
            onTap: () => context.push('/export-plans'),
          ),
          const SizedBox(height: 8),
          _ActionRow(
            emoji: '📅',
            label: 'Export Planting Calendar as PDF',
            onTap: () => context.push('/export-calendar'),
          ),
          const SizedBox(height: 24),

          // ── Contact ───────────────────────────────────────
          _SectionHeader(label: 'Contact'),
          _ActionRow(
            emoji: '✉️',
            label: 'Contact Developer',
            value: 'guru_morgan@atguru.xyz',
            onTap: () async {
              final uri = Uri(
                scheme: 'mailto',
                path: 'guru_morgan@atguru.xyz',
                queryParameters: {
                  'subject': 'OmniGarden App Feedback',
                },
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                await Clipboard.setData(const ClipboardData(text: 'guru_morgan@atguru.xyz'));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email copied to clipboard')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 8),
          _ActionRow(
            emoji: '🔒',
            label: 'Privacy Policy',
            onTap: () async {
              final uri = Uri.parse('https://atguru.github.io/omnigarden-privacy/');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: 24),

          // ── About ─────────────────────────────────────────
          _SectionHeader(label: 'About'),
          _ActionRow(
            emoji: '📖',
            label: 'How to Use OmniGarden',
            onTap: () => context.push('/guide'),
          ),
          const SizedBox(height: 8),
          _ActionRow(
            emoji: '📚',
            label: 'Sources & Credits',
            onTap: () => context.push('/sources'),
          ),
          const SizedBox(height: 8),
          _InfoRow(emoji: '🌿', label: 'App', value: 'OmniGarden'),
          const SizedBox(height: 8),
          _InfoRow(emoji: '📦', label: 'Version', value: '1.0.0 (Beta)'),
          const SizedBox(height: 8),
          _InfoRow(emoji: '🌍', label: 'Zone coverage', value: 'US Zones 4a–10b'),
          const SizedBox(height: 8),
          _InfoRow(emoji: '🪴', label: 'Plant database', value: '2,200+ varieties'),
          const SizedBox(height: 24),

          // ── Session ───────────────────────────────────────
          _SectionHeader(label: 'Session'),
          GestureDetector(
            onTap: () => _confirmSignOut(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.rust.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(color: AppColors.rust.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Text('🚪', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Text('Sign Out', style: AppTypography.labelM(color: AppColors.rust)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Danger Zone ───────────────────────────────────
          _SectionHeader(label: 'Danger Zone'),
          GestureDetector(
            onTap: () => _confirmDeleteAccount(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.rust.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(color: AppColors.rust.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Text('🗑️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Text('Delete Account', style: AppTypography.labelM(color: AppColors.rust)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: Text('Sign out?', style: AppTypography.sectionTitle()),
        content: Text(
          'Your gardens and data are saved in the cloud.',
          style: AppTypography.bodyS(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authStateNotifierProvider.notifier).signOut();
            },
            child: Text('Sign Out', style: TextStyle(color: AppColors.rust)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: Text('Delete Account?', style: AppTypography.sectionTitle()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('⚠️ This will permanently delete:', style: AppTypography.bodyM()),
            const SizedBox(height: 12),
            Text(
              '• All your gardens\n• All garden plants\n• All journal entries\n• Your profile data',
              style: AppTypography.bodyS(color: AppColors.warmGray),
            ),
            const SizedBox(height: 16),
            Text('This action cannot be undone.', style: AppTypography.bodyS(color: AppColors.rust)),
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
              await _deleteAccount(context, ref);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.rust)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authStateNotifierProvider.notifier).deleteAccount();
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.charcoal,
            title: Text('Data Removed', style: AppTypography.sectionTitle()),
            content: Text(
              'Your data has been removed.\n\nContact support to fully delete your authentication record.',
              style: AppTypography.bodyS(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/onboarding');
                },
                child: Text('OK', style: TextStyle(color: AppColors.leaf)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}

// ── Notification settings widget ──────────────────────────────
class _NotificationSettings extends ConsumerStatefulWidget {
  const _NotificationSettings();

  @override
  ConsumerState<_NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends ConsumerState<_NotificationSettings> {
  bool _indoorStart = true;
  bool _transplant  = true;
  bool _harvest     = true;
  bool _weekly      = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ToggleRow(
          emoji: '🌱',
          label: 'Indoor start reminders',
          value: _indoorStart,
          onChanged: (v) => setState(() => _indoorStart = v),
        ),
        const SizedBox(height: 8),
        _ToggleRow(
          emoji: '🌿',
          label: 'Transplant reminders',
          value: _transplant,
          onChanged: (v) => setState(() => _transplant = v),
        ),
        const SizedBox(height: 8),
        _ToggleRow(
          emoji: '🌾',
          label: 'Harvest reminders',
          value: _harvest,
          onChanged: (v) => setState(() => _harvest = v),
        ),
        const SizedBox(height: 8),
        _ToggleRow(
          emoji: '📅',
          label: 'Weekly garden check',
          value: _weekly,
          onChanged: (v) => setState(() => _weekly = v),
        ),
      ],
    );
  }
}

// ── Settings Methods ────────────────────────────────────────

void _showChangePassword(BuildContext context) {
  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.charcoal,
      title: Text('Change Password', style: AppTypography.sectionTitle()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: newCtrl,
            obscureText: true,
            style: const TextStyle(color: AppColors.cream),
            decoration: InputDecoration(hintText: 'New password',
                hintStyle: TextStyle(color: AppColors.warmGray)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: confirmCtrl,
            obscureText: true,
            style: const TextStyle(color: AppColors.cream),
            decoration: InputDecoration(hintText: 'Confirm new password',
                hintStyle: TextStyle(color: AppColors.warmGray)),
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
            if (newCtrl.text != confirmCtrl.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Passwords do not match')),
              );
              return;
            }
            Navigator.pop(context);
            try {
              await Supabase.instance.client.auth.updateUser(
                UserAttributes(password: newCtrl.text.trim()),
              );
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Password updated')),
              );
            } catch (e) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          child: Text('Update', style: TextStyle(color: AppColors.terracotta)),
        ),
      ],
    ),
  );
}

void _showChangeEmail(BuildContext context) {
  final emailCtrl = TextEditingController();
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.charcoal,
      title: Text('Change Email', style: AppTypography.sectionTitle()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Enter your new email address. You\'ll need to verify it.',
              style: AppTypography.bodyS()),
          const SizedBox(height: 16),
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppColors.cream),
            decoration: InputDecoration(hintText: 'New email address',
                hintStyle: TextStyle(color: AppColors.warmGray)),
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
              await Supabase.instance.client.auth.updateUser(
                UserAttributes(email: emailCtrl.text.trim()),
              );
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Verification sent to new email')),
              );
            } catch (e) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          child: Text('Update', style: TextStyle(color: AppColors.terracotta)),
        ),
      ],
    ),
  );
}

// ── Reusable row widgets ───────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.monoS(color: AppColors.warmGray)
            .copyWith(fontSize: 10, letterSpacing: 1.2),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.emoji,
    required this.label,
    required this.value,
  });
  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(label, style: AppTypography.bodyS(color: AppColors.warmGray)),
          const Spacer(),
          Text(
            value,
            style: AppTypography.labelM(
              color: isDark ? AppColors.cream : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.emoji,
    required this.label,
    this.onTap,
    this.value,
  });
  final String emoji;
  final String label;
  final VoidCallback? onTap;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Text(label,
                style: AppTypography.labelM(
                  color: isDark ? AppColors.cream : AppColors.ink,
                )),
            const Spacer(),
            if (value != null)
              Text(value!,
                  style: AppTypography.bodyS(color: AppColors.warmGray)),
            const Icon(Icons.chevron_right, color: AppColors.warmGray, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.emoji,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String emoji;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: AppTypography.labelM(
                  color: isDark ? AppColors.cream : AppColors.ink,
                )),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.terracotta,
          ),
        ],
      ),
    );
  }
}
