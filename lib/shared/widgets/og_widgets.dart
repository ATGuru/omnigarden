// lib/shared/widgets/og_widgets.dart
// OmniGarden shared widget library

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';

// ── SkeletonBox ───────────────────────────────────────────
/// Shimmer placeholder for any loading state
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = AppTheme.radiusSM,
  });
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A28) : const Color(0xFFE8E4DD),
      highlightColor: isDark ? const Color(0xFF3A3A36) : const Color(0xFFF5F2EC),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ── OGErrorState ─────────────────────────────────────────
/// Consistent error widget for async data failures
class OGErrorState extends StatelessWidget {
  const OGErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🥀', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Something went sideways',
              style: AppTypography.displayM(color: AppColors.cream),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.bodyS(color: AppColors.warmGray),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Try Again',
                  style: AppTypography.labelM(color: AppColors.leaf),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── ZoneBadge ────────────────────────────────────────────
/// Pill showing USDA zone, e.g. "ZONE 6A"
class ZoneBadge extends StatelessWidget {
  const ZoneBadge({super.key, required this.zone});
  final String zone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        zone.toUpperCase(),
        style: AppTypography.monoM(color: AppColors.sprout),
      ),
    );
  }
}

// ── FrostChip ─────────────────────────────────────────────
/// Shows last/first frost date with frost-blue color
class FrostChip extends StatelessWidget {
  const FrostChip({
    super.key,
    required this.label,
    required this.date,
    this.daysAway,
  });
  final String label;
  final String date;
  final int? daysAway;

  Color get _urgencyColor {
    if (daysAway == null) return AppColors.frost;
    if (daysAway! <= 14) return AppColors.terracotta;
    if (daysAway! <= 30) return const Color(0xFFD4B44A); // amber
    return AppColors.frost;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _urgencyColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: _urgencyColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('❄', style: TextStyle(fontSize: 11, color: _urgencyColor)),
          const SizedBox(width: 4),
          Text(
            '$label: $date',
            style: AppTypography.monoS(color: _urgencyColor),
          ),
          if (daysAway != null) ...[
            const SizedBox(width: 6),
            Text(
              '${daysAway}d',
              style: AppTypography.monoS(
                color: _urgencyColor.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── SectionLabel ─────────────────────────────────────────
/// Mono uppercase section header with horizontal rule
class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label, this.trailing});
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.sectionLabel(),
        ),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: AppColors.borderDark)),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}

// ── OGTag ────────────────────────────────────────────────
/// Rounded tag chip (green default, red for warnings)
class OGTag extends StatelessWidget {
  const OGTag({super.key, required this.label, this.isWarning = false});
  final String label;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? AppColors.rust : AppColors.moss;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(label, style: AppTypography.monoS(color: color)),
    );
  }
}

// ── OGButton ─────────────────────────────────────────────
/// Full-width primary button with loading state
class OGButton extends StatelessWidget {
  const OGButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Text(icon!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                ],
                Text(label, style: AppTypography.button()),
              ],
            ),
    );
  }
}

// ── OGTextField ───────────────────────────────────────────
class OGTextField extends StatelessWidget {
  const OGTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixEmoji,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.textInputAction,
  });
  final TextEditingController controller;
  final String hint;
  final String? prefixEmoji;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      textInputAction: textInputAction,
      style: AppTypography.bodyM(color: AppColors.cream),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixEmoji != null
            ? Padding(
                padding: const EdgeInsets.only(left: 14, right: 8),
                child: Text(
                  prefixEmoji!,
                  style: const TextStyle(fontSize: 18),
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
