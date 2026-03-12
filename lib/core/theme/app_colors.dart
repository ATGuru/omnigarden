// lib/core/theme/app_colors.dart
// Direct port of CSS :root design tokens from OmniGarden HTML prototype

import 'package:flutter/material.dart';

/// Every color in OmniGarden maps 1:1 to the CSS :root variables.
abstract final class AppColors {
  // ── Earthy Browns ──────────────────────────────────────
  static const soil        = Color(0xFF2C1A0E); // --soil  · darkest bg
  static const bark        = Color(0xFF4A2E18); // --bark  · Chelle header bg
  static const clay        = Color(0xFF8B5E3C); // --clay  · mid-tone brown
  static const terracotta  = Color(0xFFC4622D); // --terracotta · PRIMARY CTA
  static const rust        = Color(0xFFA0421D); // --rust  · destructive / Phase 4

  // ── Greens ─────────────────────────────────────────────
  static const sage        = Color(0xFF6B7C5E); // --sage
  static const moss        = Color(0xFF4A5E3A); // --moss  · nav active / hero bg
  static const fern        = Color(0xFF3D5229); // --fern  · onboarding bg
  static const leaf        = Color(0xFF7A9E4E); // --leaf  · secondary action
  static const sprout      = Color(0xFFA8C56E); // --sprout· accent / highlights

  // ── Light / Neutral ────────────────────────────────────
  static const mist        = Color(0xFFF0EDE6); // --mist
  static const parchment   = Color(0xFFFAF7F2); // --parchment · light screen bg
  static const cream       = Color(0xFFFFF9F0); // --cream · primary text on dark
  static const charcoal    = Color(0xFF1C1C1A); // --charcoal
  static const ink         = Color(0xFF2E2E2A); // --ink  · primary text on light
  static const warmGray    = Color(0xFF8A8580); // --warm-gray · secondary text
  static const frost       = Color(0xFFB8D4E8); // --frost · frost date chip

  // ── Surface overlays (not in CSS :root, derived) ───────
  static const surfaceLight  = Color(0xFFFFFFFF);
  static const surfaceDark   = Color(0x0AFFFFFF); // 4% white
  static const borderLight   = Color(0x14000000); // 8% black
  static const borderDark    = Color(0x17FFFFFF); // ~9% white
  static const overlayDark   = Color(0x33000000); // 20% black

  // ── Semantic aliases ───────────────────────────────────
  static const primary    = terracotta;
  static const success    = leaf;
  static const info       = frost;
  static const error      = rust;
}
