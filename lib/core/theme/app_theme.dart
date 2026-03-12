// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  // ── Shared radius constants ─────────────────────────────
  static const radiusSM = 8.0;
  static const radiusMD = 14.0;
  static const radiusLG = 20.0;
  static const radiusXL = 28.0;
  static const radiusFull = 100.0;

  // ── Dark Theme (primary — "5am gardener" mode) ──────────
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.soil,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.terracotta,
        secondary: AppColors.leaf,
        tertiary: AppColors.sprout,
        surface: AppColors.charcoal,
        error: AppColors.rust,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.cream,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.cream,
        displayColor: AppColors.cream,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        foregroundColor: AppColors.cream,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          elevation: 0,
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cream,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          side: const BorderSide(color: AppColors.borderDark),
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: AppColors.terracotta, width: 1.5),
        ),
        hintStyle: GoogleFonts.dmSans(
          color: AppColors.warmGray,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.charcoal,
        selectedItemColor: AppColors.leaf,
        unselectedItemColor: AppColors.warmGray,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDark,
        labelStyle: GoogleFonts.dmMono(
          fontSize: 10,
          color: AppColors.warmGray,
        ),
        side: const BorderSide(color: AppColors.borderDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  // ── Light Theme (content screens: Plant Detail, Journal) ─
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.parchment,
      colorScheme: const ColorScheme.light(
        primary: AppColors.terracotta,
        secondary: AppColors.leaf,
        tertiary: AppColors.sprout,
        surface: Colors.white,
        error: AppColors.rust,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.ink,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        foregroundColor: AppColors.ink,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: AppColors.terracotta, width: 1.5),
        ),
        hintStyle: GoogleFonts.dmSans(
          color: AppColors.warmGray,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.moss,
        unselectedItemColor: AppColors.warmGray,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
