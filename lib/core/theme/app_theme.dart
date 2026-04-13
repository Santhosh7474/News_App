import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  // ── Dark Theme ──────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.accent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        surface: AppColors.surfaceDark,
        onPrimary: AppColors.backgroundDark,
        onSurface: AppColors.textPrimaryDark,
      ),
      textTheme: _buildTextTheme(
        primary: AppColors.textPrimaryDark,
        secondary: AppColors.textSecondaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
      ),
      cardColor: AppColors.surfaceDark,
      dividerColor: Colors.white12,
    );
  }

  // ── Light Theme ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.accentLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentLight,
        surface: AppColors.surfaceLight,
        onPrimary: AppColors.backgroundLight,
        onSurface: AppColors.textPrimaryLight,
      ),
      textTheme: _buildTextTheme(
        primary: AppColors.textPrimaryLight,
        secondary: AppColors.textSecondaryLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
      ),
      cardColor: AppColors.surfaceLight,
      dividerColor: Colors.black12,
    );
  }

  // ── Shared Text Theme ────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme({
    required Color primary,
    required Color secondary,
  }) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        color: primary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        color: primary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.inter(
        color: primary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.inter(
        color: primary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        color: primary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.inter(
        color: secondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.inter(
        color: secondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
