// lib/core/theme/app_typography.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  // ── Display — Playfair Display (serif, editorial) ───────────────────────────
  // Used for: screen headlines, plant names, garden names, section titles

  static TextStyle displayXL({Color? color}) => GoogleFonts.playfairDisplay(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    color: color ?? AppColors.cream,
    letterSpacing: -0.5,
    height: 1.0,
  );

  static TextStyle displayL({Color? color}) => GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    color: color ?? AppColors.cream,
    letterSpacing: -0.3,
    height: 1.1,
  );

  static TextStyle displayM({Color? color}) => GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.cream,
    height: 1.2,
  );

  static TextStyle plantName({Color? color}) => GoogleFonts.playfairDisplay(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    color: color ?? AppColors.ink,
    letterSpacing: -0.2,
  );

  static TextStyle sectionTitle({Color? color}) => GoogleFonts.playfairDisplay(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
    color: color ?? AppColors.ink,
  );

  // ── Body — DM Sans (clean, outdoor-readable) ────────────────────────────────
  // Used for: body copy, descriptions, quick cards, list items

  static TextStyle bodyL({Color? color}) => GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.cream,
    height: 1.6,
  );

  static TextStyle bodyM({Color? color}) => GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.cream,
    height: 1.5,
  );

  static TextStyle bodyS({Color? color}) => GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.warmGray,
    height: 1.4,
  );

  static TextStyle labelL({Color? color}) => GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.cream,
  );

  static TextStyle labelM({Color? color}) => GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.cream,
  );

  static TextStyle labelS({Color? color}) => GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.ink,
  );

  static TextStyle button({Color? color}) => GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: color ?? Colors.white,
    letterSpacing: 0.3,
  );

  // ── Mono — DM Mono (zones, dates, tags, badges) ─────────────────────────────

  static TextStyle monoL({Color? color}) => GoogleFonts.dmMono(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: color ?? AppColors.terracotta,
    letterSpacing: 0.08,
  );

  static TextStyle monoM({Color? color}) => GoogleFonts.dmMono(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: color ?? AppColors.terracotta,
    letterSpacing: 0.10,
  );

  static TextStyle monoS({Color? color}) => GoogleFonts.dmMono(
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.warmGray,
    letterSpacing: 0.12,
  );

  static TextStyle sectionLabel({Color? color}) => GoogleFonts.dmMono(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    color: color ?? AppColors.terracotta,
    letterSpacing: 0.15,
  );
}
